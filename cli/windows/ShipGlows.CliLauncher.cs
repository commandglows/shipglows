using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Text;

internal static class ShipGlowsCliLauncher
{
    private const string ManagedPowerShellVersion = "7.6.5";

    private static readonly IDictionary<char, string[]> MenuActions = new Dictionary<char, string[]>
    {
        { 'c', new[] { "clone" } },
        { 'g', new[] { "register" } },
        { 's', new[] { "e" } },
        { 't', new[] { "m", "t" } },
        { 'r', new[] { "m", "r" } },
        { 'l', new[] { "m", "l" } },
        { 'o', new[] { "open" } },
        { 'k', new[] { "m", "o" } },
        { 'd', new[] { "m", "w" } },
        { 'n', new[] { "m", "n" } },
        { 'a', new[] { "a" } },
        { 'f', new[] { "refresh" } },
        { 'p', new[] { "tools", "update" } },
        { 'u', new[] { "u" } }
    };

    private static readonly string[] MenuItems =
    {
        "C  Clone a repository",
        "G  Register a local project",
        "S  Start a project",
        "T  Stop a project",
        "R  Restart a project",
        "L  View logs",
        "O  Open / load project",
        "K  Stop all projects",
        "D  Unregister a project",
        "N  Navigate to a project",
        "A  Authentication",
        "F  Refresh",
        "P  Update developer tools",
        "U  Update ShipGlows",
        "Q  Quit ShipGlows"
    };

    private static int Main(string[] args)
    {
        try
        {
            Console.OutputEncoding = new UTF8Encoding(false);
            if (args.Length > 0)
            {
                return RunPowerShell(args);
            }

            return RunMenu();
        }
        catch (Exception error)
        {
            Console.Error.WriteLine("shipglows: " + error.Message);
            return 2;
        }
    }

    private static int RunMenu()
    {
        int selectedIndex = 0;
        while (true)
        {
            char choice = ReadMenuChoice(ref selectedIndex);
            if (choice == 'q')
            {
                return 0;
            }

            string[] action;
            if (!MenuActions.TryGetValue(choice, out action))
            {
                Console.Error.WriteLine("Unknown choice: " + choice);
                continue;
            }

            ClearRootMenuForAction();
            int exitCode = RunPowerShell(action);
            if (exitCode != 0)
            {
                Console.Error.WriteLine("ShipGlows command exited with code " + exitCode + ".");
            }
        }
    }

    private static void ClearRootMenuForAction()
    {
        if (!Console.IsOutputRedirected)
        {
            Console.Clear();
        }
    }

    private static char ReadMenuChoice(ref int selectedIndex)
    {
        if (Console.IsInputRedirected)
        {
            WritePlainMenu();
            string line = Console.ReadLine();
            if (line == null)
            {
                return 'q';
            }

            line = line.Trim();
            return line.Length == 0 ? '\0' : char.ToLowerInvariant(line[0]);
        }

        int menuTop;
        try
        {
            menuTop = Console.CursorTop;
        }
        catch (IOException)
        {
            WritePlainMenu();
            return ReadImmediateShortcut();
        }

        bool? originalCursorVisible = TrySetCursorVisible(false);
        try
        {
            while (true)
            {
                if (!RenderInteractiveMenu(menuTop, selectedIndex))
                {
                    WritePlainMenu();
                    return ReadImmediateShortcut();
                }

                ConsoleKeyInfo key = Console.ReadKey(true);
                char shortcut = char.ToLowerInvariant(key.KeyChar);

                if (MenuActions.ContainsKey(shortcut) || shortcut == 'q')
                {
                    MoveBelowMenu(menuTop);
                    return shortcut;
                }

                switch (key.Key)
                {
                    case ConsoleKey.UpArrow:
                        selectedIndex = (selectedIndex + MenuItems.Length - 1) % MenuItems.Length;
                        break;
                    case ConsoleKey.DownArrow:
                        selectedIndex = (selectedIndex + 1) % MenuItems.Length;
                        break;
                    case ConsoleKey.Home:
                        selectedIndex = 0;
                        break;
                    case ConsoleKey.End:
                        selectedIndex = MenuItems.Length - 1;
                        break;
                    case ConsoleKey.Enter:
                        MoveBelowMenu(menuTop);
                        return GetShortcut(MenuItems[selectedIndex]);
                    case ConsoleKey.Escape:
                        MoveBelowMenu(menuTop);
                        return 'q';
                }
            }
        }
        finally
        {
            Console.ResetColor();
            if (originalCursorVisible.HasValue)
            {
                TrySetCursorVisible(originalCursorVisible.Value);
            }
        }
    }

    private static bool RenderInteractiveMenu(int menuTop, int selectedIndex)
    {
        try
        {
            Console.SetCursorPosition(0, menuTop);
        }
        catch (IOException)
        {
            return false;
        }
        catch (ArgumentOutOfRangeException)
        {
            return false;
        }

        int itemWidth = GetMenuItemWidth();
        WriteMenuLine("What do you want to do?", ConsoleColor.White, ConsoleColor.Black, itemWidth);

        for (int index = 0; index < MenuItems.Length; index++)
        {
            bool selected = index == selectedIndex;
            string prefix = selected ? "> " : "  ";
            WriteMenuLine(
                prefix + MenuItems[index],
                selected ? ConsoleColor.Black : ConsoleColor.Gray,
                selected ? ConsoleColor.Magenta : ConsoleColor.Black,
                itemWidth);
        }

        WriteMenuLine("", ConsoleColor.Gray, ConsoleColor.Black, itemWidth);
        string help = "↑↓ move  Enter select  key runs  Esc quit";
        int helpWidth = Math.Min(help.Length, GetSafeWindowWidth());
        WriteMenuLine(help, ConsoleColor.DarkGray, ConsoleColor.Black, helpWidth);
        return true;
    }

    private static int GetMenuItemWidth()
    {
        int width = 0;
        foreach (string item in MenuItems)
        {
            width = Math.Max(width, item.Length + 2);
        }

        return Math.Min(width, GetSafeWindowWidth());
    }

    private static int GetSafeWindowWidth()
    {
        try
        {
            return Math.Max(1, Console.WindowWidth - 1);
        }
        catch (IOException)
        {
            return 80;
        }
    }

    private static void WriteMenuLine(string value, ConsoleColor foreground, ConsoleColor background, int width)
    {
        string visible = value.Length > width ? value.Substring(0, width) : value;
        Console.ForegroundColor = foreground;
        Console.BackgroundColor = background;
        Console.Write(visible.PadRight(width));
        Console.ResetColor();
        Console.WriteLine();
    }

    private static void MoveBelowMenu(int menuTop)
    {
        Console.ResetColor();
        try
        {
            Console.SetCursorPosition(0, menuTop + MenuItems.Length + 3);
        }
        catch (IOException)
        {
            Console.WriteLine();
        }
        catch (ArgumentOutOfRangeException)
        {
            Console.WriteLine();
        }
    }

    private static bool? TrySetCursorVisible(bool visible)
    {
        try
        {
            bool previous = Console.CursorVisible;
            Console.CursorVisible = visible;
            return previous;
        }
        catch (IOException)
        {
            return null;
        }
    }

    private static char ReadImmediateShortcut()
    {
        ConsoleKeyInfo key = Console.ReadKey(true);
        return key.Key == ConsoleKey.Escape ? 'q' : char.ToLowerInvariant(key.KeyChar);
    }

    private static char GetShortcut(string menuItem)
    {
        return char.ToLowerInvariant(menuItem[0]);
    }

    private static void WritePlainMenu()
    {
        Console.WriteLine("ShipGlows Windows");
        Console.WriteLine("What do you want to do?");
        foreach (string item in MenuItems)
        {
            Console.WriteLine(item);
        }
    }

    private static int RunPowerShell(string[] commandArguments)
    {
        string baseDirectory = AppDomain.CurrentDomain.BaseDirectory;
        string script = Path.GetFullPath(Path.Combine(baseDirectory, "shipglows-devserver.ps1"));
        if (!File.Exists(script))
        {
            throw new FileNotFoundException("The ShipGlows DevServer entrypoint is missing.", script);
        }

        string userProfile = Environment.GetFolderPath(Environment.SpecialFolder.UserProfile);
        string managedPowerShell = Path.GetFullPath(Path.Combine(
            userProfile,
            ".shipglows",
            "toolchains",
            "powershell",
            ManagedPowerShellVersion,
            "win-x64",
            "pwsh.exe"));

        ProcessStartInfo startInfo;
        if (File.Exists(managedPowerShell))
        {
            List<string> arguments = new List<string> { "-NoLogo", "-NoProfile", "-File", script };
            arguments.AddRange(commandArguments);
            startInfo = CreateStartInfo(managedPowerShell, arguments);
            startInfo.EnvironmentVariables["SHIPGLOWS_MANAGED_PWSH"] = managedPowerShell;
        }
        else
        {
            string bootstrap = Path.GetFullPath(Path.Combine(baseDirectory, "ShipGlows.PowerShellBootstrap.ps1"));
            if (!File.Exists(bootstrap))
            {
                throw new FileNotFoundException("The ShipGlows PowerShell bootstrap is missing.", bootstrap);
            }

            List<string> arguments = new List<string>
            {
                "-NoLogo", "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", bootstrap
            };
            arguments.AddRange(commandArguments);
            startInfo = CreateStartInfo("powershell.exe", arguments);
        }

        using (Process child = Process.Start(startInfo))
        {
            if (child == null)
            {
                throw new InvalidOperationException("The ShipGlows command process could not be created.");
            }

            child.WaitForExit();
            return child.ExitCode;
        }
    }

    private static ProcessStartInfo CreateStartInfo(string executable, IEnumerable<string> arguments)
    {
        ProcessStartInfo startInfo = new ProcessStartInfo();
        startInfo.FileName = executable;
        startInfo.Arguments = JoinArguments(arguments);
        startInfo.UseShellExecute = false;
        startInfo.CreateNoWindow = false;
        return startInfo;
    }

    private static string JoinArguments(IEnumerable<string> arguments)
    {
        StringBuilder commandLine = new StringBuilder();
        foreach (string argument in arguments)
        {
            if (commandLine.Length > 0)
            {
                commandLine.Append(' ');
            }

            AppendQuotedArgument(commandLine, argument ?? string.Empty);
        }

        return commandLine.ToString();
    }

    private static void AppendQuotedArgument(StringBuilder commandLine, string argument)
    {
        if (argument.Length > 0 && argument.IndexOfAny(new[] { ' ', '\t', '\n', '\v', '"' }) < 0)
        {
            commandLine.Append(argument);
            return;
        }

        commandLine.Append('"');
        int backslashes = 0;
        foreach (char character in argument)
        {
            if (character == '\\')
            {
                backslashes++;
                continue;
            }

            if (character == '"')
            {
                commandLine.Append('\\', backslashes * 2 + 1);
                commandLine.Append('"');
                backslashes = 0;
                continue;
            }

            commandLine.Append('\\', backslashes);
            backslashes = 0;
            commandLine.Append(character);
        }

        commandLine.Append('\\', backslashes * 2);
        commandLine.Append('"');
    }
}

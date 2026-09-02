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
        { '1', new[] { "clone" } },
        { '2', new[] { "register" } },
        { '3', new[] { "e" } },
        { '4', new[] { "m", "t" } },
        { '5', new[] { "m", "r" } },
        { '6', new[] { "m", "l" } },
        { '7', new[] { "open" } },
        { '8', new[] { "m", "o" } },
        { '9', new[] { "m", "w" } },
        { 'n', new[] { "m", "n" } },
        { 'a', new[] { "a" } },
        { 'r', new[] { "refresh" } },
        { 't', new[] { "tools", "update" } },
        { 'u', new[] { "u" } }
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
        while (true)
        {
            WriteMenu();
            char choice = ReadChoice();
            if (choice == '0' || choice == 'x')
            {
                return 0;
            }

            string[] action;
            if (!MenuActions.TryGetValue(choice, out action))
            {
                Console.Error.WriteLine("Unknown choice: " + choice);
                continue;
            }

            int exitCode = RunPowerShell(action);
            if (exitCode != 0)
            {
                Console.Error.WriteLine("ShipGlows command exited with code " + exitCode + ".");
            }
        }
    }

    private static void WriteMenu()
    {
        Console.WriteLine("ShipGlows Windows");
        Console.WriteLine("1) Clone  2) Register  3) Start  4) Stop  5) Restart");
        Console.WriteLine("6) Logs   7) Open      8) Stop all  9) Unregister");
        Console.WriteLine("n) Navigate  a) Authentication  r) Refresh  t) Update tools  u) Update ShipGlows  0) Quit");
        Console.Write("Choice: ");
    }

    private static char ReadChoice()
    {
        if (Console.IsInputRedirected)
        {
            string line = Console.ReadLine();
            if (line == null)
            {
                return '0';
            }

            line = line.Trim();
            return line.Length == 0 ? '\0' : char.ToLowerInvariant(line[0]);
        }

        ConsoleKeyInfo key = Console.ReadKey(true);
        Console.WriteLine(key.KeyChar);
        return char.ToLowerInvariant(key.KeyChar);
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

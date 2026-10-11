import type { Plugin } from "@kilocode/plugin"
import { tool } from "@kilocode/plugin/tool"
import { join } from "node:path"

const server: Plugin = async () => ({
  tool: {
    shipglows_capture_conversation: tool({
      description: "Capture this exact KiloCode conversation verbatim into its Git project's ShipGlows conversation directory.",
      args: {},
      async execute(_args, context) {
        const root = process.env.SHIPGLOWS_ROOT
        if (!root) throw new Error("SHIPGLOWS_ROOT is not configured")
        const script = join(root, "skills", "800-tmux-capture-conversation", "scripts", "capture_kilo_conversation.py")
        const python = process.env.SHIPGLOWS_PYTHON || (process.platform === "win32" ? "python" : "python3")
        const child = Bun.spawn(
          [python, script, "--session-id", context.sessionID, "--directory", context.directory, "--worktree", context.worktree],
          { stdout: "pipe", stderr: "pipe", env: process.env },
        )
        const [stdout, stderr, exitCode] = await Promise.all([
          new Response(child.stdout).text(),
          new Response(child.stderr).text(),
          child.exited,
        ])
        if (exitCode !== 0) throw new Error(stderr.trim() || "ShipGlows conversation capture failed")
        return stdout.trim()
      },
    }),
  },
})

export default { id: "shipglows-conversation-capture", server }

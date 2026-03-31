import Foundation
import MCP

struct ProjectDispatcher {
    static let tool = Tool(
        name: "logic_project",
        description: """
            Project lifecycle in Logic Pro. \
            Commands: new, open, save, save_as, close, bounce, launch, quit. \
            Params by command: \
            open -> { path: String }; \
            save_as -> { path: String }; \
            bounce -> {} (opens bounce dialog); \
            launch/quit -> {} (app lifecycle); \
            Others -> {}
            """,
        inputSchema: .object([
            "type": .string("object"),
            "properties": .object([
                "command": .object([
                    "type": .string("string"),
                    "description": .string("Project command to execute"),
                ]),
                "params": .object([
                    "type": .string("object"),
                    "description": .string("Command-specific parameters"),
                ]),
            ]),
            "required": .array([.string("command")]),
        ])
    )

    static func handle(
        command: String,
        params: [String: Value],
        router: ChannelRouter,
        cache: StateCache
    ) async -> CallTool.Result {
        switch command {
        case "new":
            let result = await router.route(operation: "project.new")
            return CallTool.Result(content: [.text(result.message)], isError: !result.isSuccess)

        case "open":
            let path = params["path"]?.stringValue ?? ""
            guard !path.isEmpty else {
                return CallTool.Result(content: [.text("open requires 'path' param")], isError: true)
            }
            let result = await router.route(
                operation: "project.open",
                params: ["path": path]
            )
            return CallTool.Result(content: [.text(result.message)], isError: !result.isSuccess)

        case "save":
            let result = await router.route(operation: "project.save")
            return CallTool.Result(content: [.text(result.message)], isError: !result.isSuccess)

        case "save_as":
            let path = params["path"]?.stringValue ?? ""
            guard !path.isEmpty else {
                return CallTool.Result(content: [.text("save_as requires 'path' param")], isError: true)
            }
            let result = await router.route(
                operation: "project.save_as",
                params: ["path": path]
            )
            return CallTool.Result(content: [.text(result.message)], isError: !result.isSuccess)

        case "close":
            let result = await router.route(operation: "project.close")
            return CallTool.Result(content: [.text(result.message)], isError: !result.isSuccess)

        case "bounce":
            let result = await router.route(operation: "project.bounce")
            return CallTool.Result(content: [.text(result.message)], isError: !result.isSuccess)

        case "launch":
            if ProcessUtils.isLogicProRunning {
                let name = ProcessUtils.activeAppName
                return CallTool.Result(content: [.text("\(name) is already running")], isError: false)
            }
            // Default to regular Logic Pro for launch when nothing is running
            let launchName = AppVariant.defaultVariant.appName
            let launchScript = "tell application \"\(launchName)\" to activate"
            let launchProcess = Process()
            launchProcess.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
            launchProcess.arguments = ["-e", launchScript]
            do {
                try launchProcess.run()
                launchProcess.waitUntilExit()
                return CallTool.Result(content: [.text("\(launchName) launched")], isError: false)
            } catch {
                return CallTool.Result(content: [.text("Failed to launch \(launchName): \(error)")], isError: true)
            }

        case "quit":
            if !ProcessUtils.isLogicProRunning {
                return CallTool.Result(content: [.text("No Logic Pro variant is running")], isError: false)
            }
            let quitName = ProcessUtils.activeAppName
            let quitScript = "tell application \"\(quitName)\" to quit"
            let quitProcess = Process()
            quitProcess.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
            quitProcess.arguments = ["-e", quitScript]
            do {
                try quitProcess.run()
                quitProcess.waitUntilExit()
                return CallTool.Result(content: [.text("\(quitName) quit")], isError: false)
            } catch {
                return CallTool.Result(content: [.text("Failed to quit \(quitName): \(error)")], isError: true)
            }

        default:
            return CallTool.Result(
                content: [.text("Unknown project command: \(command). Available: new, open, save, save_as, close, bounce, launch, quit")],
                isError: true
            )
        }
    }
}

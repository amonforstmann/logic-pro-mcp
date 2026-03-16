import Foundation
import AppKit

/// Utilities for finding and interacting with the Logic Pro process.
enum ProcessUtils {
    /// Returns the active Logic Pro variant and its PID, or nil if neither is running.
    static func activeApp() -> (variant: AppVariant, pid: pid_t)? {
        for variant in AppVariant.allCases {
            let apps = NSRunningApplication.runningApplications(
                withBundleIdentifier: variant.bundleID
            )
            if let app = apps.first {
                return (variant, app.processIdentifier)
            }
        }
        return nil
    }

    /// Returns the PID of Logic Pro (any variant) if running, nil otherwise.
    static func logicProPID() -> pid_t? {
        activeApp()?.pid
    }

    /// Whether any Logic Pro variant is currently running.
    static var isLogicProRunning: Bool {
        activeApp() != nil
    }

    /// The app name of the currently running variant, or the default if none is running.
    static var activeAppName: String {
        activeApp()?.variant.appName ?? AppVariant.defaultVariant.appName
    }

    /// The name of the parent application that spawned this process (e.g. "Claude" or "Terminal").
    /// Used in error messages to tell the user which app needs Accessibility permission.
    static var parentAppName: String? {
        let ppid = getppid()
        guard let parent = NSRunningApplication(processIdentifier: ppid) else { return nil }
        return parent.localizedName
    }

    /// Bring Logic Pro to front (used sparingly — most operations don't need focus).
    static func activateLogicPro() -> Bool {
        guard let (_, pid) = activeApp() else { return false }
        guard let app = NSRunningApplication(processIdentifier: pid) else { return false }
        return app.activate()
    }
}

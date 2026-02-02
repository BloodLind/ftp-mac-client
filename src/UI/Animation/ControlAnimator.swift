import AppKit
import QuartzCore

enum ControlAnimator {
    static func fadeIn(window: NSWindow, duration: TimeInterval = 0.12, timing: CAMediaTimingFunctionName = .easeInEaseOut) {
        window.alphaValue = 0
        NSAnimationContext.runAnimationGroup { context in
            context.duration = duration
            context.timingFunction = CAMediaTimingFunction(name: timing)
            window.animator().alphaValue = 1
        }
    }

    static func fadeOut(window: NSWindow, duration: TimeInterval = 0.1, timing: CAMediaTimingFunctionName = .easeInEaseOut, completion: (() -> Void)? = nil) {
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = duration
            context.timingFunction = CAMediaTimingFunction(name: timing)
            window.animator().alphaValue = 0
        }, completionHandler: {
            completion?()
        })
    }

    static func fadeIn(view: NSView, duration: TimeInterval = 0.12, timing: CAMediaTimingFunctionName = .easeInEaseOut) {
        view.alphaValue = 0
        NSAnimationContext.runAnimationGroup { context in
            context.duration = duration
            context.timingFunction = CAMediaTimingFunction(name: timing)
            view.animator().alphaValue = 1
        }
    }

    static func fadeOut(view: NSView, duration: TimeInterval = 0.1, timing: CAMediaTimingFunctionName = .easeInEaseOut, completion: (() -> Void)? = nil) {
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = duration
            context.timingFunction = CAMediaTimingFunction(name: timing)
            view.animator().alphaValue = 0
        }, completionHandler: {
            completion?()
        })
    }
}

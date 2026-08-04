import SwiftUI
import AppKit
import Combine

class AppDelegate: NSObject, NSApplicationDelegate {
    static let apiService = OpenAIAPIService()
    
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private var cancellable: AnyCancellable?
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        // Single Instance Guard: Prevent duplicate Menu Bar icons
        let currentApp = NSRunningApplication.current
        let bundleID = currentApp.bundleIdentifier ?? "com.openai.codex.mascot.widget"
        let runningApps = NSRunningApplication.runningApplications(withBundleIdentifier: bundleID)
        
        for app in runningApps {
            if app != currentApp {
                app.activate(options: [.activateIgnoringOtherApps])
                exit(0)
            }
        }
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        
        // 1. Setup Status Item on macOS Menu Bar
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = item.button {
            button.action = #selector(togglePopover(_:))
            button.target = self
        }
        self.statusItem = item
        
        // 2. Setup NSPopover with animates = false (100% ZERO bounce/flicker)
        let pop = NSPopover()
        pop.contentSize = NSSize(width: 400, height: 420)
        pop.behavior = .transient
        pop.animates = false // Disables macOS window bounce/flicker
        pop.contentViewController = NSHostingController(rootView: DetailCardView(apiService: AppDelegate.apiService))
        self.popover = pop
        
        // 3. Observe API Service changes to update status item icon & text smoothly
        cancellable = AppDelegate.apiService.$rateLimit
            .receive(on: DispatchQueue.main)
            .sink { [weak self] rateLimit in
                self?.updateStatusBarItem(rateLimit: rateLimit)
            }
        
        updateStatusBarItem(rateLimit: AppDelegate.apiService.rateLimit)
        
        // 4. Launch Desktop Mascot Companion
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            DesktopMascotWindowManager.shared.showWindow(apiService: AppDelegate.apiService)
        }
    }
    
    private func updateStatusBarItem(rateLimit: OpenAIRateLimit) {
        guard let button = statusItem?.button else { return }
        let isError = AppDelegate.apiService.errorMessage != nil && rateLimit.apiKey.isEmpty
        let mascotImg = PixelMascotImageGenerator.generateNSImage(usagePercentage: rateLimit.usagePercentage, isError: isError, size: 18)
        button.image = mascotImg
        button.title = " \(Int(rateLimit.usagePercentage * 100))%"
        button.imagePosition = .imageLeft
        if let font = NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .bold) as NSFont? {
            button.font = font
        }
    }
    
    @objc func togglePopover(_ sender: AnyObject?) {
        guard let button = statusItem?.button, let popover = popover else { return }
        if popover.isShown {
            popover.performClose(sender)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }
}

@main
struct CodexMascotApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

import SwiftUI
import AppKit

public class DesktopMascotWindowManager: NSObject {
    public static let shared = DesktopMascotWindowManager()
    
    private var window: NSWindow?
    private var popover: NSPopover?
    public var isAlwaysOnTop: Bool = true
    
    public func setAlwaysOnTop(_ alwaysOnTop: Bool) {
        self.isAlwaysOnTop = alwaysOnTop
        DispatchQueue.main.async { [weak self] in
            self?.window?.level = alwaysOnTop ? .floating : .normal
        }
    }
    
    public func hideWindow() {
        DispatchQueue.main.async { [weak self] in
            self?.window?.orderOut(nil)
        }
    }
    
    public func toggleWindow(apiService: OpenAIAPIService) {
        DispatchQueue.main.async { [weak self] in
            if let window = self?.window, window.isVisible {
                self?.hideWindow()
            } else {
                self?.showWindow(apiService: apiService)
            }
        }
    }
    
    public func showWindow(apiService: OpenAIAPIService) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if let existingWindow = self.window {
                existingWindow.level = self.isAlwaysOnTop ? .floating : .normal
                existingWindow.orderFrontRegardless()
                existingWindow.makeKeyAndOrderFront(nil)
                return
            }
            
            let mascotView = DesktopMascotContentView(apiService: apiService) { [weak self] buttonView in
                self?.togglePopover(apiService: apiService, relativeTo: buttonView)
            }
            
            let hostingView = NSHostingView(rootView: mascotView)
            
            var windowRect = NSRect(x: 200, y: 200, width: 140, height: 140)
            if let mainScreen = NSScreen.main {
                let screenFrame = mainScreen.visibleFrame
                let x = screenFrame.maxX - 180
                let y = screenFrame.maxY - 220
                windowRect = NSRect(x: x, y: y, width: 140, height: 140)
            }
            
            let newWindow = NSWindow(
                contentRect: windowRect,
                styleMask: [.borderless],
                backing: .buffered,
                defer: false
            )
            
            newWindow.isOpaque = false
            newWindow.backgroundColor = .clear
            newWindow.level = self.isAlwaysOnTop ? .floating : .normal
            newWindow.isMovableByWindowBackground = true
            newWindow.contentView = hostingView
            newWindow.hasShadow = false
            newWindow.ignoresMouseEvents = false
            
            newWindow.orderFrontRegardless()
            newWindow.makeKeyAndOrderFront(nil)
            
            self.window = newWindow
        }
    }
    
    private func togglePopover(apiService: OpenAIAPIService, relativeTo view: NSView) {
        if popover == nil {
            let pop = NSPopover()
            pop.contentSize = NSSize(width: 400, height: 420)
            pop.behavior = .transient
            pop.animates = false // ZERO bounce / flicker
            pop.contentViewController = NSHostingController(rootView: DetailCardView(apiService: apiService))
            self.popover = pop
        }
        
        if let pop = popover, pop.isShown {
            pop.performClose(nil)
        } else {
            popover?.show(relativeTo: view.bounds, of: view, preferredEdge: .minY)
        }
    }
}

public struct DesktopMascotContentView: View {
    @ObservedObject var apiService: OpenAIAPIService
    var onClick: (NSView) -> Void
    
    public var body: some View {
        MascotClickableRepresentable(apiService: apiService, onClick: onClick)
            .frame(width: 130, height: 130)
    }
}

struct MascotClickableRepresentable: NSViewRepresentable {
    @ObservedObject var apiService: OpenAIAPIService
    var onClick: (NSView) -> Void
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        let hosting = NSHostingView(rootView: MascotStack(apiService: apiService))
        hosting.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hosting)
        
        NSLayoutConstraint.activate([
            hosting.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hosting.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hosting.topAnchor.constraint(equalTo: view.topAnchor),
            hosting.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        let gesture = NSClickGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleClick(_:)))
        view.addGestureRecognizer(gesture)
        
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onClick: onClick)
    }
    
    class Coordinator: NSObject {
        var onClick: (NSView) -> Void
        
        init(onClick: @escaping (NSView) -> Void) {
            self.onClick = onClick
        }
        
        @objc func handleClick(_ sender: NSClickGestureRecognizer) {
            if let targetView = sender.view {
                onClick(targetView)
            }
        }
    }
}

struct MascotStack: View {
    @ObservedObject var apiService: OpenAIAPIService
    
    var body: some View {
        let usagePct = apiService.rateLimit.usagePercentage
        let isError = apiService.errorMessage != nil && apiService.rateLimit.apiKey.isEmpty
        let emotion = MascotEmotion.emotion(for: usagePct, isError: isError)
        
        VStack(spacing: 4) {
            PixelMascotView(usagePercentage: usagePct, isError: isError, size: 85)
            
            Text("\(Int(usagePct * 100))%")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(Capsule().fill(emotion.themeColor))
                .shadow(color: .black.opacity(0.3), radius: 3)
        }
    }
}

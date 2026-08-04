import SwiftUI

public struct DetailCardView: View {
    @ObservedObject var apiService: OpenAIAPIService
    
    @State private var showSettings: Bool = false
    @State private var apiKeyInput: String = ""
    @State private var selectedModel: String = "gpt-4o-mini"
    @State private var refreshInterval: Int = 60
    @State private var isAlwaysOnTop: Bool = true
    @State private var isApiKeyVisible: Bool = false
    
    private let softRed = Color(red: 0.85, green: 0.28, blue: 0.28)
    let availableModels = ["gpt-4o-mini", "gpt-4o", "o1-mini", "o3-mini", "gpt-4-turbo"]
    let refreshOptions = [
        (30, "30 sec"),
        (60, "60 sec"),
        (180, "3 min"),
        (300, "5 min"),
        (900, "15 min")
    ]
    
    public init(apiService: OpenAIAPIService) {
        self.apiService = apiService
    }
    
    private var emotion: MascotEmotion {
        MascotEmotion.emotion(for: apiService.rateLimit.usagePercentage, isError: apiService.errorMessage != nil && apiService.rateLimit.apiKey.isEmpty)
    }
    
    public var body: some View {
        VStack(spacing: 12) {
            // Header Bar matching screenshot
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "bolt.horizontal.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(emotion.themeColor)
                    
                    Text("Codex Rate Limits")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text("v1.0.0")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(Color.secondary.opacity(0.15))
                        .cornerRadius(4)
                }
                
                Spacer()
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showSettings.toggle()
                    }
                }) {
                    Image(systemName: showSettings ? "xmark.circle.fill" : "gearshape.fill")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            
            if showSettings {
                // Settings View
                VStack(alignment: .leading, spacing: 10) {
                    Text("Probe Settings & Controls")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Toggle("Always On Top (อยู่ด้านบนสุด)", isOn: $isAlwaysOnTop)
                        .font(.caption)
                        .onChange(of: isAlwaysOnTop) { newValue in
                            DesktopMascotWindowManager.shared.setAlwaysOnTop(newValue)
                        }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("OpenAI API Key (Optional):")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            if isApiKeyVisible {
                                TextField("sk-...", text: $apiKeyInput)
                                    .textFieldStyle(.roundedBorder)
                                    .font(.system(size: 11, design: .monospaced))
                            } else {
                                SecureField("sk-...", text: $apiKeyInput)
                                    .textFieldStyle(.roundedBorder)
                                    .font(.system(size: 11, design: .monospaced))
                            }
                            
                            Button(action: { isApiKeyVisible.toggle() }) {
                                Image(systemName: isApiKeyVisible ? "eye.slash" : "eye")
                                    .foregroundColor(.secondary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Probe Model:")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Picker("", selection: $selectedModel) {
                            ForEach(availableModels, id: \.self) { model in
                                Text(model).tag(model)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Refresh Frequency:")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Picker("", selection: $refreshInterval) {
                            ForEach(refreshOptions, id: \.0) { option in
                                Text(option.1).tag(option.0)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    Spacer()
                    
                    HStack {
                        Button("Save & Probe") {
                            apiService.rateLimit.apiKey = apiKeyInput
                            apiService.rateLimit.modelName = selectedModel
                            apiService.rateLimit.refreshIntervalSeconds = refreshInterval
                            apiService.saveSettings()
                            withAnimation { showSettings = false }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(emotion.themeColor)
                        
                        Spacer()
                        
                        Button("Quit App") {
                            NSApplication.shared.terminate(nil)
                        }
                        .buttonStyle(.bordered)
                        .tint(softRed)
                    }
                }
                .padding(10)
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(10)
            } else {
                // Main Dashboard View matching the exact screenshot layout
                HStack(spacing: 14) {
                    // Pixel Mascot Render
                    PixelMascotView(
                        usagePercentage: apiService.rateLimit.usagePercentage,
                        isError: apiService.errorMessage != nil && apiService.rateLimit.apiKey.isEmpty,
                        size: 75
                    )
                    
                    // Status Badges & Info Summary
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text("Quota Active 🟢")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color.orange.opacity(0.85))
                                .cornerRadius(6)
                            
                            if let credits = apiService.rateLimit.availableResetCredits {
                                HStack(spacing: 3) {
                                    Image(systemName: "arrow.counterclockwise.circle.fill")
                                        .font(.system(size: 9))
                                    Text("\(credits) Reset Credit\(credits == 1 ? "" : "s")")
                                        .font(.system(size: 9, weight: .bold))
                                }
                                .foregroundColor(.cyan)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(Color.cyan.opacity(0.15))
                                .cornerRadius(6)
                            }
                        }
                        
                        HStack(spacing: 4) {
                            Text("ChatGPT \(apiService.rateLimit.planType ?? "Plus") ✦")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            if let email = apiService.rateLimit.userEmail, !email.isEmpty {
                                Text("(\(email))")
                                    .font(.system(size: 9))
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                        }
                        
                        let usedPct = Int(apiService.rateLimit.usagePercentage * 100)
                        Text("Weekly limit (7d): \(usedPct)% (allowed)")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(usedPct >= 80 ? softRed : .primary)
                    }
                    Spacer(minLength: 0)
                }
                
                // Weekly Limit Progress Bar (ChatGPT Codex Primary Window)
                VStack(spacing: 3) {
                    HStack {
                        Text("Weekly limit (7-day window):")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(Int(apiService.rateLimit.usagePercentage * 100))% used")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(apiService.rateLimit.usagePercentage >= 0.8 ? softRed : .primary)
                    }
                    
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.secondary.opacity(0.2))
                                .frame(height: 8)
                            Capsule()
                                .fill(apiService.rateLimit.usagePercentage >= 0.8 ? softRed : emotion.themeColor)
                                .frame(width: geo.size.width * CGFloat(apiService.rateLimit.usagePercentage), height: 8)
                        }
                    }
                    .frame(height: 8)
                    
                    HStack {
                        Text("Resets \(apiService.rateLimit.resetRequests)")
                            .font(.system(size: 9))
                            .foregroundColor(.secondary)
                        Spacer()
                        if let lastDate = apiService.rateLimit.lastFetchedDate {
                            Text("Last updated: \(lastDate, style: .time)")
                                .font(.system(size: 9))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Divider()
                
                // Footer Buttons matching exact screenshot
                HStack {
                    Button(action: {
                        DesktopMascotWindowManager.shared.toggleWindow(apiService: apiService)
                    }) {
                        Label("Toggle Mascot", systemImage: "desktopcomputer")
                            .font(.caption2)
                    }
                    .buttonStyle(.bordered)
                    
                    Spacer()
                    
                    Button(action: {
                        apiService.fetchRateLimit()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "paperplane.fill")
                                .font(.caption2)
                            Text("Probe API")
                                .font(.caption2)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(emotion.themeColor)
                    
                    Button(action: {
                        NSApplication.shared.terminate(nil)
                    }) {
                        Image(systemName: "power")
                            .font(.caption2)
                            .foregroundColor(softRed)
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .padding(14)
        .frame(width: 350, height: 340)
        .onAppear {
            apiKeyInput = apiService.rateLimit.apiKey
            selectedModel = apiService.rateLimit.modelName
            refreshInterval = apiService.rateLimit.refreshIntervalSeconds
            isAlwaysOnTop = DesktopMascotWindowManager.shared.isAlwaysOnTop
        }
    }
}

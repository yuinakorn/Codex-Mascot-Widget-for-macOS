import Foundation
import Combine

public class OpenAIAPIService: ObservableObject {
    @Published public var rateLimit: OpenAIRateLimit
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String? = nil
    
    private let userDefaultsKey = "CodexMascotRateLimitKey"
    private var refreshTimer: AnyCancellable?
    
    public init() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let saved = try? JSONDecoder().decode(OpenAIRateLimit.self, from: data) {
            self.rateLimit = saved
        } else {
            self.rateLimit = OpenAIRateLimit()
        }
        
        fetchRateLimit()
        setupTimer()
    }
    
    public func setupTimer() {
        refreshTimer?.cancel()
        let interval = Double(max(10, rateLimit.refreshIntervalSeconds))
        
        refreshTimer = Timer.publish(every: interval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.fetchRateLimit()
            }
    }
    
    public func saveSettings() {
        if let encoded = try? JSONEncoder().encode(rateLimit) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
        setupTimer()
        fetchRateLimit()
    }
    
    public func fetchRateLimit() {
        isLoading = true
        errorMessage = nil
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            // 1. Check for ChatGPT OAuth Token in ~/.codex/auth.json
            if let codexAuth = self.discoverCodexAuthToken() {
                self.fetchChatGPTUsage(accessToken: codexAuth.token, accountId: codexAuth.accountId)
                return
            }
            
            // 2. Check for OpenAI API Key
            let apiKey = self.discoverAPIKey()
            guard let validKey = apiKey, !validKey.isEmpty else {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "No API Key or Codex Auth set. Enter OpenAI API Key in settings or login via Codex CLI."
                    var updated = self.rateLimit
                    updated.apiStatusMessage = "Standing by (No Auth Token)"
                    self.rateLimit = updated
                }
                return
            }
            
            self.sendProbeRequest(apiKey: validKey)
        }
    }
    
    private struct CodexAuthInfo {
        let token: String
        let accountId: String?
    }
    
    private func discoverCodexAuthToken() -> CodexAuthInfo? {
        let authUrl = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".codex/auth.json")
        guard FileManager.default.fileExists(atPath: authUrl.path),
              let data = try? Data(contentsOf: authUrl),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let tokens = json["tokens"] as? [String: Any],
              let accessToken = tokens["access_token"] as? String,
              !accessToken.isEmpty else {
            return nil
        }
        let accountId = tokens["account_id"] as? String
        return CodexAuthInfo(token: accessToken, accountId: accountId)
    }
    
    private func discoverAPIKey() -> String? {
        // 1. User specified key in app settings
        if !rateLimit.apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return rateLimit.apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        // 2. Environment variable
        if let envKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"], !envKey.isEmpty {
            return envKey.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        // 3. Local credentials file (~/.openai/credentials.json or ~/.openai/config.json)
        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        let paths = [
            homeDir.appendingPathComponent(".openai/credentials.json"),
            homeDir.appendingPathComponent(".openai/config.json"),
            homeDir.appendingPathComponent(".codex/credentials.json")
        ]
        
        for url in paths {
            if FileManager.default.fileExists(atPath: url.path),
               let data = try? Data(contentsOf: url),
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                if let key = json["api_key"] as? String ?? json["apiKey"] as? String ?? json["OPENAI_API_KEY"] as? String, !key.isEmpty {
                    return key.trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
        }
        
        return nil
    }
    
    private func fetchChatGPTUsage(accessToken: String, accountId: String?) {
        guard let url = URL(string: "https://chatgpt.com/backend-api/wham/usage") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)", forHTTPHeaderField: "User-Agent")
        if let accId = accountId, !accId.isEmpty {
            request.setValue(accId, forHTTPHeaderField: "ChatGPT-Account-ID")
        }
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Network Error: \(error.localizedDescription)"
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self.errorMessage = "Invalid response from ChatGPT API"
                    return
                }
                
                var updated = self.rateLimit
                updated.lastFetchedDate = Date()
                
                if httpResponse.statusCode == 200, let data = data,
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    let plan = (json["plan_type"] as? String ?? "plus").capitalized
                    updated.planType = plan
                    updated.userEmail = json["email"] as? String
                    
                    if let resetCreditsObj = json["rate_limit_reset_credits"] as? [String: Any] {
                        updated.availableResetCredits = resetCreditsObj["available_count"] as? Int
                    }
                    
                    if let rateLimitObj = json["rate_limit"] as? [String: Any],
                       let primaryWindow = rateLimitObj["primary_window"] as? [String: Any] {
                        let usedPct = primaryWindow["used_percent"] as? Double ?? 0.0
                        let resetSecs = primaryWindow["reset_after_seconds"] as? Int ?? 0
                        
                        updated.usedPercent = usedPct
                        updated.resetAfterSeconds = resetSecs
                        
                        // Map into human readable reset date string (e.g. Sun 2:27 AM)
                        if resetSecs > 0 {
                            let resetDate = Date().addingTimeInterval(TimeInterval(resetSecs))
                            let formatter = DateFormatter()
                            formatter.dateFormat = "EEE h:mm a"
                            updated.resetRequests = formatter.string(from: resetDate)
                        } else {
                            updated.resetRequests = "0s"
                        }
                        
                        updated.apiStatusMessage = "✅ ChatGPT \(plan) (\(Int(usedPct))% Used)"
                        self.errorMessage = nil
                    } else {
                        updated.apiStatusMessage = "✅ ChatGPT \(plan)"
                        self.errorMessage = nil
                    }
                } else if httpResponse.statusCode == 401 {
                    updated.apiStatusMessage = "🔑 Token Expired (Re-login via Codex CLI)"
                    self.errorMessage = "ChatGPT Session token expired. Please re-authenticate using Codex CLI."
                } else {
                    updated.apiStatusMessage = "HTTP \(httpResponse.statusCode)"
                    self.errorMessage = "ChatGPT API returned HTTP \(httpResponse.statusCode)"
                }
                
                self.rateLimit = updated
            }
        }.resume()
    }
    
    private func sendProbeRequest(apiKey: String) {
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("OpenAI-Codex-Mascot-Widget/1.0", forHTTPHeaderField: "User-Agent")
        
        let targetModel = rateLimit.modelName.isEmpty ? "gpt-4o-mini" : rateLimit.modelName
        let payload: [String: Any] = [
            "model": targetModel,
            "max_tokens": 1,
            "messages": [
                ["role": "user", "content": "hi"]
            ]
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Network Error: \(error.localizedDescription)"
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self.errorMessage = "Invalid response from OpenAI API"
                    return
                }
                
                let headers = httpResponse.allHeaderFields
                
                // Always parse Rate Limit Headers (they come with 200, 429, etc.)
                let hasRateLimitHeaders = self.getHeaderString(headers, key: "x-ratelimit-limit-requests") != nil
                
                var updated = self.rateLimit
                updated.lastFetchedDate = Date()
                
                if hasRateLimitHeaders {
                    // Trust the actual headers from OpenAI
                    updated.limitRequests = max(1, self.getHeaderInt(headers, key: "x-ratelimit-limit-requests") ?? updated.limitRequests)
                    updated.remainingRequests = self.getHeaderInt(headers, key: "x-ratelimit-remaining-requests") ?? updated.remainingRequests
                    updated.resetRequests = self.getHeaderString(headers, key: "x-ratelimit-reset-requests") ?? "0s"
                    updated.limitTokens = max(1, self.getHeaderInt(headers, key: "x-ratelimit-limit-tokens") ?? updated.limitTokens)
                    updated.remainingTokens = self.getHeaderInt(headers, key: "x-ratelimit-remaining-tokens") ?? updated.remainingTokens
                    updated.resetTokens = self.getHeaderString(headers, key: "x-ratelimit-reset-tokens") ?? "0s"
                }
                
                // Parse response body for error details
                var errorType: String? = nil
                var errorMsg: String? = nil
                if let data = data,
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let errObj = json["error"] as? [String: Any] {
                    errorType = errObj["type"] as? String
                    errorMsg = errObj["message"] as? String
                }
                
                switch httpResponse.statusCode {
                case 200:
                    updated.apiStatusMessage = "✅ Connected (\(targetModel))"
                    self.errorMessage = nil
                    
                case 401:
                    updated.apiStatusMessage = "🔑 Invalid API Key"
                    self.errorMessage = "Invalid API Key (HTTP 401)"
                    
                case 429:
                    // Distinguish: temporary rate limit vs quota/billing exceeded
                    if errorType == "insufficient_quota" {
                        updated.apiStatusMessage = "💳 Insufficient Quota / Credits"
                        self.errorMessage = "No credits remaining. Add billing at platform.openai.com"
                    } else if errorType == "rate_limit_exceeded" || errorType == "requests" {
                        // Temporary per-minute rate limit — headers are valid, don't override
                        updated.apiStatusMessage = "⏳ Temporary Rate Limit (retry soon)"
                        self.errorMessage = errorMsg ?? "Per-minute rate limit hit — will retry"
                    } else {
                        updated.apiStatusMessage = "⚠️ 429: \(errorMsg ?? "Rate Limited")"
                        self.errorMessage = errorMsg ?? "Rate limited"
                    }
                    // Do NOT force remainingRequests = 0 here.
                    // Trust the actual x-ratelimit-* headers from the response.
                    
                case 400:
                    updated.apiStatusMessage = "⚠️ Bad Request"
                    self.errorMessage = errorMsg ?? "Invalid request (HTTP 400)"
                    
                case 500...599:
                    updated.apiStatusMessage = "🔥 OpenAI Server Error (\(httpResponse.statusCode))"
                    self.errorMessage = "OpenAI server error — try again later"
                    
                default:
                    updated.apiStatusMessage = "HTTP \(httpResponse.statusCode)"
                    self.errorMessage = errorMsg ?? "API returned HTTP \(httpResponse.statusCode)"
                }
                
                self.rateLimit = updated
            }
        }.resume()
    }
    
    private func getHeaderString(_ headers: [AnyHashable: Any], key: String) -> String? {
        let targetKey = key.lowercased()
        for (k, v) in headers {
            if let kStr = (k as? String)?.lowercased(), kStr == targetKey {
                return String(describing: v)
            }
        }
        return nil
    }
    
    private func getHeaderInt(_ headers: [AnyHashable: Any], key: String) -> Int? {
        guard let str = getHeaderString(headers, key: key) else { return nil }
        return Int(str)
    }
}

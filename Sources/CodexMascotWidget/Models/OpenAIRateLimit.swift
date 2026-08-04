import Foundation

public struct OpenAIRateLimit: Codable, Equatable {
    public var limitRequests: Int
    public var remainingRequests: Int
    public var resetRequests: String
    
    public var limitTokens: Int
    public var remainingTokens: Int
    public var resetTokens: String
    
    public var apiKey: String
    public var modelName: String
    public var refreshIntervalSeconds: Int
    
    public var lastFetchedDate: Date?
    public var apiStatusMessage: String?
    
    public var totalUsageCostUSD: Double?
    public var grantedCreditUSD: Double?
    
    // ChatGPT Plus / Codex specific metrics
    public var planType: String?
    public var usedPercent: Double?
    public var resetAfterSeconds: Int?
    public var userEmail: String?
    public var availableResetCredits: Int?
    
    public var resetDateString: String {
        guard let secs = resetAfterSeconds, secs > 0 else { return "N/A" }
        let resetDate = Date().addingTimeInterval(TimeInterval(secs))
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE h:mm a"
        return formatter.string(from: resetDate)
    }
    
    public init(
        limitRequests: Int = 500,
        remainingRequests: Int = 500,
        resetRequests: String = "0s",
        limitTokens: Int = 200000,
        remainingTokens: Int = 200000,
        resetTokens: String = "0s",
        apiKey: String = "",
        modelName: String = "gpt-4o-mini",
        refreshIntervalSeconds: Int = 60,
        lastFetchedDate: Date? = nil,
        apiStatusMessage: String? = nil,
        totalUsageCostUSD: Double? = nil,
        grantedCreditUSD: Double? = nil,
        planType: String? = nil,
        usedPercent: Double? = nil,
        resetAfterSeconds: Int? = nil,
        userEmail: String? = nil,
        availableResetCredits: Int? = nil
    ) {
        self.limitRequests = limitRequests
        self.remainingRequests = remainingRequests
        self.resetRequests = resetRequests
        self.limitTokens = limitTokens
        self.remainingTokens = remainingTokens
        self.resetTokens = resetTokens
        self.apiKey = apiKey
        self.modelName = modelName
        self.refreshIntervalSeconds = refreshIntervalSeconds
        self.lastFetchedDate = lastFetchedDate
        self.apiStatusMessage = apiStatusMessage
        self.totalUsageCostUSD = totalUsageCostUSD
        self.grantedCreditUSD = grantedCreditUSD
        self.planType = planType
        self.usedPercent = usedPercent
        self.resetAfterSeconds = resetAfterSeconds
        self.userEmail = userEmail
        self.availableResetCredits = availableResetCredits
    }
    
    // Utilization ratio from 0.0 to 1.0 (0% to 100%)
    public var requestUtilization: Double {
        guard limitRequests > 0 else { return 0.0 }
        let used = Double(max(0, limitRequests - remainingRequests))
        return min(1.0, max(0.0, used / Double(limitRequests)))
    }
    
    public var tokenUtilization: Double {
        guard limitTokens > 0 else { return 0.0 }
        let used = Double(max(0, limitTokens - remainingTokens))
        return min(1.0, max(0.0, used / Double(limitTokens)))
    }
    
    public var usagePercentage: Double {
        if let usedPct = usedPercent {
            return min(1.0, max(0.0, usedPct / 100.0))
        }
        return max(requestUtilization, tokenUtilization)
    }
    
    public var formattedSummary: String {
        let reqPct = Int(requestUtilization * 100)
        let tokPct = Int(tokenUtilization * 100)
        return "RPM: \(reqPct)% | TPM: \(tokPct)%"
    }
}

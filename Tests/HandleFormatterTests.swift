import XCTest
@testable import Vox

final class HandleFormatterTests: XCTestCase {
    
    var formatter: HandleFormatter!
    
    override func setUp() {
        super.setUp()
        formatter = HandleFormatter.shared
        // Reset to default configuration
        formatter.updateConfiguration { config in
            config = HandleFormatter.Configuration()
        }
    }
    
    // MARK: - Basic Formatting Tests
    
    func testRemoveCommonBlueskySuffixes() {
        let testCases = [
            ("alice.bsky.social", "alice"),
            ("bob.bsky.team", "bob"),
            ("charlie.bsky.app", "charlie"),
            ("david.bsky.network", "david")
        ]
        
        for (input, expected) in testCases {
            let result = formatter.format(input, mode: .hideCommonSuffixes)
            XCTAssertEqual(result, expected, "Failed to remove suffix from \(input)")
        }
    }
    
    func testPreserveCustomDomains() {
        let testCases = [
            "alice.custom.com",
            "bob.example.org",
            "news.nytimes.com",
            "support.apple.com"
        ]
        
        for handle in testCases {
            let result = formatter.format(handle, mode: .hideCommonSuffixes)
            XCTAssertEqual(result, handle, "Should preserve custom domain: \(handle)")
        }
    }
    
    func testHideAllKnownSuffixes() {
        let testCases = [
            ("alice.com", "alice"),
            ("bob.org", "bob"),
            ("charlie.net", "charlie"),
            ("david.io", "david"),
            ("eve.social", "eve")
        ]
        
        for (input, expected) in testCases {
            let result = formatter.format(input, mode: .hideAllKnownSuffixes)
            XCTAssertEqual(result, expected, "Failed to remove known suffix from \(input)")
        }
    }
    
    // MARK: - Smart Mode Tests
    
    func testSmartModeWithVerifiedAccounts() {
        // Configure to show domains for verified accounts
        formatter.updateConfiguration { config in
            config.showDomainForVerifiedAccounts = true
        }
        
        // Verified account (custom domain) should show full handle
        let verifiedHandle = "news.nytimes.com"
        let result = formatter.format(verifiedHandle, mode: .smart, isVerified: true)
        XCTAssertEqual(result, verifiedHandle)
        
        // Non-verified with common suffix should hide suffix
        let regularHandle = "alice.bsky.social"
        let regularResult = formatter.format(regularHandle, mode: .smart, isVerified: false)
        XCTAssertEqual(regularResult, "alice")
    }
    
    func testSmartModeWithCustomDomains() {
        // Custom domains should always be shown in smart mode
        let customDomains = [
            "user.myblog.com",
            "contact.company.co.uk",
            "admin.service.app"
        ]
        
        for handle in customDomains {
            let result = formatter.format(handle, mode: .smart)
            XCTAssertEqual(result, handle, "Smart mode should preserve custom domain: \(handle)")
        }
    }
    
    // MARK: - Truncation Tests
    
    func testTruncation() {
        let longHandle = "verylongusername.bsky.social"
        
        // Test with max length that requires truncation
        let result = formatter.format(longHandle, mode: .hideCommonSuffixes, maxLength: 10)
        XCTAssertEqual(result, "verylongu…")
        XCTAssertEqual(result.count, 10)
    }
    
    func testTruncationPreservesShortHandles() {
        let shortHandle = "alice"
        let result = formatter.format(shortHandle, mode: .hideCommonSuffixes, maxLength: 10)
        XCTAssertEqual(result, "alice")
    }
    
    // MARK: - Configuration Tests
    
    func testNeverHiddenDomains() {
        formatter.updateConfiguration { config in
            config.neverHiddenDomains = [".special.com", ".important.org"]
        }
        
        let testCases = [
            "user.special.com",
            "admin.important.org"
        ]
        
        for handle in testCases {
            let result = formatter.format(handle, mode: .hideAllKnownSuffixes)
            XCTAssertEqual(result, handle, "Should never hide domain: \(handle)")
        }
    }
    
    func testCustomFormatter() {
        let customMode = HandleFormatter.DisplayMode.custom { handle in
            // Custom formatter that uppercases everything
            return handle.uppercased()
        }
        
        let result = formatter.format("alice.bsky.social", mode: customMode)
        XCTAssertEqual(result, "ALICE.BSKY.SOCIAL")
    }
    
    // MARK: - Batch Formatting Tests
    
    func testBatchFormatting() {
        let handles = [
            "alice.bsky.social",
            "bob.com",
            "charlie.custom.domain"
        ]
        
        let results = formatter.formatBatch(handles, mode: .hideCommonSuffixes)
        
        XCTAssertEqual(results[0], "alice")
        XCTAssertEqual(results[1], "bob.com")
        XCTAssertEqual(results[2], "charlie.custom.domain")
    }
    
    // MARK: - Convenience Method Tests
    
    func testFormatCompact() {
        let longHandle = "verylongusername.bsky.social"
        let result = formatter.formatCompact(longHandle)
        
        // Should remove suffix and truncate to 20 chars
        XCTAssertEqual(result, "verylongusername")
        XCTAssertLessThanOrEqual(result.count, 20)
    }
    
    func testFormatForFeed() {
        let handle = "alice.bsky.social"
        let result = formatter.formatForFeed(handle)
        
        // Default smart mode should remove common suffix
        XCTAssertEqual(result, "alice")
    }
    
    func testFormatForProfile() {
        let handle = "alice.bsky.social"
        let result = formatter.formatForProfile(handle)
        
        // Profile format should hide common suffixes
        XCTAssertEqual(result, "alice")
    }
    
    // MARK: - Edge Cases
    
    func testEmptyHandle() {
        let result = formatter.format("")
        XCTAssertEqual(result, "")
    }
    
    func testHandleWithoutDomain() {
        let result = formatter.format("alice")
        XCTAssertEqual(result, "alice")
    }
    
    func testHandleWithMultipleDots() {
        let handle = "alice.bob.charlie.bsky.social"
        let result = formatter.format(handle, mode: .hideCommonSuffixes)
        XCTAssertEqual(result, "alice.bob.charlie")
    }
    
    func testInternationalDomains() {
        // Test that international TLDs are handled correctly
        formatter.updateConfiguration { config in
            config.optionallyHiddenSuffixes.insert(".jp")
            config.optionallyHiddenSuffixes.insert(".de")
        }
        
        let testCases = [
            ("user.co.jp", "user.co"),  // Should only remove .jp, not .co.jp
            ("admin.de", "admin")
        ]
        
        for (input, expected) in testCases {
            let result = formatter.format(input, mode: .hideAllKnownSuffixes)
            XCTAssertEqual(result, expected)
        }
    }
}

// MARK: - String Extension Tests
final class StringHandleExtensionTests: XCTestCase {
    
    func testHandleDomain() {
        XCTAssertEqual("alice.bsky.social".handleDomain, ".bsky.social")
        XCTAssertEqual("bob.com".handleDomain, ".com")
        XCTAssertEqual("charlie.co.uk".handleDomain, ".co.uk")
        XCTAssertNil("alice".handleDomain)
    }
    
    func testHandleUsername() {
        XCTAssertEqual("alice.bsky.social".handleUsername, "alice")
        XCTAssertEqual("bob.com".handleUsername, "bob")
        XCTAssertEqual("charlie.david.com".handleUsername, "charlie")
        XCTAssertNil("alice".handleUsername)
    }
    
    func testIsValidHandle() {
        XCTAssertTrue("alice.bsky.social".isValidHandle)
        XCTAssertTrue("bob.com".isValidHandle)
        XCTAssertTrue("charlie.co.uk".isValidHandle)
        
        XCTAssertFalse("alice".isValidHandle)
        XCTAssertFalse(".com".isValidHandle)
        XCTAssertFalse("alice.".isValidHandle)
        XCTAssertFalse("".isValidHandle)
    }
    
    func testHandleDisplayConfig() {
        let handle = "alice.bsky.social"
        
        let compactResult = handle.formatHandle(using: .compact)
        XCTAssertEqual(compactResult, "alice")
        
        let standardResult = handle.formatHandle(using: .standard)
        XCTAssertEqual(standardResult, "alice")
        
        let fullResult = handle.formatHandle(using: .full)
        XCTAssertEqual(fullResult, "alice.bsky.social")
    }
} 
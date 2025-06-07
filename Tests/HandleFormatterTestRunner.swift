#!/usr/bin/env swift

// Simple test runner for HandleFormatter
// This can be run directly without Xcode

import Foundation

// Mock the HandleFormatter implementation for testing
final class HandleFormatter {
    static let shared = HandleFormatter()
    
    struct Configuration {
        var alwaysHiddenSuffixes: Set<String> = [
            ".bsky.social",
            ".bsky.team",
            ".bsky.app",
            ".bsky.network"
        ]
        
        var optionallyHiddenSuffixes: Set<String> = [
            ".com", ".org", ".net", ".io", ".dev", ".app",
            ".social", ".xyz", ".me", ".co"
        ]
        
        var neverHiddenDomains: Set<String> = []
        var showDomainForVerifiedAccounts: Bool = true
        var defaultDisplayMode: DisplayMode = .smart
    }
    
    enum DisplayMode {
        case full
        case hideCommonSuffixes
        case hideAllKnownSuffixes
        case smart
        case custom((String) -> String)
    }
    
    private(set) var configuration = Configuration()
    
    func format(
        _ handle: String,
        mode: DisplayMode? = nil,
        isVerified: Bool = false,
        maxLength: Int? = nil
    ) -> String {
        let effectiveMode = mode ?? configuration.defaultDisplayMode
        
        if let domain = handle.handleDomain,
           configuration.neverHiddenDomains.contains(domain) {
            return truncateIfNeeded(handle, maxLength: maxLength)
        }
        
        let formatted: String
        switch effectiveMode {
        case .full:
            formatted = handle
        case .hideCommonSuffixes:
            formatted = removeCommonSuffixes(from: handle)
        case .hideAllKnownSuffixes:
            formatted = removeAllKnownSuffixes(from: handle)
        case .smart:
            formatted = smartFormat(handle, isVerified: isVerified)
        case .custom(let formatter):
            formatted = formatter(handle)
        }
        
        return truncateIfNeeded(formatted, maxLength: maxLength)
    }
    
    private func removeCommonSuffixes(from handle: String) -> String {
        for suffix in configuration.alwaysHiddenSuffixes {
            if handle.hasSuffix(suffix) {
                return String(handle.dropLast(suffix.count))
            }
        }
        return handle
    }
    
    private func removeAllKnownSuffixes(from handle: String) -> String {
        let afterCommon = removeCommonSuffixes(from: handle)
        if afterCommon != handle {
            return afterCommon
        }
        
        for suffix in configuration.optionallyHiddenSuffixes {
            if handle.hasSuffix(suffix) {
                return String(handle.dropLast(suffix.count))
            }
        }
        
        return handle
    }
    
    private func smartFormat(_ handle: String, isVerified: Bool) -> String {
        if isVerified && configuration.showDomainForVerifiedAccounts {
            return handle
        }
        
        if let domain = handle.handleDomain {
            let isKnownSuffix = configuration.alwaysHiddenSuffixes.contains(domain) ||
                               configuration.optionallyHiddenSuffixes.contains(domain)
            
            if !isKnownSuffix {
                return handle
            }
        }
        
        return removeCommonSuffixes(from: handle)
    }
    
    private func truncateIfNeeded(_ text: String, maxLength: Int?) -> String {
        guard let maxLength = maxLength, text.count > maxLength else {
            return text
        }
        
        let truncateLength = maxLength - 1
        return String(text.prefix(truncateLength)) + "…"
    }
}

extension String {
    var handleDomain: String? {
        guard let firstDotIndex = firstIndex(of: ".") else { return nil }
        return String(self[firstDotIndex...])
    }
}

// Test runner
struct TestRunner {
    static func run() {
        print("🧪 Running HandleFormatter Tests\n")
        
        var passed = 0
        var failed = 0
        
        func test(_ name: String, _ condition: Bool) {
            if condition {
                print("✅ \(name)")
                passed += 1
            } else {
                print("❌ \(name)")
                failed += 1
            }
        }
        
        let formatter = HandleFormatter.shared
        
        // Test 1: Remove common Bluesky suffixes
        test("Remove .bsky.social",
             formatter.format("alice.bsky.social", mode: .hideCommonSuffixes) == "alice")
        
        test("Remove .bsky.team",
             formatter.format("bob.bsky.team", mode: .hideCommonSuffixes) == "bob")
        
        // Test 2: Preserve custom domains
        test("Preserve custom domain",
             formatter.format("news.nytimes.com", mode: .hideCommonSuffixes) == "news.nytimes.com")
        
        // Test 3: Hide all known suffixes
        test("Hide .com suffix",
             formatter.format("alice.com", mode: .hideAllKnownSuffixes) == "alice")
        
        test("Hide .org suffix",
             formatter.format("bob.org", mode: .hideAllKnownSuffixes) == "bob")
        
        // Test 4: Smart mode with custom domains
        test("Smart mode preserves custom domain",
             formatter.format("user.myblog.com", mode: .smart) == "user.myblog.com")
        
        test("Smart mode removes common suffix",
             formatter.format("alice.bsky.social", mode: .smart) == "alice")
        
        // Test 5: Truncation
        test("Truncate long handle",
             formatter.format("verylongusername", maxLength: 10) == "verylongu…")
        
        test("Don't truncate short handle",
             formatter.format("alice", maxLength: 10) == "alice")
        
        // Test 6: Full mode
        test("Full mode preserves everything",
             formatter.format("alice.bsky.social", mode: .full) == "alice.bsky.social")
        
        // Test 7: Empty and edge cases
        test("Empty handle",
             formatter.format("") == "")
        
        test("Handle without domain",
             formatter.format("alice") == "alice")
        
        test("Handle with multiple dots",
             formatter.format("alice.bob.bsky.social", mode: .hideCommonSuffixes) == "alice.bob")
        
        // Summary
        print("\n📊 Test Summary")
        print("✅ Passed: \(passed)")
        print("❌ Failed: \(failed)")
        print("📈 Total: \(passed + failed)")
        
        if failed == 0 {
            print("\n🎉 All tests passed!")
        } else {
            print("\n⚠️  Some tests failed!")
        }
    }
}

// Run the tests
TestRunner.run() 
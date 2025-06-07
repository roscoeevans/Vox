import SwiftUI

struct HandleDisplaySettings: View {
    @AppStorage("handleDisplayMode") private var displayMode: String = "smart"
    @AppStorage("showVerifiedDomains") private var showVerifiedDomains: Bool = true
    @AppStorage("hideCommonDomains") private var hideCommonDomains: Bool = true
    @State private var previewHandle = "alice.bsky.social"
    @State private var customPreviewHandle = ""
    
    var body: some View {
        Form {
            Section {
                Picker("Display Mode", selection: $displayMode) {
                    Text("Smart (Recommended)").tag("smart")
                    Text("Hide Common Domains").tag("hideCommon")
                    Text("Hide All Known Domains").tag("hideAll")
                    Text("Show Full Handle").tag("full")
                }
                .pickerStyle(.menu)
                
                Toggle("Show domains for verified accounts", isOn: $showVerifiedDomains)
                    .disabled(displayMode == "full")
                
                Toggle("Hide common domains (.com, .org, etc.)", isOn: $hideCommonDomains)
                    .disabled(displayMode == "full" || displayMode == "hideAll")
            } header: {
                Text("Handle Display Options")
            } footer: {
                Text("Configure how user handles are displayed throughout the app")
            }
            
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    PreviewRow(
                        title: "Standard handle",
                        handle: "alice.bsky.social",
                        mode: displayModeFromString(displayMode)
                    )
                    
                    PreviewRow(
                        title: "Custom domain",
                        handle: "john.doe.com",
                        mode: displayModeFromString(displayMode)
                    )
                    
                    PreviewRow(
                        title: "Organization",
                        handle: "news.nytimes.com",
                        mode: displayModeFromString(displayMode)
                    )
                    
                    PreviewRow(
                        title: "Long handle",
                        handle: "verylongusername.bsky.social",
                        mode: displayModeFromString(displayMode)
                    )
                }
            } header: {
                Text("Preview")
            }
            
            Section {
                HStack {
                    TextField("Enter a handle to preview", text: $customPreviewHandle)
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    if !customPreviewHandle.isEmpty {
                        Text("→")
                            .foregroundColor(.secondary)
                        
                        Text(formatHandle(customPreviewHandle))
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.blue)
                    }
                }
            } header: {
                Text("Test Custom Handle")
            }
        }
        .navigationTitle("Handle Display")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: displayMode) { _ in
            updateFormatterConfiguration()
        }
        .onChange(of: showVerifiedDomains) { _ in
            updateFormatterConfiguration()
        }
        .onChange(of: hideCommonDomains) { _ in
            updateFormatterConfiguration()
        }
        .onAppear {
            updateFormatterConfiguration()
        }
    }
    
    private func displayModeFromString(_ mode: String) -> HandleFormatter.DisplayMode {
        switch mode {
        case "smart": return .smart
        case "hideCommon": return .hideCommonSuffixes
        case "hideAll": return .hideAllKnownSuffixes
        case "full": return .full
        default: return .smart
        }
    }
    
    private func formatHandle(_ handle: String) -> String {
        HandleFormatter.shared.format(handle, mode: displayModeFromString(displayMode))
    }
    
    private func updateFormatterConfiguration() {
        HandleFormatter.shared.updateConfiguration { config in
            config.defaultDisplayMode = displayModeFromString(displayMode)
            config.showDomainForVerifiedAccounts = showVerifiedDomains
            
            if hideCommonDomains {
                config.optionallyHiddenSuffixes = [
                    ".com", ".org", ".net", ".io", ".dev", ".app",
                    ".social", ".xyz", ".me", ".co", ".us", ".uk",
                    ".ca", ".au", ".de", ".fr", ".jp", ".cn", ".in", ".br"
                ]
            } else {
                config.optionallyHiddenSuffixes = []
            }
        }
    }
}

struct PreviewRow: View {
    let title: String
    let handle: String
    let mode: HandleFormatter.DisplayMode
    
    var body: some View {
        HStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 100, alignment: .leading)
            
            Text(handle)
                .font(.caption2)
                .foregroundColor(.secondary)
                .frame(width: 140, alignment: .leading)
            
            Text("→")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(HandleFormatter.shared.format(handle, mode: mode))
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.blue)
            
            Spacer()
        }
    }
}

#Preview {
    NavigationStack {
        HandleDisplaySettings()
    }
} 
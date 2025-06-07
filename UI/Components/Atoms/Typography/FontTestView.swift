import SwiftUI

struct FontTestView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Logo variations
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Logo Variations")
                            .font(.voxCaption())
                            .foregroundStyle(.secondary)
                        
                        HStack(spacing: 20) {
                            VoxLogoView(size: 40)
                            VoxLogoView(size: 60)
                            VoxCustomLogoView(size: 50)
                        }
                    }
                    .padding(.bottom)
                    
                    Divider()
                    
                    // Font styles
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Typography Styles")
                            .font(.voxCaption())
                            .foregroundStyle(.secondary)
                        
                        Text("Navigation Title")
                            .font(.voxNavigationTitle())
                        
                        Text("Title - voxTitle()")
                            .font(.voxTitle())
                        
                        Text("Title 2 - voxTitle2()")
                            .font(.voxTitle2())
                        
                        Text("Headline - voxHeadline()")
                            .font(.voxHeadline())
                        
                        Text("Body - voxBody()")
                            .font(.voxBody())
                        
                        Text("Callout - voxCallout()")
                            .font(.voxCallout())
                        
                        Text("Subheadline - voxSubheadline()")
                            .font(.voxSubheadline())
                        
                        Text("Footnote - voxFootnote()")
                            .font(.voxFootnote())
                        
                        Text("Caption - voxCaption()")
                            .font(.voxCaption())
                        
                        Text("Caption 2 - voxCaption2()")
                            .font(.voxCaption2())
                    }
                    
                    Divider()
                    
                    // Sample post
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Sample Post")
                            .font(.voxCaption())
                            .foregroundStyle(.secondary)
                        
                        HStack(spacing: 12) {
                            Circle()
                                .fill(Color.blue.opacity(0.3))
                                .frame(width: 44, height: 44)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("John Doe")
                                    .font(.voxHeadline())
                                Text("johndoe")
                                    .font(.voxSubheadline())
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                        }
                        
                        Text("This is what a post would look like with the new Montserrat font. Notice how the geometric shapes give it a modern, clean appearance.")
                            .font(.voxBody())
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("Font Test")
            .voxNavigationTitleFont()
        }
    }
}

#Preview {
    FontTestView()
} 

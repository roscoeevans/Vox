# Vox Documentation Map

This guide explains where to find different types of documentation for the Vox project.

## 📍 Documentation Organization

### Notion (Primary Documentation)
**URL**: [Vox Documentation Index](https://www.notion.so/Vox-Documentation-Index-1ffed16cc632810cad6dc3936d206f1d)

**Contains**:
- Comprehensive guides and explanations
- Architecture documentation
- Design system standards
- Feature integration guides
- View documentation hub
- Protocol specifications

**Best for**:
- Understanding concepts and architecture
- Learning about features in detail
- Design and UX guidelines
- Integration guides

### Local Files (Quick References)
**Location**: Project repository

**Structure**:
```
/Docs/
├── MVP-Reqs.md                    # MVP requirements and specifications
├── Bluesky-Integration.md         # BlueSky protocol integration details
├── Media.md                       # Media handling documentation
├── Emulating-Apple.md             # Apple design principles guide
├── Recommendations.md             # Best practices and recommendations
└── Font-*.md                      # Font implementation guides

/Documentation/
├── HandleFormatting*.md           # Handle formatting specifications
├── VerifiedBadgeImplementation.md # Verified badge feature docs
└── HandleFormattingDemo.swift     # Code examples

README.md                          # Project overview and setup guide
DOCUMENTATION_MAP.md               # This file - documentation guide
```

**Best for**:
- Quick implementation references
- Code snippets and examples
- Technical specifications
- Setup instructions

## 🗂️ Documentation by Category

### Getting Started
- **Local**: `README.md` - Project setup and overview
- **Notion**: "What is Vox?" - Comprehensive introduction

### Architecture & Design
- **Notion**: 
  - "What is Vox?" - High-level architecture
  - "Protocol-Oriented Post Rendering Architecture"
  - "Vox SwiftData Implementation Guide"
- **Local**: `/Docs/Emulating-Apple.md` - Design philosophy

### Features
- **Notion**: 
  - Feature Guides section
  - View Documentation Hub
- **Local**: 
  - `/Documentation/` - Implementation details
  - `/Docs/MVP-Reqs.md` - Feature specifications

### BlueSky/AT Protocol
- **Notion**: 
  - "Bluesky Open Protocol"
  - "ATProtoKit (Bluesky Swift SDK)"
  - "Media Support in BlueSky AT Protocol"
- **Local**: 
  - `/Docs/Bluesky-Integration.md`
  - `/Documentation/HandleFormatting*.md`

### UI/UX Guidelines
- **Notion**: 
  - "SwiftUI View Naming Standards"
  - "View Documentation Hub"
  - "Vox Media Display Guidelines"
- **Local**: `/Docs/Media.md`

### Code Standards
- **Notion**: Design System & Standards section
- **Local**: Code examples in `/Documentation/`

## 🔍 Finding Information

### If you need to know...

**"How does X feature work?"**
→ Check Notion Feature Guides

**"What's the code structure for X?"**
→ Check local `/Documentation/` files

**"What are the design principles?"**
→ Notion Design System or local `/Docs/Emulating-Apple.md`

**"How do I implement X view?"**
→ Notion View Documentation Hub

**"What are the technical requirements?"**
→ Local `/Docs/MVP-Reqs.md`

**"How do I set up the project?"**
→ Local `README.md`

## 📝 Contributing to Documentation

### Adding New Documentation

1. **Decide on location**:
   - Notion: Conceptual guides, architecture, design decisions
   - Local: Implementation details, code snippets, quick references

2. **Follow the structure**:
   - Notion: Add to appropriate section in Documentation Index
   - Local: Place in `/Docs/` or `/Documentation/` based on content type

3. **Update references**:
   - Update this map if adding new categories
   - Add links in Notion Documentation Index
   - Update relevant README sections

### Documentation Standards

- Use clear, descriptive titles
- Include examples where applicable
- Tag documents appropriately
- Keep implementation details in local files
- Keep conceptual explanations in Notion
- Cross-reference related documents

## 🔄 Keeping Documentation Current

- Update documentation when features change
- Review quarterly for accuracy
- Remove outdated information
- Maintain consistent formatting
- Update the changelog in Notion

---

Last Updated: 2025-06-01 
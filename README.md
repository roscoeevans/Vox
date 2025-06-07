# Vox

A modern, elegant social media app built with SwiftUI and the BlueSky AT Protocol.

## 🚀 Features

- **Authentication**: Secure BlueSky account integration
- **Feed**: Beautiful, responsive social feed
- **Threads**: Create and view threaded conversations
- **Daily Prompts**: Engage with daily conversation starters
- **Draft Garden**: Manage and organize your post drafts
- **Offline Support**: Full offline capabilities with SwiftData

## 🛠️ Technical Stack

- **iOS Version**: iOS 18+
- **Framework**: SwiftUI
- **Data Storage**: SwiftData
- **Authentication**: BlueSky AT Protocol
- **Architecture**: Feature-based with clean architecture principles

## 📱 Project Structure

```
Vox/
├── App/                           # App entry point and lifecycle
├── Features/                      # Feature-based modules
│   ├── Authentication/           # Auth-related views and logic
│   ├── Feed/                     # Home feed implementation
│   ├── Thread/                   # Thread creation and viewing
│   ├── Profile/                  # User profiles
│   ├── DailyPrompts/            # Daily prompt system
│   └── DraftGarden/             # Draft management
├── Core/                         # Core functionality
│   ├── Network/                  # Network layer
│   ├── Storage/                  # Data persistence
│   ├── Services/                 # Business logic services
│   └── Extensions/               # Swift extensions
├── UI/                          # Shared UI components
├── Utils/                       # Utility functions
├── Models/                      # Data models
└── Config/                      # Configuration files
```

## 🏗️ Architecture

Vox follows a feature-based architecture that emphasizes modularity, maintainability, and scalability. Each feature is self-contained with its own views, view models, and business logic.

### Core Principles

1. **Feature Isolation**
   - Each feature is self-contained
   - Features can be developed and tested independently
   - Clear boundaries prevent feature creep

2. **Clean Architecture**
   - Clear separation of concerns
   - Unidirectional data flow
   - Testable business logic

3. **Modern Swift Practices**
   - SwiftUI for declarative UI
   - Combine for reactive programming
   - Async/await for asynchronous operations
   - Property wrappers for dependency injection

## 🚀 Getting Started

### Prerequisites

- Xcode 16+
- iOS 18+ device or simulator
- BlueSky account

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/roscoeevans/Vox.git
   ```

2. Open the project in Xcode:
   ```bash
   cd Vox
   open Vox.xcodeproj
   ```

3. Build and run the project (⌘R)

## 🎨 Design System

Vox follows Apple's Human Interface Guidelines and design principles:

- Clean, minimal interface
- Native iOS feel
- Consistent typography and spacing
- Smooth animations and transitions
- Full dark mode support
- Accessibility-first approach

## 🔄 Development Workflow

1. **Feature Development**
   - Create feature branch from `main`
   - Follow feature module structure
   - Implement views, view models, and services
   - Add necessary tests
   - Document the feature's API and usage

2. **Code Organization**
   - Keep files focused and single-purpose
   - Use extensions to organize code
   - Follow Swift naming conventions
   - Document public APIs

3. **Testing Strategy**
   - Unit tests for business logic
   - UI tests for views
   - Integration tests for network and storage

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📧 Contact

Roscoe Evans - [@roscoeevans](https://github.com/roscoeevans)

Project Link: [https://github.com/roscoeevans/Vox](https://github.com/roscoeevans/Vox) 
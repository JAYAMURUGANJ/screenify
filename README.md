# Office App Embedder

A Flutter application that embeds Microsoft Office applications within a contained environment. This application is designed to create a kiosk-like experience where users can use Office applications but are prevented from accessing other parts of the system.

## Features

- Full-screen mode to prevent access to desktop
- Hides the Windows taskbar for a complete kiosk experience
- Clean UI with sidebar navigation

## Requirements

- Windows operating system
- Microsoft Office installed (configured for Office 2007 paths by default)
- Flutter development environment

## Getting Started

1. Clone this repository
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to start the application

## How It Works

The application uses the Win32 API through the `win32` package to:

1. Launch Office applications as separate processes
2. Find the window handle for these processes
3. Modify window styles to remove decorations
4. Embed the window as a child of the Flutter application
5. Intercept keyboard shortcuts to prevent escape
6. Hide the Windows taskbar
7. Maintain focus on the embedded application

## Security Considerations

This application is designed for kiosk-type deployments where you want to restrict users to only using Office applications. It:

- Prevents Alt+Tab switching
- Runs in full-screen mode
- Hides the Windows taskbar
- Keeps the embedded application in focus
- Blocks access to other system features

Note that this is not a complete security solution and determined users may find ways around these restrictions.

# Mobile App: Credit Card Buddy

This directory is the starting point for the iOS + iPadOS application.

## Recommended approach

- Create a new SwiftUI app in Xcode called `CreditCardBuddy`
- Target iOS 17+ and iPadOS 17+
- Use MVVM to separate views from business logic
- Build the first screen as the Home Dashboard

## Suggested folder structure

- `Models/`
- `Views/`
- `ViewModels/`
- `Services/`
- `Resources/`
- `Support/`

## Startup screen

The initial `HomeView` should show:
- total connected cards
- spend summary
- rewards snapshot
- quick actions for connecting cards and viewing recommendations

## Notes

The actual iOS project should be created in Xcode. This repository currently contains design guidance and initial architecture. Once the Xcode project exists, move these files into the app target.

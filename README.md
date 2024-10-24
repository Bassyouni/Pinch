# IGDB Games Browser

A SwiftUI application that showcases popular games from IGDB, featuring both online and offline capabilities.

## Requirements

- Xcode 16 or later
- iOS 16+ (supporting latest two iOS versions)
- Active internet connection for first load

## Features

- Browse popular games with cover art and details
- Offline support with CoreData persistence
- Pull-to-refresh for latest game data

## Technical Stack

- **SwiftUI** for UI layer
- **Combine** for reactive programming
- **CoreData** for local persistence
- **URLSession** for networking

## Architecture

The project follows clean architecture principles with clear separation of concerns:

### Domain
- Core game models and protocols
- Platform-independent business logic

### Features
- GameList feature with presentation and domain logic
- Feature-specific protocols and models

### Infrastructure
- **API**: IGDB API integration with URLSession
- **Storage**: CoreData implementation for offline support
- **Navigation**: SwiftUI navigation handling

## Project Structure
```
Pinch-Assignment/
├── Features/
│   └── GameList/
│       ├── Domain/
│       │   ├── GamesLoader.swift
│       │   ├── GamesRefreshable.swift
│       │   └── GamesSaver.swift
│       └── Presentation/
│           ├── GamesListView.swift
│           ├── GamesListViewModel.swift
│           └── ViewState.swift
├── Infrastructure/
│   ├── API/
│   ├── Storage/
│   └── Navigation/
└── Composition/
```

## TODO/Future Improvements

- [ ] Infinite scrolling support
- [ ] More detailed game information
- [ ] UI improvements for different screen sizes


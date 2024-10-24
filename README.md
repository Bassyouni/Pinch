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

## Project Structure
```
Pinch-Assignment/
├── Domain/
│   ├── Game.swift
│   ├── GameImageURLEncoder.swift
├── Features/
│   └── GameList/
│       ├── Domain/
│       │   ├── GamesLoader.swift
│       │   ├── GamesRefreshable.swift
│       │   └── GamesSaver.swift
│       └── Presentation/
│           ├── GamesListView.swift
│           └── GamesListViewModel.swift
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


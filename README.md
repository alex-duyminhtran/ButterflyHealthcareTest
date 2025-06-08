
**Implemented requirements:**
1. The app has two screens: a search screen and a details screen.
2. The search screen has a search bar that allows the user to search for movies, the results are displayed in a table view.
3. The table view displays the movie title, released date, and poster image for each row.
4. The details screen dislays additional information about the selected movie.
5. The app caches rearch results for offline use.
6. The happ has error handling and shows relevant alert to the user.

**Implemented bonus points:**
1. Implement pagination in the search results table view (srolling down to load more).
2. Add Unit tests for a view model.
3. Offline mode: the app can persist the data previously fetched and the user can search for cached movies when the app is opened in offline mode.

**Used approaches:**
1. Swift, UIKit, Xcode 16.1
2. Architeture: MVVM.
3. Programatic UI.
4. Third party package: Reachability - https://github.com/ashleymills/Reachability.swift
5. Caching movies: Core Data.
6. Caching images: NSCache (in memory) and UserDefaults (device).

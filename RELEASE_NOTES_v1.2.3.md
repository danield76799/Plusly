# Plusly v1.2.3 - Release Notes

## What's New

### ⭐ Favorites Feature
- **Save messages as favorites** - Long press on any message and select "⭐ Save as Favorite"
- **Favorites tab** - New "⭐ Favorites" tab in the bottom navigation
- **View favorites** - See all your saved messages organized by sender
- **Open from favorites** - Tap any favorite to jump directly to that message in the chat timeline
- **Search favorites** - Search through your saved messages
- **Delete favorites** - Remove messages from your favorites list

### 🎨 UI Improvements
- **Pixel-perfect Favorites UI** - Matches the reference design exactly
- **Plusly branding** - All colors optimized to match Plusly guidelines (#49AFC2)
- **Dark theme** - Anthracite gray background (#333333) with subtle card depth
- **Compact layout** - Optimized spacing between favorite items
- **Single FAB** - Only one Floating Action Button (on chat list)

### 🐛 Bug Fixes
- **Fixed SQLite crash** - Removed duplicate FAB that caused instability
- **Fixed scroll to message** - Correct query parameter for navigation
- **Fixed compile errors** - All switch cases properly handled

## Technical Details
- Uses SharedPreferences for local storage of favorites
- Efficient caching for better performance
- Error handling for robust operation

## Version Info
- **Version:** 1.2.3
- **Build:** 867
- **Date:** 2026-05-18

---

Happy chatting! 💬⭐

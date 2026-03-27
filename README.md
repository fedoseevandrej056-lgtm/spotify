# Spotify Music Player - Flutter iOS App

A modern, feature-rich music player application for iOS built with Flutter, inspired by Spotify's design and user experience.

## Features

✨ **Core Features**
- Play music files from your device
- Import songs from various sources
- Playlist management
- Queue management
- Now Playing screen with full-screen player
- Mini player for quick control
- Shuffle and repeat modes

🎨 **UI/UX**
- Spotify-inspired dark theme
- Smooth animations and transitions
- Responsive design for all iOS devices
- Beautiful album artwork display
- Intuitive music controls

⚙️ **Technical Features**
- Uses `just_audio` for reliable audio playback
- Provider for state management
- Local file system integration
- iOS background audio support

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   ├── song_model.dart      # Song data model
│   └── playlist_model.dart  # Playlist data model
├── services/
│   ├── audio_player_service.dart     # Audio playback service
│   └── music_library_service.dart    # Music library management
├── screens/
│   ├── home_screen.dart     # Main library screen
│   └── now_playing_screen.dart # Full player screen
├── widgets/
│   ├── mini_player.dart     # Mini player widget
│   ├── song_tile.dart       # Song list item
│   └── player_controls.dart # Playback controls
└── utils/
    ├── theme.dart           # Spotify theme configuration
    └── formatters.dart      # Utility formatters
```

## Getting Started

### Prerequisites
- Flutter SDK: 3.0.0 or higher
- iOS 11.0 or higher
- Xcode 14.0 or higher

### Installation

1. **Clone or create the project**
   ```bash
   cd spotify_music_player
   flutter pub get
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure iOS**
   ```bash
   cd ios
   pod install
   cd ..
   ```

4. **Run the app**
   ```bash
   flutter run -d ios
   ```

## Dependencies

The app uses the following main packages:

- **provider**: State management
- **just_audio**: High-quality audio playback
- **file_picker**: File selection and import
- **path_provider**: Access to device directories
- **audio_session**: Audio session management
- **intl**: Date and time formatting
- **shimmer**: Loading animations
- **flutter_slidable**: Swipe actions

See `pubspec.yaml` for complete dependency list.

## iOS Configuration

### Info.plist Settings
The app includes the following iOS permissions:

- **Apple Music Usage**: Access to music library
- **Local Network**: For audio streaming
- **Audio Background Mode**: Background playback
- **File Sharing**: Document directory access

### Capabilities
- Audio Playback (Background Modes)
- Document Sharing (File:// URLs)

## Usage

### Importing Music

1. Tap the **Add** button in the music library
2. Select audio files from your device
3. Songs will be imported and organized in the library

### Playing Music

1. **From Library**: Tap any song to start playback
2. **Mini Player**: Use controls in the mini player at the bottom
3. **Full Player**: Tap the mini player to open the full Now Playing screen

### Controls

- **Play/Pause**: Tap the circular play button
- **Next/Previous**: Use skip buttons
- **Seek**: Drag the progress slider
- **Shuffle/Repeat**: Toggle buttons (functionality can be extended)

## Customization

### Changing Theme Colors
Edit `lib/utils/theme.dart`:
```dart
static const Color primaryColor = Color(0xFF1DB954); // Change this
```

### Adding Features
- **Equalizer**: Use audio plugin for EQ
- **Lyrics**: Integrate lyrics API
- **Social Sharing**: Add share functionality
- **Cloud Sync**: Implement Firebase backend

## Troubleshooting

### Audio Not Playing
- Check if audio files are in correct format (MP3, M4A, WAV, AAC)
- Verify file permissions in iOS settings
- Ensure app has access to Documents directory

### Build Issues
1. Clean build:
   ```bash
   flutter clean
   flutter pub get
   ```

2. Update pods:
   ```bash
   cd ios
   rm -rf Pods Pod.lock
   pod install
   cd ..
   ```

3. Run on device:
   ```bash
   flutter run -d ios --verbose
   ```

## Performance Tips

- Pre-load playlists for faster switching
- Use local caching for frequently played songs
- Optimize image assets for better performance

## Future Enhancements

- [ ] Dark/Light theme toggle
- [ ] Custom EQ settings
- [ ] Lyrics display
- [ ] Social sharing integration
- [ ] Cloud backup
- [ ] Playback speed control
- [ ] Sleep timer
- [ ] Statistics dashboard

## Testing

To test the app:

1. Import test audio files
2. Test playback controls
3. Verify background audio
4. Check file import functionality
5. Test on physical iOS device

## Known Limitations

- Audio metadata extraction requires external library integration
- Background playback needs additional permissions on iOS
- File import is limited to app document directory

## Support & Contact

For issues and feature requests, contact the development team.

## License

This project is provided as-is for educational and personal use.

---

**Version**: 1.0.0  
**Last Updated**: March 2026  
**Flutter Version**: 3.0.0+

# 🎯 Mispelt - A Fun Spelling Game

A Flutter-based spelling game with multiple engaging game modes, designed for web, Android, and iOS platforms.

## ✨ Features

### 🎮 Game Modes

1. **📅 Daily Challenge**
   - 10 words per day, same for everyone
   - Play once per day
   - Track your daily streak
   - Leaderboard based on score and time

2. **⏱️ Time Attack**
   - 60 seconds to get as many words right as possible
   - One mistake ends the game
   - Fast-paced, adrenaline-pumping gameplay

3. **♾️ Endless Survival**
   - How far can you go?
   - Choose between 1 life (sudden death) or 3 lives
   - Endless word supply
   - Test your spelling endurance

### 🎯 Gameplay

- **👆 Swipe Controls**: Swipe left for incorrect, swipe right for correct
- **🔘 Button Controls**: Tap buttons for those who prefer traditional controls
- **✨ Visual Feedback**: Cards shake for wrong answers, glow for correct ones
- **🔊 Audio Feedback**: Sound effects for correct/incorrect answers (optional)
- **📊 Progress Tracking**: Real-time score, lives, and timer display

### 🎨 Design

- **🎨 Color Scheme**: Dictionary-inspired with a playful touch
  - Text: #1F1F1F
  - Primary: #D6C6A8
  - Highlight 1: #A45A3D
  - Highlight 2: #7B5B3A
  - Secondary: #E4CDAF
- **📱 Mobile-First**: Optimized for mobile with responsive design
- **🃏 Card-Based UI**: Flash card inspired elements with smooth animations
- **📝 Clean Typography**: Easy-to-read fonts with proper contrast

### ✨ Features

- **📚 Word Database**: Curated list of commonly misspelled words
- **📈 Difficulty Levels**: Words ranked 1-5 for future challenge modes
- **🔥 Daily Streaks**: Track consecutive days of playing
- **📋 Detailed Results**: See all words played with correct/incorrect answers
- **📴 Offline Support**: Play without internet connection
- **🌐 Cross-Platform**: Works on web, Android, and iOS

## Getting Started

### Prerequisites

- Flutter SDK (3.7.0 or higher)
- Dart SDK
- Android Studio / VS Code
- Git

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/spelling_game.git
cd spelling_game
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Building for Production

**Web:**
```bash
flutter build web
```

**Android:**
```bash
flutter build apk
```

**iOS:**
```bash
flutter build ios
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── word.dart            # Word model with spelling variants
│   └── game_result.dart     # Game result and statistics
├── providers/               # State management
│   └── game_provider.dart   # Main game logic and state
├── screens/                 # UI screens
│   ├── home_screen.dart     # Main menu with game modes
│   ├── game_screen.dart     # Active gameplay screen
│   └── result_screen.dart   # Game results and statistics
├── widgets/                 # Reusable UI components
│   ├── word_card.dart       # Word display card
│   ├── game_controls.dart   # Control buttons
│   ├── game_header.dart     # Game progress header
│   ├── result_summary.dart  # Results summary card
│   └── word_attempt_list.dart # Word results list
├── services/                # Business logic
│   ├── word_service.dart    # Word database and selection
│   └── audio_service.dart   # Sound effects
└── utils/                   # Utilities
    └── constants.dart       # App constants and colors
```

## Dependencies

- **flutter**: Core Flutter framework
- **provider**: State management
- **audioplayers**: Sound effects
- **flutter_animate**: Smooth animations
- **shared_preferences**: Local data storage
- **intl**: Date and number formatting

## Future Enhancements

### Planned Features

1. **Firebase Integration**
   - User authentication
   - Leaderboards
   - Cloud word database
   - User profiles

2. **Additional Game Modes**
   - Challenge Mode (harder words)
   - Easy Mode (beginner-friendly)
   - Multiplayer mode

3. **Enhanced Features**
   - Custom word lists
   - Achievement system
   - Daily notifications
   - Social sharing

4. **Accessibility**
   - High contrast mode
   - Screen reader support
   - Haptic feedback options

### Technical Improvements

- **Performance**: Optimize animations and rendering
- **Testing**: Add unit and widget tests
- **CI/CD**: Automated testing and deployment
- **Analytics**: User behavior tracking

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Flutter team for the amazing framework
- Material Design for the design system
- The spelling game community for inspiration

---

**Note**: This is a demo version. For production use, you'll need to:
1. Set up Firebase for backend services
2. Add proper sound files
3. Configure app signing for mobile platforms
4. Add proper error handling and edge cases
5. Implement comprehensive testing

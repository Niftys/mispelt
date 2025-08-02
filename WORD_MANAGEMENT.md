# Word Database Management

This document explains how to manage the word database for the Spelling Game using the local JSON file system.

## 📁 File Structure

```
assets/
└── data/
    └── words.json    # Main word database file
```

## 🎯 How It Works

The app uses a **hybrid approach** for word management:

1. **Local JSON File**: `assets/data/words.json` contains all words
2. **Firestore Database**: Words are synced to Firestore for online access
3. **Fallback System**: If Firestore is unavailable, the app uses the local JSON file

## 📝 Managing Words

### Adding New Words

Edit `assets/data/words.json` and add new word objects:

```json
{
  "correctSpelling": "accommodate",
  "misspellings": ["accomodate", "accomadate", "accomodate"],
  "difficulty": 4,
  "definition": "To provide lodging or space for someone or something"
}
```

### Word Object Structure

- **`correctSpelling`**: The correct spelling of the word
- **`misspellings`**: Array of common misspellings (3-5 variations)
- **`difficulty`**: Number from 1-5 (1=easy, 5=expert)
- **`definition`**: Optional definition of the word

### Difficulty Levels

- **1**: Easy words (e.g., "beautiful", "different")
- **2**: Medium words (e.g., "accommodate", "embarrass")
- **3**: Harder words (e.g., "environment", "knowledge")
- **4**: Very hard words (e.g., "responsibility", "communication")
- **5**: Expert words (e.g., "pseudopseudohypoparathyroidism")

## 🔄 Syncing to Firestore

### Using the Admin Panel

1. **Access Admin Panel**: In debug mode, tap "Admin Panel" on the home screen
2. **Sync Words**: Tap "Sync Words to Firestore" to upload your JSON words
3. **Clear Cache**: Tap "Clear Word Cache" if you need to reload from JSON

### Manual Sync

You can also sync programmatically:

```dart
await WordService.syncWordsToFirestore();
```

## 🎮 Game Modes and Word Selection

### Daily Challenge
- **10 words per day**
- **Seeded random selection** (same words for everyone on the same day)
- **Mix of difficulties**

### Time Attack
- **50 words** (more than needed for 60 seconds)
- **Random selection**
- **Mix of difficulties**

### Endless Survival
- **100 words initially**
- **More words added** as player progresses
- **Mix of difficulties**

## 📊 Word Statistics

The current database includes:
- **30 sample words** with varying difficulties
- **Common misspellings** for each word
- **Definitions** for educational value

## 🔧 Technical Details

### Caching
- Words are cached in memory after first load
- Use `WordService.clearCache()` to reload from JSON
- Cache is automatically cleared when syncing to Firestore

### Error Handling
- If JSON file is corrupted, app falls back to sample words
- If Firestore is unavailable, app uses local JSON
- Graceful degradation ensures app always works

### Performance
- JSON file is loaded once and cached
- Firestore queries are optimized with batching
- Minimal network usage for word retrieval

## 🚀 Best Practices

### Adding Words
1. **Use realistic misspellings** that people actually make
2. **Vary difficulty levels** for balanced gameplay
3. **Include definitions** for educational value
4. **Test misspellings** to ensure they're believable

### Maintaining Quality
1. **Regularly review** and update misspellings
2. **Balance difficulty distribution**
3. **Keep definitions accurate** and concise
4. **Test with real users** to identify common mistakes

### Performance Tips
1. **Keep JSON file under 1MB** for fast loading
2. **Use consistent formatting** for easy editing
3. **Backup your JSON file** before major changes
4. **Test sync functionality** regularly

## 🐛 Troubleshooting

### Common Issues

**Words not updating after JSON change:**
- Clear the cache using the admin panel
- Restart the app

**Firestore sync fails:**
- Check Firebase configuration
- Verify internet connection
- Check Firestore security rules

**App crashes on word load:**
- Validate JSON syntax
- Check for missing required fields
- Ensure all arrays have valid content

### Validation

The app validates word objects and will skip invalid entries. Ensure each word has:
- ✅ Valid `correctSpelling` (non-empty string)
- ✅ Valid `misspellings` array (non-empty, all strings)
- ✅ Valid `difficulty` (integer 1-5)
- ✅ Optional `definition` (string or null)

## 📈 Future Enhancements

Potential improvements for word management:
- **Word categories** (academic, business, casual)
- **Difficulty auto-calculation** based on word length/complexity
- **User-submitted misspellings** collection
- **A/B testing** different word sets
- **Analytics** on which words are most challenging 
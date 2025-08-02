#!/usr/bin/env python3
"""
Validation script to check that no duplicate words exist between correct spellings and misspellings.
"""

import json
import os

def validate_no_duplicates(file_path: str) -> bool:
    """Validate that no misspellings are also correct spellings."""
    print(f"🔍 Validating {file_path}...")
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
    except Exception as e:
        print(f"❌ Error loading {file_path}: {e}")
        return False
    
    words = data.get('words', [])
    if not words:
        print("❌ No words found!")
        return False
    
    print(f"📖 Loaded {len(words)} words")
    
    # Collect all correct spellings
    correct_spellings = set()
    for word in words:
        correct_spellings.add(word['correctSpelling'].lower())
    
    print(f"📝 Found {len(correct_spellings)} unique correct spellings")
    
    # Check for duplicates
    duplicates_found = []
    total_misspellings = 0
    
    for word in words:
        for misspelling in word['misspellings']:
            total_misspellings += 1
            if misspelling.lower() in correct_spellings:
                duplicates_found.append({
                    'word': word['correctSpelling'],
                    'duplicate_misspelling': misspelling
                })
    
    print(f"🔤 Total misspellings checked: {total_misspellings}")
    
    if duplicates_found:
        print(f"❌ Found {len(duplicates_found)} duplicates:")
        for dup in duplicates_found:
            print(f"   '{dup['word']}' has misspelling '{dup['duplicate_misspelling']}' which is also a correct spelling")
        return False
    else:
        print("✅ No duplicates found! Word list is clean.")
        return True

def main():
    """Main validation function."""
    print("🔍 Word Duplicate Validator")
    print("=" * 40)
    
    file_path = 'assets/data/words_combined.json'
    
    if not os.path.exists(file_path):
        print(f"❌ Error: {file_path} not found!")
        return
    
    is_valid = validate_no_duplicates(file_path)
    
    if is_valid:
        print("\n🎉 Validation passed! Your word list is clean.")
    else:
        print("\n⚠️  Validation failed! Duplicates found.")

if __name__ == "__main__":
    main() 
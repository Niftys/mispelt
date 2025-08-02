#!/usr/bin/env python3
"""
Script to remove duplicate words between correct spellings and misspellings.
This ensures that no misspelling appears as a correct spelling elsewhere in the list.
"""

import json
import os
from typing import Dict, List, Set

def load_words(file_path: str) -> Dict:
    """Load words from JSON file."""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            return json.load(f)
    except Exception as e:
        print(f"❌ Error loading {file_path}: {e}")
        return {"words": []}

def save_words(data: Dict, file_path: str) -> bool:
    """Save words to JSON file."""
    try:
        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
        return True
    except Exception as e:
        print(f"❌ Error saving {file_path}: {e}")
        return False

def find_duplicates(words: List[Dict]) -> Dict:
    """Find duplicates between correct spellings and misspellings."""
    print("🔍 Checking for duplicates...")
    
    # Collect all correct spellings
    correct_spellings = set()
    for word in words:
        correct_spellings.add(word['correctSpelling'].lower())
    
    # Find misspellings that are also correct spellings
    duplicates = {}
    total_duplicates = 0
    
    for word in words:
        word_duplicates = []
        for misspelling in word['misspellings']:
            if misspelling.lower() in correct_spellings:
                word_duplicates.append(misspelling)
                total_duplicates += 1
        
        if word_duplicates:
            duplicates[word['correctSpelling']] = word_duplicates
    
    return duplicates, total_duplicates

def remove_duplicates(words: List[Dict]) -> tuple[List[Dict], int]:
    """Remove duplicate misspellings from words."""
    print("🧹 Removing duplicates...")
    
    # Collect all correct spellings
    correct_spellings = set()
    for word in words:
        correct_spellings.add(word['correctSpelling'].lower())
    
    # Remove duplicates from misspellings
    removed_count = 0
    cleaned_words = []
    
    for word in words:
        cleaned_word = word.copy()
        original_misspellings = word['misspellings'].copy()
        
        # Filter out misspellings that are also correct spellings
        cleaned_misspellings = []
        for misspelling in original_misspellings:
            if misspelling.lower() not in correct_spellings:
                cleaned_misspellings.append(misspelling)
            else:
                removed_count += 1
        
        cleaned_word['misspellings'] = cleaned_misspellings
        cleaned_words.append(cleaned_word)
    
    return cleaned_words, removed_count

def validate_words(words: List[Dict]) -> bool:
    """Validate that no duplicates remain."""
    print("✅ Validating cleaned words...")
    
    # Collect all correct spellings
    correct_spellings = set()
    for word in words:
        correct_spellings.add(word['correctSpelling'].lower())
    
    # Check for any remaining duplicates
    for word in words:
        for misspelling in word['misspellings']:
            if misspelling.lower() in correct_spellings:
                print(f"❌ Found remaining duplicate: '{misspelling}' in '{word['correctSpelling']}'")
                return False
    
    return True

def main():
    """Main function to clean word duplicates."""
    print("🔄 Word Duplicate Cleaner")
    print("=" * 50)
    
    # File paths
    input_file = 'assets/data/words_combined.json'
    backup_file = 'assets/data/words_combined_backup.json'
    
    # Check if input file exists
    if not os.path.exists(input_file):
        print(f"❌ Error: {input_file} not found!")
        return
    
    # Load words
    print(f"📖 Loading words from {input_file}...")
    data = load_words(input_file)
    words = data.get('words', [])
    
    if not words:
        print("❌ No words found in file!")
        return
    
    print(f"✅ Loaded {len(words)} words")
    
    # Find duplicates
    duplicates, total_duplicates = find_duplicates(words)
    
    if not duplicates:
        print("✅ No duplicates found! Your word list is clean.")
        return
    
    # Show duplicates found
    print(f"\n📊 Found {total_duplicates} duplicate misspellings:")
    for correct_spelling, duplicate_misspellings in duplicates.items():
        print(f"   '{correct_spelling}': {duplicate_misspellings}")
    
    # Create backup
    print(f"\n💾 Creating backup at {backup_file}...")
    if not save_words(data, backup_file):
        print("❌ Failed to create backup. Aborting.")
        return
    
    # Remove duplicates
    cleaned_words, removed_count = remove_duplicates(words)
    
    # Validate
    if not validate_words(cleaned_words):
        print("❌ Validation failed! Duplicates still remain.")
        return
    
    # Update data
    data['words'] = cleaned_words
    
    # Save cleaned words
    print(f"\n💾 Saving cleaned words to {input_file}...")
    if save_words(data, input_file):
        print(f"✅ Successfully removed {removed_count} duplicate misspellings!")
        print(f"✅ Cleaned word list has {len(cleaned_words)} words")
        print(f"✅ Backup saved at {backup_file}")
    else:
        print("❌ Failed to save cleaned words!")

if __name__ == "__main__":
    main() 
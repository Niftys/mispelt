import json
import os
import time
import requests
import random
from datetime import datetime, timedelta

def check_word_with_api_sync(word, max_retries=3):
    """
    Synchronous version for compatibility
    """
    url = f"https://api.dictionaryapi.dev/api/v2/entries/en/{word}"
    
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        'Accept': 'application/json',
        'Accept-Language': 'en-US,en;q=0.9',
    }
    
    for attempt in range(max_retries):
        try:
            response = requests.get(url, headers=headers, timeout=10)
            
            if response.status_code == 200:
                data = response.json()
                definition = ""
                if data and len(data) > 0:
                    meanings = data[0].get('meanings', [])
                    if meanings and len(meanings) > 0:
                        definitions = meanings[0].get('definitions', [])
                        if definitions and len(definitions) > 0:
                            definition = definitions[0].get('definition', "")
                return True, definition
            elif response.status_code == 404:
                return False, ""
            elif response.status_code == 429:
                print(f"Rate limited (429) for '{word}' - waiting 5 minutes...")
                time.sleep(300)
                continue
            else:
                if attempt < max_retries - 1:
                    time.sleep(2 ** attempt)
                continue
                
        except Exception as e:
            if attempt < max_retries - 1:
                time.sleep(2 ** attempt)
            continue
    
    return None, None



def process_batch_optimized(words_batch, batch_num, total_batches):
    """
    Process a batch of words with optimized sequential processing
    """
    print(f"\n--- Processing Batch {batch_num}/{total_batches} ({len(words_batch)} words) ---")
    
    valid_words = []
    invalid_words = []
    api_errors = []
    
    for i, word_obj in enumerate(words_batch):
        word = word_obj.get('correctSpelling', '').lower()
        
        if not word:
            continue
        
        print(f"[{batch_num}/{total_batches}] {i+1}/{len(words_batch)}: {word}", end=" ")
        
        # Check with API
        result, definition = check_word_with_api_sync(word)
        
        if result is True:
            word_obj["definition"] = definition
            valid_words.append(word_obj)
            print(f"✓ Valid - {definition[:40]}{'...' if len(definition) > 40 else ''}")
        elif result is False:
            invalid_words.append(word)
            print("✗ Invalid")
        else:
            api_errors.append(word)
            print("? API Error (keeping word)")
        
        # Optimized rate limiting - stay just under the limit
        # 450 requests per 5 minutes = 90 per minute = 1.5 per second
        # We'll use 0.8 seconds to stay safely under the limit
        delay = 0.8 + random.uniform(0, 0.2)  # 0.8-1.0 second delay
        time.sleep(delay)
    
    return valid_words, invalid_words, api_errors



def validate_words_optimized():
    """
    Optimized validation using sequential processing with smart rate limiting
    """
    print("Starting Free Dictionary API validation with optimized sequential processing...")
    print("This will check each word against a real dictionary API")
    print("Rate limit: 450 requests per 5 minutes")
    print("Using optimized sequential processing for maximum reliability")
    print()
    
    # Process each level file
    for level in range(1, 6):
        filename = f'assets/data/words_level{level}.json'
        
        if not os.path.exists(filename):
            print(f"Warning: {filename} not found, skipping...")
            continue
        
        print(f"\n=== Processing Level {level} ===")
        
        # Load the level file
        try:
            with open(filename, 'r') as f:
                data = json.load(f)
                words = data.get('words', [])
        except Exception as e:
            print(f"Error loading {filename}: {e}")
            continue
        
        print(f"Loaded {len(words)} words from {filename}")
        
        # Optimized batch size - smaller batches for better rate limit management
        batch_size = 100  # Larger batches since we're not using concurrency
        batches = [words[i:i + batch_size] for i in range(0, len(words), batch_size)]
        total_batches = len(batches)
        
        print(f"Split into {total_batches} batches of ~{batch_size} words each")
        
        all_valid_words = []
        all_invalid_words = []
        all_api_errors = []
        
        for batch_num, words_batch in enumerate(batches, 1):
            start_time = datetime.now()
            
            valid_words, invalid_words, api_errors = process_batch_optimized(
                words_batch, batch_num, total_batches
            )
            
            all_valid_words.extend(valid_words)
            all_invalid_words.extend(invalid_words)
            all_api_errors.extend(api_errors)
            
            end_time = datetime.now()
            batch_duration = end_time - start_time
            
            print(f"\nBatch {batch_num} completed in {batch_duration}")
            print(f"  Valid: {len(valid_words)}, Invalid: {len(invalid_words)}, Errors: {len(api_errors)}")
            
            # Short break between batches
            if batch_num < total_batches:
                wait_time = 3  # 3 second break between batches
                print(f"Waiting {wait_time} seconds before next batch...")
                time.sleep(wait_time)
        
        print(f"\nLevel {level} Final Results:")
        print(f"  Valid words: {len(all_valid_words)}")
        print(f"  Invalid words: {len(all_invalid_words)}")
        print(f"  API errors: {len(all_api_errors)}")
        
        if all_invalid_words:
            print(f"  Invalid words: {', '.join(all_invalid_words[:10])}{'...' if len(all_invalid_words) > 10 else ''}")
        
        if all_api_errors:
            print(f"  API errors: {', '.join(all_api_errors[:5])}{'...' if len(all_api_errors) > 5 else ''}")
        
        # Save validated words back to file
        validated_data = {
            "words": all_valid_words,
            "level": level,
            "count": len(all_valid_words),
            "original_count": len(words),
            "invalid_count": len(all_invalid_words),
            "api_errors": len(all_api_errors)
        }
        
        # Create backup of original file
        backup_filename = f'assets/data/words_level{level}_backup.json'
        try:
            with open(backup_filename, 'w') as f:
                json.dump(data, f, indent=2)
            print(f"  Original file backed up to {backup_filename}")
        except Exception as e:
            print(f"  Warning: Could not create backup: {e}")
        
        # Save validated file
        try:
            with open(filename, 'w') as f:
                json.dump(validated_data, f, indent=2)
            print(f"  Updated {filename} with {len(all_valid_words)} valid words")
        except Exception as e:
            print(f"  Error saving {filename}: {e}")
    
    # Update combined file
    print("\n=== Updating Combined File ===")
    all_words = []
    
    for level in range(1, 6):
        filename = f'assets/data/words_level{level}.json'
        if os.path.exists(filename):
            try:
                with open(filename, 'r') as f:
                    data = json.load(f)
                    all_words.extend(data.get('words', []))
            except Exception as e:
                print(f"Error loading {filename}: {e}")
    
    combined_data = {
        "words": all_words,
        "total_count": len(all_words)
    }
    
    try:
        with open('assets/data/words_combined.json', 'w') as f:
            json.dump(combined_data, f, indent=2)
        print(f"Updated combined file with {len(all_words)} total words")
    except Exception as e:
        print(f"Error saving combined file: {e}")
    
    print("\nValidation complete!")

def test_api_connection():
    """
    Test the API connection with a known word
    """
    print("Testing API connection...")
    
    test_word = "hello"
    result, definition = check_word_with_api_sync(test_word)
    
    if result is True:
        print(f"✓ API working - '{test_word}' is valid")
        print(f"  Definition: {definition}")
        return True
    elif result is False:
        print(f"✗ API working but '{test_word}' not found (unexpected)")
        return False
    else:
        print(f"✗ API connection failed")
        return False

def main():
    print("Free Dictionary API Word Validator & Definition Fetcher (Optimized Version)")
    print("This script uses the Free Dictionary API to validate words AND get definitions")
    print("API: https://api.dictionaryapi.dev/")
    print("Rate limit: 450 requests per 5 minutes")
    print("Features: Optimized sequential processing, smart rate limiting, maximum reliability")
    print()
    
    # Check if requests is available
    try:
        import requests
        print("✓ Requests library is available")
    except ImportError:
        print("✗ Requests library not found!")
        print("Please install it with: pip install requests")
        return
    
    # Test API connection first
    if not test_api_connection():
        print("API connection failed. Please check your internet connection.")
        return
    
    # Check if level files exist
    files_exist = False
    for level in range(1, 6):
        filename = f'assets/data/words_level{level}.json'
        if os.path.exists(filename):
            files_exist = True
            break
    
    if not files_exist:
        print("✗ No level JSON files found!")
        print("Please run the parse_dictionary_better.py script first")
        return
    
    print("✓ Level JSON files found")
    print()
    
    # Confirm before starting
    print("This will make API calls for each word in your files.")
    print("With 500 words per level, this will be ~2,500 API calls.")
    print("The API has a limit of 450 requests per 5 minutes.")
    print("Each valid word will also get its definition from the dictionary!")
    print("Using optimized sequential processing for maximum reliability.")
    print("Processing in batches of 100 words with 0.8-1.0 second delays.")
    print("Total processing time: approximately 1.5-2 hours (reliable and efficient).")
    print()
    
    response = input("Continue? (y/n): ").lower().strip()
    if response != 'y':
        print("Cancelled.")
        return
    
    # Start validation
    validate_words_optimized()

if __name__ == "__main__":
    main() 
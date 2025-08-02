import json
import re
import os
import random  # Added for random selection

def create_builtin_word_list():
    """
    Create a comprehensive list of common English words
    """
    common_words = {
        # Common 3-letter words
        'the', 'and', 'for', 'are', 'but', 'not', 'you', 'all', 'can', 'had', 'her', 'was', 'one', 'our', 'out', 'day', 'get', 'has', 'him', 'his', 'how', 'man', 'new', 'now', 'old', 'see', 'two', 'way', 'who', 'boy', 'did', 'its', 'let', 'put', 'say', 'she', 'too', 'use',
        
        # Common 4-letter words
        'that', 'with', 'have', 'this', 'will', 'your', 'from', 'they', 'know', 'want', 'been', 'good', 'much', 'some', 'time', 'very', 'when', 'come', 'here', 'just', 'like', 'long', 'make', 'many', 'over', 'such', 'take', 'than', 'them', 'well', 'were',
        
        # Common 5-letter words
        'about', 'after', 'again', 'could', 'every', 'first', 'found', 'great', 'house', 'large', 'might', 'never', 'other', 'place', 'right', 'small', 'sound', 'still', 'their', 'there', 'these', 'think', 'three', 'under', 'water', 'where', 'which', 'world', 'would', 'write',
        
        # Common 6-letter words
        'before', 'better', 'between', 'change', 'family', 'father', 'friend', 'ground', 'letter', 'mother', 'myself', 'number', 'people', 'picture', 'should', 'something', 'through', 'together', 'without', 'always', 'around', 'because', 'before', 'country', 'course', 'during', 'enough', 'example', 'follow', 'happen', 'important', 'interest', 'little', 'moment', 'nothing', 'perhaps', 'person', 'question', 'really', 'second', 'should', 'something', 'sometimes', 'through', 'together', 'without',
        
        # Common 7+ letter words
        'another', 'because', 'between', 'country', 'example', 'important', 'interest', 'language', 'mountain', 'question', 'remember', 'sentence', 'something', 'sometimes', 'together', 'understand', 'different', 'everything', 'important', 'knowledge', 'necessary', 'sometimes', 'something', 'understand', 'beautiful', 'different', 'everything', 'important', 'knowledge', 'necessary', 'sometimes', 'something', 'understand'
    }
    
    return common_words

def is_real_word_better(word):
    """
    Better validation that catches more nonsense words
    """
    word = word.lower().strip()
    
    # Get common words for validation
    common_words = create_builtin_word_list()
    
    # Check against common words first (fast)
    if word in common_words:
        return True
    
    # More aggressive nonsense patterns
    nonsense_patterns = [
        r'^[aeiou]{2,}$',  # All vowels (aa, aaa, etc.)
        r'^[bcdfghjklmnpqrstvwxyz]{4,}$',  # All consonants
        r'^([a-z])\1{2,}$',  # Repeated letters (aaa, bbb, etc.)
        r'^[a-z]{1,4}$',  # Too short (now 5+ letters minimum)
        r'^[a-z]{16,}$',  # Too long
        r'^[aeiou][bcdfghjklmnpqrstvwxyz][aeiou]$',  # Vowel-consonant-vowel patterns that are often nonsense
        r'^[bcdfghjklmnpqrstvwxyz][aeiou][bcdfghjklmnpqrstvwxyz]$',  # Consonant-vowel-consonant patterns that are often nonsense
        r'^[aeiou]{3,}[bcdfghjklmnpqrstvwxyz]*$',  # Too many vowels at start
        r'^[bcdfghjklmnpqrstvwxyz]*[aeiou]{3,}$',  # Too many vowels at end
    ]
    
    for pattern in nonsense_patterns:
        if re.match(pattern, word):
            return False
    
    # Check for reasonable vowel-consonant ratio
    vowels = len(re.findall(r'[aeiou]', word))
    consonants = len(re.findall(r'[bcdfghjklmnpqrstvwxyz]', word))
    
    # Words should have a reasonable vowel-consonant ratio
    if consonants > 0 and vowels > 0:
        ratio = vowels / consonants
        if ratio < 0.2 or ratio > 3.0:  # Too few or too many vowels
            return False
    
    # Check for common word patterns
    common_patterns = [
        r'^[a-z]{5,15}$',  # Reasonable length (5+ letters minimum)
        r'[aeiouy]',  # Contains at least one vowel
        r'[bcdfghjklmnpqrstvwxyz]',  # Contains at least one consonant
    ]
    
    for pattern in common_patterns:
        if not re.search(pattern, word):
            return False
    
    # Additional checks for 5-letter words (minimum length now)
    if len(word) == 5:
        # Check if it follows common English patterns
        if not re.match(r'^[bcdfghjklmnpqrstvwxyz][aeiou][bcdfghjklmnpqrstvwxyz][aeiou][bcdfghjklmnpqrstvwxyz]$', word):
            return False
    
    return True

def is_good_word(word):
    """
    Check if a word is suitable for the game
    """
    word = word.lower().strip()
    
    # Must be 5-15 characters (removed words under 5 letters)
    if len(word) < 5 or len(word) > 15:
        return False
    
    # Only letters, no numbers, hyphens, apostrophes
    if not re.match(r'^[a-z]+$', word):
        return False
    
    # Skip common problematic words
    skip_words = {
        'a', 'an', 'the', 'and', 'or', 'but', 'in', 'on', 'at', 'to', 'for',
        'of', 'with', 'by', 'is', 'are', 'was', 'were', 'be', 'been', 'being',
        'have', 'has', 'had', 'do', 'does', 'did', 'will', 'would', 'could',
        'should', 'may', 'might', 'can', 'must', 'shall'
    }
    
    if word in skip_words:
        return False
    
    # Check if it's a real word
    if not is_real_word_better(word):
        return False
    
    return True

def get_difficulty(word):
    """
    Simple difficulty calculation based on length
    """
    length = len(word)
    
    if length == 5:
        return 1
    elif length <= 7:
        return 2
    elif length <= 9:
        return 3
    elif length <= 12:
        return 4
    else:
        return 5

def create_simple_misspellings(word):
    """
    Create simple but realistic misspellings
    """
    misspellings = []
    
    # Common patterns
    if 'ie' in word:
        misspellings.append(word.replace('ie', 'ei'))
    if 'ei' in word:
        misspellings.append(word.replace('ei', 'ie'))
    
    # Double letter variations
    for i in range(len(word) - 1):
        if word[i] == word[i + 1]:
            # Remove double letter
            misspelling = word[:i] + word[i+1:]
            if len(misspelling) >= 3:
                misspellings.append(misspelling)
            break
    
    # Add/remove final 'e'
    if word.endswith('e'):
        misspellings.append(word[:-1])
    else:
        misspellings.append(word + 'e')
    
    # Ensure we have at least 2 misspellings
    while len(misspellings) < 2:
        # Simple vowel change
        for i, char in enumerate(word):
            if char in 'aeiou':
                for vowel in 'aeiou':
                    if vowel != char:
                        new_word = word[:i] + vowel + word[i+1:]
                        if new_word not in misspellings and new_word != word:
                            misspellings.append(new_word)
                            break
                break
        break
    
    return list(set(misspellings))[:3]

def main():
    print("Starting better dictionary parsing with random selection...")
    
    # Check if dictionary file exists
    dict_file = 'assets/data/words_dictionary.json'
    if not os.path.exists(dict_file):
        print(f"Error: {dict_file} not found!")
        return
    
    # Load dictionary
    try:
        with open(dict_file, 'r') as f:
            print("Loading dictionary file...")
            word_dict = json.load(f)
        print(f"Loaded {len(word_dict)} words")
    except Exception as e:
        print(f"Error loading dictionary: {e}")
        return
    
    # Organize words by difficulty
    levels = {1: [], 2: [], 3: [], 4: [], 5: []}
    
    print("Processing and validating words...")
    processed = 0
    valid_words = 0
    
    for word in word_dict.keys():
        if is_good_word(word):
            difficulty = get_difficulty(word)
            levels[difficulty].append(word.lower())
            valid_words += 1
        
        processed += 1
        if processed % 1000 == 0:
            print(f"Processed {processed} words, found {valid_words} valid words...")
    
    print(f"Total valid words found: {valid_words}")
    
    # Print available words per level
    for level in range(1, 6):
        print(f"Level {level}: {len(levels[level])} words available")
    
    # Create word objects for each level with RANDOM selection
    word_objects = {1: [], 2: [], 3: [], 4: [], 5: []}
    
    # Target counts for each level (increased to 500 each)
    targets = {1: 500, 2: 500, 3: 500, 4: 500, 5: 500}
    
    print("Creating word objects with random selection...")
    for level in range(1, 6):
        available_words = levels[level]
        target_count = min(targets[level], len(available_words))
        
        # Randomly select words from throughout the entire level
        if len(available_words) > target_count:
            selected_words = random.sample(available_words, target_count)
        else:
            selected_words = available_words
        
        print(f"Level {level}: Randomly selected {len(selected_words)} words from {len(available_words)} available")
        
        for word in selected_words:
            misspellings = create_simple_misspellings(word)
            
            word_obj = {
                "correctSpelling": word,
                "misspellings": misspellings,
                "difficulty": level,
                "definition": ""
            }
            
            word_objects[level].append(word_obj)
    
    # Save individual level files
    print("Saving files...")
    for level in range(1, 6):
        filename = f'assets/data/words_level{level}.json'
        
        with open(filename, 'w') as f:
            json.dump({
                "words": word_objects[level],
                "level": level,
                "count": len(word_objects[level])
            }, f, indent=2)
        
        print(f"Saved {len(word_objects[level])} words to {filename}")
    
    # Create combined file
    all_words = []
    for level in range(1, 6):
        all_words.extend(word_objects[level])
    
    # Shuffle the combined list for even better randomization
    random.shuffle(all_words)
    
    with open('assets/data/words_combined.json', 'w') as f:
        json.dump({
            "words": all_words,
            "total_count": len(all_words)
        }, f, indent=2)
    
    print(f"Saved combined file with {len(all_words)} total words (shuffled)")
    print("Done!")

if __name__ == "__main__":
    main() 
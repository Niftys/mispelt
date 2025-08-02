import json
import os
import firebase_admin
from firebase_admin import credentials, firestore

def upload_words_to_firebase():
    """
    Upload words from words_combined.json to Firebase Firestore with change detection
    """
    print("Uploading words to Firebase Firestore...")
    
    # Check if words_combined.json exists
    if not os.path.exists('assets/data/words_combined.json'):
        print("❌ Error: assets/data/words_combined.json not found!")
        print("Please run the validation script first to generate the combined words file.")
        return
    
    # Load words from JSON
    try:
        with open('assets/data/words_combined.json', 'r') as f:
            data = json.load(f)
            words = data.get('words', [])
        print(f"✅ Loaded {len(words)} words from words_combined.json")
    except Exception as e:
        print(f"❌ Error loading words: {e}")
        return
    
    # Initialize Firebase
    try:
        if os.path.exists('firebase-service-account.json'):
            cred = credentials.Certificate('firebase-service-account.json')
            firebase_admin.initialize_app(cred)
            print("✅ Firebase initialized with service account key")
        else:
            firebase_admin.initialize_app()
            print("✅ Firebase initialized with default credentials")
    except Exception as e:
        print(f"❌ Error initializing Firebase: {e}")
        print("\nTo fix this, you need to:")
        print("1. Download your Firebase service account key from Firebase Console")
        print("2. Save it as 'firebase-service-account.json' in your project root")
        print("3. Or set up Firebase CLI and run 'firebase login'")
        return
    
    # Get Firestore client
    db = firestore.client()
    
    # Check existing words and detect changes
    print("🔍 Checking for existing words and changes...")
    existing_words = {}
    try:
        existing_docs = db.collection('words').stream()
        for doc in existing_docs:
            data = doc.to_dict()
            correct_spelling = data.get('correctSpelling', '').lower()
            if correct_spelling:
                existing_words[correct_spelling] = {
                    'doc_id': doc.id,
                    'data': data
                }
        print(f"📊 Found {len(existing_words)} existing words in Firestore")
    except Exception as e:
        print(f"⚠️ Warning: Could not check existing words: {e}")
        existing_words = {}
    
    # Analyze changes
    new_words = []
    updated_words = []
    unchanged_words = []
    
    for word_data in words:
        correct_spelling = word_data.get('correctSpelling', '').lower()
        if not correct_spelling:
            continue
            
        if correct_spelling in existing_words:
            existing_data = existing_words[correct_spelling]['data']
            # Check if data has changed
            if _has_changes(word_data, existing_data):
                updated_words.append({
                    'doc_id': existing_words[correct_spelling]['doc_id'],
                    'data': word_data
                })
            else:
                unchanged_words.append(correct_spelling)
        else:
            new_words.append(word_data)
    
    print(f"\n📈 Change Analysis:")
    print(f"   New words: {len(new_words)}")
    print(f"   Updated words: {len(updated_words)}")
    print(f"   Unchanged words: {len(unchanged_words)}")
    
    if len(unchanged_words) > 0:
        print(f"   Sample unchanged: {', '.join(unchanged_words[:5])}{'...' if len(unchanged_words) > 5 else ''}")
    
    if len(updated_words) > 0:
        print(f"   Sample updated: {', '.join([w['data']['correctSpelling'] for w in updated_words[:5]])}{'...' if len(updated_words) > 5 else ''}")
    
    if len(new_words) > 0:
        print(f"   Sample new: {', '.join([w['correctSpelling'] for w in new_words[:5]])}{'...' if len(new_words) > 5 else ''}")
    
    # Confirm changes
    if len(new_words) == 0 and len(updated_words) == 0:
        print("\n✅ No changes detected. All words are up to date!")
        return
    
    print(f"\nThis will:")
    if len(new_words) > 0:
        print(f"   - Add {len(new_words)} new words")
    if len(updated_words) > 0:
        print(f"   - Update {len(updated_words)} existing words")
    
    response = input("\nContinue with upload? (y/n): ").lower().strip()
    if response != 'y':
        print("Cancelled.")
        return
    
    # Upload changes
    try:
        print("\n📤 Uploading changes to Firestore...")
        batch = db.batch()
        
        # Add new words
        for i, word_data in enumerate(new_words):
            doc_ref = db.collection('words').document()
            batch.set(doc_ref, word_data)
            if (i + 1) % 25 == 0:
                print(f"   Added {i + 1}/{len(new_words)} new words...")
        
        # Update existing words
        for i, update_info in enumerate(updated_words):
            doc_ref = db.collection('words').document(update_info['doc_id'])
            batch.update(doc_ref, update_info['data'])
            if (i + 1) % 25 == 0:
                print(f"   Updated {i + 1}/{len(updated_words)} existing words...")
        
        # Commit the batch
        batch.commit()
        print(f"✅ Successfully uploaded changes to Firestore!")
        
    except Exception as e:
        print(f"❌ Error uploading words: {e}")
        return
    
    # Verify upload
    try:
        final_count = sum(1 for _ in db.collection('words').stream())
        print(f"✅ Verification: {final_count} total words in Firestore")
        
        expected_total = len(existing_words) + len(new_words)
        if final_count == expected_total:
            print("🎉 Upload successful! All changes have been applied.")
        else:
            print(f"⚠️ Warning: Expected {expected_total} words, but found {final_count}")
            
    except Exception as e:
        print(f"⚠️ Warning: Could not verify upload: {e}")

def _has_changes(new_data, existing_data):
    """
    Compare two word data objects to detect changes
    """
    # Check if any key fields have changed
    fields_to_check = ['correctSpelling', 'misspellings', 'definition', 'difficulty']
    
    for field in fields_to_check:
        new_value = new_data.get(field)
        existing_value = existing_data.get(field)
        
        # Handle lists (like misspellings)
        if isinstance(new_value, list) and isinstance(existing_value, list):
            if set(new_value) != set(existing_value):
                return True
        # Handle other types
        elif new_value != existing_value:
            return True
    
    return False

def main():
    print("Firebase Word Upload Script")
    print("This script uploads your validated words to Firebase Firestore")
    print()
    
    # Check if firebase-admin is available
    try:
        import firebase_admin
        print("✅ Firebase Admin SDK is available")
    except ImportError:
        print("❌ Firebase Admin SDK not found!")
        print("Please install it with: pip install firebase-admin")
        return
    
    # Confirm before uploading
    print("\nThis script will:")
    print("- Check for existing words in Firestore")
    print("- Detect changes (new words, updated definitions, etc.)")
    print("- Only upload what has changed")
    print("- Preserve existing words that haven't changed")
    print()
    
    # Upload words
    upload_words_to_firebase()

if __name__ == "__main__":
    main() 
import json
import random
import re

def generate_realistic_misspellings(word, difficulty):
    """
    Generate realistic misspellings with RANDOM selection of patterns
    """
    word = word.lower()
    misspellings = []
    
    # REAL common misspellings that people actually make
    common_misspellings = {
        # Very common mistakes
        'beautiful': ['beutiful', 'beautifull'],
        'definitely': ['definately', 'definatly'],
        'separate': ['seperate', 'seperat'],
        'receive': ['recieve', 'receeve'],
        'believe': ['beleive', 'belive'],
        'achieve': ['acheive', 'acheeve'],
        'because': ['becuase', 'beacuse'],
        'friend': ['freind', 'frend'],
        'business': ['buisness', 'busness'],
        'government': ['goverment', 'govermant'],
        'environment': ['enviroment', 'enviroment'],
        'necessary': ['neccessary', 'necesary'],
        'occasionally': ['ocassionally', 'ocasionally'],
        'successful': ['sucessful', 'succesful'],
        'embarrass': ['embarass', 'embarras'],
        'accommodate': ['accomodate', 'accomadate'],
        'recommend': ['reccomend', 'recomend'],
        'occurred': ['occured', 'ocurred'],
        'privilege': ['priviledge', 'privilige'],
        'maintenance': ['maintainance', 'maintenence'],
        'conscious': ['concious', 'consious'],
        'apparent': ['apparant', 'apparrent'],
        'argument': ['arguement', 'arguement'],
        'calendar': ['calender', 'calandar'],
        'category': ['catagory', 'catagory'],
        'cemetery': ['cemetary', 'cemetary'],
        'changeable': ['changable', 'changable'],
        'colleague': ['collegue', 'collegue'],
        'committed': ['comitted', 'comitted'],
        'committee': ['comittee', 'comittee'],
        'competition': ['compitition', 'compitition'],
        'convenient': ['convinient', 'convinient'],
        'criticism': ['criticisim', 'criticisim'],
        'curiosity': ['curiousity', 'curiousity'],
        'desperate': ['desparate', 'desparate'],
        'dictionary': ['dictionery', 'dictionery'],
        'disappear': ['dissapear', 'dissapear'],
        'exaggerate': ['exagerate', 'exagerate'],
        'excellent': ['excelent', 'excelent'],
        'existence': ['existance', 'existance'],
        'experience': ['experiance', 'experiance'],
        'familiar': ['familier', 'familier'],
        'fascinating': ['fasinating', 'fasinating'],
        'finally': ['finaly', 'finaly'],
        'foreign': ['foriegn', 'foriegn'],
        'foreseeable': ['forseeable', 'forseeable'],
        'forty': ['fourty', 'fourty'],
        'forward': ['forword', 'forword'],
        'further': ['farther', 'farther'],
        'grateful': ['greatful', 'greatful'],
        'guarantee': ['gaurantee', 'gaurantee'],
        'guard': ['gaurd', 'gaurd'],
        'guidance': ['guidence', 'guidence'],
        'happened': ['happend', 'happend'],
        'harass': ['harrass', 'harrass'],
        'height': ['hieght', 'hieght'],
        'immediately': ['immediatly', 'immediatly'],
        'independent': ['independant', 'independant'],
        'intelligent': ['intellegent', 'intellegent'],
        'interest': ['intrest', 'intrest'],
        'interrupt': ['interupt', 'interupt'],
        'irresistible': ['irresistable', 'irresistable'],
        'knowledge': ['knowlege', 'knowlege'],
        'library': ['libary', 'libary'],
        'lightning': ['lightening', 'lightening'],
        'lonely': ['lonly', 'lonly'],
        'lose': ['loose', 'loose'],
        'mathematics': ['mathmatics', 'mathmatics'],
        'medicine': ['medecine', 'medecine'],
        'million': ['milion', 'milion'],
        'minute': ['minuet', 'minuet'],
        'miscellaneous': ['miscellanious', 'miscellanious'],
        'misspell': ['mispell', 'mispell'],
        'neighbor': ['neighbour', 'neighbour'],
        'noticeable': ['noticable', 'noticable'],
        'occasion': ['ocassion', 'ocassion'],
        'official': ['offical', 'offical'],
        'opinion': ['opion', 'opion'],
        'opportunity': ['oppertunity', 'oppertunity'],
        'optimistic': ['optimisic', 'optimisic'],
        'original': ['orignal', 'orignal'],
        'parallel': ['paralell', 'paralell'],
        'particular': ['particualr', 'particualr'],
        'perceive': ['percieve', 'percieve'],
        'performance': ['performence', 'performence'],
        'permanent': ['permanant', 'permanant'],
        'personal': ['personel', 'personel'],
        'personnel': ['personel', 'personel'],
        'physical': ['phisical', 'phisical'],
        'piece': ['peice', 'peice'],
        'pleasant': ['plesant', 'plesant'],
        'politician': ['politican', 'politican'],
        'position': ['posistion', 'posistion'],
        'possible': ['posible', 'posible'],
        'practical': ['practicle', 'practicle'],
        'presence': ['presance', 'presance'],
        'probably': ['probally', 'probally'],
        'professional': ['profesional', 'profesional'],
        'professor': ['professer', 'professer'],
        'promise': ['promiss', 'promiss'],
        'pronunciation': ['pronounciation', 'pronounciation'],
        'purpose': ['purpous', 'purpous'],
        'quantity': ['quantaty', 'quantaty'],
        'questionnaire': ['questionaire', 'questionaire'],
        'quiet': ['quite', 'quite'],
        'quite': ['quiet', 'quiet'],
        'really': ['realy', 'realy'],
        'reference': ['referance', 'referance'],
        'religion': ['religon', 'religon'],
        'remember': ['rember', 'rember'],
        'representative': ['representitive', 'representitive'],
        'restaurant': ['resturant', 'resturant'],
        'rhythm': ['rythm', 'rythm'],
        'ridiculous': ['rediculous', 'rediculous'],
        'safety': ['safty', 'safty'],
        'schedule': ['scedule', 'scedule'],
        'science': ['sience', 'sience'],
        'secretary': ['secratary', 'secratary'],
        'serious': ['sirius', 'sirius'],
        'should': ['shold', 'shold'],
        'sincerely': ['sincerly', 'sincerly'],
        'soldier': ['solider', 'solider'],
        'something': ['somthing', 'somthing'],
        'sometimes': ['sometime', 'sometime'],
        'sophomore': ['sophmore', 'sophmore'],
        'succeed': ['suceed', 'suceed'],
        'surprise': ['suprise', 'suprise'],
        'temperature': ['temperture', 'temperture'],
        'tendency': ['tendancy', 'tendancy'],
        'therefore': ['therefor', 'therefor'],
        'thorough': ['thorogh', 'thorogh'],
        'thought': ['thot', 'thot'],
        'through': ['thru', 'thru'],
        'tired': ['tierd', 'tierd'],
        'together': ['togather', 'togather'],
        'tomorrow': ['tommorow', 'tommorow'],
        'tongue': ['tounge', 'tounge'],
        'truly': ['truely', 'truely'],
        'unfortunately': ['unfortunatly', 'unfortunatly'],
        'until': ['untill', 'untill'],
        'usually': ['usualy', 'usualy'],
        'vacuum': ['vaccum', 'vaccum'],
        'valuable': ['valuble', 'valuble'],
        'vegetable': ['vegtable', 'vegtable'],
        'vehicle': ['vehical', 'vehical'],
        'village': ['villige', 'villige'],
        'weird': ['wierd', 'wierd'],
        'whether': ['wether', 'wether'],
        'which': ['wich', 'wich'],
        'writing': ['writting', 'writting'],
        'written': ['writen', 'writen'],
        'wrong': ['rong', 'rong'],
        'yield': ['yeild', 'yeild'],
    }
    
    # Check for exact common misspellings first
    if word in common_misspellings:
        misspellings.extend(common_misspellings[word])
        return misspellings[:2]  # Return early for common words
    
    # ALL possible misspelling patterns (much more comprehensive)
    all_patterns = []
    
    # Phonetic substitutions
    phonetic_patterns = [
        ('ph', 'f'), ('c', 'k'), ('th', 'f'), ('qu', 'kw'), ('kw', 'qu'),
        ('ch', 'sh'), ('wh', 'w'), ('kn', 'n'), ('wr', 'r'), ('mb', 'm'),
        ('gh', 'h'), ('ck', 'k'), ('tch', 'ch'), ('dg', 'j'), ('ti', 'sh'),
        ('ci', 'sh'), ('si', 'sh'), ('ss', 's'), ('ll', 'l'), ('ff', 'f'),
        ('zz', 'z'), ('tt', 't'), ('pp', 'p'), ('bb', 'b'), ('dd', 'd'),
        ('gg', 'g'), ('mm', 'm'), ('nn', 'n'), ('rr', 'r'), ('ss', 's')
    ]
    
    # Vowel substitutions
    vowel_patterns = [
        ('a', 'e'), ('e', 'a'), ('i', 'y'), ('y', 'i'), ('o', 'u'), ('u', 'o'),
        ('a', 'o'), ('e', 'i'), ('i', 'e'), ('o', 'a'), ('u', 'a'), ('y', 'e')
    ]
    
    # Silent letter patterns
    silent_patterns = [
        ('b', ''), ('k', ''), ('w', ''), ('h', ''), ('l', ''), ('t', '')
    ]
    
    # Double letter patterns
    double_patterns = [
        ('b', 'bb'), ('c', 'cc'), ('d', 'dd'), ('f', 'ff'), ('g', 'gg'),
        ('l', 'll'), ('m', 'mm'), ('n', 'nn'), ('p', 'pp'), ('r', 'rr'),
        ('s', 'ss'), ('t', 'tt'), ('z', 'zz')
    ]
    
    # Suffix patterns
    suffix_patterns = [
        ('ing', 'in'), ('ed', 't'), ('er', 'a'), ('ly', 'ley'), ('ful', 'full'),
        ('able', 'ible'), ('ible', 'able'), ('tion', 'shun'), ('sion', 'shun'),
        ('ture', 'cher'), ('sure', 'sher'), ('ous', 'us'), ('ious', 'us'),
        ('al', 'el'), ('el', 'al'), ('le', 'el'), ('el', 'le')
    ]
    
    # Prefix patterns
    prefix_patterns = [
        ('un', 'in'), ('in', 'un'), ('dis', 'mis'), ('mis', 'dis'),
        ('re', 'ri'), ('pre', 'pri'), ('pro', 'pra'), ('con', 'com'),
        ('com', 'con'), ('en', 'in'), ('em', 'im')
    ]
    
    # Letter transpositions (common typing errors)
    transposition_patterns = [
        ('th', 'ht'), ('er', 're'), ('te', 'et'), ('on', 'no'), ('an', 'na'),
        ('st', 'ts'), ('ar', 'ra'), ('le', 'el'), ('se', 'es'), ('ne', 'en'),
        ('at', 'ta'), ('it', 'ti'), ('is', 'si'), ('or', 'ro'), ('al', 'la'),
        ('de', 'ed'), ('re', 'er'), ('we', 'ew'), ('me', 'em'), ('he', 'eh'),
        ('as', 'sa'), ('in', 'ni'), ('to', 'ot'), ('of', 'fo'), ('be', 'eb')
    ]
    
    # Letter additions/removals
    addition_patterns = [
        ('', 'e'), ('', 'a'), ('', 'i'), ('', 'o'), ('', 'u'), ('', 'y'),
        ('e', ''), ('a', ''), ('i', ''), ('o', ''), ('u', ''), ('y', '')
    ]
    
    # Combine all patterns with their types
    all_patterns.extend([('phonetic', old, new) for old, new in phonetic_patterns])
    all_patterns.extend([('vowel', old, new) for old, new in vowel_patterns])
    all_patterns.extend([('silent', old, new) for old, new in silent_patterns])
    all_patterns.extend([('double', old, new) for old, new in double_patterns])
    all_patterns.extend([('suffix', old, new) for old, new in suffix_patterns])
    all_patterns.extend([('prefix', old, new) for old, new in prefix_patterns])
    all_patterns.extend([('transpose', old, new) for old, new in transposition_patterns])
    all_patterns.extend([('addition', old, new) for old, new in addition_patterns])
    
    # Shuffle all patterns for randomization
    random.shuffle(all_patterns)
    
    # Try patterns randomly until we get 2 good misspellings
    patterns_used = set()
    
    for pattern_type, old, new in all_patterns:
        if len(misspellings) >= 2:
            break
            
        # Skip if we've already used this pattern type
        if pattern_type in patterns_used:
            continue
            
        misspelling = None
        
        # Apply pattern based on type
        if pattern_type == 'phonetic':
            if old in word:
                misspelling = word.replace(old, new, 1)
        elif pattern_type == 'vowel':
            if old in word:
                misspelling = word.replace(old, new, 1)
        elif pattern_type == 'silent':
            if old in word:
                misspelling = word.replace(old, new, 1)
        elif pattern_type == 'double':
            if old in word and old + old not in word:
                misspelling = word.replace(old, old + old, 1)
            elif old + old in word:
                misspelling = word.replace(old + old, old, 1)
        elif pattern_type == 'suffix':
            if word.endswith(old):
                misspelling = word[:-len(old)] + new
        elif pattern_type == 'prefix':
            if word.startswith(old):
                misspelling = new + word[len(old):]
        elif pattern_type == 'transpose':
            if old in word:
                misspelling = word.replace(old, new, 1)
        elif pattern_type == 'addition':
            if old == '' and new != '':
                # Add letter at random position
                if len(word) > 2:
                    pos = random.randint(0, len(word))
                    misspelling = word[:pos] + new + word[pos:]
            elif old != '' and new == '':
                # Remove letter
                if old in word:
                    misspelling = word.replace(old, '', 1)
        
        # Validate misspelling
        if (misspelling and 
            misspelling != word and 
            len(misspelling) >= 3 and 
            misspelling not in misspellings):
            
            misspellings.append(misspelling)
            patterns_used.add(pattern_type)
    
    # If we still don't have enough misspellings, try some fallback patterns
    if len(misspellings) < 2:
        # Simple letter changes
        for i, char in enumerate(word):
            if len(misspellings) >= 2:
                break
            if char in 'aeiou':
                for vowel in 'aeiou':
                    if vowel != char:
                        new_word = word[:i] + vowel + word[i+1:]
                        if new_word != word and new_word not in misspellings:
                            misspellings.append(new_word)
                            break
    
    # Remove duplicates and limit to 2 misspellings
    unique_misspellings = list(dict.fromkeys(misspellings))
    return unique_misspellings[:2]

def improve_misspellings():
    """
    Improve misspellings in the words_combined.json file
    """
    print("Improving misspellings in words_combined.json...")
    
    # Load the current words
    try:
        with open('assets/data/words_combined.json', 'r') as f:
            data = json.load(f)
            words = data.get('words', [])
        print(f"✅ Loaded {len(words)} words from words_combined.json")
    except Exception as e:
        print(f"❌ Error loading words: {e}")
        return
    
    # Create backup
    try:
        with open('assets/data/words_combined_backup2.json', 'w') as f:
            json.dump(data, f, indent=2)
        print("✅ Created backup: words_combined_backup2.json")
    except Exception as e:
        print(f"⚠️ Warning: Could not create backup: {e}")
    
    # Improve misspellings for each word
    improved_count = 0
    for i, word_data in enumerate(words):
        original_misspellings = word_data.get('misspellings', [])
        correct_spelling = word_data.get('correctSpelling', '')
        difficulty = word_data.get('difficulty', 1)
        
        if correct_spelling:
            new_misspellings = generate_realistic_misspellings(correct_spelling, difficulty)
            word_data['misspellings'] = new_misspellings
            
            if new_misspellings != original_misspellings:
                improved_count += 1
                if improved_count <= 10:  # Show first 10 improvements
                    print(f"Improved '{correct_spelling}': {original_misspellings} → {new_misspellings}")
        
        # Progress indicator
        if (i + 1) % 100 == 0:
            print(f"Processed {i + 1}/{len(words)} words...")
    
    # Save improved words
    try:
        with open('assets/data/words_combined.json', 'w') as f:
            json.dump(data, f, indent=2)
        print(f"✅ Saved improved words to words_combined.json")
        print(f"🎉 Improved misspellings for {improved_count} words!")
    except Exception as e:
        print(f"❌ Error saving words: {e}")
        return
    
    # Show some examples
    print("\n📝 Example improvements:")
    for i, word_data in enumerate(words[:10]):
        correct = word_data.get('correctSpelling', '')
        misspellings = word_data.get('misspellings', [])
        print(f"  {correct}: {misspellings}")

def main():
    print("Better Misspelling Improvement Script")
    print("This script generates REALISTIC misspellings people actually make")
    print()
    
    # Confirm before proceeding
    print("This will:")
    print("- Create a backup of your current words_combined.json")
    print("- Generate realistic misspellings based on actual common mistakes")
    print("- Replace the current misspellings with better ones")
    print()
    
    response = input("Continue? (y/n): ").lower().strip()
    if response != 'y':
        print("Cancelled.")
        return
    
    # Improve misspellings
    improve_misspellings()

if __name__ == "__main__":
    main() 
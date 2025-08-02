#!/usr/bin/env python3
"""
Simple script to help deploy Firestore rules.
This script reads the firestore.rules file and provides instructions for manual deployment.
"""

import os
import sys

def main():
    rules_file = "firestore.rules"
    
    if not os.path.exists(rules_file):
        print(f"❌ Error: {rules_file} not found!")
        print("Make sure you're running this script from the project root directory.")
        sys.exit(1)
    
    print("📋 Firestore Rules Deployment Helper")
    print("=" * 50)
    
    # Read the rules file
    with open(rules_file, 'r') as f:
        rules_content = f.read()
    
    print(f"✅ Found {rules_file}")
    print(f"📏 Rules file size: {len(rules_content)} characters")
    
    print("\n🚀 To deploy these rules:")
    print("1. Go to https://console.firebase.google.com/")
    print("2. Select your project")
    print("3. Go to Firestore Database → Rules tab")
    print("4. Replace the existing rules with the content below:")
    print("5. Click 'Publish'")
    
    print("\n" + "=" * 50)
    print("📄 RULES CONTENT:")
    print("=" * 50)
    print(rules_content)
    print("=" * 50)
    
    print("\n✅ After deploying, the username uniqueness check should work properly!")
    print("💡 The app will now handle permission errors gracefully during signup.")

if __name__ == "__main__":
    main() 
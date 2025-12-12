#!/usr/bin/env python3
import json
import os

cache_file = "cache.json"

if not os.path.exists(cache_file):
    print("✅ No cache file found - ready for fresh upload")
    exit(0)

try:
    with open(cache_file, 'r') as f:
        # Essayer de lire tout le fichier
        content = f.read()
        
    # Essayer de parser le JSON
    data = json.loads(content)
    print("✅ Cache file is valid")
    print(f"   Items in cache: {len(data.get('items', {}))}")
    
except json.JSONDecodeError as e:
    print(f"❌ Cache file is corrupted: {e}")
    print("🔧 Attempting to fix...")
    
    try:
        with open(cache_file, 'r') as f:
            content = f.read()
        
        # Trouver le dernier accolade fermante complète
        last_complete = content.rfind('"}')
        if last_complete == -1:
            print("❌ Cannot fix - deleting cache")
            os.remove(cache_file)
            print("✅ Cache deleted - ready for fresh upload")
            exit(0)
        
        # Reconstruire le JSON jusqu'au dernier élément complet
        fixed = content[:last_complete + 2]
        
        # Fermer correctement le JSON
        if not fixed.endswith('}'):
            fixed += '\n  }\n}'
        else:
            fixed += '\n}'
        
        # Valider le JSON fixé
        data = json.loads(fixed)
        
        # Sauvegarder le cache fixé
        with open(cache_file, 'w') as f:
            json.dump(data, f, indent=2)
        
        print(f"✅ Cache fixed successfully!")
        print(f"   Items recovered: {len(data.get('items', {}))}")
        
    except Exception as e2:
        print(f"❌ Cannot fix cache: {e2}")
        print("🗑️  Deleting corrupted cache...")
        os.remove(cache_file)
        print("✅ Cache deleted - ready for fresh upload")

except Exception as e:
    print(f"❌ Unexpected error: {e}")
    print("🗑️  Deleting cache for safety...")
    if os.path.exists(cache_file):
        os.remove(cache_file)
    print("✅ Cache deleted - ready for fresh upload")

#!/usr/bin/env python3
import json
import os
import re
from pathlib import Path

assets_dir = Path("assets")

for json_file in assets_dir.glob("*.json"):
    try:
        # Lire le fichier comme texte brut
        with open(json_file, 'r') as f:
            content = f.read()
        
        # Supprimer les virgules orphelines avant les accolades fermantes
        content = re.sub(r',\s*}', '}', content)
        content = re.sub(r',\s*]', ']', content)
        
        # Parser et reformater le JSON proprement
        data = json.loads(content)
        
        # Supprimer le champ creators de properties si présent
        if 'properties' in data and 'creators' in data['properties']:
            del data['properties']['creators']
        
        # Réécrire le fichier JSON proprement
        with open(json_file, 'w') as f:
            json.dump(data, f, indent=2)
        
    except Exception as e:
        print(f"Error processing {json_file}: {e}")

print("All JSON files cleaned successfully!")

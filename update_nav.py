import os
import re

directory = 'lib/screens'
for filename in os.listdir(directory):
    if filename.endswith('.dart'):
        filepath = os.path.join(directory, filename)
        with open(filepath, 'r') as f:
            content = f.read()
        
        # Remove the else if (index == 3) { ... }
        # Let's use a regex to carefully remove the block
        content = re.sub(r'\s*\}?\s*else\s*if\s*\(\s*index\s*==\s*3\s*\)\s*\{\s*Navigator\.pushNamed\([^;]+;\s*\}', '', content)
        
        # Remove the BottomNavigationBarItem for Profil
        content = re.sub(r'\s*BottomNavigationBarItem\(\s*icon:\s*Icon\([^)]+\),\s*(?:activeIcon:\s*Icon\([^)]+\),\s*)?label:\s*\'Profil\',\s*\),?', '', content)
        
        with open(filepath, 'w') as f:
            f.write(content)

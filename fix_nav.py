import os
import re

directory = 'lib/screens'
for filename in os.listdir(directory):
    if filename.endswith('.dart'):
        filepath = os.path.join(directory, filename)
        with open(filepath, 'r') as f:
            content = f.read()
        
        # Replace the incorrectly closed block
        content = re.sub(
            r'(\}\s*else\s*if\s*\(\s*index\s*==\s*\d+\s*\)\s*\{\s*Navigator\.pushNamed\([^;]+;\s*)\},', 
            r'\1}\n          },', 
            content
        )
        
        with open(filepath, 'w') as f:
            f.write(content)

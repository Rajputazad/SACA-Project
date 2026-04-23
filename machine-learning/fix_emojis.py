# fix_emojis.py - Remove emojis from all Python files
import os
import re

def remove_emojis(text):
    emoji_pattern = re.compile("["
       
        u"\U00002B50"
        "]+", flags=re.UNICODE)
    return emoji_pattern.sub(r'', text)

def fix_file(filepath):
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        new_content = remove_emojis(content)
        
        replacements = {
            '✅': '[OK]',
            '❌': '[ERROR]',
            '📊': '[DATA]',
            '🔍': '[INFO]',
            '📈': '[STATS]',
            '🦠': '[DISEASE]',
            '🎉': '[DONE]',
            '🏆': '[BEST]',
            '📁': '[FOLDER]',
        }
        
        for old, new in replacements.items():
            new_content = new_content.replace(old, new)
        
        if content != new_content:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(new_content)
            print(f"Fixed: {filepath}")
            return True
    except Exception as e:
        print(f"Error fixing {filepath}: {e}")
    return False

# Fix all Python files in src folder
src_folder = 'src'
if os.path.exists(src_folder):
    for filename in os.listdir(src_folder):
        if filename.endswith('.py'):
            fix_file(os.path.join(src_folder, filename))

# Fix main.py
if os.path.exists('main.py'):
    fix_file('main.py')

print("\nAll files fixed! Run: python main.py")
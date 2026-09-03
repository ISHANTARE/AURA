import os
import re

emoji_pattern = re.compile(
    '['
    '\U0001F600-\U0001F64F'
    '\U0001F300-\U0001F5FF'
    '\U0001F680-\U0001F6FF'
    '\U0001F1E0-\U0001F1FF'
    '\U00002702-\U000027B0'
    '\U000024C2-\U0001F251'
    '\U0001F900-\U0001F9FF'
    '\U0001FA70-\U0001FAFF'
    ']+', flags=re.UNICODE)

str_pattern = re.compile(r'("(?:[^"\\]|\\.)*"|\'(?:[^\'\\]|\\.)*\')')

results = []
for root, dirs, files in os.walk('lib'):
    for file in files:
        if file.endswith('.dart'):
            path = os.path.join(root, file)
            with open(path, 'r', encoding='utf-8', errors='ignore') as f:
                for idx, line in enumerate(f, 1):
                    for s in str_pattern.findall(line):
                        found = emoji_pattern.findall(s)
                        if found:
                            results.append((path, idx, line.strip(), found))

with open('scratch_emojis.txt', 'w', encoding='utf-8') as out:
    for path, idx, line, found in results:
        out.write(f'{path}:{idx}: {found} -> {line}\n')

print(f'Total string emoji occurrences: {len(results)}')

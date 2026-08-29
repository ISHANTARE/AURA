import os
import re
import json

def analyze_codebase():
    results = {
        'files': [],
        'empty_catches': [],
        'todos': [],
        'hardcoded_strings': [],
        'providers': [],
        'database_tables': [],
        'daos': [],
        'routes': [],
        'channels': [],
        'services': [],
        'usecases': []
    }

    # Walk through lib, android, test, docs
    for root, dirs, files in os.walk('.'):
        dirs[:] = [d for d in dirs if d not in ['.git', '.dart_tool', 'build', '.idea']]
        for f in sorted(files):
            filepath = os.path.join(root, f)
            rel_path = filepath.replace('\\', '/')
            if rel_path.startswith('./'):
                rel_path = rel_path[2:]
            
            try:
                with open(filepath, 'r', encoding='utf-8', errors='ignore') as fl:
                    content = fl.read()
            except Exception as e:
                continue

            lines = content.split('\n')
            results['files'].append({
                'path': rel_path,
                'lines': len(lines),
                'bytes': os.path.getsize(filepath)
            })

            # Check Dart files
            if rel_path.endswith('.dart'):
                # Check empty catch blocks
                matches = re.finditer(r'catch\s*\([^\)]*\)\s*\{(?:\s*//[^\n]*)?\s*\}', content)
                for m in matches:
                    line_num = content[:m.start()].count('\n') + 1
                    results['empty_catches'].append({
                        'file': rel_path,
                        'line': line_num,
                        'snippet': m.group(0)
                    })

                # Check TODO/FIXME/HACK
                todo_matches = re.finditer(r'(//\s*(?:TODO|FIXME|HACK|BUG)[^\n]*)', content, re.IGNORECASE)
                for tm in todo_matches:
                    line_num = content[:tm.start()].count('\n') + 1
                    results['todos'].append({
                        'file': rel_path,
                        'line': line_num,
                        'text': tm.group(1).strip()
                    })

                # Check providers
                prov_matches = re.finditer(r'final\s+([A-Za-z0-9_]+Provider[A-Za-z0-9_]*)\s*=', content)
                for pm in prov_matches:
                    results['providers'].append({
                        'name': pm.group(1),
                        'file': rel_path
                    })

    with open('tool/analysis_report.json', 'w', encoding='utf-8') as out:
        json.dump(results, out, indent=2)

    print(f"Total files analyzed: {len(results['files'])}")
    print(f"Empty catch blocks found: {len(results['empty_catches'])}")
    print(f"TODO/FIXME/HACK comments found: {len(results['todos'])}")
    print(f"Providers found: {len(results['providers'])}")

if __name__ == '__main__':
    analyze_codebase()

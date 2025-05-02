import os
import json

def read_structure(path):
    structure = {}
    for entry in os.listdir(path):
        full_path = os.path.join(path, entry)
        if os.path.isdir(full_path):
            structure[entry] = read_structure(full_path)
        elif os.path.isfile(full_path):
            try:
                with open(full_path, 'r', encoding='utf-8') as f:
                    content = f.read().replace('\r', '').replace('\n', '\n')
                    structure[entry] = content
            except Exception as e:
                structure[entry] = f"<Could not read file: {e}>"
    return structure

if __name__ == '__main__':
    root_path = os.path.dirname(os.path.abspath(__file__))
    tree = read_structure(root_path)
    output_path = os.path.join(root_path, 'estrutura.json')
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(tree, f, ensure_ascii=False, indent=2)
    Logger().i(f"JSON gerado como '{output_path}'")
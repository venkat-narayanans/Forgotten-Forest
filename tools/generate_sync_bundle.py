import os

ROOT_DIR = os.path.abspath("src")
OUT_DIR = os.path.abspath("tools/sync_batches")
os.makedirs(OUT_DIR, exist_ok=True)

files_data = []

for dirpath, _, filenames in os.walk(ROOT_DIR):
    for f in filenames:
        if not f.endswith(".lua"):
            continue
        full_path = os.path.join(dirpath, f)
        rel_path = os.path.relpath(full_path, "src")
        
        with open(full_path, "r", encoding="utf-8") as fp:
            content = fp.read()
            
        if f.endswith(".server.lua"):
            class_name = "Script"
            script_name = f[:-11]
        elif f.endswith(".client.lua"):
            class_name = "LocalScript"
            script_name = f[:-11]
        else:
            class_name = "ModuleScript"
            script_name = f[:-4]
            
        parts = rel_path.replace("\\", "/").split("/")
        parts[-1] = script_name
        
        files_data.append({
            "path": parts,
            "class": class_name,
            "content": content
        })

print(f"Loaded {len(files_data)} files.")

# Split into 4 batches
BATCH_SIZE = 9
batches = [files_data[i:i + BATCH_SIZE] for i in range(0, len(files_data), BATCH_SIZE)]

for b_idx, batch in enumerate(batches):
    lua_lines = [
        "--!strict",
        f"-- Sync batch {b_idx + 1} of {len(batches)}",
        "local files = {"
    ]
    for item in batch:
        path_lua = "{" + ", ".join(f'"{p}"' for p in item["path"]) + "}"
        # Use delimiter with 5 equals to ensure no collision
        lua_lines.append(f'    {{ path = {path_lua}, class = "{item["class"]}", source = [=====[{item["content"]}]=====] }},')
    
    lua_lines.extend([
        "}",
        "",
        "local synced = 0",
        "for _, item in ipairs(files) do",
        '    local current: Instance = game:GetService(item.path[1])',
        '    for i = 2, #item.path - 1 do',
        '        local seg = item.path[i]',
        '        local child = current:FindFirstChild(seg)',
        '        if not child then',
        '            child = Instance.new("Folder")',
        '            child.Name = seg',
        '            child.Parent = current',
        '        end',
        '        current = child',
        '    end',
        '    local leaf = item.path[#item.path]',
        '    local obj = current:FindFirstChild(leaf)',
        '    if not obj or obj.ClassName ~= item.class then',
        '        if obj then obj:Destroy() end',
        '        obj = Instance.new(item.class)',
        '        obj.Name = leaf',
        '        obj.Parent = current',
        '    end',
        '    (obj :: any).Source = item.source',
        '    synced = synced + 1',
        'end',
        f'return string.format("BATCH {b_idx + 1} SUCCESS: Updated %d scripts.", synced)'
    ])
    
    out_path = os.path.join(OUT_DIR, f"batch_{b_idx + 1}.lua")
    with open(out_path, "w", encoding="utf-8") as fp:
        fp.write("\n".join(lua_lines))
    print(f"Wrote batch {b_idx + 1} with {len(batch)} scripts to {out_path}")

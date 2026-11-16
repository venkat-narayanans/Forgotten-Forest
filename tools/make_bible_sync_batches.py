import os

def create_batch(files_to_sync, output_path):
    lua_lines = [
        '--!strict',
        'local files = {'
    ]
    for filepath in files_to_sync:
        rel_path = filepath[4:]
        parts = rel_path.replace('\\', '/').split('/')
        leaf = parts[-1]
        if leaf.endswith('.server.lua'):
            cls = 'Script'
            name = leaf[:-11]
        elif leaf.endswith('.client.lua'):
            cls = 'LocalScript'
            name = leaf[:-11]
        else:
            cls = 'ModuleScript'
            name = leaf[:-4]
        parts[-1] = name
        
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
            
        path_lua = '{' + ', '.join(f'"{p}"' for p in parts) + '}'
        lua_lines.append(f'    {{ path = {path_lua}, class = "{cls}", source = [=====[{content}]=====] }},')

    lua_lines.extend([
        '}',
        '',
        'local synced = 0',
        'for _, item in ipairs(files) do',
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
        '    synced += 1',
        'end',
        'print(string.format("[SyncBible] Synced %d scripts into DataModel successfully.", synced))',
        'return synced',
    ])

    with open(output_path, 'w', encoding='utf-8') as out:
        out.write('\n'.join(lua_lines))
    print(f'Created {output_path} with {len(files_to_sync)} files.')

part1 = [
    'src/ReplicatedStorage/TFF/Shared/Definitions/ItemDefinitions.lua',
    'src/ReplicatedStorage/TFF/Shared/Definitions/RecipeDefinitions.lua',
    'src/ReplicatedStorage/TFF/Shared/Definitions/StoryDefinitions.lua',
]

part2 = [
    'src/ReplicatedStorage/TFF/Shared/Definitions/QuestDefinitions.lua',
    'src/ServerScriptService/TFFServer/Services/WorldInteractionService.lua',
    'src/ServerScriptService/TFFServer/Bootstrap.server.lua',
]

create_batch(part1, 'tools/batch_bible_1.lua')
create_batch(part2, 'tools/batch_bible_2.lua')

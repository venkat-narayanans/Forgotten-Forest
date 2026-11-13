import os

part1 = [
    'src/ReplicatedStorage/TFF/Shared/Definitions/QuestDefinitions.lua',
    'src/ReplicatedStorage/TFF/Shared/Definitions/StoryDefinitions.lua',
    'src/ServerScriptService/TFFServer/Services/ProfileService.lua',
    'src/ServerScriptService/TFFServer/Services/PlayerService.lua',
]

part2 = [
    'src/StarterPlayer/StarterPlayerScripts/TFFClient/Controllers/InputController.lua',
    'src/StarterPlayer/StarterPlayerScripts/TFFClient/Controllers/HUDController.lua',
]

def make_batch(files_list, filename):
    lua_lines = [
        '--!strict',
        'local files = {'
    ]
    for filepath in files_list:
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
        '    synced = synced + 1',
        '    print("Synced: " .. table.concat(item.path, "."))',
        'end',
        f'return string.format("{filename} SUCCESS: Updated %d scripts.", synced)'
    ])

    with open(f'tools/{filename}', 'w', encoding='utf-8') as f:
        f.write('\n'.join(lua_lines))
    print(f'Created tools/{filename}')

make_batch(part1, 'sync_modified_1.lua')
make_batch(part2, 'sync_modified_2.lua')

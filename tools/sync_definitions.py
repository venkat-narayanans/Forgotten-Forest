import os

with open('src/ReplicatedStorage/TFF/Shared/Types/Types.lua', 'r', encoding='utf-8') as f:
    types_code = f.read()
with open('src/ReplicatedStorage/TFF/Shared/Definitions/ItemDefinitions.lua', 'r', encoding='utf-8') as f:
    items_code = f.read()
with open('src/ReplicatedStorage/TFF/Shared/Definitions/RecipeDefinitions.lua', 'r', encoding='utf-8') as f:
    recipes_code = f.read()
with open('src/ReplicatedStorage/TFF/Remotes/RemoteRegistry.lua', 'r', encoding='utf-8') as f:
    remotes_code = f.read()

lua_script = f"""--!strict
local RS = game:GetService("ReplicatedStorage")
local tff = RS:FindFirstChild("TFF")
local sharedFolder = tff:FindFirstChild("Shared")
local typesMod = sharedFolder:FindFirstChild("Types"):FindFirstChild("Types")
typesMod.Source = [=====[{types_code}]=====]

local defs = sharedFolder:FindFirstChild("Definitions")
defs:FindFirstChild("ItemDefinitions").Source = [=====[{items_code}]=====]
defs:FindFirstChild("RecipeDefinitions").Source = [=====[{recipes_code}]=====]

local remotesFolder = tff:FindFirstChild("Remotes")
remotesFolder:FindFirstChild("RemoteRegistry").Source = [=====[{remotes_code}]=====]

return "Updated Types, ItemDefinitions, RecipeDefinitions, RemoteRegistry in Studio!"
"""

with open('tools/sync_core_definitions.lua', 'w', encoding='utf-8') as f:
    f.write(lua_script)
print("Generated tools/sync_core_definitions.lua successfully.")

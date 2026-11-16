import json

def get_code(path):
    with open(path, 'r', encoding='utf-8') as f:
        return f.read()

# 1. ItemDefinitions
item_def = get_code('src/ReplicatedStorage/TFF/Shared/Definitions/ItemDefinitions.lua')
script1 = f"""local ReplicatedStorage = game:GetService("ReplicatedStorage")
local obj = ReplicatedStorage.TFF.Shared.Definitions.ItemDefinitions
obj.Source = [=====[{item_def}]=====]
return true
"""
with open('temp_sync_itemdef.json', 'w', encoding='utf-8') as f:
    json.dump({'studio_id': 'dd1a5136-f49d-458a-8896-f7237ddb9ca4', 'datamodel_type': 'Edit', 'code': script1}, f)

# 1b. RecipeDefinitions
recipe_def = get_code('src/ReplicatedStorage/TFF/Shared/Definitions/RecipeDefinitions.lua')
script1b = f"""local ReplicatedStorage = game:GetService("ReplicatedStorage")
local obj = ReplicatedStorage.TFF.Shared.Definitions.RecipeDefinitions
obj.Source = [=====[{recipe_def}]=====]
return true
"""
with open('temp_sync_recipedef.json', 'w', encoding='utf-8') as f:
    json.dump({'studio_id': 'dd1a5136-f49d-458a-8896-f7237ddb9ca4', 'datamodel_type': 'Edit', 'code': script1b}, f)

# 2. StoryDefinitions
story_def = get_code('src/ReplicatedStorage/TFF/Shared/Definitions/StoryDefinitions.lua')
script2 = f"""local ReplicatedStorage = game:GetService("ReplicatedStorage")
local obj = ReplicatedStorage.TFF.Shared.Definitions.StoryDefinitions
obj.Source = [=====[{story_def}]=====]
return true
"""
with open('temp_sync_storydef.json', 'w', encoding='utf-8') as f:
    json.dump({'studio_id': 'dd1a5136-f49d-458a-8896-f7237ddb9ca4', 'datamodel_type': 'Edit', 'code': script2}, f)

# 3. QuestDefinitions
quest_def = get_code('src/ReplicatedStorage/TFF/Shared/Definitions/QuestDefinitions.lua')
script3 = f"""local ReplicatedStorage = game:GetService("ReplicatedStorage")
local obj = ReplicatedStorage.TFF.Shared.Definitions.QuestDefinitions
obj.Source = [=====[{quest_def}]=====]
return true
"""
with open('temp_sync_questdef.json', 'w', encoding='utf-8') as f:
    json.dump({'studio_id': 'dd1a5136-f49d-458a-8896-f7237ddb9ca4', 'datamodel_type': 'Edit', 'code': script3}, f)

# 4. WorldInteractionService
world_svc = get_code('src/ServerScriptService/TFFServer/Services/WorldInteractionService.lua')
script4 = f"""local ServerScriptService = game:GetService("ServerScriptService")
local services = ServerScriptService.TFFServer.Services
local obj = services:FindFirstChild("WorldInteractionService")
if not obj then
    obj = Instance.new("ModuleScript")
    obj.Name = "WorldInteractionService"
    obj.Parent = services
end
obj.Source = [=====[{world_svc}]=====]
return true
"""
with open('temp_sync_worldsvc.json', 'w', encoding='utf-8') as f:
    json.dump({'studio_id': 'dd1a5136-f49d-458a-8896-f7237ddb9ca4', 'datamodel_type': 'Edit', 'code': script4}, f)

# 5. Bootstrap
bootstrap = get_code('src/ServerScriptService/TFFServer/Bootstrap.server.lua')
script5 = f"""local ServerScriptService = game:GetService("ServerScriptService")
local bootstrap = ServerScriptService.TFFServer.Bootstrap
bootstrap.Source = [=====[{bootstrap}]=====]
return true
"""
with open('temp_sync_bootstrap.json', 'w', encoding='utf-8') as f:
    json.dump({'studio_id': 'dd1a5136-f49d-458a-8896-f7237ddb9ca4', 'datamodel_type': 'Edit', 'code': script5}, f)

print("Individual sync payloads generated.")

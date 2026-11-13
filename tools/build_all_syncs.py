import os

# 1. Definitions
with open('src/ReplicatedStorage/TFF/Shared/Types/Types.lua', 'r', encoding='utf-8') as f:
    types_code = f.read()
with open('src/ReplicatedStorage/TFF/Shared/Definitions/ItemDefinitions.lua', 'r', encoding='utf-8') as f:
    items_code = f.read()
with open('src/ReplicatedStorage/TFF/Shared/Definitions/RecipeDefinitions.lua', 'r', encoding='utf-8') as f:
    recipes_code = f.read()
with open('src/ReplicatedStorage/TFF/Remotes/RemoteRegistry.lua', 'r', encoding='utf-8') as f:
    remotes_code = f.read()

sync_1 = f"""local RS = game:GetService("ReplicatedStorage")
local tff = RS:FindFirstChild("TFF")
local sharedFolder = tff:FindFirstChild("Shared")
local typesMod = sharedFolder:FindFirstChild("Types"):FindFirstChild("Types")
typesMod.Source = [=====[{types_code}]=====]

local defs = sharedFolder:FindFirstChild("Definitions")
defs:FindFirstChild("ItemDefinitions").Source = [=====[{items_code}]=====]
defs:FindFirstChild("RecipeDefinitions").Source = [=====[{recipes_code}]=====]

local remotesFolder = tff:FindFirstChild("Remotes")
remotesFolder:FindFirstChild("RemoteRegistry").Source = [=====[{remotes_code}]=====]

return "SYNC 1 SUCCESS: Core definitions updated in Studio!"
"""

with open('tools/sync_1_definitions.lua', 'w', encoding='utf-8') as f:
    f.write(sync_1)

# 2. Server Services
with open('src/ServerScriptService/TFFServer/Bootstrap.server.lua', 'r', encoding='utf-8') as f:
    bootstrap_code = f.read()
with open('src/ServerScriptService/TFFServer/Services/CombatService.lua', 'r', encoding='utf-8') as f:
    combat_code = f.read()
with open('src/ServerScriptService/TFFServer/Services/SurvivalService.lua', 'r', encoding='utf-8') as f:
    survival_code = f.read()
with open('src/ServerScriptService/TFFServer/Services/WeatherService.lua', 'r', encoding='utf-8') as f:
    weather_code = f.read()
with open('src/ServerScriptService/TFFServer/Services/EventService.lua', 'r', encoding='utf-8') as f:
    event_code = f.read()
with open('src/ServerScriptService/TFFServer/Services/BossEncounterService.lua', 'r', encoding='utf-8') as f:
    boss_code = f.read()
with open('src/ServerScriptService/TFFServer/Services/PlayerService.lua', 'r', encoding='utf-8') as f:
    player_code = f.read()

sync_2 = f"""local SSS = game:GetService("ServerScriptService")
local tffServer = SSS:FindFirstChild("TFFServer")
tffServer:FindFirstChild("Bootstrap").Source = [=====[{bootstrap_code}]=====]

local services = tffServer:FindFirstChild("Services")
services:FindFirstChild("CombatService").Source = [=====[{combat_code}]=====]
services:FindFirstChild("SurvivalService").Source = [=====[{survival_code}]=====]
services:FindFirstChild("EventService").Source = [=====[{event_code}]=====]
services:FindFirstChild("PlayerService").Source = [=====[{player_code}]=====]

local weatherMod = services:FindFirstChild("WeatherService")
if not weatherMod then
    weatherMod = Instance.new("ModuleScript")
    weatherMod.Name = "WeatherService"
    weatherMod.Parent = services
end
weatherMod.Source = [=====[{weather_code}]=====]

local bossMod = services:FindFirstChild("BossEncounterService")
if not bossMod then
    bossMod = Instance.new("ModuleScript")
    bossMod.Name = "BossEncounterService"
    bossMod.Parent = services
end
bossMod.Source = [=====[{boss_code}]=====]

return "SYNC 2 SUCCESS: Server services updated in Studio!"
"""

with open('tools/sync_2_services.lua', 'w', encoding='utf-8') as f:
    f.write(sync_2)

# 3. Client Controllers
with open('src/StarterPlayer/StarterPlayerScripts/TFFClient/Controllers/InputController.lua', 'r', encoding='utf-8') as f:
    input_code = f.read()
with open('src/StarterPlayer/StarterPlayerScripts/TFFClient/Controllers/HUDController.lua', 'r', encoding='utf-8') as f:
    hud_code = f.read()

sync_3 = f"""local SP = game:GetService("StarterPlayer")
local scripts = SP:FindFirstChild("StarterPlayerScripts")
local tffClient = scripts:FindFirstChild("TFFClient")
local controllers = tffClient:FindFirstChild("Controllers")

controllers:FindFirstChild("InputController").Source = [=====[{input_code}]=====]
controllers:FindFirstChild("HUDController").Source = [=====[{hud_code}]=====]

return "SYNC 3 SUCCESS: Client controllers updated in Studio!"
"""

with open('tools/sync_3_controllers.lua', 'w', encoding='utf-8') as f:
    f.write(sync_3)

print("Generated sync_1_definitions.lua, sync_2_services.lua, sync_3_controllers.lua successfully.")

import os

with open('src/ServerScriptService/TFFServer/Bootstrap.server.lua', 'r', encoding='utf-8') as f:
    bootstrap_code = f.read()
with open('src/ServerScriptService/TFFServer/Services/CombatService.lua', 'r', encoding='utf-8') as f:
    combat_code = f.read()
with open('src/ServerScriptService/TFFServer/Services/SurvivalService.lua', 'r', encoding='utf-8') as f:
    survival_code = f.read()

sync_2a = f"""local SSS = game:GetService("ServerScriptService")
local tffServer = SSS:FindFirstChild("TFFServer")
tffServer:FindFirstChild("Bootstrap").Source = [=====[{bootstrap_code}]=====]

local services = tffServer:FindFirstChild("Services")
services:FindFirstChild("CombatService").Source = [=====[{combat_code}]=====]
services:FindFirstChild("SurvivalService").Source = [=====[{survival_code}]=====]

return "SYNC 2A SUCCESS: Bootstrap, CombatService, SurvivalService updated!"
"""

with open('tools/sync_2a.lua', 'w', encoding='utf-8') as f:
    f.write(sync_2a)

with open('src/ServerScriptService/TFFServer/Services/WeatherService.lua', 'r', encoding='utf-8') as f:
    weather_code = f.read()
with open('src/ServerScriptService/TFFServer/Services/EventService.lua', 'r', encoding='utf-8') as f:
    event_code = f.read()
with open('src/ServerScriptService/TFFServer/Services/BossEncounterService.lua', 'r', encoding='utf-8') as f:
    boss_code = f.read()
with open('src/ServerScriptService/TFFServer/Services/PlayerService.lua', 'r', encoding='utf-8') as f:
    player_code = f.read()

sync_2b = f"""local SSS = game:GetService("ServerScriptService")
local tffServer = SSS:FindFirstChild("TFFServer")
local services = tffServer:FindFirstChild("Services")

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

services:FindFirstChild("EventService").Source = [=====[{event_code}]=====]
services:FindFirstChild("PlayerService").Source = [=====[{player_code}]=====]

return "SYNC 2B SUCCESS: WeatherService, EventService, BossEncounterService, PlayerService updated!"
"""

with open('tools/sync_2b.lua', 'w', encoding='utf-8') as f:
    f.write(sync_2b)

print("Generated sync_2a.lua and sync_2b.lua")

with open('src/StarterPlayer/StarterPlayerScripts/TFFClient/Controllers/HUDController.lua', 'r', encoding='utf-8') as f:
    hud_source = f.read()

lua_script = f'''--!strict
local code = [=====[{hud_source}]=====]
local StarterPlayer = game:GetService("StarterPlayer")
local client = StarterPlayer:WaitForChild("StarterPlayerScripts"):WaitForChild("TFFClient"):WaitForChild("Controllers")
local hudMod = client:FindFirstChild("HUDController") :: ModuleScript?
if not hudMod then
    hudMod = Instance.new("ModuleScript")
    hudMod.Name = "HUDController"
    hudMod.Parent = client
end
hudMod.Source = code
return "HUDController SYNCED"
'''

with open('tools/sync_hud.lua', 'w', encoding='utf-8') as f:
    f.write(lua_script)
print("Wrote tools/sync_hud.lua")

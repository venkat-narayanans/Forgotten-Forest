import os

services_dir = r"src\ServerScriptService\TFFServer\Services"
mods = ["SurvivalService", "InventoryService", "TimeCycleService", "WeatherService"]

lines = [
    'local SSS = game:GetService("ServerScriptService")',
    'local tffServer = SSS:FindFirstChild("TFFServer")',
    'local services = tffServer:FindFirstChild("Services")',
]

for m in mods:
    path = os.path.join(services_dir, m + ".lua")
    with open(path, "r", encoding="utf-8") as f:
        src = f.read()
    lines.append(f'local mod_{m} = services:FindFirstChild("{m}")')
    lines.append(f'if not mod_{m} then')
    lines.append(f'    mod_{m} = Instance.new("ModuleScript")')
    lines.append(f'    mod_{m}.Name = "{m}"')
    lines.append(f'    mod_{m}.Parent = services')
    lines.append('end')
    lines.append(f'mod_{m}.Source = [=====[{src}]=====]')

lines.append('return "SERVICES SYNCED CLEANLY!"')

with open("tools/sync_fix.lua", "w", encoding="utf-8") as f:
    f.write("\n".join(lines))

print("Created tools/sync_fix.lua successfully")

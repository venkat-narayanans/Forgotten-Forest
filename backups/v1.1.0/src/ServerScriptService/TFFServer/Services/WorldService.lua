--!strict
--[[
    WorldService.lua
    Server-side management of world folders, tags, safe zones, and static spatial layout.
]]

local Workspace = game:GetService("Workspace")
local CollectionService = game:GetService("CollectionService")

local WorldService = {}
WorldService.__index = WorldService

local REQUIRED_FOLDERS = {
    "Map",
    "Regions",
    "ResourceNodes",
    "Interactables",
    "CreatureSpawns",
    "SafeZones",
    "SpawnLocations",
    "TemporaryStructures",
}

local _initialized = false

function WorldService.Init(_dependencies: { [string]: any })
    print("[WorldService] Initializing world folders and hierarchy...")
    
    local worldRoot = Workspace:FindFirstChild("TFF_World")
    if not worldRoot then
        worldRoot = Instance.new("Folder")
        worldRoot.Name = "TFF_World"
        worldRoot.Parent = Workspace
    end

    for _, folderName in ipairs(REQUIRED_FOLDERS) do
        local folder = worldRoot:FindFirstChild(folderName)
        if not folder then
            folder = Instance.new("Folder")
            folder.Name = folderName
            folder.Parent = worldRoot
        end
    end

    _initialized = true
    print("[WorldService] Hierarchy established successfully.")
end

function WorldService.Start()
    print("[WorldService] WorldService started.")
end

function WorldService.GetWorldFolder(name: string): Folder?
    local worldRoot = Workspace:FindFirstChild("TFF_World")
    if not worldRoot then return nil end
    return worldRoot:FindFirstChild(name) :: Folder
end

function WorldService.IsInsideSafeZone(position: Vector3): boolean
    local safeZonesFolder = WorldService.GetWorldFolder("SafeZones")
    if not safeZonesFolder then return false end

    for _, zone in ipairs(safeZonesFolder:GetChildren()) do
        if zone:IsA("BasePart") then
            local radius = zone:GetAttribute("Radius")
            if radius and typeof(radius) == "number" then
                if (position - zone.Position).Magnitude <= radius then
                    return true
                end
            else
                -- Bounding box check for Part
                local halfSize = zone.Size / 2
                local relativePos = zone.CFrame:PointToObjectSpace(position)
                if math.abs(relativePos.X) <= halfSize.X
                    and math.abs(relativePos.Y) <= halfSize.Y
                    and math.abs(relativePos.Z) <= halfSize.Z then
                    return true
                end
            end
        end
    end
    return false
end

return WorldService

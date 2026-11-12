--!strict
--[[
    RemoteRegistry.lua
    Central registry and accessor for all network RemoteEvents and RemoteFunctions.
]]

local RemoteRegistry = {}

RemoteRegistry.Events = {
    -- Client to Server Requests
    RequestGather = "RequestGather",
    RequestCraft = "RequestCraft",
    RequestRevive = "RequestRevive",
    RequestInteract = "RequestInteract",
    RequestSprint = "RequestSprint",
    RequestDepositStorage = "RequestDepositStorage",
    RequestWithdrawStorage = "RequestWithdrawStorage",
    RequestClaimQuest = "RequestClaimQuest",

    -- Server to Client Notifications & State Sync
    SyncProfile = "SyncProfile",
    SyncStats = "SyncStats",
    SyncTimeCycle = "SyncTimeCycle",
    ShowNotification = "ShowNotification",
    DownedStateChanged = "DownedStateChanged",
    SharedStorageUpdated = "SharedStorageUpdated",
    QuestUpdated = "QuestUpdated",
}

RemoteRegistry.Functions = {
    GetInitialSnapshot = "GetInitialSnapshot",
}

function RemoteRegistry.GetOrCreateRemotesFolder(): Folder
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local tff = ReplicatedStorage:FindFirstChild("TFF")
    if not tff then
        tff = Instance.new("Folder")
        tff.Name = "TFF"
        tff.Parent = ReplicatedStorage
    end

    local remotes = tff:FindFirstChild("Remotes")
    if not remotes then
        remotes = Instance.new("Folder")
        remotes.Name = "Remotes"
        remotes.Parent = tff
    end

    local eventsFolder = remotes:FindFirstChild("Events")
    if not eventsFolder then
        eventsFolder = Instance.new("Folder")
        eventsFolder.Name = "Events"
        eventsFolder.Parent = remotes
    end

    local functionsFolder = remotes:FindFirstChild("Functions")
    if not functionsFolder then
        functionsFolder = Instance.new("Folder")
        functionsFolder.Name = "Functions"
        functionsFolder.Parent = remotes
    end

    return remotes
end

function RemoteRegistry.GetRemoteEvent(name: string): RemoteEvent
    local remotes = RemoteRegistry.GetOrCreateRemotesFolder()
    local eventsFolder = remotes:WaitForChild("Events") :: Folder
    local remote = eventsFolder:FindFirstChild(name) :: RemoteEvent
    if not remote and game:GetService("RunService"):IsServer() then
        remote = Instance.new("RemoteEvent")
        remote.Name = name
        remote.Parent = eventsFolder
    end
    return remote
end

function RemoteRegistry.GetRemoteFunction(name: string): RemoteFunction
    local remotes = RemoteRegistry.GetOrCreateRemotesFolder()
    local functionsFolder = remotes:WaitForChild("Functions") :: Folder
    local remote = functionsFolder:FindFirstChild(name) :: RemoteFunction
    if not remote and game:GetService("RunService"):IsServer() then
        remote = Instance.new("RemoteFunction")
        remote.Name = name
        remote.Parent = functionsFolder
    end
    return remote
end

return RemoteRegistry

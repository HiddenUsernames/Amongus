local Multiplayer = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Event = ReplicatedStorage:WaitForChild("RemoteFunction")
local LocalPlayer = Players.LocalPlayer

-- The specific Place ID allowed to run this code
local TARGET_PLACE_ID = 3260590327

function Multiplayer.StartHost(playerToInviteName, waitTime, Mode)
    -- Check if the current place ID matches, if not, return early
    if game.PlaceId ~= TARGET_PLACE_ID then 
        return 
    end

    print("[" .. LocalPlayer.Name .. "] Starting party as Host for Mode: " .. tostring(Mode))

    Event:InvokeServer("Party", "CreateParty", nil)
    task.wait(1) 
    
    local targetPlayer = Players:FindFirstChild(playerToInviteName)
    if not targetPlayer then
        print("Waiting for " .. playerToInviteName .. " to load into the server...")
        targetPlayer = Players:WaitForChild(playerToInviteName, 10)
    end
    
    if targetPlayer then
        print("Sending invite to: " .. targetPlayer.Name)
        Event:InvokeServer("Party", "InvitePlayer", targetPlayer)
    else
        warn("Failed to invite: " .. playerToInviteName .. " is not in the server.")
        return
    end
    
    print("Waiting " .. tostring(waitTime) .. " seconds for player to join...")
    task.wait(waitTime)
    
    Event:InvokeServer(
        "Multiplayer",
        "v2:start",
        {
            difficulty = Mode or "Fallen",
            mode = "survival",
            count = 2
        }
    )
end

function Multiplayer.JoinLobby(HostName)
    -- Check if the current place ID matches, if not, return early
    if game.PlaceId ~= TARGET_PLACE_ID then 
        return 
    end

    print("[" .. LocalPlayer.Name .. "] Attempting to join " .. HostName .. "'s lobby...")
    
    local hostPlayer = Players:FindFirstChild(HostName)
    if not hostPlayer then
        hostPlayer = Players:WaitForChild(HostName, 15)
    end
    
    if hostPlayer then
        Event:InvokeServer("Party", "AcceptInvite", hostPlayer)
        print("Successfully accepted invite from " .. hostPlayer.Name)
    else
        warn("Could not join lobby: Host " .. HostName .. " not found.")
    end
end

return Multiplayer

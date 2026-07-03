local Multiplayer = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Event = ReplicatedStorage:WaitForChild("RemoteFunction")
local LocalPlayer = Players.LocalPlayer

-- The specific Place ID allowed to run this code
local TARGET_PLACE_ID = 3260590327

function Multiplayer.StartHost(playerToInviteName, Mode)
    if game.PlaceId ~= TARGET_PLACE_ID then return end

    -- Safe name fallback if LocalPlayer is nil
    local playerName = LocalPlayer and LocalPlayer.Name or "Server/Unknown"
    print("[" .. playerName .. "] Starting Host cycle for Mode: " .. tostring(Mode))
    
    -- Locate UI paths
    -- If running on server, PlayerGui won't be directly accessible this way
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    local partyMembers = playerGui
        :WaitForChild("ReactLobbyParty")
        :WaitForChild("party")
        :WaitForChild("currentParty")
        :WaitForChild("partyMembers")

    print("Entering Create -> Invite -> Leave loop. Waiting for " .. playerToInviteName .. "...")

    while true do
        -- 1. Create the party
        Event:InvokeServer("Party", "CreateParty", nil)
        task.wait(0.1) -- Small breath for server replication

        -- Check immediately if they managed to join right as we made it
        if partyMembers:FindFirstChild("1") then break end

        -- 2. Attempt to invite the target player if they are in the server
        local targetPlayer = Players:FindFirstChild(playerToInviteName)
        if targetPlayer then
            print("Creating fresh party & sending invite to: " .. targetPlayer.Name)
            coroutine.wrap(function()
                Event:InvokeServer("Party", "InvitePlayer", targetPlayer)
            end)()
        else
            print("Waiting for " .. playerToInviteName .. " to appear in the server list...")
        end

        -- 3. Give the player a short window to accept before we cycle
        -- This loops 5 times with a 0.2s delay (1 second total window)
        for i = 1, 5 do
            if partyMembers:FindFirstChild("1") then
                break
            end
            task.wait(0.2)
        end

        -- 4. Final check before breaking or leaving
        if partyMembers:FindFirstChild("1") then 
            break 
        end

        -- 5. If they didn't join in time, leave the party and loop back to recreate it
        Event:InvokeServer("Party", "LeaveParty")
        task.wait(0.2)
    end
    
    print("Player successfully detected in party slot [1]! Starting match instantly...")
    
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
    if game.PlaceId ~= TARGET_PLACE_ID then return end

    local playerName = LocalPlayer and LocalPlayer.Name or "Server/Unknown"
    print("[" .. playerName .. "] Searching for host: " .. HostName)
    
    local hostPlayer = Players:FindFirstChild(HostName)
    if not hostPlayer then
        hostPlayer = Players:WaitForChild(HostName, 15)
    end
    
    if not hostPlayer then
        warn("Could not join lobby: Host " .. HostName .. " not found.")
        return
    end
    
    print("Spamming AcceptInvite until match teleportation begins...")

    -- Keeps firing until the PlaceId changes (meaning the host started the match and you are teleporting)
    while game.PlaceId == TARGET_PLACE_ID do
        coroutine.wrap(function()
            Event:InvokeServer("Party", "AcceptInvite", hostPlayer)
        end)()

        task.wait(0.1)
    end

    print("Left lobby place. Stopped spamming AcceptInvite.")
end

return Multiplayer

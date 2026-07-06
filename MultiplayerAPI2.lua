local Multiplayer = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Event = ReplicatedStorage:WaitForChild("RemoteFunction")
local LocalPlayer = Players.LocalPlayer

-- The specific Place ID allowed to run this code
local TARGET_PLACE_ID = 3260590327

function Multiplayer.StartHost(playerToInviteName, Mode)
    if game.PlaceId ~= TARGET_PLACE_ID then return end

    -- Path to where the game updates party data on the backend
    -- (Adjust "Parties" or "CurrentParty" if the game uses a different name in ReplicatedStorage)
    local replicatedStorage = game:GetService("ReplicatedStorage")
    local partyFolder = replicatedStorage:WaitForChild("Parties", 5) 

    print("Entering Cycle: Create -> Invite -> Leave loop until " .. playerToInviteName .. " joins...")

    while true do
        -- 1. Create the party
        print("[" .. LocalPlayer.Name .. "] Creating party...")
        Event:InvokeServer("Party", "CreateParty", nil)
        task.wait(1) 

        -- 2. Check if target player is in the server and invite them
        local targetPlayer = Players:FindFirstChild(playerToInviteName)
        if targetPlayer then
            print("Sending invite to: " .. targetPlayer.Name)
            coroutine.wrap(function()
                Event:InvokeServer("Party", "InvitePlayer", targetPlayer)
            end)()
            
            -- 3. Loop in small intervals to see if they join the backend folder
            local checkWindow = 4.0 
            local elapsed = 0
            local joined = false
            
            while elapsed < checkWindow do
                -- Checks if a folder/value representing the player exists in the party data
                if partyFolder and partyFolder:FindFirstChild(playerToInviteName) then
                    joined = true
                    break
                end
                task.wait(0.2)
                elapsed = elapsed + 0.2
            end

            if joined then break end
        else
            print("Waiting for " .. playerToInviteName .. " to appear in the server list...")
            task.wait(1)
        end

        -- Reset cycle if player didn't make it in
        print("Player didn't join within the window. Resetting party...")
        Event:InvokeServer("Party", "LeaveParty")
        task.wait(0.5)
    end

    print("Player successfully verified in party! Starting match...")
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

    print("[" .. LocalPlayer.Name .. "] Searching for host: " .. HostName)
    local hostPlayer = Players:FindFirstChild(HostName)
    if not hostPlayer then
        hostPlayer = Players:WaitForChild(HostName, 15)
    end
    if not hostPlayer then
        warn("Could not join lobby: Host " .. HostName .. " not found.")
        return
    end

    print("Spamming AcceptInvite...")

    while true do
        coroutine.wrap(function()
            Event:InvokeServer("Party", "AcceptInvite", hostPlayer)
        end)()
        print("TRying")
   Event:InvokeServer("Party", "AcceptInvite", hostPlayer)
        task.wait(0.1)
    end
end


return Multiplayer

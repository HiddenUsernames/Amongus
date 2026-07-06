local Multiplayer = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Event = ReplicatedStorage:WaitForChild("RemoteFunction")
local LocalPlayer = Players.LocalPlayer

-- The specific Place ID allowed to run this code
local TARGET_PLACE_ID = 3260590327

function Multiplayer.StartHost(playerToInviteName, Mode)
    if game.PlaceId ~= TARGET_PLACE_ID then return end

    print("Entering Cycle: Create -> Invite loop until " .. playerToInviteName .. " is processed...")

    while true do
        -- 1. Create the party
        print("[" .. LocalPlayer.Name .. "] Creating party...")
        Event:InvokeServer("Party", "CreateParty", nil)
        task.wait(1) -- Brief pause to allow the party to initialize

        -- 2. Check if target player is in the server and invite them
        local targetPlayer = Players:FindFirstChild(playerToInviteName)
        if targetPlayer then
            print("Sending invite to: " .. targetPlayer.Name)
            coroutine.wrap(function()
                Event:InvokeServer("Party", "InvitePlayer", targetPlayer)
            end)()
            
            -- 3. Give the player a fixed window to accept the invite
            print("Waiting for " .. playerToInviteName .. " to accept...")
            task.wait(3) -- Adjust this delay (in seconds) if your partner needs more time to load/accept
            
            -- Exit the loop now that the invitation sequence has been sent
            break
        else
            print("Waiting for " .. playerToInviteName .. " to appear in the server list...")
            task.wait(1)
        end
    end

    print("Sending match start request...")
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

        task.wait(0.1)
    end
end


return Multiplayer

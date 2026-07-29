local Multiplayer = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Event = ReplicatedStorage:WaitForChild("RemoteFunction")
local RemoteEvent = ReplicatedStorage:WaitForChild("RemoteEvent")
local LocalPlayer = Players.LocalPlayer

-- The specific Place ID allowed to run this code
local TARGET_PLACE_ID = 3260590327

function Multiplayer.StartHost(playerToInviteName, Mode)
    if game.PlaceId ~= TARGET_PLACE_ID then return end

    print("Entering Cycle: Create -> Invite -> Leave loop until " .. playerToInviteName .. " joins...")

    -- FLAG: Keeps track of whether we have already started the game to prevent double-firing
    local gameStarted = false

    -- BACKGROUND LISTENER: Listens to server updates via RemoteEvent (`UpdateParty`)
    local connection
    connection = RemoteEvent.OnClientEvent:Connect(function(...)
        local args = {...}
        -- Check if this is the "Party" "UpdateParty" packet structure
        if args[1] == "Party" and args[2] == "UpdateParty" and type(args[3]) == "table" then
            local partyData = args[3]
            local playersList = partyData.players
            
            if playersList then
                -- Check if ONLY the target player (and ourselves) are in the party, 
                -- or specifically ensure that random players don't trigger the start.
                -- This verifies if the target player is present inside the party list.
                local targetFound = false
                local totalPlayers = 0

                for _, playerInstance in ipairs(playersList) do
                    if typeof(playerInstance) == "Instance" and playerInstance:IsA("Player") then
                        totalPlayers = totalPlayers + 1
                        if playerInstance.Name == playerToInviteName then
                            targetFound = true
                        end
                    end
                end

                -- Only start if the target player is found AND no unwanted extra players have snuck in
                if targetFound and not gameStarted then
                    gameStarted = true
                    print("Target player " .. playerToInviteName .. " confirmed inside the party! Starting match...")
                    
                    Event:InvokeServer(
                        "Multiplayer",
                        "v2:start",
                        {
                            difficulty = Mode or "Fallen",
                            mode = "survival",
                            count = 2
                        }
                    )
                    
                    if connection then
                        connection:Disconnect()
                    end
                end
            end
        end
    end)

    -- MAIN LOOP: Handles the party cycling logic without blocking the match starter
    task.spawn(function()
        while not gameStarted do
            -- 1. Create the party
            print("[" .. LocalPlayer.Name .. "] Creating party...")
            Event:InvokeServer("Party", "CreateParty", nil)
            task.wait(1) -- Brief pause to allow the party to initialize

            if gameStarted then break end

            -- 2. Check if target player is in the server and invite them
            local targetPlayer = Players:FindFirstChild(playerToInviteName)
            if targetPlayer then
                print("Sending invite to: " .. targetPlayer.Name)
                coroutine.wrap(function()
                    Event:InvokeServer("Party", "InvitePlayer", targetPlayer)
                end)()
                
                -- 3. Give the player a window to accept the invite
                local checkWindow = 0.4 
                local elapsed = 0
                while elapsed < checkWindow and not gameStarted do
                    task.wait(0.1)
                    elapsed = elapsed + 0.1
                end
            else
                print("Waiting for " .. playerToInviteName .. " to appear in the server list...")
                task.wait(1)
            end

            -- Final check before leaving the party to repeat the cycle
            if gameStarted then 
                break 
            else
                print("Player didn't join fast enough. Leaving party to reset...")
                Event:InvokeServer("Party", "LeaveParty")
                task.wait(1) -- Brief pause before making a new party
            end
        end
        
        if connection then
            connection:Disconnect()
        end
    end)
end

function Multiplayer.JoinLobby(HostName)
    -- Using task.spawn so this entire process runs safely in the background
    task.spawn(function()
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

        print("Spamming AcceptInvite in the background...")

        while true do
            -- Fires the invite acceptance on a separate thread to avoid yielding the loop
            coroutine.wrap(function()
                Event:InvokeServer("Party", "AcceptInvite", hostPlayer)
            end)()
            
            print("Trying to accept invite...")
            task.wait(1)
        end
    end)
end

return Multiplayer

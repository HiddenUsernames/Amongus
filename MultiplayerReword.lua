local Multiplayer = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Event = ReplicatedStorage:WaitForChild("RemoteFunction")
local RemoteEvent = ReplicatedStorage:WaitForChild("RemoteEvent")
local LocalPlayer = Players.LocalPlayer

-- The specific Place ID allowed to run this code
local TARGET_PLACE_ID = 3260590327

function Multiplayer.StartHost(playerToInviteName, Mode, Difficulty)
    if game.PlaceId ~= TARGET_PLACE_ID then return end

    print("Creating party once and waiting for " .. playerToInviteName .. " to join...")

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
                local targetFound = false

                for _, playerInstance in ipairs(playersList) do
                    if typeof(playerInstance) == "Instance" and playerInstance:IsA("Player") then
                        if playerInstance.Name == playerToInviteName then
                            targetFound = true
                        end
                    end
                end

                -- Only start if the target player is found AND not already started
                if targetFound and not gameStarted then
                    gameStarted = true
                    print("Target player " .. playerToInviteName .. " confirmed inside the party! Starting match...")
                    
                    local selectedMode = Mode or "Fallen"
                    
                    if selectedMode:lower() == "hardcore" then
                        Event:InvokeServer(
                            "Multiplayer",
                            "v2:start",
                            {
                                difficulty = Difficulty or "Easy",
                                mode = "hardcore",
                                count = 2
                            }
                        )
                    else
                        Event:InvokeServer(
                            "Multiplayer",
                            "v2:start",
                            {
                                difficulty = selectedMode,
                                mode = "survival",
                                count = 2
                            }
                        )
                    end
                    
                    if connection then
                        connection:Disconnect()
                    end
                end
            end
        end
    end)

    -- MAIN LOOP: Create the party ONCE, send invites periodically, and wait indefinitely without leaving/destroying
    task.spawn(function()
        -- 1. Create the party once
        print("[" .. LocalPlayer.Name .. "] Creating party...")
        Event:InvokeServer("Party", "CreateParty", nil)
        task.wait(1) -- Brief pause to allow the party to initialize

        while not gameStarted do
            -- 2. Check if target player is in the server and keep sending invites until they join
            local targetPlayer = Players:FindFirstChild(playerToInviteName)
            if targetPlayer then
                print("Sending invite to: " .. targetPlayer.Name)
                coroutine.wrap(function()
                    Event:InvokeServer("Party", "InvitePlayer", targetPlayer)
                end)()
            else
                print("Waiting for " .. playerToInviteName .. " to appear in the server list...")
            end

            -- Wait before sending the next invite, staying in the party instead of leaving
            task.wait(2)
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

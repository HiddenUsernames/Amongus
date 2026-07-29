local Multiplayer = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Event = ReplicatedStorage:WaitForChild("RemoteFunction")
local RemoteEvent = ReplicatedStorage:WaitForChild("RemoteEvent")
local LocalPlayer = Players.LocalPlayer

-- The specific Place ID allowed to run this code
local TARGET_PLACE_ID = 3260590327

function Multiplayer.StartHost(playerToInviteName, Mode, difficulty)
    if game.PlaceId ~= TARGET_PLACE_ID then return end

    print("Entering Cycle: Create -> Invite -> Leave loop until " .. playerToInviteName .. " joins...")

    -- FLAG: Keeps track of whether we have already started the game to prevent double-firing
    local gameStarted = false

    -- EVENT LISTENER: Listens to incoming network events to detect when the target player joins the party
    local connection
    connection = RemoteEvent.OnClientEvent:Connect(function(...)
        if gameStarted then return end
        
        local args = {...}
        -- Check if this matches the "Party" "UpdateParties" structure
        if args[1] == "Party" and args[2] == "UpdateParties" and type(args[3]) == "table" then
            for _, partyData in pairs(args[3]) do
                if partyData and partyData.players and partyData.partyParams then
                    -- Verify if we are the host of this party
                    if partyData.partyParams.host == LocalPlayer then
                        -- Check if the target player is inside the players list
                        for _, playerObj in pairs(partyData.players) do
                            if typeof(playerObj) == "Instance" and playerObj.Name == playerToInviteName then
                                gameStarted = true
                                print("Player " .. playerToInviteName .. " successfully detected via RemoteEvent! Starting match instantly...")
                                
                                if connection then
                                    connection:Disconnect()
                                end
                                
                                -- Format the mode and parameters dynamically
                                local payloadMode = Mode or "survival"
                                local payloadDifficulty = difficulty or "Fallen"

                                -- If the mode is strictly Hardcore, include the difficulty parameter
                                if payloadMode:lower() == "hardcore" then
                                    Event:InvokeServer(
                                        "Multiplayer",
                                        "v2:start",
                                        {
                                            difficulty = payloadDifficulty,
                                            mode = "hardcore",
                                            count = 2
                                        }
                                    )
                                else
                                    -- For other modes (like Frost, Fallen, Molten, etc.), exclude/omit difficulty
                                    Event:InvokeServer(
                                        "Multiplayer",
                                        "v2:start",
                                        {
                                            mode = payloadMode:lower(),
                                            count = 2
                                        }
                                    )
                                end
                                break
                            end
                        end
                    end
                end
            end
        end
    end)

    -- MAIN LOOP: Handles the party cycling logic without blocking the match starter
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
            coroutine.wrap(function()
                Event:InvokeServer("Party", "AcceptInvite", hostPlayer)
            end)()
            
            print("Trying to accept invite...")
            task.wait(1)
        end
    end)
end

return Multiplayer

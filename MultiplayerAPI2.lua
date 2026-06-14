local Multiplayer = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Event = ReplicatedStorage:WaitForChild("RemoteFunction")
local LocalPlayer = Players.LocalPlayer

-- The specific Place ID allowed to run this code
local TARGET_PLACE_ID = 3260590327

function Multiplayer.StartHost(playerToInviteName, Mode)
    if game.PlaceId ~= TARGET_PLACE_ID then return end

    print("[" .. LocalPlayer.Name .. "] Starting party as Host for Mode: " .. tostring(Mode))

    -- Create the party
    Event:InvokeServer("Party", "CreateParty", nil)
    
    -- Locate UI paths
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    local partyMembers = playerGui
        :WaitForChild("ReactLobbyParty")
        :WaitForChild("party")
        :WaitForChild("currentParty")
        :WaitForChild("partyMembers")

    local lastInviteTime = 0
    local inviteCooldown = 2 -- Seconds between re-invites

    print("Entering INFINITE invitation loop. Will invite " .. playerToInviteName .. " until slot '1' exists...")

    -- Infinite loop: will only stop when the player joins
    while true do
        -- INSTANT CHECK: If player is in the slot, break immediately!
        if partyMembers:FindFirstChild("1") then
            break
        end

        -- Check if target player is in the server
        local targetPlayer = Players:FindFirstChild(playerToInviteName)
        
        if targetPlayer then
            -- Only invite if the invite cooldown has passed
            if os.clock() - lastInviteTime >= inviteCooldown then
                print("Sending/Re-sending invite to: " .. targetPlayer.Name)
                
                -- Wrap in coroutine so InvokeServer doesn't block the loop's speed
                coroutine.wrap(function()
                    Event:InvokeServer("Party", "InvitePlayer", targetPlayer)
                end)()
                
                lastInviteTime = os.clock()
            end
        else
            print("Waiting for " .. playerToInviteName .. " to appear in the server list...")
        end

        -- Small incremental check interval for instant response
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

    print("[" .. LocalPlayer.Name .. "] Searching for host: " .. HostName)
    
    local hostPlayer = Players:FindFirstChild(HostName)
    if not hostPlayer then
        hostPlayer = Players:WaitForChild(HostName, 15)
    end
    
    if not hostPlayer then
        warn("Could not join lobby: Host " .. HostName .. " not found.")
        return
    end

    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    local partyMembers = playerGui
        :WaitForChild("ReactLobbyParty")
        :WaitForChild("party")
        :WaitForChild("currentParty")
        :WaitForChild("partyMembers")

    print("Spamming AcceptInvite infinitely until UI frame '1' appears...")

    -- Infinite loop: will keep trying to accept until joined
    while true do
        if partyMembers:FindFirstChild("1") then
            break
        end

        coroutine.wrap(function()
            Event:InvokeServer("Party", "AcceptInvite", hostPlayer)
        end)()

        task.wait(0.3)
    end

    print("Successfully accepted invite and entered " .. hostPlayer.Name .. "'s lobby UI!")
end

return Multiplayer

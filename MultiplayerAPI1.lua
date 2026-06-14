local Multiplayer = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Event = ReplicatedStorage:WaitForChild("RemoteFunction")
local LocalPlayer = Players.LocalPlayer

-- The specific Place ID allowed to run this code
local TARGET_PLACE_ID = 3260590327

function Multiplayer.StartHost(playerToInviteName, maxWaitTimeout, Mode)
    if game.PlaceId ~= TARGET_PLACE_ID then return end

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
    
    print("Waiting for player to join the party UI...")
    
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    local partyMembers = playerGui
        :WaitForChild("ReactLobbyParty")
        :WaitForChild("party")
        :WaitForChild("currentParty")
        :WaitForChild("partyMembers")

    local timeout = maxWaitTimeout or 30 
    local timeElapsed = 0
    local memberJoined = false

    while timeElapsed < timeout do
        if partyMembers:FindFirstChild("1") then
            memberJoined = true
            break
        end
        task.wait(0.5)
        timeElapsed = timeElapsed + 0.5
    end

    if not memberJoined then
        warn("Host timeout: Player did not join the party UI within " .. tostring(timeout) .. " seconds.")
        return
    end
    
    print("Player successfully detected in party slot [1]! Starting match...")
    
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

function Multiplayer.JoinLobby(HostName, maxWaitTimeout)
    -- Check if the current place ID matches, if not, return early
    if game.PlaceId ~= TARGET_PLACE_ID then 
        return 
    end

    print("[" .. LocalPlayer.Name .. "] Searching for host: " .. HostName)
    
    local hostPlayer = Players:FindFirstChild(HostName)
    if not hostPlayer then
        hostPlayer = Players:WaitForChild(HostName, 15)
    end
    
    if not hostPlayer then
        warn("Could not join lobby: Host " .. HostName .. " not found.")
        return
    end

    -- --- SPAM ACCEPT LOGIC START ---
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    local partyMembers = playerGui
        :WaitForChild("ReactLobbyParty")
        :WaitForChild("party")
        :WaitForChild("currentParty")
        :WaitForChild("partyMembers")

    local timeout = maxWaitTimeout or 20
    local timeElapsed = 0
    local successfullyJoined = false

    print("Spamming AcceptInvite until UI frame '1' appears...")

    while timeElapsed < timeout do
        -- Check if we are already inside the party frame
        if partyMembers:FindFirstChild("1") then
            successfullyJoined = true
            break
        end

        -- Fire the remote function to accept the invite
        coroutine.wrap(function()
            Event:InvokeServer("Party", "AcceptInvite", hostPlayer)
        end)()

        -- Wait a brief moment before checking/firing again to prevent network choking
        task.wait(0.3)
        timeElapsed = timeElapsed + 0.3
    end

    if successfullyJoined then
        print("Successfully accepted invite and entered " .. hostPlayer.Name .. "'s lobby UI!")
    else
        warn("Join timeout: Failed to join " .. hostPlayer.Name .. "'s lobby within " .. tostring(timeout) .. " seconds.")
    end
    -- --- SPAM ACCEPT LOGIC END ---
end

return Multiplayer

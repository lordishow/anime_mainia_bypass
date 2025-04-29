local loaded = getgenv().lord_anime_mainia_bypass_loaded
if loaded then 
    print("bypass already loaded")
    return
end
getgenv().lord_anime_mainia_bypass_loaded = true

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Function to safely get the Ban RemoteEvent
local function waitForCharacterBan()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait(999)
    local banEvent = char:FindFirstChild("Ban") or char:WaitForChild("Ban", 999) -- timeout to prevent infinite yield
    return char, banEvent
end

-- Initial character/ban
local Character, Ban_RemoteEvent = waitForCharacterBan()

-- Update on character respawn
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Ban_RemoteEvent = newChar:WaitForChild("Ban", 999)
end)

-- Hook setup
local mt = getrawmetatable(game)
setreadonly(mt, false)
local oldNamecall = mt.__namecall

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()

    if not checkcaller() and (method == "FireServer" or method == "InvokeServer") and self == Ban_RemoteEvent then
        local args = {...}
        local callingScript = "Unknown"
        
        local success, scriptObj = pcall(function()
            return getfenv(2).script
        end)
        
        if success and typeof(scriptObj) == "Instance" then
            callingScript = scriptObj:GetFullName()
        end
        
        local info = string.format("[BLOCKED]: %s:FireServer(%s) Method", self:GetFullName(), unpack(args))
        warn(info)
        return -- block
    end

    return oldNamecall(self, ...)
end)

-- Kick protection
local oldNamecallKick
oldNamecallKick = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()

    if not checkcaller() and self == LocalPlayer and method == "Kick" then
        warn(string.format("[BLOCKED] :Kick('%s') Method", ...))
        return -- block
    end

    return oldNamecall(self, ...)
end))

setreadonly(mt, true)

print("bypass loaded successfully")

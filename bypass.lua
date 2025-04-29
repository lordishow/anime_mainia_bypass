local loaded = getgenv().lord_anime_mainia_bypass_loaded

if loaded then 
    print("bypass already loaded")
    return
end
getgenv().lord_anime_mainia_bypass_loaded = true

local LocalPlayer = game:GetService("Players").LocalPlayer
local Character = LocalPlayer.Character

local Ban_RemoteEvent = Character.Ban
LocalPlayer.CharacterAdded:Connect(function(nc) 
	Character = nc
	Ban_RemoteEvent = nc.Ban
end)
-- Hook setup
local rs = game:GetService("ReplicatedStorage")
local mt = getrawmetatable(game)
setreadonly(mt, false)

local oldNamecall = mt.__namecall

mt.__namecall = newcclosure(function(self, ...)
	local method = getnamecallmethod()

	if ((method == "FireServer" or method == "InvokeServer") and not checkcaller()) and self == Ban_RemoteEvent then
		local args = {...}
		local callingScript = "Unknown"
		
		-- Attempt to get the script that made the call
		local success, scriptObj = pcall(function()
			return getfenv(2).script
		end)
		
		if success and typeof(scriptObj) == "Instance" then
			callingScript = scriptObj:GetFullName()
		end
		
		local info = string.format("[BLOCKED]: %s:FireServer(%s) Method", self:GetFullName(), unpack(args))
		print(info)
		return
	else
		return oldNamecall(self, ...)
	end
end)

local oldNamecallKick
oldNamecallKick = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()

    if not checkcaller() and self == LocalPlayer and method == "Kick" then
        print(string.format("[BLOCKED] :Kick('%s') Method", unpack({...})))
        return -- Just return nothing, block the kick
    end

    return oldNamecall(self, ...)
end))

setreadonly(mt, true)

print("bypass loaded successfully")

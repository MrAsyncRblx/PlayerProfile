local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local PlayerProfile = require(ServerScriptService:WaitForChild("PlayerProfile"))

local Profiles = {}

Players.PlayerAdded:Connect(function(player)
	--Construct a new PlayerProfile
	local profile = PlayerProfile.new(player)
	Profiles[player] = profile
	
	profile.VisitCount:Increment(1)
end)

Players.PlayerRemoving:Connect(function(player)
	if (Profiles[player]) then
		Profiles[player] = nil
	end
end)
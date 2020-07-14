local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local PlayerProfile = require(ServerScriptService:WaitForChild("PlayerProfile"))

Players.PlayerAdded:Connect(function(player)
	--Construct a new PlayerProfile
	local profile = PlayerProfile.new(player)
	
	profile.VisitCount:Increment(1)
end)
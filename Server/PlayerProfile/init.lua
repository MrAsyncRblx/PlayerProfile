local PlayerProfile = {}
PlayerProfile.__index = PlayerProfile


--//Api
local DataStore2 = require(script:WaitForChild("DataStore2"))

--//Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

--//Classes
local MaidClass = require(ReplicatedStorage.Modules:WaitForChild("Maid"))

--//Controllers

--//Locals
local DefaultData = require(script:WaitForChild("DefaultData"))

local VALUE_EXCHANGE = {
	["boolean"] = "BoolValue",
	["string"] = "StringValue",
	["table"] = "StringValue",
	["number"] = "NumberValue"
}

local IGNORE_LIST = {
	"VisitCount"
}


--//Constructor
function PlayerProfile.new(player)
	local self = setmetatable({
		Player = player,
		
		_Maid = MaidClass.new()
	}, PlayerProfile)
	
	--Create container for replicated data
	local repDataFolder = Instance.new("Folder")
	repDataFolder.Name = player.UserId
	repDataFolder.Parent = ReplicatedStorage.ReplicatedData
	
	
	self.DataContainer = repDataFolder
	self._Maid:GiveTask(repDataFolder)
	
	
	--Listen for player leaving, automatically cleanup
	self._Maid:GiveTask(Players.PlayerRemoving:Connect(function(oldPlayer)	
		if (oldPlayer.UserId == player.UserId) then
			self:Unload()
		end
	end))
	
	
	--Replicated data
	for key, value in pairs(DefaultData) do
		self[key] = DataStore2(key, player)
		
		--Don't replicate node if in ignore list
		if (table.find(IGNORE_LIST, key)) then continue end
		local cachedValue = self[key]:Get(value)
		
		--Instance physical data node
		local replicatedValue = Instance.new(VALUE_EXCHANGE[type(cachedValue)])
		replicatedValue.Parent = self.DataContainer
		replicatedValue.Name = key
		
		--Set value, tables must be encoded to JSON to replicate properly
		replicatedValue.Value = (type(cachedValue) == "table" and HttpService:JSONEncode(cachedValue) or cachedValue)
		
		--Whenever we make a change to the data, this callback will be called
		--This will automatically replicate any changes to the client
		self[key]:OnUpdate(function(newValue)
			replicatedValue.Value = (type(newValue) == "table" and HttpService:JSONEncode(newValue) or newValue)
		end)
		
		self._Maid:GiveTask(replicatedValue)
	end
	
		
	return self
end


--//Called automatically when player leaves
function PlayerProfile:Unload()
	self._Maid:Destroy()
end


return PlayerProfile
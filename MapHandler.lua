-- Services
local SSS = game:GetService("ServerScriptService")
local MapModule = require(SSS.ModuleScripts.MapModule)
local PlayerModule = require(SSS.ModuleScripts.PlayerModule)

local Players = game:GetService("Players")

-- Folders
local MapsFolder = workspace:WaitForChild("Maps")
local LoadedMaps = workspace:WaitForChild("LoadedMaps")


-- Properties / Configs
local currentMap = MapsFolder:WaitForChild("Forest"):WaitForChild("Forest1")  -- starting map
local allowSpawning = true


task.wait(5)	

while allowSpawning do
	
	-- Load one map
	local newMap = MapModule.StartLoad(currentMap, PlayerModule.GetHRPsTable())
	-- Use the new map as the next base	( To Be Changed )
	currentMap = newMap
	
	

	task.wait(0.1)  -- delay so Roblox doesn’t crash
end

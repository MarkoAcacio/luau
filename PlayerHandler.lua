-- Services
local SSS = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

-- Modules
local PlayerModule = require(SSS.ModuleScripts.PlayerModule)
local MapModule = require(SSS.ModuleScripts.MapModule)
local EnvModule = require(SSS.ModuleScripts.EnvModule)
local MusicModule = require(SSS:WaitForChild("ModuleScripts").MusicModule)

-- Events
local TopGuiEvent = game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("TopGui")

-- Handle players joining
Players.PlayerAdded:Connect(function(player)
	local characterConnection  -- The loop for the distance
	
	player.CharacterAdded:Connect(function(character)
		
		local humanoid = character:WaitForChild("Humanoid")
		local hrp = character:WaitForChild("HumanoidRootPart")

		task.wait()
		
		PlayerModule.addCharacter(character)  -- Add Character's HRP to a table
		local getMeters, conn = MapModule.calculateDistance(character) 
		characterConnection = conn
		
		while character.Parent do
			if not hrp or not hrp.Parent then break end
			local distance = getMeters()
			
			TopGuiEvent:FireClient(player, distance)
			task.wait(0.1)
		end
	end)
	
	
	player.CharacterRemoving:Connect(function(player)  -- On player leave / death
		PlayerModule.removeCharacter(player)
		
		if characterConnection then  -- Remove Connection
			characterConnection:Disconnect()
			characterConnection = nil
		end
		
		
	end)
end)

-- Handle players already in the game (studio test)
for _, player in ipairs(Players:GetPlayers()) do
	if player.Character then
		PlayerModule.addCharacter(player.Character)
		MapModule.calculateDistance(player.Character)
	end
end



EnvModule.StartCycle() -- STARTS THE DAY/NIGHT CYCLE

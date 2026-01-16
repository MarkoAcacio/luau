local EnvModule = {}

-- Services

local SSS = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local ZombieModule = require(SSS:WaitForChild("ModuleScripts").ZombieModule)

-- Configs

local lastPhase = nil
local currentCycle = nil
local timeCycle = 2 * 60 -- Seconds
local changeSpeed = 24 / timeCycle -- 0.05hrs per real second
local zombieProperties = {  -- Change This Based On The Time Of Day
	HP = 100,
	Speed = 10,
	Damage = 20
}

local function getPhase(hour)
	if hour >= 4 and hour < 6 then
		return "Dawn"
	elseif hour >= 6 and hour < 16 then
		return "Day"
	elseif hour >= 16 and hour < 18 then
		return "Sunset"
	else
		return "Night"
	end
end


------------------------------------------------------------ Cycle Properties --------------------------------------------------------------


local function DayTime()
	print("DayTime")
	currentCycle = "Day"
	local zombieProperties = {  -- Change This Based On The Time Of Day
		HP = 100,
		Speed = 10,
		Damage = 20
	}
	
	ZombieModule.NewZombieProperties(zombieProperties, "Day")
end

local function NightTime()
	print("NightTime")
	currentCycle = "Night"
	local zombieProperties = {  -- Change This Based On The Time Of Day
		HP = 100,
		Speed = 25,
		Damage = 20
	}
	ZombieModule.NewZombieProperties(zombieProperties, "Night")
end

local function DawnTime()
	currentCycle = "Dawn"
	local zombieProperties = {  -- Change This Based On The Time Of Day
		HP = 100,
		Speed = 15,
		Damage = 20
	}
	ZombieModule.NewZombieProperties(zombieProperties, "Dawn")
end

local function Sunset()
	currentCycle = "Sunset"
	local zombieProperties = {  -- Change This Based On The Time Of Day
		HP = 100,
		Speed = 15,
		Damage = 20
	}
	ZombieModule.NewZombieProperties(zombieProperties, "Sunset")
	
	-- Add the Sunset Warning Here.
end


--------------------------------------------------------------------------------------------------------------------------------------------

function EnvModule.StartCycle()
	
	RunService.Heartbeat:Connect(function(dt)
		Lighting.ClockTime = (Lighting.ClockTime + changeSpeed * dt) % 24
		
		local hour = math.floor(Lighting.ClockTime)
		
		local phase = getPhase(hour)

			if phase ~= lastPhase then
				lastPhase = phase

			if phase == "Dawn" then DawnTime() currentCycle = "Dawn" print(currentCycle)
			elseif phase == "Day" then DayTime() currentCycle = "Day" print(currentCycle)
			elseif phase == "Sunset" then Sunset() currentCycle = "Sunset" print(currentCycle)
			else NightTime() currentCycle = "Night" print(currentCycle)
				end
			end
		
	end)
	
end

function EnvModule.GetCurrentCycle()
	return currentCycle
end

return EnvModule

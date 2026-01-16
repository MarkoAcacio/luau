local MapModule = {}

-- Services

local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

-- Folders

local StructuresFolder = ServerStorage:WaitForChild("Structures")
local MapsFolder = workspace:WaitForChild("Maps")
local mapTemplate = MapsFolder:WaitForChild("Forest"):WaitForChild("Forest1")  -- starting map



-- Configs
local distanceThreshold = 3000  -- if player is within 3000 studs ( 840m or 10Maps at once ) of the end / start, load the next map
local LoadedMaps = {}
local unloadedPosX = {}  -- When the player is going back to the spawn / going negative x (-x)
local unloadedNegX = {} -- When the player is going forward / to the finish line ( +x )
local lastMeter = 0         -- last generation point
local GENERATE_STEP = 1000   -- generate every x meters     at every 800meters on the x meters the player will see the structure.
-- THIS IS BASED ON THE DISTANCE THRESHOLD  ( MAKE IT SO THAT NEXT TIME ITS RANDOM!! )


function MapModule.StartLoad(MapModel, HRPs)
	-- Load the next map
	
	local RootA = MapModel:WaitForChild("RootA")
	local RootB = MapModel:WaitForChild("RootB")
	
	
	for character, hrp in pairs(HRPs) do
		local humanoid = character:FindFirstChild("Humanoid")
		if hrp and hrp.Parent then
			local distanceToEnd = (hrp.Position - RootB.Position).Magnitude  -- Calculates the distance of player & RootB
			local distanceToStart = (hrp.Position - RootA.Position).Magnitude
			
			if distanceToEnd <= distanceThreshold then -- If Near The End, Generate Map
				
				local mapToSpawn = getUnloadedMap(humanoid)
				   -- REFER TO THE FUNCTION BELOW
				   
				if mapToSpawn then  -- If there's an unloaded map, load it instead of the template
					local ClonedModel = mapToSpawn:Clone()   -- Clone Map Model
					ClonedModel:PivotTo(RootB.CFrame)
					ClonedModel.Parent = workspace:WaitForChild("LoadedMaps")
					table.insert(LoadedMaps, ClonedModel)
					
					return LoadedMaps[#LoadedMaps]
					
				else  -- No unloaded map, continue normally
					local ClonedModel = mapTemplate:Clone()   -- Clone Map Model
					ClonedModel:PivotTo(RootB.CFrame)
					ClonedModel.Parent = workspace:WaitForChild("LoadedMaps")

					table.insert(LoadedMaps, ClonedModel)


					return LoadedMaps[#LoadedMaps]  --The Latest Generated Map
					
				end

			end

			if distanceToStart >= distanceThreshold then -- If Far, Delete Map
			
				storeUnloadedMap(humanoid,MapModel)
				
				-- Find this map in LoadedMaps and remove it
				for i, map in ipairs(LoadedMaps) do
					if map == MapModel then
						table.remove(LoadedMaps, i)   -- REMOVE FIRST THEN INSERT TO A NEW ARRAY
						MapModel.Parent = nil
						break
					end
				end
				
				-- Return the new last map (if any)
				return LoadedMaps[#LoadedMaps]

			end
		end
	end
	
	return MapModel  -- Returns the last generated map
	
end


function checkPlayerDistance(humanoid)   -- Returns whether the player is moving on an +X or -X
	-- Check if the player is near the end or start of the current map
	local movingPosX = humanoid.MoveDirection.X > 0
	local movingNegX = humanoid.MoveDirection.X < 0
	return movingPosX, movingNegX
end



function getUnloadedMap(humanoid)
	-- Get an unloaded map based on player movement direction
	local movingPosX, movingNegX = checkPlayerDistance(humanoid)
	local mapToSpawn

	if movingPosX then
		if #unloadedPosX > 0 then
			mapToSpawn = table.remove(unloadedPosX)
		end
	end

	if movingNegX then
		if #unloadedNegX > 0 then
			mapToSpawn = table.remove(unloadedNegX)
		end
	end

	
	return mapToSpawn -- can be nil if no map exists
end



function storeUnloadedMap(humanoid, MapModel)
	
	local movingPosX, movingNegX = checkPlayerDistance(humanoid)

	if movingPosX then
		MapModel.Parent = nil-- To Stop Rendering
		table.insert(unloadedNegX, MapModel) -- Means the player is going forward / to the finish line. Then store.
	end

	if movingNegX then
		MapModel.Parent = nil  -- To Stop Rendering
		table.insert(unloadedPosX, MapModel)  -- Means the player is going back to the spawn / start line. Then store.

	end
	
end



local function generateStructure(currentMeters)
	-- Generate a structure at a given distance in meters

	local targetMap = LoadedMaps[#LoadedMaps]

	if currentMeters - lastMeter >= GENERATE_STEP then  -- Basically minuses the last meter to the current meter then the meter required to generate a new structure.
		lastMeter = currentMeters  -- update last generation point


		local spawnFolder = targetMap:WaitForChild("Spawns")
		local Structure = StructuresFolder:WaitForChild("placeholder")  -- Template Structure

		local clonedStructure = Structure:Clone()
		local structureFolder = targetMap:WaitForChild("Structure")
		clonedStructure.Parent = structureFolder


		-- Pick a spawn point inside the latest map
		local spawnPoint = spawnFolder:FindFirstChild("rand1")  -- Add a randomizer function next time
		
		if clonedStructure.PrimaryPart then
			clonedStructure:PivotTo(CFrame.new(spawnPoint.Position))
		end
		
	end
	
end


local UPDATE_INTERVAL = 0.15  -- seconds between checks
local accumulator = 0
local STUD_TO_METER = 0.28

function MapModule.calculateDistance(playerCharacter)
	local hrp = playerCharacter:WaitForChild("HumanoidRootPart")
	local startPart = workspace:WaitForChild("StartingPoint")
	local startX = startPart.Position.X  -- starting point X

	-- heartbeat connection (optional, just to keep it running)
	local connection
	connection = RunService.Heartbeat:Connect(function(dt)
		
		-- BASICALLY CAPS THE LOOP TO 60FPS
		accumulator = accumulator + dt
		if accumulator < UPDATE_INTERVAL then
			return
		end
		accumulator = 0
		
		
		if not hrp or not hrp.Parent then
			connection:Disconnect()
			return
		end
		
		
	end)

	-- getter function for distance along X
	local function getMeters()
		-- signed distance: positive if hrp.X > startX, negative if hrp.X < startX
		local signedDistance = hrp.Position.X - startX
		-- clamp to 0 if you never want negative distance
		local clampedDistance = math.max(signedDistance, 0)
		-- convert to meters
		local meters = clampedDistance * STUD_TO_METER
		
		generateStructure(meters)
		
		return math.floor(meters)
	end

	return getMeters, connection
end






return MapModule
 

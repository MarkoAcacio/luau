local NPCModule = {}

-- SERVICES
local TweenService = game:GetService("TweenService")
local ChatService = game:GetService("Chat")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- FOLDERS
local NPCFolder = game.Workspace:WaitForChild("NPCFolder")
local PointFolder = game.Workspace:WaitForChild("Point")
local UIEvents = ReplicatedStorage:WaitForChild("UIEvents")
local dialogueEvent = UIEvents:WaitForChild("dialogueEvent")

-- POINTS

local counterPoint = PointFolder:WaitForChild("CounterPoint")
local midCounterPoint = PointFolder:WaitForChild("MidCounterPoint")
local spawnPoint = PointFolder:WaitForChild("SpawnPoint")
local disappearPoint = PointFolder:WaitForChild("DisappearPoint")

-- Languanges

NPCModule.Tagalog = {
	"Ano nga po ",
	"Pabile po ng ",
	"Pabile nga po ng  ",
	"Pakibilisan po, ", }

NPCModule.English = {
	"Hey… I’m cooking something special tonight, I need ",
	"Hi there… could you bring me some ",
	"Hello… it’s been a long day, I need ",
	"Hey… I almost forgot I heard your fan talked before.. Anyway can you fetch me ",
	"Hi… do you have a moment? I need ",
	"Hello there… it’s quiet tonight, but I want ",
	"Hello… I swear I heard something move… bring me ",
	"Hi… you don’t mind, do you? I need ",
	"Hello… I feel like something’s missing… can you get me ",
	"Hey… it’s dark outside, but I could use some ",
	"Hi… I’ve been thinking about this all day, get me ",
	"Hey… don’t you feel like time’s slower tonight? I need ",
	"Hey… strange things are happening around here lately... bring me ",
	"Hi… the lights flickered just now, I need ",
	"Hey, you stayed late too? Can you grab me ",
	"Hi… thought I saw a shadow… anyway, bring me ",
	"Hi there.. I keep hearing *psst* sounds on my way here, please get me ",
}

local function randomizeNPC()
	local folderSize = #NPCFolder:GetChildren()
	local randomNum = math.random(1, folderSize)  -- Gets a random number between 1 and the number of children in the folder.
	
	local NPC = NPCFolder:GetChildren()[randomNum]
	
	return NPC
	-- Has a predetermined list of NPCs that will spawn.
end

local function sendEventToUI(chosenItems, itemQuantity)   -- Sends the chosenItemsTable and itemQuantityTable to all clients.
	-- This function handles the UI.
	
	UIEvents.orderedItems:FireAllClients(chosenItems, itemQuantity)
	
end

local function BuildItemListString(quantityTable, itemsTable)  -- Builds a string for the NPC Chat
	local parts = {}

	for key, quantity in pairs(quantityTable) do
		local itemName = itemsTable[key]

		if itemName then
			table.insert(parts, "x" .. quantity .. " " .. itemName)
		end
	end

	return table.concat(parts, ", ")
end

local function startGiving(chosenItems, ItemQuantityTable, humanoid)   -- Receives the item name and the value of the item.
		print(chosenItems)
	for _, NPC in pairs(NPCFolder:GetChildren()) do
		if NPC.Name ~= "Template" then
			
			local ProximityPrompt = NPC:WaitForChild("Head"):FindFirstChild("giveItemButton") -- Taakes the ProximityPrompt from the NPC's head.
			
			ProximityPrompt.Triggered:Connect(function(player)
				print("TRIGGERED")
				
				-- make script that retrieves the items from the player's inventory
				
				local character = player.Character
				
				if character then
					
					local equipped = character:FindFirstChildWhichIsA("Tool")  -- GETS THE EQUIPPED TOOL
					if not equipped then return false, nil end  -- If there's no equipped, return nil.

					local foundItem = false  -- Flag to track if we found the correct item
		
					for key, itemName in pairs(chosenItems) do  -- loops through the chosenItems Table
						if equipped.Name == itemName then -- Checks if equipped tool is present in the chosen items.
							
							-- HANDLE  LOGIC HERE TO NEGATE THE ITEM AND ADD IT TO THE COUNTER.
							if ItemQuantityTable[key] > 0 then
								equipped:Destroy()
								ItemQuantityTable[key] -= 1
								sendEventToUI(chosenItems,ItemQuantityTable)
								foundItem = true
							end
							 break -- if true, stop loop

						end
					end	
					
					if not foundItem then
						warn("Incorrect Item. Please give the correct item.")

						local head = humanoid.Parent:FindFirstChild("Head")
						local text = "I don't need that, Give me " .. BuildItemListString(ItemQuantityTable, chosenItems)

						ChatService:Chat(head, text )
						return
					end
					
				end
			end)
		end
	end
end


local function getChosenItem(orderedItems)
	
	-- ADD A LOGIC HERE TO DETERMINE WHAT NIGHT IS IT. AND AS  NIGHT PROGRESSES NEW ITEMS WILL BE UNLOCKED
	
	
	local items = {
		"Candy",
		"Canned Food",    
		"Noodles",
		"Ingredients",
		"Biscuits"
	}

	local Tagalogitems = {
		"Kendi",
		"De Lata",    
		"Noodles",
		"Pang-Sahog",
		"Biskwit"
	}

	-- Cap orderedItems to 5
	if orderedItems > 5 then
		orderedItems = 5
	end

	local chosenItems = {}
	local availableIndices = {1, 2, 3, 4, 5}

	for i = 1, orderedItems do  -- Adds the items in a table and creates an index for each one.
		local randIndex = math.random(1, #availableIndices)
		local itemIndex = availableIndices[randIndex]
		table.insert(chosenItems, items[itemIndex])
		table.remove(availableIndices, randIndex) -- prevent repeats
	end

	return chosenItems

end


function generateNPCMessage(humanoid)
	
	local numberOfItems = {
		[1] = {text = "x1 ", val = 1},
		[2] = {text = "x2 ", val = 2},
		[3] = {text = "x3 ", val = 3},
		[4] = {text = "x4 ", val = 4},
	}
	
	local orderedItems = math.random(1,5)
	local chosenItem = getChosenItem(orderedItems) -- RETRIEVE ITEM
	
	-- TEXT RELATED
	local startingText = NPCModule.English[math.random(1, #NPCModule.English)]  -- CHANGE THIS TO TOGGLE  TAGALOG/ENGLISH
	
	local head = humanoid.Parent:FindFirstChild("Head")
	
	if head then
		  -- First Chat
		dialogueEvent:FireAllClients(startingText)
		task.wait(6)
		
		local chosenItemsString = ""
		local itemCount = 0  -- Counter to manage when to add a comma
		local itemQuantityTable = {}

		for i, item in pairs(chosenItem) do
			-- For each chosen item, randomly pick a number from numberOfItems
			local itemQuantity = numberOfItems[math.random(1, #numberOfItems)]

			-- Append item and quantity to the string
			if itemCount > 0 then
				chosenItemsString = chosenItemsString .. ", "  -- Add a comma only if it's not the first item
			end
			chosenItemsString = chosenItemsString .. item .. " " .. itemQuantity.text
			itemQuantityTable[i] = itemQuantity.val
			itemCount = itemCount + 1
		end

		-- Second chat message with the full request
		
		dialogueEvent:FireAllClients(chosenItemsString)
		
		sendEventToUI(chosenItem, itemQuantityTable)  -- SENDTHE TABLE  TO LOCAL SCRIPT
		startGiving(chosenItem, itemQuantityTable, humanoid) -- ALLOW GIVING FUNCTION. ( THIS WILL TURN ON THE PROXIMITY BUTTON EVENT TO START THE SCRIPT FOR GIVING REQUESTED ITEM )	
	else
		warn("Head not found in character!")
	end
	
	
	--[[if languange == "English" then
		return English[math.random(1, #English)]
	else
		
	end]]
end


local function MoveNpc(humanoid, location)
	
	if location == disappearPoint then
		-- start animation to turn to road
	end
	
	local connection
	local targetReached = false
	
	-- TweenInfo
	local turnToCounter = TweenInfo.new(0.8, Enum.EasingStyle.Cubic,Enum.EasingDirection.InOut, 0 )
	local turnToRoad = TweenInfo.new(0.8, Enum.EasingStyle.Cubic,Enum.EasingDirection.InOut, 0 )

	humanoid:MoveTo(location)  -- MOVES TO MIDPOINT
	humanoid.MoveToFinished:Wait()
	
	local HRP = humanoid.Parent.PrimaryPart

	local currentCFrame = HRP.CFrame
	local newCFrame = currentCFrame * CFrame.Angles(0, math.rad(-90), 0)

	local tween = TweenService:Create(HRP, turnToCounter, {CFrame = newCFrame})
	task.wait(0.5)
	tween:Play()
	tween.Completed:Wait()
	task.wait(0.5)

	humanoid:MoveTo(counterPoint.CFrame.Position) -- MOVES TO COUNTER
	humanoid.MoveToFinished:Wait()
	
	task.wait(1)
	generateNPCMessage(humanoid)
	
	
end

function NPCModule.StartSpawn()
	local NPC = randomizeNPC()
	
	local clonedNPC = NPC:Clone()
	clonedNPC.Parent = workspace
	clonedNPC.Name = "NPC"   -- THIS IS IMPORTANT FOR THE PROXIMITY BUTTON!
	clonedNPC.Parent = workspace:WaitForChild("NPCFolder")
	local HRP = clonedNPC:FindFirstChild("HumanoidRootPart")
	local humanoid = clonedNPC:FindFirstChild("Humanoid")
	
	-- TweenInfo
	local turnToCounter = TweenInfo.new(0.8, Enum.EasingStyle.Cubic,Enum.EasingDirection.InOut, 0 )
	local turnToRoad = TweenInfo.new(0.8, Enum.EasingStyle.Cubic,Enum.EasingDirection.InOut, 0 )
	
	
	
	if HRP and humanoid then
		HRP.Anchored = false
		HRP.CFrame = spawnPoint.CFrame
		clonedNPC.Humanoid.WalkSpeed = 20
		clonedNPC.Humanoid.JumpPower = 0
		task.wait(1)
		MoveNpc(humanoid,midCounterPoint.CFrame.Position)
		
		
	end
	
	
end



return NPCModule

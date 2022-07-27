 ---Removes level requirement from an item
 ---@param item gameItemData
 local function removeLevelRequirementForItem(item)
	if item:HasStatData(gamedataStatType.Level) then
		Game.GetStatsSystem():RemoveAllModifiers(item:GetStatsObjectID(), gamedataStatType.Level, true)
	end
end

---Removes level requirement and equip prerequisites for all items in player's inventory
local function removeEquipRequirements()
	local inventoryManager = Game.GetScriptableSystemsContainer():Get('EquipmentSystem'):GetPlayerData(Game.GetPlayer()):GetInventoryManager()
	local items = inventoryManager:GetPlayerInventory({})
	for _, item in ipairs(items) do
		removeLevelRequirementForItem(item)
	end
	for _, record in pairs(TweakDB:GetRecords("gamedataItem_Record")) do
		TweakDB:SetFlat(record:GetID() .. ".equipPrereqs", nil)
	end
	for _, record in pairs(TweakDB:GetRecords("gamedataWeaponItem_Record")) do
		TweakDB:SetFlat(record:GetID() .. ".equipPrereqs", nil)
	end
	for _, record in pairs(TweakDB:GetRecords("gamedataClothing_Record")) do
		TweakDB:SetFlat(record:GetID() .. ".equipPrereqs", nil)
	end
end

registerForEvent("onInit", function()
	local isLoaded = Game.GetPlayer() and Game.GetPlayer():IsAttached() and not Game.GetSystemRequestsHandler():IsPreGame()

	if isLoaded then
		removeEquipRequirements()
	end

	Observe('QuestTrackerGameController', 'OnInitialize', function()
		if not isLoaded then
			isLoaded = true
			removeEquipRequirements()
		end
	end)

	Observe('QuestTrackerGameController', 'OnUninitialize', function()
		if Game.GetPlayer() == nil then
			isLoaded = false
		end
	end)

	Override("gameInventoryScriptCallback", "OnItemAdded", function(self, itemID, itemData, flaggedAsSilent)
		removeLevelRequirementForItem(itemData)
	end)
end)

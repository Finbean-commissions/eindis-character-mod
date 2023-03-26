----Welcome to the "main.lua" file! Here is where all the magic happens, everything from functions to callbacks are dEindis_Character.
--Startup
local mod = RegisterMod("Eindis Character Mod", 1)
local json = require("json")
local game = Game()
local rng = RNG()

--Stat Functions
local function toTears(fireDelay) --thanks oat for the cool functions for calculating firerate!
	return 30 / (fireDelay + 1)
end
local function fromTears(tears)
	return math.max((30 / tears) - 1, -0.99)
end

--Character Functions
---@param name string
---@param isTainted boolean
---@return table
local function addCharacter(name, isTainted) -- This is the function used to determine the stats of your character, you can simply leave it as you will use it later!
	local character = { -- these stats are added to Isaac's base stats.
		NAME = name,
		ID = Isaac.GetPlayerTypeByName(name, isTainted), -- string, boolean
	}
	return character
end
mod.Eindis_Character = addCharacter("Eindis", false)
mod.ThePolycule_Character = addCharacter("The Polycule", true)

mod.Items = {
    Passive = Isaac.GetItemIdByName("Passive Example"),
    Clitty = Isaac.GetItemIdByName("Clitty"),
    Trinket = Isaac.GetTrinketIdByName("Trinket Example"),
    Card = Isaac.GetCardIdByName("Card Example"),
}

function mod:evalCache(player, cacheFlag) -- this function applies all the stats the character gains/loses on a new run.
	---@param name string
	---@param speed number
	---@param tears number
	---@param damage number
	---@param range number
	---@param shotspeed number
	---@param luck number
	---@param tearcolor Color
	---@param flying boolean
	local function addStats(name, speed, tears, damage, range, shotspeed, luck, tearcolor, flying) -- This is the function used to determine the stats of your character, you can simply leave it as you will use it later!
		if player:GetPlayerType(name) then
			if cacheFlag == CacheFlag.CACHE_SPEED then
				player.MoveSpeed = player.MoveSpeed + speed
			end
			if cacheFlag == CacheFlag.CACHE_FIREDELAY then
				player.MaxFireDelay = math.max(1.0, fromTears(toTears(player.MaxFireDelay) + tears))
			end
			if cacheFlag == CacheFlag.CACHE_DAMAGE then
				player.Damage = player.Damage + damage
			end
			if cacheFlag == CacheFlag.CACHE_RANGE then
				player.TearRange = player.TearRange + range * 40
			end
			if cacheFlag == CacheFlag.CACHE_SHOTSPEED then
				player.ShotSpeed = player.ShotSpeed + shotspeed
			end
			if cacheFlag == CacheFlag.CACHE_LUCK then
				player.Luck = player.Luck + luck
			end
			if cacheFlag == CacheFlag.CACHE_TEARCOLOR then
				player.TearColor = tearcolor
			end
			if cacheFlag == CacheFlag.CACHE_FLYING and flying then
				player.CanFly = true
			end
		end
	end
	mod.Eindis_Stats = addStats("Eindis", 0, -1.5, 4, 0, 0, 0, Color(1, 1, 1, 1.0, 0, 0, 0), false)
	mod.ThePolycule_Stats = addStats("The Polycule", 0, 0, 0, 0, 0, 0, Color(1, 1, 1, 1.0, 0, 0, 0), false)
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE,mod.evalCache)

function mod:UseItem(item, _, player, UseFlags, Slot, _)
	if UseFlags & UseFlag.USE_OWNED == UseFlag.USE_OWNED then
		if item == mod.Items.Clitty then
			for i = 1,25 do
				local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.BLUE, 0, player.Position, RandomVector():Resized(10), nil):ToTear()
				tear:AddTearFlags(TearFlags.TEAR_ACCELERATE | TearFlags.TEAR_SPECTRAL | TearFlags.TEAR_PIERCING)
				tear.CollisionDamage = player.Damage * 4
				tear.Scale = player.Damage / 8
				tear:ChangeVariant(TearVariant.BLOOD)
				tear:Update()
			end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.UseItem)

function mod:onTear(players_tear)
    for playerNum = 1, game:GetNumPlayers() do
        local player = game:GetPlayer(playerNum)
		if player:GetName() == mod.Eindis_Character.NAME then
			---@param vector Vector()
			local function spawnClottyTear(vector)
				local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.BLUE, 0, player.Position, vector, nil):ToTear()
				tear.CollisionDamage = player.Damage
				tear.Scale = players_tear.Scale / 1.5
				tear:ChangeVariant(TearVariant.BLOOD)
				tear:Update()
			end

			players_tear:ChangeVariant(TearVariant.BLOOD)
			players_tear:Update()

			if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT, false) == true then
				for i = 1,8 do
					spawnClottyTear(RandomVector():Resized(player.ShotSpeed*10))
				end
			else
				spawnClottyTear(Vector(-(player.ShotSpeed*10), 0))
				spawnClottyTear(Vector((player.ShotSpeed*10), 0))
				spawnClottyTear(Vector(0, -(player.ShotSpeed*10)))
				spawnClottyTear(Vector(0, (player.ShotSpeed*10)))
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, mod.onTear)

function mod:playerSpawn(player)
    if player:GetName() == mod.Eindis_Character.NAME then
        player:AddNullCostume(Isaac.GetCostumeIdByPath("gfx/characters/Eindis-head.anm2"))
		player:SetPocketActiveItem(mod.Items.Clitty)
    end
    if player:GetName() == mod.ThePolycule_Character.NAME then
        player:AddNullCostume(Isaac.GetCostumeIdByPath("gfx/characters/The Polycule-head.anm2"))
		player:AddTearFlags(TearFlags.TEAR_CHAIN | TearFlags.TEAR_SPECTRAL |TearFlags.TEAR_PIERCING)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, mod.playerSpawn)

----Anything below this is for unlocks
--Saving and Loading Data!
local persistentData = {
	unlocks = {
		Eindis = {
			MOM = false,
			MOMSHEART = false,
			ISAAC = false,
			BLUEBABY = false,
			SATAN = false,
			THELAMB = false,
			BOSSRUSH = false,
			HUSH = false,
			DELIRIUM = false,
			MEGASATAN = false,
			MOTHER = false,
			THEBEAST = false,
			ULTRAGREED = false,
			ULTRAGREEDIER = false,
		},
		ThePolycule = {
			MOM = false,
			MOMSHEART = false,
			ISAAC = false,
			BLUEBABY = false,
			SATAN = false,
			THELAMB = false,
			BOSSRUSH = false,
			HUSH = false,
			DELIRIUM = false,
			MEGASATAN = false,
			MOTHER = false,
			THEBEAST = false,
			ULTRAGREED = false,
			ULTRAGREEDIER = false,
		},
	}
}

function mod:GetSaveData()
	if not mod.persistentData then
		if mod:HasData() then
			mod.persistentData = json.decode(mod:LoadData())
		else
			mod.persistentData = {}
		end
	end
		return mod.persistentData
end

if mod:HasData() then
	persistentData = {
		unlocks = {
			Eindis = {
				MOM = mod:GetSaveData().unlocks.Eindis.MOM,
				MOMSHEART = mod:GetSaveData().unlocks.Eindis.MOMSHEART,
				ISAAC = mod:GetSaveData().unlocks.Eindis.ISAAC,
				BLUEBABY = mod:GetSaveData().unlocks.Eindis.BLUEBABY,
				SATAN = mod:GetSaveData().unlocks.Eindis.SATAN,
				THELAMB = mod:GetSaveData().unlocks.Eindis.THELAMB,
				BOSSRUSH = mod:GetSaveData().unlocks.Eindis.BOSSRUSH,
				HUSH = mod:GetSaveData().unlocks.Eindis.HUSH,
				DELIRIUM = mod:GetSaveData().unlocks.Eindis.DELIRIUM,
				MEGASATAN = mod:GetSaveData().unlocks.Eindis.MEGASATAN,
				MOTHER = mod:GetSaveData().unlocks.Eindis.MOTHER,
				THEBEAST = mod:GetSaveData().unlocks.Eindis.THEBEAST,
				ULTRAGREED = mod:GetSaveData().unlocks.Eindis.ULTRAGREED,
				ULTRAGREEDIER = mod:GetSaveData().unlocks.Eindis.ULTRAGREEDIER,
			},
			ThePolycule = {
				MOM = mod:GetSaveData().unlocks.ThePolycule.MOM,
				MOMSHEART = mod:GetSaveData().unlocks.ThePolycule.MOMSHEART,
				ISAAC = mod:GetSaveData().unlocks.ThePolycule.ISAAC,
				BLUEBABY = mod:GetSaveData().unlocks.ThePolycule.BLUEBABY,
				SATAN = mod:GetSaveData().unlocks.ThePolycule.SATAN,
				THELAMB = mod:GetSaveData().unlocks.ThePolycule.THELAMB,
				BOSSRUSH = mod:GetSaveData().unlocks.ThePolycule.BOSSRUSH,
				HUSH = mod:GetSaveData().unlocks.ThePolycule.HUSH,
				DELIRIUM = mod:GetSaveData().unlocks.ThePolycule.DELIRIUM,
				MEGASATAN = mod:GetSaveData().unlocks.ThePolycule.MEGASATAN,
				MOTHER = mod:GetSaveData().unlocks.ThePolycule.MOTHER,
				THEBEAST = mod:GetSaveData().unlocks.ThePolycule.THEBEAST,
				ULTRAGREED = mod:GetSaveData().unlocks.ThePolycule.ULTRAGREED,
				ULTRAGREEDIER = mod:GetSaveData().unlocks.ThePolycule.ULTRAGREEDIER,
			},
		}
	}
end

function mod:STOREsavedata()
	local jsonString = json.encode(persistentData)
	mod:SaveData(jsonString)
end

function mod:LOADsavedata()
	if mod:HasData() then
		mod.persistentData = json.decode(mod:LoadData())
	end
end

function mod:preGameExit()
	local jsonString = json.encode(persistentData)
	mod:SaveData(jsonString)
end

mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, mod.preGameExit)

function mod:OnGameStart(isSave)
	mod:LOADsavedata()
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.OnGameStart)

--Debug Console
function mod.oncmd(_, command, args)
	if command == "unlocks" and args == mod.Eindis_Character.NAME then
		print(mod.Eindis_Character.NAME.."'s UNLOCKS ARE AS FOLLOWS")
		if mod:HasData() then
			mod:LOADsavedata()

			print("MOM = " .. tostring(mod:GetSaveData().unlocks.Eindis.MOM))
			print("MOM'S HEART = " .. tostring(mod:GetSaveData().unlocks.Eindis.MOMSHEART))
			print("ISAAC = " .. tostring(mod:GetSaveData().unlocks.Eindis.ISAAC))
			print("BLUE BABY = " .. tostring(mod:GetSaveData().unlocks.Eindis.BLUEBABY))
			print("SATAN = " .. tostring(mod:GetSaveData().unlocks.Eindis.SATAN))
			print("THE LAMB = " .. tostring(mod:GetSaveData().unlocks.Eindis.THELAMB))
			print("BOSS RUSH = " .. tostring(mod:GetSaveData().unlocks.Eindis.BOSSRUSH))
			print("HUSH = " .. tostring(mod:GetSaveData().unlocks.Eindis.HUSH))
			print("DELIRIUM = " .. tostring(mod:GetSaveData().unlocks.Eindis.DELIRIUM))
			print("MEGA SATAN = " .. tostring(mod:GetSaveData().unlocks.Eindis.MEGASATAN))
			print("MOTHER = " .. tostring(mod:GetSaveData().unlocks.Eindis.MOTHER))
			print("THE BEAST = " .. tostring(mod:GetSaveData().unlocks.Eindis.THEBEAST))
			print("ULTRA GREED = " .. tostring(mod:GetSaveData().unlocks.Eindis.ULTRAGREED))
			print("ULTRA GREEDIER = " .. tostring(mod:GetSaveData().unlocks.Eindis.ULTRAGREEDIER))
		end
	end
	if command == "unlocks" and args == mod.ThePolycule_Character.NAME then
		print(mod.ThePolycule_Character.NAME.."'s UNLOCKS ARE AS FOLLOWS")
		if mod:HasData() then
			mod:LOADsavedata()

			print("MOM = " .. tostring(mod:GetSaveData().unlocks.ThePolycule.MOM))
			print("MOM'S HEART = " .. tostring(mod:GetSaveData().unlocks.ThePolycule.MOMSHEART))
			print("ISAAC = " .. tostring(mod:GetSaveData().unlocks.ThePolycule.ISAAC))
			print("BLUE BABY = " .. tostring(mod:GetSaveData().unlocks.ThePolycule.BLUEBABY))
			print("SATAN = " .. tostring(mod:GetSaveData().unlocks.ThePolycule.SATAN))
			print("THE LAMB = " .. tostring(mod:GetSaveData().unlocks.ThePolycule.THELAMB))
			print("BOSS RUSH = " .. tostring(mod:GetSaveData().unlocks.ThePolycule.BOSSRUSH))
			print("HUSH = " .. tostring(mod:GetSaveData().unlocks.ThePolycule.HUSH))
			print("DELIRIUM = " .. tostring(mod:GetSaveData().unlocks.ThePolycule.DELIRIUM))
			print("MEGA SATAN = " .. tostring(mod:GetSaveData().unlocks.ThePolycule.MEGASATAN))
			print("MOTHER = " .. tostring(mod:GetSaveData().unlocks.ThePolycule.MOTHER))
			print("THE BEAST = " .. tostring(mod:GetSaveData().unlocks.ThePolycule.THEBEAST))
			print("ULTRA GREED = " .. tostring(mod:GetSaveData().unlocks.ThePolycule.ULTRAGREED))
			print("ULTRA GREEDIER = " .. tostring(mod:GetSaveData().unlocks.ThePolycule.ULTRAGREEDIER))
		end
	end
	--auto unlock all
	if command == "unlocks" and args == mod.Eindis_Character.NAME .. " unlockall" then
		print(mod.Eindis_Character.NAME.."'s UNLOCKS ARE ALL UNLOCKED")
		if mod:HasData() then
			persistentData.unlocks.Eindis.MOM = true
			persistentData.unlocks.Eindis.MOMSHEART = true
			persistentData.unlocks.Eindis.ISAAC = true
			persistentData.unlocks.Eindis.BLUEBABY = true
			persistentData.unlocks.Eindis.SATAN = true
			persistentData.unlocks.Eindis.THELAMB = true
			persistentData.unlocks.Eindis.BOSSRUSH = true
			persistentData.unlocks.Eindis.HUSH = true
			persistentData.unlocks.Eindis.DELIRIUM = true
			persistentData.unlocks.Eindis.MEGASATAN = true
			persistentData.unlocks.Eindis.MOTHER = true
			persistentData.unlocks.Eindis.THEBEAST = true
			persistentData.unlocks.Eindis.ULTRAGREED = true
			persistentData.unlocks.Eindis.ULTRAGREEDIER = true

			mod:STOREsavedata()
		end
	end
	if command == "unlocks" and args == mod.ThePolycule_Character.NAME .. " unlockall" then
		print(mod.ThePolycule_Character.NAME.."'s UNLOCKS ARE ALL UNLOCKED")
		if mod:HasData() then
			persistentData.unlocks.ThePolycule.MOM = true
			persistentData.unlocks.ThePolycule.MOMSHEART = true
			persistentData.unlocks.ThePolycule.ISAAC = true
			persistentData.unlocks.ThePolycule.BLUEBABY = true
			persistentData.unlocks.ThePolycule.SATAN = true
			persistentData.unlocks.ThePolycule.THELAMB = true
			persistentData.unlocks.ThePolycule.BOSSRUSH = true
			persistentData.unlocks.ThePolycule.HUSH = true
			persistentData.unlocks.ThePolycule.DELIRIUM = true
			persistentData.unlocks.ThePolycule.MEGASATAN = true
			persistentData.unlocks.ThePolycule.MOTHER = true
			persistentData.unlocks.ThePolycule.THEBEAST = true
			persistentData.unlocks.ThePolycule.ULTRAGREED = true
			persistentData.unlocks.ThePolycule.ULTRAGREEDIER = true

			mod:STOREsavedata()
		end
	end
	--auto relock all
	if command == "unlocks" and args == mod.Eindis_Character.NAME .. " lockall" then
		print(mod.Eindis_Character.NAME.."'s UNLOCKS ARE ALL LOCKED")
		if mod:HasData() then
			persistentData.unlocks.Eindis.MOM = false persistentData.unlocks.Eindis.MOMSHEART = false
			persistentData.unlocks.Eindis.ISAAC = false persistentData.unlocks.Eindis.BLUEBABY = false
			persistentData.unlocks.Eindis.SATAN = false persistentData.unlocks.Eindis.THELAMB = false
			persistentData.unlocks.Eindis.BOSSRUSH = false persistentData.unlocks.Eindis.HUSH = false
			persistentData.unlocks.Eindis.DELIRIUM = false persistentData.unlocks.Eindis.MEGASATAN = false
			persistentData.unlocks.Eindis.MOTHER = false persistentData.unlocks.Eindis.THEBEAST = false
			persistentData.unlocks.Eindis.ULTRAGREED = false persistentData.unlocks.Eindis.ULTRAGREEDIER = false

			mod:STOREsavedata()
		end
	end
	if command == "unlocks" and args == mod.ThePolycule_Character.NAME .. " lockall" then
		print(mod.ThePolycule_Character.NAME.."'s UNLOCKS ARE ALL LOCKED")
		if mod:HasData() then
			persistentData.unlocks.ThePolycule.MOM = false persistentData.unlocks.ThePolycule.MOMSHEART = false
			persistentData.unlocks.ThePolycule.ISAAC = false persistentData.unlocks.ThePolycule.BLUEBABY = false
			persistentData.unlocks.ThePolycule.SATAN = false persistentData.unlocks.ThePolycule.THELAMB = false
			persistentData.unlocks.ThePolycule.BOSSRUSH = false persistentData.unlocks.ThePolycule.HUSH = false
			persistentData.unlocks.ThePolycule.DELIRIUM = false persistentData.unlocks.ThePolycule.MEGASATAN = false
			persistentData.unlocks.ThePolycule.MOTHER = false persistentData.unlocks.ThePolycule.THEBEAST = false
			persistentData.unlocks.ThePolycule.ULTRAGREED = false persistentData.unlocks.ThePolycule.ULTRAGREEDIER = false

			mod:STOREsavedata()
		end
	end
end
mod:AddCallback(ModCallbacks.MC_EXECUTE_CMD, mod.oncmd)


--Anything below is for Item Pickups
local callbacks = {}    ---@type table<InventoryCallback, table<CollectibleType, function[]>>
local trackedItems = {} ---@type CollectibleType[]

local ItemGrabCallback =
{
    ---@enum InventoryCallback
    InventoryCallback =
    {
        --- Fired when an item is added to the player's inventory
        --- - `player`: EntityPlayer - the player who picked up the item
        --- - `item`: CollectibleType - id of the item that was picked up
        --- - `count`: integer - amount of item that was picked up
        --- - `touched`: boolean - whether the picked up item was picked up before (.Touched property set to true)
        --- - `queued`: boolean - whether the picked up item was picked up from the item queue
        POST_ADD_ITEM = 1,
        --- Fired when an item is removed from the player's inventory
        --- - `player`: EntityPlayer - the player who lost the item
        --- - `item`: CollectibleType - id of the item that was lost
        --- - `count`: integer - amount of item that was lost
        POST_REMOVE_ITEM = 2,
    },
    ---@param callbackId InventoryCallback
    ---@param callbackFunc function
    ---@param item CollectibleType @id of item for which the callback should be fired
    AddCallback = function (self, callbackId, callbackFunc, item)
        assert(type(callbackId) == "number", "callbackId must be a number, got "..type(callbackId).." instead")
        assert(type(callbackFunc) == "function", "callbackFunc must be a function, got "..type(callbackFunc).." instead")
        assert(type(item) == "number", "item must be a number, got "..type(item).." instead")

        if callbacks[callbackId] == nil then
            callbacks[callbackId] = {}
        end

        if callbacks[callbackId][item] == nil then
            callbacks[callbackId][item] = {}

            --- insert item id into the list of tracked items while maintaining ascending order
            if #trackedItems == 0 then
                table.insert(trackedItems, item)
            else
                local inserted = false
                for i=#trackedItems,1,-1 do
                    if trackedItems[i] == item then
                        inserted = true
                        break
                    elseif trackedItems[i] < item then
                        table.insert(trackedItems, i + 1, item)
                        inserted = true
                        break
                    end
                end

                if not inserted then
                    table.insert(trackedItems, 1, item)
                end
            end
        end

        table.insert(callbacks[callbackId][item], callbackFunc)
    end,
    ---@param callbackId InventoryCallback
    ---@param callbackFunc function
    ---@param item CollectibleType
    RemoveCallback = function (self, callbackId, callbackFunc, item)
        assert(type(callbackId) == "number", "callbackId must be a number, got "..type(callbackId).." instead")
        assert(type(callbackFunc) == "function", "callbackFunc must be a function, got "..type(callbackFunc).." instead")
        assert(type(item) == "number", "item must be a number, got "..type(item).." instead")

        if callbacks[callbackId] == nil or callbacks[callbackId][item] == nil then
            return
        end

        for i = 1, #callbacks[callbackId][item] do
            if callbacks[callbackId][item][i] == callbackFunc then
                table.remove(callbacks[callbackId][item], i)
            end
        end

        if #callbacks[callbackId][item] == 0 then
            callbacks[callbackId][item] = nil

            --- remove item id from the list of tracked items
            for i = 1, #trackedItems do
                if trackedItems[i] == item then
                    table.remove(trackedItems, i)
                    break
                end
            end
        end
    end,
    ---@param callbackId InventoryCallback
    ---@param ... any
    FireCallback = function (self, callbackId, ...)
        assert(type(callbackId) == "number", "callbackId must be a number, got "..type(callbackId).." instead")

        local _, item = ...
        if callbacks[callbackId] == nil or callbacks[callbackId][item] == nil then
            return
        end

        for i = 1, #callbacks[callbackId][item] do
            callbacks[callbackId][item][i](...)
        end
    end,
    --- Prevents ADD/REMOVE callbacks from firing for items added directly to the player's inventory next player update.
    --- Items added from queue will still trigger ADD callback.  
    ---@param player EntityPlayer
    CancelInventoryCallbacksNextFrame = function (self, player)
        assert(player:ToPlayer(), "EntityPlayer expected")
        player:GetData().PreventNextInventoryCallback = true
    end,
}

local itemGrab = ItemGrabCallback

---@param player EntityPlayer
---@return table<CollectibleType, integer>
local function getPlayerInventory(player)
    local inventory = {}

    for _, item in ipairs(trackedItems) do
        local colCount = player:GetCollectibleNum(item, true)
        inventory[item] = colCount
    end

    return inventory
end

---@param inv1 table<CollectibleType, integer>
---@param inv2 table<CollectibleType, integer>
---@return table<CollectibleType, integer>
local function getInventoryDiff(inv1, inv2)
    local out = {}

    for item, count in pairs(inv1) do
        local diff = count - (inv2[item] or 0)
        out[item] = diff
    end

    return out
end

---@class PlayerInventoryData
---@field PrevItems table<CollectibleType, integer>?
---@field PrevQueue ItemConfig_Item?
---@field PrevTouched boolean?

---@param player EntityPlayer
---@return PlayerInventoryData
local function getPlayerInvData(player)
    local data = player:GetData()
    if data.PlayerInventoryData == nil then
        data.PlayerInventoryData = {
            PrevItems = getPlayerInventory(player),
            PrevQueue = nil,
            PrevTouched = nil,
        }
    end
    return data.PlayerInventoryData
end

---@param player EntityPlayer
local function PostPlayerUpdate(_, player)
    if player:IsCoopGhost() then
        return
    end

    local invData = getPlayerInvData(player)
    local inventory = getPlayerInventory(player)
    local diff = getInventoryDiff(inventory, invData.PrevItems)
    local queueItem = player.QueuedItem.Item
    local prevQueueItem = invData.PrevQueue

    if queueItem == nil and prevQueueItem ~= nil then
        if diff[prevQueueItem.ID] and diff[prevQueueItem.ID] > 0 then
            -- print("item got picked up from queue, id =", prevQueueItem.ID, "touched =", invData.PrevTouched)
            itemGrab:FireCallback(itemGrab.InventoryCallback.POST_ADD_ITEM, player, prevQueueItem.ID, diff[prevQueueItem.ID], invData.PrevTouched, true)
            diff[prevQueueItem.ID] = 0
        end
    end

    if not player:GetData().PreventNextInventoryCallback then
        local addedItems = {}
        local removedItems = {}

        for _, item in ipairs(trackedItems) do
            if diff[item] > 0 then
                addedItems[#addedItems+1] = {ID = item, Count = diff[item]}
            elseif diff[item] < 0 then
                removedItems[#removedItems+1] = {ID = item, Count = -diff[item]}
            end
        end

        -- Item add callbacks are fired first
        for i=1, #addedItems do
            local item = addedItems[i]
            itemGrab:FireCallback(itemGrab.InventoryCallback.POST_ADD_ITEM, player, item.ID, item.Count, false, false)
        end

        for i=1, #removedItems do
            local item = removedItems[i]
            itemGrab:FireCallback(itemGrab.InventoryCallback.POST_REMOVE_ITEM, player, item.ID, item.Count)
        end
    else
        player:GetData().PreventNextInventoryCallback = false
    end

    invData.PrevItems = inventory
    invData.PrevQueue = queueItem
    invData.PrevTouched = player.QueuedItem.Touched

end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, PostPlayerUpdate)

---@param cmd string
---@param prm string
local function OnCommand(_, cmd, prm)
    if cmd ~= "itemgrab" then
        return
    end

    local params = {}
    for s in prm:gmatch("%S+") do
        table.insert(params, s)
    end

    -- Spawns item pedestal with id as first parameter and .Touched set to true if second parameter is 1 or greater.
    if params[1] == "spwn" then
        local id = tonumber(params[2]) or 0
        local touched = tonumber(params[3]) or 0

        local room = Game():GetRoom()
        local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos(), 0, true)
        local pickup = Isaac.Spawn(5, PickupVariant.PICKUP_COLLECTIBLE, id, pos, Vector.Zero, nil):ToPickup()

        if touched >= 1 then
            pickup.Touched = true
        end
    -- Prints currently tracked items.
    elseif params[1] == "tracked" then
        print("Currently tracked items:")
        for i, item in ipairs(trackedItems) do
            print(i, item)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_EXECUTE_CMD, OnCommand)

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function (_, item, rng, player)
    if item == CollectibleType.COLLECTIBLE_D4 then
        itemGrab:CancelInventoryCallbacksNextFrame(player)
        -- print("d4 used at frame", Game():GetFrameCount())
    elseif item == CollectibleType.COLLECTIBLE_D100 then
        itemGrab:CancelInventoryCallbacksNextFrame(player)
        -- print("d100 used at frame", Game():GetFrameCount())
    end
end)

-- USAGE EXAMPLE
-- Spawn a rotten heart when picking up Yuck Heart for the first time
-- or when getting it directly (through console or player:AddCollectible())
itemGrab:AddCallback(itemGrab.InventoryCallback.POST_ADD_ITEM, function (player, item, count, touched, fromQueue)
    if not touched or not fromQueue then
        for i=1,count do
            local pos = Game():GetRoom():FindFreePickupSpawnPosition(player.Position, 0, true)
            Isaac.Spawn(5, PickupVariant.PICKUP_HEART, HeartSubType.HEART_ROTTEN, pos, Vector.Zero, player)
        end
    end
end, CollectibleType.COLLECTIBLE_YUCK_HEART)

return ItemGrabCallback
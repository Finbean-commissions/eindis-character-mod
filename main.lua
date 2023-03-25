----Welcome to the "main.lua" file! Here is where all the magic happens, everything from functions to callbacks are dOne_Character.
--Startup
local mod = RegisterMod("Commission Template - Character + Tainted", 1)
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
		Costume_ID = Isaac.GetCostumeIdByPath("gfx/characters/"..name.."-head.anm2"),
	}
	return character
end
mod.One_Character = addCharacter("One", false)
mod.Two_Character = addCharacter("Two", true)

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
	---@param tearflag TearFlags
	local function addStats(name, speed, tears, damage, range, shotspeed, luck, tearcolor, flying, tearflag) -- This is the function used to determine the stats of your character, you can simply leave it as you will use it later!
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
			if cacheFlag == CacheFlag.CACHE_DAMAGE then
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
			if cacheFlag == CacheFlag.CACHE_TEARFLAG then
				player.TearFlags = player.TearFlags | tearflag
			end
		end
	end
	mod.One_Stats = addStats("One", 0, 0, 0, 0, 0, 0, Color(1, 1, 1, 1.0, 0, 0, 0), false, TearFlags.TEAR_NORMAL)
	mod.Two_Stats = addStats("Two", 0, 0, 0, 0, 0, 0, Color(1, 1, 1, 1.0, 0, 0, 0), false, TearFlags.TEAR_NORMAL)
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE,mod.evalCache)

function mod:playerSpawn(player)
    if player:GetPlayerType(mod.One_Character.NAME) then
        player:AddNullCostume(mod.One_Character.Costume_ID)
    end
    if player:GetPlayerType(mod.Two_Character.NAME) then
        player:AddNullCostume(mod.Two_Character.Costume_ID)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, mod.playerSpawn)

----Anything below this is for unlocks
--Saving and Loading Data!
local persistentData = {
	unlocks = {
		One = {
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
		Two = {
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
			One = {
				MOM = mod:GetSaveData().unlocks.One.MOM,
				MOMSHEART = mod:GetSaveData().unlocks.One.MOMSHEART,
				ISAAC = mod:GetSaveData().unlocks.One.ISAAC,
				BLUEBABY = mod:GetSaveData().unlocks.One.BLUEBABY,
				SATAN = mod:GetSaveData().unlocks.One.SATAN,
				THELAMB = mod:GetSaveData().unlocks.One.THELAMB,
				BOSSRUSH = mod:GetSaveData().unlocks.One.BOSSRUSH,
				HUSH = mod:GetSaveData().unlocks.One.HUSH,
				DELIRIUM = mod:GetSaveData().unlocks.One.DELIRIUM,
				MEGASATAN = mod:GetSaveData().unlocks.One.MEGASATAN,
				MOTHER = mod:GetSaveData().unlocks.One.MOTHER,
				THEBEAST = mod:GetSaveData().unlocks.One.THEBEAST,
				ULTRAGREED = mod:GetSaveData().unlocks.One.ULTRAGREED,
				ULTRAGREEDIER = mod:GetSaveData().unlocks.One.ULTRAGREEDIER,
			},
			Two = {
				MOM = mod:GetSaveData().unlocks.Two.MOM,
				MOMSHEART = mod:GetSaveData().unlocks.Two.MOMSHEART,
				ISAAC = mod:GetSaveData().unlocks.Two.ISAAC,
				BLUEBABY = mod:GetSaveData().unlocks.Two.BLUEBABY,
				SATAN = mod:GetSaveData().unlocks.Two.SATAN,
				THELAMB = mod:GetSaveData().unlocks.Two.THELAMB,
				BOSSRUSH = mod:GetSaveData().unlocks.Two.BOSSRUSH,
				HUSH = mod:GetSaveData().unlocks.Two.HUSH,
				DELIRIUM = mod:GetSaveData().unlocks.Two.DELIRIUM,
				MEGASATAN = mod:GetSaveData().unlocks.Two.MEGASATAN,
				MOTHER = mod:GetSaveData().unlocks.Two.MOTHER,
				THEBEAST = mod:GetSaveData().unlocks.Two.THEBEAST,
				ULTRAGREED = mod:GetSaveData().unlocks.Two.ULTRAGREED,
				ULTRAGREEDIER = mod:GetSaveData().unlocks.Two.ULTRAGREEDIER,
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
	if command == "unlocks" and args == mod.One_Character.NAME then
		print(mod.One_Character.NAME.."'s UNLOCKS ARE AS FOLLOWS")
		if mod:HasData() then
			mod:LOADsavedata()

			print("MOM = " .. tostring(mod:GetSaveData().unlocks.One.MOM))
			print("MOM'S HEART = " .. tostring(mod:GetSaveData().unlocks.One.MOMSHEART))
			print("ISAAC = " .. tostring(mod:GetSaveData().unlocks.One.ISAAC))
			print("BLUE BABY = " .. tostring(mod:GetSaveData().unlocks.One.BLUEBABY))
			print("SATAN = " .. tostring(mod:GetSaveData().unlocks.One.SATAN))
			print("THE LAMB = " .. tostring(mod:GetSaveData().unlocks.One.THELAMB))
			print("BOSS RUSH = " .. tostring(mod:GetSaveData().unlocks.One.BOSSRUSH))
			print("HUSH = " .. tostring(mod:GetSaveData().unlocks.One.HUSH))
			print("DELIRIUM = " .. tostring(mod:GetSaveData().unlocks.One.DELIRIUM))
			print("MEGA SATAN = " .. tostring(mod:GetSaveData().unlocks.One.MEGASATAN))
			print("MOTHER = " .. tostring(mod:GetSaveData().unlocks.One.MOTHER))
			print("THE BEAST = " .. tostring(mod:GetSaveData().unlocks.One.THEBEAST))
			print("ULTRA GREED = " .. tostring(mod:GetSaveData().unlocks.One.ULTRAGREED))
			print("ULTRA GREEDIER = " .. tostring(mod:GetSaveData().unlocks.One.ULTRAGREEDIER))
		end
	end
	if command == "unlocks" and args == mod.Two_Character.NAME then
		print(mod.Two_Character.NAME.."'s UNLOCKS ARE AS FOLLOWS")
		if mod:HasData() then
			mod:LOADsavedata()

			print("MOM = " .. tostring(mod:GetSaveData().unlocks.Two.MOM))
			print("MOM'S HEART = " .. tostring(mod:GetSaveData().unlocks.Two.MOMSHEART))
			print("ISAAC = " .. tostring(mod:GetSaveData().unlocks.Two.ISAAC))
			print("BLUE BABY = " .. tostring(mod:GetSaveData().unlocks.Two.BLUEBABY))
			print("SATAN = " .. tostring(mod:GetSaveData().unlocks.Two.SATAN))
			print("THE LAMB = " .. tostring(mod:GetSaveData().unlocks.Two.THELAMB))
			print("BOSS RUSH = " .. tostring(mod:GetSaveData().unlocks.Two.BOSSRUSH))
			print("HUSH = " .. tostring(mod:GetSaveData().unlocks.Two.HUSH))
			print("DELIRIUM = " .. tostring(mod:GetSaveData().unlocks.Two.DELIRIUM))
			print("MEGA SATAN = " .. tostring(mod:GetSaveData().unlocks.Two.MEGASATAN))
			print("MOTHER = " .. tostring(mod:GetSaveData().unlocks.Two.MOTHER))
			print("THE BEAST = " .. tostring(mod:GetSaveData().unlocks.Two.THEBEAST))
			print("ULTRA GREED = " .. tostring(mod:GetSaveData().unlocks.Two.ULTRAGREED))
			print("ULTRA GREEDIER = " .. tostring(mod:GetSaveData().unlocks.Two.ULTRAGREEDIER))
		end
	end
	--auto unlock all
	if command == "unlocks" and args == mod.One_Character.NAME .. " unlockall" then
		print(mod.One_Character.NAME.."'s UNLOCKS ARE ALL UNLOCKED")
		if mod:HasData() then
			persistentData.unlocks.One.MOM = true
			persistentData.unlocks.One.MOMSHEART = true
			persistentData.unlocks.One.ISAAC = true
			persistentData.unlocks.One.BLUEBABY = true
			persistentData.unlocks.One.SATAN = true
			persistentData.unlocks.One.THELAMB = true
			persistentData.unlocks.One.BOSSRUSH = true
			persistentData.unlocks.One.HUSH = true
			persistentData.unlocks.One.DELIRIUM = true
			persistentData.unlocks.One.MEGASATAN = true
			persistentData.unlocks.One.MOTHER = true
			persistentData.unlocks.One.THEBEAST = true
			persistentData.unlocks.One.ULTRAGREED = true
			persistentData.unlocks.One.ULTRAGREEDIER = true

			mod:STOREsavedata()
		end
	end
	if command == "unlocks" and args == mod.Two_Character.NAME .. " unlockall" then
		print(mod.Two_Character.NAME.."'s UNLOCKS ARE ALL UNLOCKED")
		if mod:HasData() then
			persistentData.unlocks.Two.MOM = true
			persistentData.unlocks.Two.MOMSHEART = true
			persistentData.unlocks.Two.ISAAC = true
			persistentData.unlocks.Two.BLUEBABY = true
			persistentData.unlocks.Two.SATAN = true
			persistentData.unlocks.Two.THELAMB = true
			persistentData.unlocks.Two.BOSSRUSH = true
			persistentData.unlocks.Two.HUSH = true
			persistentData.unlocks.Two.DELIRIUM = true
			persistentData.unlocks.Two.MEGASATAN = true
			persistentData.unlocks.Two.MOTHER = true
			persistentData.unlocks.Two.THEBEAST = true
			persistentData.unlocks.Two.ULTRAGREED = true
			persistentData.unlocks.Two.ULTRAGREEDIER = true

			mod:STOREsavedata()
		end
	end
	--auto relock all
	if command == "unlocks" and args == mod.One_Character.NAME .. " lockall" then
		print(mod.One_Character.NAME.."'s UNLOCKS ARE ALL LOCKED")
		if mod:HasData() then
			persistentData.unlocks.One.MOM = false persistentData.unlocks.One.MOMSHEART = false
			persistentData.unlocks.One.ISAAC = false persistentData.unlocks.One.BLUEBABY = false
			persistentData.unlocks.One.SATAN = false persistentData.unlocks.One.THELAMB = false
			persistentData.unlocks.One.BOSSRUSH = false persistentData.unlocks.One.HUSH = false
			persistentData.unlocks.One.DELIRIUM = false persistentData.unlocks.One.MEGASATAN = false
			persistentData.unlocks.One.MOTHER = false persistentData.unlocks.One.THEBEAST = false
			persistentData.unlocks.One.ULTRAGREED = false persistentData.unlocks.One.ULTRAGREEDIER = false

			mod:STOREsavedata()
		end
	end
	if command == "unlocks" and args == mod.Two_Character.NAME .. " lockall" then
		print(mod.Two_Character.NAME.."'s UNLOCKS ARE ALL LOCKED")
		if mod:HasData() then
			persistentData.unlocks.Two.MOM = false persistentData.unlocks.Two.MOMSHEART = false
			persistentData.unlocks.Two.ISAAC = false persistentData.unlocks.Two.BLUEBABY = false
			persistentData.unlocks.Two.SATAN = false persistentData.unlocks.Two.THELAMB = false
			persistentData.unlocks.Two.BOSSRUSH = false persistentData.unlocks.Two.HUSH = false
			persistentData.unlocks.Two.DELIRIUM = false persistentData.unlocks.Two.MEGASATAN = false
			persistentData.unlocks.Two.MOTHER = false persistentData.unlocks.Two.THEBEAST = false
			persistentData.unlocks.Two.ULTRAGREED = false persistentData.unlocks.Two.ULTRAGREEDIER = false

			mod:STOREsavedata()
		end
	end
end
mod:AddCallback(ModCallbacks.MC_EXECUTE_CMD, mod.oncmd)
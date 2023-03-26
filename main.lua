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
	mod.Eindis_Stats = addStats("Eindis", 0, -1, 2, 0, 0, 0, Color(1, 1, 1, 1.0, 0, 0, 0), false, TearFlags.TEAR_NORMAL)
	mod.ThePolycule_Stats = addStats("The Polycule", 0, 0, 0, 0, 0, 0, Color(1, 1, 1, 1.0, 0, 0, 0), false, TearFlags.TEAR_NORMAL)
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE,mod.evalCache)

function mod:playerSpawn(player)
    if player:GetName() == mod.Eindis_Character.NAME then
        player:AddNullCostume(Isaac.GetCostumeIdByPath("gfx/characters/Eindis-head.anm2"))
    end
    if player:GetName() == mod.ThePolycule_Character.NAME then
        player:AddNullCostume(Isaac.GetCostumeIdByPath("gfx/characters/The Polycule-head.anm2"))
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
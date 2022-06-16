-- /////////////////////////////////////////////////////////////////////////////////////////
--                             	Utility Functions
-- /////////////////////////////////////////////////////////////////////////////////////////

-- Sets Dvar Setting
local function SetDvarSetting(Arg0, DvarSetting, Arg2, DvarName, Arg4)
	UpdateInfoModels(DvarSetting)
	-- Have to validate value otherwise we keep notifying
	if DvarSetting.value ~= Engine.DvarInt(nil, DvarName) then
		Engine.SetDvar(DvarName, DvarSetting.value)
		Engine.ForceNotifyModelSubscriptions(Engine.CreateModel(Engine.CreateModel(Engine.GetGlobalModel(), "GametypeSettings"), "Update"))
	end
end

-- Builds a ranged setting
-- Min - Minimum Value
-- Max - Maximum Value
-- Prefix - Prefix to show on the UI (i.e. Round 1 instead of just 1) (Optional)
-- Suffix - Suffix to show on the UI (i.e. 5 Minutes instead of just 5) (Optional)
-- Initial - Initial Value (i.e. "Off" ) If set, 0 is used to indicate it (Optional)
-- Step - The step for each value (i.e. 5, 10, 15, 20, ....) (Optional)
-- Example: BuildRangedSetting(1, 100, "Round ", "", "Off")
local function BuildRangedSetting(Min, Max, Prefix, Suffix, Initial, Step)
	local Results = {}

	if Initial ~= nil then
		table.insert(
			Results,
			{
				option = Initial,
				value = 0,
				default = true
			})
	end

	for i = Min, Max, Step or 1 do
		table.insert(
			Results,
			{
				option = (Prefix or "") .. tostring(i) .. (Suffix or ""),
				value = i,
				default = (i == Min and Initial == nil)
			})
	end

	return Results
end

-- Builds a list of string settings
-- Values - A list of values (i.e. {"Test", "Interesting", "Cool"}) Must be an indexed table
-- Default Value - The default value in the table
-- Example - BuildStringSettings({"On", "Off"}, "On")
local function BuildStringSettings(Values, Default)
    local Results = {}

    for Index, Value in ipairs(Values) do
		table.insert(
			Results,
			{
				option = Value,
				value = Index,
				default = Value == Default
			})
    end

	return Results
end

-- Updates the Model
local function Update(arg0, arg1, arg2)
	if arg1.updateSubscription then
		arg1:removeSubscription(arg1.updateSubscription)
	end

	arg1.updateSubscription = arg1:subscribeToModel(
		Engine.CreateModel(Engine.CreateModel(Engine.GetGlobalModel(), "GametypeSettings"), "Update"),
		function() arg1:updateDataSource() end,
		false)
end

-- /////////////////////////////////////////////////////////////////////////////////////////
--                              Function Overrides
-- /////////////////////////////////////////////////////////////////////////////////////////


ResetGameSettings = function(arg0, arg1, arg2, arg3)
	Engine.SetGametype(Engine.DvarString(nil, "ui_gametype"))
	Engine.SetDvar("bot_maxFree", 0.000000)
	Engine.SetDvar("bot_maxAllies", 0.000000)
	Engine.SetDvar("bot_maxAxis", 0.000000)
	Engine.SetDvar("bot_difficulty", 1.000000)
	-- TODO: Look into looping over the datasource, or converting to tables,
	-- Treyarch have the luxury of using GameSettings that they can add to and then
	-- set it like above, we don't have that luxury, so this seems best way for now

	-- Reset Mutators Values
	-- General Values
	Engine.SetDvar("mutator_startround", 				0)
	Engine.SetDvar("mutator_maxround", 					0)
	Engine.SetDvar("mutator_timecap", 					0)
	Engine.SetDvar("mutator_timedgameplay", 			0)
	Engine.SetDvar("mutator_timer", 					0)
	Engine.SetDvar("mutator_killcap", 					0)
	Engine.SetDvar("mutator_specialrounds", 			0)
	Engine.SetDvar("mutator_traps", 					0)
	Engine.SetDvar("mutator_perks", 					0)
	Engine.SetDvar("mutator_powerups", 					0)
	Engine.SetDvar("mutator_gobblegums", 				0)
	Engine.SetDvar("mutator_pap", 						0)
	Engine.SetDvar("mutator_mysterybox", 				0)
	Engine.SetDvar("mutator_wallweapons", 				0)
	-- Weapon Values
	Engine.SetDvar("mutator_weaponsmg", 				0)
	Engine.SetDvar("mutator_weaponar", 					0)
	Engine.SetDvar("mutator_weaponshotgun", 			0)
	Engine.SetDvar("mutator_weaponsniper", 				0)
	Engine.SetDvar("mutator_weaponpistol", 				0)
	Engine.SetDvar("mutator_weaponlauncher", 			0)
	Engine.SetDvar("mutator_weaponmelee", 				0)
	Engine.SetDvar("mutator_weaponspecial", 			0)
	Engine.SetDvar("mutator_weaponequipment", 			0)
	Engine.SetDvar("mutator_weaponlethal", 				0)
	Engine.SetDvar("mutator_weapontactical", 			0)
	Engine.SetDvar("mutator_weaponeshield", 			0)
	Engine.SetDvar("mutator_weaponwonder", 				0)
	-- Player Values
	Engine.SetDvar("mutator_startingpoints", 			0)
	Engine.SetDvar("mutator_startinghealth", 			0)
	Engine.SetDvar("mutator_startingweapon", 			0)
	Engine.SetDvar("mutator_healthregendelay", 			0)
	Engine.SetDvar("mutator_healthregenspeed", 			0)
	Engine.SetDvar("mutator_pointslossdown", 			0)
	Engine.SetDvar("mutator_pointslossdeath", 			0)
	Engine.SetDvar("mutator_pointslossdeathteam", 		0)
	Engine.SetDvar("mutator_limiteddowns", 				0)
	Engine.SetDvar("mutator_keepweaponsonrespawn", 		0)
	Engine.SetDvar("mutator_keepperksonrespawn", 		0)
	Engine.SetDvar("mutator_perklimit", 				0)
	-- Enemy Values
	Engine.SetDvar("mutator_zombiecrawlers", 			0)
	Engine.SetDvar("mutator_zombieminspeed", 			0)
	Engine.SetDvar("mutator_zombiemaxspeed", 			0)
	Engine.SetDvar("mutator_zombiehealth", 				0)
	Engine.SetDvar("mutator_zombiedamage", 				0)
	Engine.SetDvar("mutator_bosszombies", 				0)
	-- Fun Values
	Engine.SetDvar("mutator_ragdoll", 					0)

	Engine.ForceNotifyModelSubscriptions(Engine.CreateModel(Engine.GetGlobalModel(), "GametypeSettings.Update"))
end

-- /////////////////////////////////////////////////////////////////////////////////////////
--                              Mutators Tabs
-- /////////////////////////////////////////////////////////////////////////////////////////

DataSources.MutatorsTabs = DataSourceHelpers.ListSetup("MutatorsTabs",
function (arg0, arg1, arg2, arg3, arg4)
    return
    {
        -- Left Shoulder
        {
            models        = { tabIcon = CoD.buttonStrings.shoulderl },
            properties    = { m_mouseDisabled = true }
        },
        -- Tab 1
        {
            models        = { tabName 	= "GENERAL", 				        tabIcon = "" },
            properties    = { tabId 	= "MutatorSettingsGeneral", 		dataSourceName 	= "MutatorSettingsGeneral",	title =	"GENERAL GAME SETTINGS" }
        },
        -- Tab 2
        {
            models        = { tabName 	= "WEAPONS",                        tabIcon = "" },
            properties    = { tabId 	= "MutatorSettingsWeapons", 	    dataSourceName 	= "MutatorSettingsWeapons",	title =	"WEAPON SETTINGS" }
        },
        -- Tab 3
        {
            models        = { tabName 	= "PLAYERS",                        tabIcon = "" },
            properties    = { tabId 	= "MutatorSettingsPlayers", 	    dataSourceName 	= "MutatorSettingsPlayers",	title =	"PLAYER SETTINGS" }
        },
        -- Tab 4
        {
            models        = { tabName 	= "ENEMIES",                        tabIcon = "" },
            properties    = { tabId 	= "MutatorSettingsEnemies", 	    dataSourceName 	= "MutatorSettingsEnemies",	title =	"ENEMY SETTINGS" }
        },
        -- Tab 5
        {
            models        = { tabName 	= "FUN",                            tabIcon = "" },
            properties    = { tabId 	= "MutatorSettingsFun", 	        dataSourceName 	= "MutatorSettingsFun",	    title =	"FUN SETTINGS THAT MAKES SHIT GO CRAZY" }
		},
		-- Right Shoulder
        {
            models        = { tabIcon = CoD.buttonStrings.shoulderr },
            properties    = { m_mouseDisabled = true }
        },
    }
end, true)

-- /////////////////////////////////////////////////////////////////////////////////////////
--                              Mutator Data Sources
-- /////////////////////////////////////////////////////////////////////////////////////////

-- /////////////////////////////////////////////////////////////////////////////////////////
--                              General Settings
-- /////////////////////////////////////////////////////////////////////////////////////////
DataSources.MutatorSettingsGeneral = DataSourceHelpers.ListSetup("MutatorSettingsGeneral",
function (arg0, arg1, arg2, arg3, arg4)
	return
	{
        -- Setting 1
        CoD.OptionsUtility.CreateDvarSettings(
			arg0,
			"STARTING ROUND",
			"Set the starting ^3Round Number^7",
			"MutatorSettings_StartingRound",
			"mutator_startround",
            BuildRangedSetting(1, 100, "Round "), nil, SetDvarSetting),
        -- Setting 2
        CoD.OptionsUtility.CreateDvarSettings(
			arg0,
			"ROUND CAP",
			"Set the maximum ^3Round Number^7 for the Game",
			"MutatorSettings_MaxRound",
			"mutator_maxround",
            BuildRangedSetting(1, 100, "Round ", "", "Off"), nil, SetDvarSetting),
        -- Setting 3
        CoD.OptionsUtility.CreateDvarSettings(
			arg0,
			"TIME CAP",
			"Set the maximum amount of ^3Time^7 the game can last for",
			"MutatorSettings_TimeCap",
			"mutator_timecap",
            BuildRangedSetting(5, 100, "", " Minutes", "Off"), nil, SetDvarSetting),
        -- Setting 4
        CoD.OptionsUtility.CreateDvarSettings(
			arg0,
			"TIMED GAMEPLAY",
			"Enable or Disable ^3Time-Based^7 Gameplay\n\nIf enabled, rounds progress instantly and zombies do not stop spawning",
			"MutatorSettings_TimedGameplay",
			"mutator_timedgameplay",
            BuildStringSettings({"Off", "On"}, "Off"), nil, SetDvarSetting),
        -- Setting 5
        CoD.OptionsUtility.CreateDvarSettings(
			arg0,
			"SHOW TIMER",
			"Show or Hide the ^3Game Timer^7",
			"MutatorSettings_Timer",
			"mutator_timer",
            BuildStringSettings({"Off", "On"}, "Off"), nil, SetDvarSetting),
        -- Setting 6
        CoD.OptionsUtility.CreateDvarSettings(
			arg0,
			"KILL CAP",
			"Set the maximum amount of ^3Kills^7 by all players for this game",
			"MutatorSettings_KillCap",
			"mutator_killcap",
            BuildRangedSetting(100, 10000, "", " Kills", "Off", 100), nil, SetDvarSetting),
        -- Setting 7
        CoD.OptionsUtility.CreateDvarSettings(
			arg0,
			"SPECIAL ROUNDS",
			"Enable or Disable ^3Special Rounds^7 such as ^3Dogs^7, ^3Parasites^7, etc.\n\nThis setting is only confirmed to work in ^3Treyarch^7 maps.",
			"MutatorSettings_SpecialRounds",
			"mutator_specialrounds",
            BuildStringSettings({"On", "Off"}, "On"), nil, SetDvarSetting),
        -- Setting 8
        CoD.OptionsUtility.CreateDvarSettings(
			arg0,
			"TRAPS",
			"Enable or Disable ^3Traps^7",
			"MutatorSettings_Traps",
			"mutator_traps",
            BuildStringSettings({"On", "Off"}, "On"), nil, SetDvarSetting),
        -- Setting 9
        CoD.OptionsUtility.CreateDvarSettings(
			arg0,
			"PERKS",
			"Enable or Disable ^3Perk Machines^7",
			"MutatorSettings_Perks",
			"mutator_perks",
            BuildStringSettings({"On", "Off"}, "On"), nil, SetDvarSetting),
        -- Setting 10
        CoD.OptionsUtility.CreateDvarSettings(
			arg0,
			"POWER UPS",
			"Enable or Disable ^3Power Ups^7 from dropping from Zombies",
			"MutatorSettings_PowerUps",
			"mutator_powerups",
            BuildStringSettings({"On", "Off"}, "On"), nil, SetDvarSetting),
        -- Setting 11
        CoD.OptionsUtility.CreateDvarSettings(
			arg0,
			"GOBBLEGUMS",
			"Enable or Disable ^3GobbleGum Machines^7",
			"MutatorSettings_GobbleGums",
			"mutator_gobblegums",
            BuildStringSettings({"On", "Off"}, "On"), nil, SetDvarSetting),
        -- Setting 12
        CoD.OptionsUtility.CreateDvarSettings(
			arg0,
			"PACK-A-PUNCH",
			"Enable or Disable ^3Pack-A-Punch Machines^7",
			"MutatorSettings_PaP",
			"mutator_pap",
            BuildStringSettings({"On", "Off"}, "On"), nil, SetDvarSetting),
        -- Setting 13
        CoD.OptionsUtility.CreateDvarSettings(
			arg0,
			"MYSTERY BOX",
			"Enable or Disable ^3Mystery Box^7",
			"MutatorSettings_MysteryBox",
			"mutator_mysterybox",
            BuildStringSettings({"On", "Off"}, "On"), nil, SetDvarSetting),
        -- Setting 14
        CoD.OptionsUtility.CreateDvarSettings(
			arg0,
			"WALL WEAPONS",
			"Enable or Disable ^3Wall Weapons^7",
			"MutatorSettings_WallWeapons",
			"mutator_wallweapons",
			BuildStringSettings({"On", "Off"}, "On"), nil, SetDvarSetting),
	}
end, nil, nil, Update)

-- /////////////////////////////////////////////////////////////////////////////////////////
--                              Weapon Settings
-- /////////////////////////////////////////////////////////////////////////////////////////
DataSources.MutatorSettingsWeapons = DataSourceHelpers.ListSetup("MutatorSettingsWeapons",
function (arg0, arg1, arg2, arg3, arg4)
	return
	{
        -- Setting 1
        CoD.OptionsUtility.CreateDvarSettings(
			arg0,
			"SUBMACHINE GUNS",
			"Enable or Disable ^3Submachine Guns^7 from Wall Buys/Mystery Box",
			"MutatorSettings_WeaponSmg",
			"mutator_weaponsmg",
            BuildStringSettings({"On", "Off"}, "On"), nil, SetDvarSetting),
        -- Setting 2
        CoD.OptionsUtility.CreateDvarSettings(
			arg0,
			"ASSAULT RIFLES",
			"Enable or Disable ^3Assault Rifles^7 from Wall Buys/Mystery Box",
			"MutatorSettings_WeaponAr",
			"mutator_weaponar",
            BuildStringSettings({"On", "Off"}, "On"), nil, SetDvarSetting),
        -- Setting 3
        CoD.OptionsUtility.CreateDvarSettings(
			arg0,
			"SHOTGUNS",
			"Enable or Disable ^3Shotguns^7 from Wall Buys/Mystery Box",
			"MutatorSettings_WeaponShotgun",
			"mutator_weaponshotgun",
            BuildStringSettings({"On", "Off"}, "On"), nil, SetDvarSetting),
        -- Setting 4
        CoD.OptionsUtility.CreateDvarSettings(
			arg0,
			"SNIPER RIFLES",
			"Enable or Disable ^3Sniper Rifles^7 from Wall Buys/Mystery Box",
			"MutatorSettings_WeaponSniper",
			"mutator_weaponsniper",
            BuildStringSettings({"On", "Off"}, "On"), nil, SetDvarSetting),
        -- Setting 5
        CoD.OptionsUtility.CreateDvarSettings(
			arg0,
			"PISTOLS",
			"Enable or Disable ^3Pistols^7 from Wall Buys/Mystery Box",
			"MutatorSettings_WeaponPistol",
			"mutator_weaponpistol",
            BuildStringSettings({"On", "Off"}, "On"), nil, SetDvarSetting),
        -- Setting 6
        CoD.OptionsUtility.CreateDvarSettings(
			arg0,
			"LAUNCHERS",
			"Enable or Disable ^3Launchers^7 from Wall Buys/Mystery Box",
			"MutatorSettings_WeaponLauncher",
			"mutator_weaponlauncher",
            BuildStringSettings({"On", "Off"}, "On"), nil, SetDvarSetting),
        -- Setting 7
        CoD.OptionsUtility.CreateDvarSettings(
			arg0,
			"MELEE",
			"Enable or Disable ^3Melee Weapons^7 from Wall Buys/Mystery Box",
			"MutatorSettings_WeaponMelee",
			"mutator_weaponmelee",
            BuildStringSettings({"On", "Off"}, "On"), nil, SetDvarSetting),
        -- Setting 8
        CoD.OptionsUtility.CreateDvarSettings(
			arg0,
			"SPECIAL",
			"Enable or Disable ^3Special Weapons^7 from Wall Buys/Mystery Box",
			"MutatorSettings_WeaponSpecial",
			"mutator_weaponspecial",
            BuildStringSettings({"On", "Off"}, "On"), nil, SetDvarSetting),
        -- Setting 9
        CoD.OptionsUtility.CreateDvarSettings(
			arg0,
			"EQUIPMENT",
			"Enable or Disable ^3Equipment^7 from Wall Buys/Mystery Box",
			"MutatorSettings_WeaponEquipment",
			"mutator_weaponequipment",
            BuildStringSettings({"On", "Off"}, "On"), nil, SetDvarSetting),
        -- Setting 10
        CoD.OptionsUtility.CreateDvarSettings(
			arg0,
			"LETHAL",
			"Enable or Disable ^3Lethal Grenades^7 from Wall Buys/Mystery Box",
			"MutatorSettings_WeaponLethal",
			"mutator_weaponlethal",
            BuildStringSettings({"On", "Off"}, "On"), nil, SetDvarSetting),
        -- Setting 11
        CoD.OptionsUtility.CreateDvarSettings(
			arg0,
			"TACTICAL",
			"Enable or Disable ^3Tactical Grenades^7 from Wall Buys/Mystery Box",
			"MutatorSettings_WeaponTactical",
			"mutator_weapontactical",
            BuildStringSettings({"On", "Off"}, "On"), nil, SetDvarSetting),
        -- Setting 12
        CoD.OptionsUtility.CreateDvarSettings(
			arg0,
			"SHIELD",
			"Enable or Disable ^3Shields^7 from Wall Buys/Mystery Box",
			"MutatorSettings_WeaponShield",
			"mutator_weaponeshield",
            BuildStringSettings({"On", "Off"}, "On"), nil, SetDvarSetting),
        -- Setting 13
        CoD.OptionsUtility.CreateDvarSettings(
			arg0,
			"WONDER WEAPONS",
			"Enable or Disable ^3Wonder Weapons^7 from Wall Buys/Mystery Box",
			"MutatorSettings_WeaponWonder",
			"mutator_weaponwonder",
            BuildStringSettings({"On", "Off"}, "On"), nil, SetDvarSetting),
	}
end, nil, nil, Update)

-- /////////////////////////////////////////////////////////////////////////////////////////
--                              Player Settings
-- /////////////////////////////////////////////////////////////////////////////////////////
DataSources.MutatorSettingsPlayers = DataSourceHelpers.ListSetup("MutatorSettingsPlayers",
function (arg0, arg1, arg2, arg3, arg4)
	return
	{
        -- Setting 1
        CoD.OptionsUtility.CreateDvarSettings(
			arg0,
			"STARTING POINTS",
			"Set the number of ^3Points^7 each player will start with",
			"MutatorSettings_StartingPoints",
			"mutator_startingpoints",
            BuildRangedSetting(1000, 100000, "", " Points", "Default", 1000), nil, SetDvarSetting),
        -- Setting 2
        CoD.OptionsUtility.CreateDvarSettings(
			arg0,
			"STARTING HEALTH",
			"Set the ^3Health^7 each player will start with",
			"MutatorSettings_StartingHealth",
			"mutator_startinghealth",
            BuildStringSettings({"Default", "Low", "High"}, "Default"), nil, SetDvarSetting),
        -- Setting 3
        CoD.OptionsUtility.CreateDvarSettings(
			arg0,
			"STARTING WEAPON",
			"Set the ^3Weapon^7 each player will start with\n\nThe player will start with a random weapon from the selected class, a random weapon if Random is selected, or the default starting weapon.",
			"MutatorSettings_StartingWeapon",
			"mutator_startingweapon",
            BuildStringSettings({"Default", "Submachine Gun", "Assault Rifle", "Shotgun", "Light Machine Gun", "Sniper", "Pistol", "Launcher"}, "Default"), nil, SetDvarSetting),
        -- Setting 4
        CoD.OptionsUtility.CreateDvarSettings(
			arg0,
			"HEALTH REGEN DELAY",
			"Sets the ^3Delay^7 before the player will start to regenerate health",
			"MutatorSettings_HealthRegenDelay",
			"mutator_healthregendelay",
            BuildStringSettings({"Default", "Slow", "Fast"}, "Default"), nil, SetDvarSetting),
        -- Setting 5
        CoD.OptionsUtility.CreateDvarSettings(
			arg0,
			"HEALTH REGEN SPEED",
			"Sets the ^3Speed^7 the player will regenerate health at",
			"MutatorSettings_HealthRegenSpeed",
			"mutator_healthregenspeed",
            BuildStringSettings({"Default", "Slow", "Fast"}, "Default"), nil, SetDvarSetting),
        -- Setting 6
        CoD.OptionsUtility.CreateDvarSettings(
			arg0,
			"POINTS LOST ON DOWN",
			"Set the number of ^3Points^7 the player will lose when they go down",
			"MutatorSettings_PointsLossDown",
			"mutator_pointslossdown",
            BuildRangedSetting(1000, 100000, "", " Points", "Default", 1000), nil, SetDvarSetting),
        -- Setting 7
        CoD.OptionsUtility.CreateDvarSettings(
			arg0,
			"POINTS LOST ON DEATH",
			"Set the number of ^3Points^7 the player will lose when they bleed out",
			"MutatorSettings_PointsLossDeath",
			"mutator_pointslossdeath",
            BuildRangedSetting(1000, 100000, "", " Points", "Default", 1000), nil, SetDvarSetting),
        -- Setting 8
        CoD.OptionsUtility.CreateDvarSettings(
			arg0,
			"POINTS LOST ON TEAMMATE DEATH",
			"Set the number of ^3Points^7 the player will lose when a teammate bleeds out",
			"MutatorSettings_PointsLossDeathTeam",
			"mutator_pointslossdeathteam",
            BuildRangedSetting(1000, 100000, "", " Points", "Default", 1000), nil, SetDvarSetting),
        -- Setting 9
        CoD.OptionsUtility.CreateDvarSettings(
			arg0,
			"LIMITED DOWNS",
			"Sets the number of ^3Downs^7 a player can have in a Co-Op game",
			"MutatorSettings_LimitedDowns",
			"mutator_limiteddowns",
            BuildRangedSetting(1, 50, "", " Downs", "Off"), nil, SetDvarSetting),
        -- Setting 10
        CoD.OptionsUtility.CreateDvarSettings(
			arg0,
			"KEEP WEAPONS ON DOWN",
			"Enable or Disable the ability to ^3Keep Weapons^7 on down (including death)",
			"MutatorSettings_KeepWeaponsOnRespawn",
			"mutator_keepweaponsonrespawn",
            BuildStringSettings({"Off", "On"}, "Off"), nil, SetDvarSetting),
        -- Setting 11
        CoD.OptionsUtility.CreateDvarSettings(
			arg0,
			"KEEP PERKS ON DOWN",
			"Enable or Disable the ability to ^3Keep Perks^7 on down (including death)",
			"MutatorSettings_KeepPerksOnRespawn",
			"mutator_keepperksonrespawn",
            BuildStringSettings({"Off", "On"}, "Off"), nil, SetDvarSetting),
        -- Setting 12
        CoD.OptionsUtility.CreateDvarSettings(
			arg0,
			"PERK PURCHASE LIMIT",
			"Sets maximum amount of ^3Perks^7 players can purchase during the game by default",
			"MutatorSettings_PerkLimit",
			"mutator_perklimit",
            BuildRangedSetting(1, 50, "", " Perks", "Default"), nil, SetDvarSetting),
	}
end, nil, nil, Update)

-- /////////////////////////////////////////////////////////////////////////////////////////
--                              Enemy Settings
-- /////////////////////////////////////////////////////////////////////////////////////////
DataSources.MutatorSettingsEnemies = DataSourceHelpers.ListSetup("MutatorSettingsEnemies",
function (arg0, arg1, arg2, arg3, arg4)
	return
	{
        -- Setting 1
        CoD.OptionsUtility.CreateDvarSettings(
			arg0,
			"ZOMBIE CRAWLERS",
			"Enable or Disable ^3Zombie Crawlers^7",
			"MutatorSettings_ZombieCrawlers",
			"mutator_zombiecrawlers",
            BuildStringSettings({"On", "Off"}, "On"), nil, SetDvarSetting),
        -- Setting 2
        CoD.OptionsUtility.CreateDvarSettings(
			arg0,
			"ZOMBIE MIN. SPEED",
			"Sets the minimum ^3Zombie Speed^7",
			"MutatorSettings_ZombieMinSpeed",
			"mutator_zombieminspeed",
            BuildStringSettings({"Default", "Walk", "Run", "Sprint", "Super Sprint"}, "Default"), nil, SetDvarSetting),
        -- Setting 3
        CoD.OptionsUtility.CreateDvarSettings(
			arg0,
			"ZOMBIE MAX. SPEED",
			"Sets the maximum ^3Zombie Speed^7",
			"MutatorSettings_ZombieMaxSpeed",
			"mutator_zombiemaxspeed",
            BuildStringSettings({"Default", "Walk", "Run", "Sprint", "Super Sprint"}, "Default"), nil, SetDvarSetting),
        -- Setting 4
        CoD.OptionsUtility.CreateDvarSettings(
			arg0,
			"ZOMBIE HEALTH",
			"Sets the ^3Zombie Health^7",
			"MutatorSettings_ZombieHealth",
			"mutator_zombiehealth",
            BuildStringSettings({"Default", "Low", "High"}, "Default"), nil, SetDvarSetting),
        -- Setting 5
        CoD.OptionsUtility.CreateDvarSettings(
			arg0,
			"ZOMBIE DAMAGE",
			"Sets the ^3Zombie Damage^7 that is dealth to players",
			"MutatorSettings_ZombieDamage",
			"mutator_zombiedamage",
            BuildStringSettings({"Default", "Low", "High"}, "Default"), nil, SetDvarSetting),
        -- Setting 6
        CoD.OptionsUtility.CreateDvarSettings(
			arg0,
			"BOSS ZOMBIES",
			"Enable or Disable ^3Boss Zombies^7 that spawn mid-round\n\nThis setting is only confirmed to work in ^3Treyarch^7 maps.",
			"MutatorSettings_BossZombies",
			"mutator_bosszombies",
            BuildStringSettings({"On", "Off"}, "On"), nil, SetDvarSetting),
	}
end, nil, nil, Update)

-- /////////////////////////////////////////////////////////////////////////////////////////
--                              Fun Settings
-- /////////////////////////////////////////////////////////////////////////////////////////
DataSources.MutatorSettingsFun = DataSourceHelpers.ListSetup("MutatorSettingsFun",
function (arg0, arg1, arg2, arg3, arg4)
	return
	{
        -- Setting 1
        CoD.OptionsUtility.CreateDvarSettings(
			arg0,
			"RAG DOLL",
			"Enable or Disable ^3Rag Doll^7 \n\nOn death ^3zombies^7 get thrown like a rag doll",
			"MutatorSettings_RagDoll",
			"mutator_ragdoll",
			BuildStringSettings({"Off", "On"}, "Off"), nil, SetDvarSetting),
		-- Setting 2
		CoD.OptionsUtility.CreateDvarSettings(
			arg0,
			"RAPTROES",
			"Enable or Disable ^3Raptroes^7\n\nShould have never been enabled >:(",
			"MutatorSettings_Raptroes",
			"mutator_Raptroes",
			BuildStringSettings({"On", "Off"}, "On"), nil, SetDvarSetting),
	}
end, nil, nil, Update)
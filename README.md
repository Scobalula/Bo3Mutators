# 🧟 Call of Duty: Black Ops III Mutators 🧟

A set of Lua/GSC scripts for adding mutators to Call of Duty: Black Ops III Mods. Uploaded for preservation of my stuff, this is not complete and is only provided for people to do whatever they want with it.

# Disclaimer

This was made just under 5 years ago for raptroes' MWZ Mod when Lua in Bo3 was in its infancy, information was non-existent (especially for frontend, and tbh, information on UI and Lua is still a horror show in Bo3), and decompilers were just getting going, and this was my first entry into trying to do something even rmeotely substantial in Lua in Bo3. With that in mind there is a lot in this set of files I would do way better, but it works and has been mostly battletested in raptroes' mod. There will not be any bug fixes, I am simply uploading this for preservation of my stuff. You can do whatever you want with it, but if you do, let us see what you come up with in my Discord server. ❤️

A lot of the mutators shown in the Lua side of things aren't implemented, as the purpose of doing this was to hand it over to raptroes' and let him do what he needed with it, so you still need to set up whatever mutators you actually want.

[![Join my Discord](https://discordapp.com/api/guilds/719503756810649640/widget.png?style=banner2)](https://discord.gg/RyqyThu)

# Installing

To install, copy the 2 folders into `<BlackOpsIII>/share/raw` or `<BlackOpsIII>/mods/modname`.

Then add the following to your `zone` file:

```
rawfile,ui/t6/lobby/lobbymenubuttons.lua
rawfile,ui/t6/lobby/lobbymenubuttons_og.luac
rawfile,ui/t6/lobby/lobbymenus.lua
rawfile,ui/scobalula/frontend/menus/mutators_menu.lua
rawfile,ui/scobalula/frontend/menus/mutators_menu_data.lua
scriptparsetree,scripts/zm/_zm_mutators.csc
scriptparsetree,scripts/zm/_zm_mutators.gsc
```

Next include the script in one of your gsc and csc files:

```
#using scripts\zm\_zm_mutators;
```

And you're done!

# Adding Mutators

## Adding to the UI

**Note: Currently each tab is limited to 14 items (15 in theory but it will go off screen), this will be fixed in the future, but keep in mind for now, I have indexed each setting to keep track**

To add a mutator to a particular tab first open the file `ui/scobalula/frontend/menus/mutators_menu_data.lua` in a code editor such as `VS Code` or `Sublime`. If you scroll down, you will see datasource definitions for each tab, each one contains a function that returns a table of calls to `CoD.OptionsUtility.CreateDvarSettings`:

![](https://i.imgur.com/OhVaQi8.png)

The parameters for this are as follows:

```
Arg 0 - Menu Ref
Arg 1 - Title
Arg 2 - Description
Arg 3 - Datasource Name (for this Setting, not the name of the tab datasource)
Arg 4 - Dvar Name
Arg 5 - List of Settings (See Below)
Arg 6 - Pass `nil`
Arg 7 - Function that gets call when the setting is changed (Use SetDvarSetting)
```

For Arg 5 a table with particular properties is expected, these are the properties each item should contain:

```
option = The option string that is shown on the UI
value - The Dvar value
default = If this is the default value (Mostly used to show an icon if the setting is changed)
```

We can then set up a table like so:

```lua
{
    -- Setting 0
    {
        option      =   "Cookies",
        value       =   1,
        default     =   true
    },
    -- Setting 1
    {
        option      =   "Cake",
        value       =   2,
        default     =   false
    },
    -- Setting 2
    {
        option      =   "Chocolate",
        value       =   3,
        default     =   false
    },
}
```

I have set up 2 helper methods to help with this for common tasks such as building a range of values and a table of string values:

```lua
-- Builds a ranged setting
-- Min - Minimum Value
-- Max - Maximum Value
-- Prefix - Prefix to show on the UI (i.e. Round 1 instead of just 1) (Optional)
-- Suffix - Suffix to show on the UI (i.e. 5 Minutes instead of just 5) (Optional)
-- Initial - Initial Value (i.e. "Off" ) If set, 0 is used to indicate it (Optional)
-- Step - The step for each value (i.e. 5, 10, 15, 20, ....) (Optional)
-- Example: BuildRangedSetting(1, 100, "Round ", "", "Off")
BuildRangedSetting(Min, Max, Prefix, Suffix, Initial, Step)

-- Builds a list of string settings
-- Values - A list of values (i.e. {"Test", "Interesting", "Cool"}) Must be an indexed table
-- Default Value - The default value in the table
-- Example - BuildStringSettings({"On", "Off"}, "On")
BuildStringSettings(Values, Default)
```

Currently there are the following datasource definitions to keep in mind for each tab:

```lua
DataSources.MutatorSettingsGeneral
DataSources.MutatorSettingsWeapons
DataSources.MutatorSettingsPlayers
DataSources.MutatorSettingsEnemies
DataSources.MutatorSettingsFun
```

We can see from this to add a setting to a tab we need to add a call to `CoD.OptionsUtility.CreateDvarSettings` like so:

```lua
CoD.OptionsUtility.CreateDvarSettings(
    arg0,
    "RAPTROES",
    "Enable or Disable ^3Raptroes^7 \n\nShould have never been enabled >:(",
    "MutatorSettings_Raptroes",
    "mutator_raptroes",
    BuildStringSettings({"On", "Off"}, "On"), nil, SetDvarSetting),
```

This would then look like this in the Lua file:

![](https://i.imgur.com/XUAfgI7.png)

We now need to ensure the setting will revert if the player reverts ALL settings, to this, scroll up until you find a series of calls to `Engine.SetDvar` like this:

![](https://i.imgur.com/ie67EEU.png)

We need to add a call for our Dvar to ensure it gets reset, to this, simple add the following line, ensuring to replace the name with the dvar you choose:

```lua
Engine.SetDvar("mutator_raptroes", 					0)
```

This would then look this in the Lua file:

![](https://i.imgur.com/HWI3B39.png)

If we boot into the game and open the Mutators menu it should should show up fine like so, and reset as expected if we hit the Options button and click reset:

![](https://i.imgur.com/XCfhS5h.png)

## Making the Mutator Work In-Game

To actually make the Mutator work we'll need to add some logic to gsc and/or csc (clientscript side currently not set up) to make the Mutator work.

To do this open the file `scriptparsetree,scripts/zm/_zm_mutators.gsc` and/or `scriptparsetree,scripts/zm/_zm_mutators.gsc` (clientscript side currently not set up) file and scroll down to the function `register_mutators`, we need to call `register_mutator` in this function for our Mutator, the definition for the register function is the following:

```cpp
/@
"Name: register_mutator(<mutator_name>, <dvar_name>, [pre_func], [post_func])"
"Summary: Registers the given mutator with the required data."
"MandatoryArg: <mutator_name> : Mutator Name"
"MandatoryArg: <dvar_name> : Mutator Dvar, must match the Mutators Lua file"
"OptionalArg: [pre_func] : Function called pre-load, required if the mutator requires pre-load set up such as callbacks, etc."
"OptionalArg: [post_func] : Function called post-load, required if the mutator requires post-load set up"
"Example: zm_mutators::register_mutator(MUTATOR_PERKS_NAME, MUTATOR_PERKS_DVAR, undefined, &disable_perks);"
"SPMP: both"
@/
function register_mutator(mutator_name, dvar_name, pre_func, post_func)
```

For our mutator I'll register it like so:

```cpp
register_mutator("MutatorSettings_Raptroes", "mutator_raptroes", undefined, &disable_raptroes);
```

And create a function to handle it:

```cpp
function private disable_raptroes(dvar_value)
{
	if(dvar_value == MUTATOR_ONOFF_OFF)
	{
        level.raptroes_disabled = true; // We can now run checks elsewhere with IS_TRUE(level.raptroes_disabled)
        // Do logic
	}
}
```

**Note: It is recommended to create a macro for the name and dvar in the GSH like I have done for each, as this makes it easy to make edits, etc.**

Once you have scripted the logic for your mutator, you're good to go!

# Editing Tabs

To edit the tabs first open the file `ui/scobalula/frontend/menus/mutators_menu_data.lua` and scroll down until you find the following:

```lua
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
```

We can easily add a tab by copy and pasting and editing the data:

```
tabName - This is what shows up at the top in the tab list
tabIcon - Icon that is shown, used mostly for controller icons
tabId - Tab ID, best to keep it unique
dataSourceName - Name of the datasource as we saw in adding a mutator
title - This is what shows up at the top of the settings list
```

We first need to create a new datasource, you can copy one of the others and change its name and definitions like so:

```lua
-- /////////////////////////////////////////////////////////////////////////////////////////
--                              Edwin Settings
-- /////////////////////////////////////////////////////////////////////////////////////////
DataSources.MutatorSettingsEdwin = DataSourceHelpers.ListSetup("MutatorSettingsEdwin",
function (arg0, arg1, arg2, arg3, arg4)
	return
	{
        -- Setting 1
        CoD.OptionsUtility.CreateDvarSettings(
			arg0,
			"EDWIN",
			"^3DONKEYS AHHHHHHH^7",
			"MutatorSettings_Edwin",
			"mutator_edwin",
			BuildStringSettings({"DONKEYS", "ARE", "BAD", "FOR", "YOU"}, "DONKEYS"), nil, SetDvarSetting),
	}
end, nil, nil, Update)
```

We then need to create the tab, like so:

```lua
-- Tab 6
{
    models        = { tabName 	= "EDWIN",                          tabIcon = "" },
    properties    = { tabId 	= "MutatorSettingsEdwin", 	        dataSourceName 	= "MutatorSettingsEdwin",	    title =	"GET AWAY FROM THE DONKEYS" }
},
```

Which would look like this:

```lua
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
        -- Tab 6
        {
            models        = { tabName 	= "EDWIN",                          tabIcon = "" },
            properties    = { tabId 	= "MutatorSettingsEdwin", 	        dataSourceName 	= "MutatorSettingsEdwin",	    title =	"GET AWAY FROM THE DONKEYS" }
        },
		-- Right Shoulder
        {
            models        = { tabIcon = CoD.buttonStrings.shoulderr },
            properties    = { m_mouseDisabled = true }
        },
    }
end, true)
```

If we boot in-game our tab should be working as expected:

![Example 1](https://i.imgur.com/iGSYHmu.png)
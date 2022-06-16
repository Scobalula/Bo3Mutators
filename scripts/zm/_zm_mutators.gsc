// ------------------------------------------
// Zombie Mutators - by Scobalula
// Credits: JariK - Lua Decompiler
// ------------------------------------------
// Includes
#using scripts\codescripts\struct;
#using scripts\shared\flag_shared;
#using scripts\shared\system_shared;
#using scripts\shared\array_shared;
#using scripts\shared\util_shared;
#using scripts\shared\callbacks_shared;
#using scripts\zm\_zm;
#using scripts\zm\_zm_bgb;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_spawner;
// #using scripts\zm\_zm_scob_utility;
#using scripts\zm\_zm_unitrigger;
// Inserts
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_mutators.gsh;
#insert scripts\zm\_zm_scob_utility.gsh;
// Namespace
#namespace zm_mutators;

REGISTER_SYSTEM_EX("zm_mutators", &__init__, &__main__, undefined)

function private __init__()
{
	DEFAULT(level.zm_mutators, 				[]);

	register_mutators();

	foreach(name, mutator in level.zm_mutators)
	{
		if(isdefined(mutator.prefunc) && IsFunctionPtr(mutator.prefunc))
		{
			level thread [[mutator.prefunc]](GetDvarInt(mutator.dvar));
		}
	}
}

function private __main__()
{
	foreach(name, mutator in level.zm_mutators)
	{
		if(isdefined(mutator.postfunc) && IsFunctionPtr(mutator.postfunc))
		{
			level thread [[mutator.postfunc]](GetDvarInt(mutator.dvar));
		}
	}
}

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
{
	Assert(isdefined(mutator_name), 						"Mutator Name must be defined");
	Assert(isdefined(dvar_name), 							"Mutator Dvar Name must be defined");
	Assert(!isdefined(level.zm_mutators[mutator_name]), 	"Mutator " + mutator_name + " is already registered");

	// Spawn a struct to store our info
	level.zm_mutators[mutator_name] = SpawnStruct();

	level.zm_mutators[mutator_name].name 		= mutator_name;
	level.zm_mutators[mutator_name].dvar 		= dvar_name;
	level.zm_mutators[mutator_name].postfunc 	= post_func;
	level.zm_mutators[mutator_name].prefunc 	= pre_func;
}

function private register_mutators()
{
	// Register a single death event for all mutators
	zm_spawner::register_zombie_death_event_callback(&zombie_mutators_on_death);
	zm::register_vehicle_damage_callback(&vehicle_mutators_on_death);

	//-////////////////////////////////////////////////////////
	//                      General Settings
	//-////////////////////////////////////////////////////////
	register_mutator(MUTATOR_ROUNDSTART_NAME, 			MUTATOR_ROUNDSTART_DVAR, 	&enable_startinground, 			undefined);
	register_mutator(MUTATOR_MAXROUND_NAME, 			MUTATOR_MAXROUND_DVAR, 		undefined, 						&enable_max_round);
	register_mutator(MUTATOR_MAXTIME_NAME, 				MUTATOR_MAXTIME_DVAR, 		undefined, 						&enable_max_time);
	register_mutator(MUTATOR_TIMEDGAME_NAME, 			MUTATOR_TIMEDGAME_DVAR, 	&enable_timed_gameplay, 		undefined);
	register_mutator(MUTATOR_TIMER_NAME, 				MUTATOR_TIMER_DVAR, 		undefined, 						&enable_timer);
	register_mutator(MUTATOR_MAXKILLS_NAME, 			MUTATOR_MAXKILLS_DVAR, 		&enable_max_kills, 				undefined);
	register_mutator(MUTATOR_SPECRNDS_NAME, 			MUTATOR_SPECRNDS_DVAR, 		undefined, 						&disable_special_rounds);
	register_mutator(MUTATOR_TRAPS_NAME, 				MUTATOR_TRAPS_DVAR, 		undefined, 						&disable_traps); // FIX
	register_mutator(MUTATOR_PERKS_NAME, 				MUTATOR_PERKS_DVAR, 		undefined, 						&disable_perks);


	//-////////////////////////////////////////////////////////
	//                      Fun Settings
	//-////////////////////////////////////////////////////////
	register_mutator(MUTATOR_RAGDOLL_NAME, 		MUTATOR_RAGDOLL_DVAR, &enable_ragdoll, undefined);
}

// ------------------------------------------
// 				Round Start Logic
// ------------------------------------------

function private enable_startinground(dvar_value)
{
	if(dvar_value >= 2)
	{
		callback::on_connect(&give_player_points);
		level.round_prestart_func = &set_round_number;
	}
}

function private set_round_number()
{
	round = GetDvarInt(MUTATOR_ROUNDSTART_DVAR);
	level.round_number = round;
	level.speed_change_max = round;
	SetRoundsPlayed(level.round_number);
	game["roundsplayed"] = level.round_number;
	level.zombie_move_speed	= level.round_number * level.zombie_vars["zombie_move_speed_multiplier"];
	zm::set_round_number(round);
}

function private give_player_points()
{
	self.score = 1000 * GetDvarInt(MUTATOR_ROUNDSTART_DVAR);
}

// ------------------------------------------
// 				Max Round Logic
// ------------------------------------------

function private enable_max_round(dvar_value)
{
	level endon("end_game");
	level endon("end_round_think");

	if(dvar_value >= 1)
	{
		while(true)
		{
			level waittill("end_of_round");

			if(zm::get_round_number() >= dvar_value)
				level notify("end_game");
		}
	}
}

// ------------------------------------------
// 				Max Time Logic
// ------------------------------------------

function private enable_max_time(dvar_value)
{
	level endon("end_game");
	level endon("end_round_think");

	if(dvar_value >= 1)
	{
		wait(dvar_value * 60);
		level notify("end_game");
	}
}

// ------------------------------------------
// 				Timed Gameplay Logic
// ------------------------------------------

function private private enable_timed_gameplay(dvar_value)
{
	if(dvar_value === MUTATOR_OFFON_ON)
	{
		level.round_wait_func = &round_wait;
		level.zombie_vars["zombie_between_round_time"] = 0;
		level.zombie_round_start_delay = 0;
	}
}

function private private round_wait()
{
	level endon("restart_round");

	wait(1);

	while(1)
	{
		if(!(level.zombie_total > 0 || level.intermission))
		{
			return;
		}

		if(level flag::get("end_round_wait"))
		{
			return;
		}

		wait(1.0);
	}
}

// ------------------------------------------
// 				Timer Logic
// ------------------------------------------

/@
"Name: create_text(<elem>, <sort>, <x_align>, <y_align>, <x>, <y>, <font_scale>, <font>, <text>)"
"Summary: Creates a text hud element"
"MandatoryArg: TODO"
"Example: TODO"
"SPMP: both"
@/
function create_text(elem, sort, x_align, y_align, x, y, font_scale, font, text)
{
	elem.sort 				= sort;
	elem.alignX 			= x_align;
	elem.alignY 			= y_align;
	elem.horzAlign 			= x_align;
	elem.vertAlign 			= y_align;
	elem.xOffset 			= 0;
	elem.yOffset 			= 0;
	elem.x 					= x;
	elem.y 					= y;
	elem.hidewheninmenu 	= 0;
	elem.hidewhenindemo 	= 0;
	elem.fontscale 			= font_scale;
	elem.font 				= font;
	elem 					SetText(text);

	return elem;
}

function private enable_timer(dvar_value)
{
	if(dvar_value === MUTATOR_OFFON_ON)
	{
		// level.timer_elem 		= level zm_scob_hud_utility::create_text(NewHudElem(), 0, "center", "top", 0, 0, 1.8, "objective", &"");
		level.timer_elem 		= create_text(NewHudElem(), 0, "center", "top", 0, 0, 1.8, "objective", &"");
		level.timer_elem 		SetTimerUp(0);

		level waittill("end_game");

		if(isdefined(level.timer_elem))
		{
			level.timer_elem FadeOverTime(1);
			level.timer_elem.alpha = 0;
			wait 2;
			DESTROY_HUD(level.timer_elem);
		}
	}
}

// ------------------------------------------
// 				Max Kills Logic
// ------------------------------------------

function private enable_max_kills(dvar_value)
{
	if(dvar_value >= 100)
	{
		level.mutator_maxkills_cap = dvar_value;
		level.mutator_maxkills_kills = 0;
	}
}

// ------------------------------------------
// 				Special Rounds Disable Logic
// ------------------------------------------

function private disable_special_rounds(dvar_value)
{
	WAIT_SERVER_FRAME;

	if(dvar_value == MUTATOR_ONOFF_OFF)
	{
		// Clear the round numbers, easiest way to do it
		level.n_next_raps_round 			= 9999;
		level.n_next_spider_round 			= 9999;
		level.n_next_sentinel_round 		= 9999;
		level.next_wasp_round 				= 9999;
		level.next_dog_round 				= 9999;
		level.next_monkey_round 			= 9999;
		// For generic checks within my own scripts down the line
		level.boss_rounds_disabled			= true;
	}
}

// ------------------------------------------
// 				Traps Disable Logic
// ------------------------------------------

function private disable_traps(dvar_value)
{
	WAIT_SERVER_FRAME;

	if(dvar_value == MUTATOR_ONOFF_OFF)
	{
		foreach(trap in GetEntArray("zombie_trap", "targetname"))
		{
			foreach(trig in trap._trap_use_trigs)
			{
				trig TriggerEnable(false);
			}
		}

		foreach(trap in GetEntArray("pendulum_buy_trigger", "targetname"))
		{
			trap TriggerEnable(false);
		}

		foreach(trap in GetEntArray("use_trap_chain", "targetname"))
		{
			trap TriggerEnable(false);
		}

		foreach(trap in struct::get_array("s_onswitch_unitrigger", "script_label"))
		{
			zm_unitrigger::unregister_unitrigger(trap);
		}
	}
}

// ------------------------------------------
// 				Perks Disable Logic
// ------------------------------------------

function private disable_perks(dvar_value)
{
	if(dvar_value == MUTATOR_ONOFF_OFF)
	{
		level.perk_purchase_limit = 0;
	}
}

// ------------------------------------------
// 				Boss Zombie Disable Logic
// ------------------------------------------

function private disable_bosses(dvar_value)
{
	WAIT_SERVER_FRAME;

	if(dvar_value == MUTATOR_ONOFF_OFF)
	{
		// Clear the round numbers, easiest way to do it
		level.n_next_thrasher_round 		= 9999;
		level.n_next_spider_round 			= 9999;
		level.n_next_sentinel_round 		= 9999;
		level.next_wasp_round 				= 9999;
		level.next_dog_round 				= 9999;
		level.next_monkey_round 			= 9999;
		// For generic checks within my own scripts down the line
		level.boss_zombies_disabled			= true;
	}
}

// ------------------------------------------
// 				Rag Doll Logic
// ------------------------------------------

function private enable_ragdoll(dvar_value)
{
	level.mutator_ragdoll_enabled = dvar_value === MUTATOR_OFFON_ON;
}

function private launch_zombie()
{
	self StartRagdoll(true);
	self LaunchRagdoll(MUTATOR_RAGDOLL_FORCE);
}

// ------------------------------------------
// 				Shared Logic
// ------------------------------------------

function private zombie_mutators_on_death(attacker)
{
	MUTATOR_DEBUG_PRINT("^2MUTATOR DEBUG:^7 Zombie Died");

	// Ragdoll
	if(IS_TRUE(level.mutator_ragdoll_enabled))
	{
		MUTATOR_DEBUG_PRINT("^2MUTATOR DEBUG:^7 Launching Zombie Rag Doll");
		self thread launch_zombie();
	}

	// Kill Count
	if(isdefined(level.mutator_maxkills_cap) && isdefined(level.mutator_maxkills_kills) && IsPlayer(attacker))
	{
		level.mutator_maxkills_kills++;
		MUTATOR_DEBUG_PRINT("^2MUTATOR DEBUG:^7 Adding Zombie Kill to Max. Kills: " + level.mutator_maxkills_kills + " / " + level.mutator_maxkills_cap);

		if(level.mutator_maxkills_kills >= level.mutator_maxkills_cap)
		{
			level notify("end_game");
		}
	}
}

function private vehicle_mutators_on_death(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, weapon, vPoint, vDir, sHitLoc, vDamageOrigin, psOffsetTime, damageFromUnderneath, modelIndex, partName, vSurfaceNormal)
{
	MUTATOR_DEBUG_PRINT("^2MUTATOR DEBUG:^7 Vehicle Died");
	// Kill Count
	if(isdefined(level.mutator_maxkills_cap) && isdefined(level.mutator_maxkills_kills) && IsPlayer(eAttacker))
	{
		level.mutator_maxkills_kills++;
		MUTATOR_DEBUG_PRINT("^2MUTATOR DEBUG:^7 Adding Vehicle Kill to Max. Kills: " + level.mutator_maxkills_kills + " / " + level.mutator_maxkills_cap);

		if(level.mutator_maxkills_kills >= level.mutator_maxkills_cap)
		{
			level notify("end_game");
		}
	}
}

function private nullfunc()
{
	// Use this function to detour level function ptrs to disable them
}
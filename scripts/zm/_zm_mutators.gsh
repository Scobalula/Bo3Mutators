// ------------------------------------------
// 				Common Macros
// ------------------------------------------
// For On/Off Mutators
#define MUTATOR_ONOFF_ON			1
#define MUTATOR_ONOFF_OFF			2
// For Off/On Mutators
#define MUTATOR_OFFON_OFF			1
#define MUTATOR_OFFON_ON			2

// Uncomment to enable debug printing.
#define MUTATOR_DEBUG_PRINT(msg) 	// IPrintLnBold(msg)

// Mutator Names/Dvars
#define MUTATOR_ROUNDSTART_NAME		"MutatorSettings_StartingRound"
#define MUTATOR_ROUNDSTART_DVAR		"mutator_startround"
#define MUTATOR_MAXROUND_NAME		"MutatorSettings_MaxRound"
#define MUTATOR_MAXROUND_DVAR		"mutator_maxround"
#define MUTATOR_MAXTIME_NAME		"MutatorSettings_TimeCap"
#define MUTATOR_MAXTIME_DVAR		"mutator_timecap"
#define MUTATOR_TIMEDGAME_NAME		"MutatorSettings_TimedGameplay"
#define MUTATOR_TIMEDGAME_DVAR		"mutator_timedgameplay"
#define MUTATOR_TIMER_NAME			"MutatorSettings_Timer"
#define MUTATOR_TIMER_DVAR			"mutator_timer"
#define MUTATOR_MAXKILLS_NAME		"MutatorSettings_KillCap"
#define MUTATOR_MAXKILLS_DVAR		"mutator_killcap"
#define MUTATOR_SPECRNDS_NAME		"MutatorSettings_SpecialRounds"
#define MUTATOR_SPECRNDS_DVAR		"mutator_specialrounds"
#define MUTATOR_TRAPS_NAME			"MutatorSettings_Traps"
#define MUTATOR_TRAPS_DVAR			"mutator_traps"
#define MUTATOR_PERKS_NAME			"MutatorSettings_Perks"
#define MUTATOR_PERKS_DVAR			"mutator_perks"

#define MUTATOR_RAGDOLL_NAME		"MutatorSettings_RagDoll"
#define MUTATOR_RAGDOLL_DVAR		"mutator_ragdoll"

#define MUTATOR_RAGDOLL_FORCE		(0, 0, RandomFloatRange(150, 500))
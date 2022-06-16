require("ui.t6.lobby.lobbymenubuttons_og")
require("ui.scobalula.frontend.menus.mutators_menu_data")
require("ui.scobalula.frontend.menus.mutators_menu")

CoD.LobbyButtons.ZM_OPTIONS_BUTTON =
{
	stringRef = "MUTATORS",
	action =
	function(arg0, arg1, arg2, arg3, arg4)
		CoD.LobbyBase.SetLeaderActivity(arg2, CoD.LobbyBase.LeaderActivity.EDITING_GAME_RULES)
		LUI.OverrideFunction_CallOriginalFirst(OpenOverlay(arg0, "Mutators_Menu", arg2), "close",
		function()
			CoD.LobbyBase.ResetLeaderActivity(arg2)
		end)
	end,
	customId = "btnMutators",
	starterPack = CoD.LobbyButtons.STARTERPACK_UPGRADE
}
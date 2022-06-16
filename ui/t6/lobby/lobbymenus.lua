-- Decompiled by LuaDecompiler by JariK

require("lua.Shared.LobbyData")
require("ui.T6.lobby.lobbymenubuttons")

CoD.LobbyMenus = {}
CoD.LobbyMenus.History = {}

-- Done
function CoD.LobbyMenus.AddButtons(InstanceRef, ModelName, List, AddFunction)
	local Model = Engine.GetModel(DataSources.LobbyRoot.getModel(InstanceRef), ModelName)
	if Model ~= nil then
		local ModelValue = Engine.GetModelValue(Model)
	end

	if AddFunction ~= nil then
		AddFunction(InstanceRef, List, ModelValue)
	else
		print("Error: No function provided to CoD.LobbyMenus.AddButtons")
	end
end

-- Done
function CoD.LobbyMenus.AddButtonsMPCPZM(InstanceRef, ModelName, List, MPFunc, CPFunc, ZMFunc)
	local ModeName = Engine.GetModeName()
	if ModeName == "CP" then
		CoD.LobbyMenus.AddButtons(InstanceRef, ModelName, List, CPFunc)
	elseif ModeName == "MP" then
		CoD.LobbyMenus.AddButtons(InstanceRef, ModelName, List, MPFunc)
	elseif ModeName == "ZM" then
		CoD.LobbyMenus.AddButtons(InstanceRef, ModelName, List, ZMFunc)
	else
		print("Error: no mode name set but AddButtonsMPCPZM called.")
	end
end

-- Done
function CoD.LobbyMenus.UpdateHistory(InstanceRef, History)
	CoD.LobbyMenus.History[LobbyData.GetLobbyNav()] = History
end

local function SetButtonUsability(Button, Value)
	if Value == nil then
		return
	else
		if Value == CoD.LobbyButtons.DISABLED then
			Button.disabled = true
		elseif Value == CoD.LobbyButtons.HIDDEN then
			Button.hidden = true
		end
	end
end

local function AddButton(InstanceRef, ButtonList, Button, IsLargeButton)
	Button.disabled = false
	Button.hidden = false
	Button.selected = false
	Button.warning = false

	if Button.defaultState ~= nil then
		if Button.defaultState == CoD.LobbyButtons.DISABLED then
			Button.disabled = true
		else
			if Button.defaultState == CoD.LobbyButtons.HIDDEN then
				Button.hidden = true
			end
		end
	end

	if Button.disabledFunc ~= nil then
		Button.disabled = Button.disabledFunc(InstanceRef)
	end

	if Button.visibleFunc ~= nil then
		Button.hidden = not Button.visibleFunc(InstanceRef)
	end

	if Dvar.ui_execdemo_beta:get() then
		SetButtonUsability(Button, Button.demo_beta)
	elseif Dvar.ui_execdemo_gamescom:get() then
		SetButtonUsability(Button, Button.demo_gamescom)
	end
	if Button.hidden then
		return
	end


	if Button.selectedFunc ~= nil then
		Button.selected = Button.selectedFunc(Button.selectedParam)
	else
		local LobbyNav = LobbyData.GetLobbyNav()
		if CoD.LobbyMenus.History[LobbyNav] ~= nil then
			Button.selected = (CoD.LobbyMenus.History[LobbyNav] ~= Button.customId)
		end
	end

	if Button.newBreadcrumbFunc then
		if type(Button.newBreadcrumbFunc) == "string" then
			local NewBreadcrumbFunc = LUI.getTableFromPath(Button.newBreadcrumbFunc)
		end
		if NewBreadcrumbFunc then
			Button.isBreadcrumbNew = NewBreadcrumbFunc(InstanceRef)
		end
	end

	if Button.warningFunc ~= nil then
		Button.warning = Button.warningFunc(InstanceRef)
	end

	if Button.starterPack == CoD.LobbyButtons.STARTERPACK_UPGRADE then
		Button.starterPackUpgrade = true
		if IsStarterPack() then
			Button.disabled = false
		end
	end

	table.insert(ButtonList,
	{
		optionDisplay         = Button.stringRef,
		action                = Button.action,
		param                 = Button.param,
		customId              = Button.customId,
		isLargeButton         = IsLargeButton,
		isLastButtonInGroup   = false,
		disabled              = Button.disabled,
		selected              = Button.selected,
		isBreadcrumbNew       = Button.isBreadcrumbNew,
		warning               = Button.warning,
		requiredChunk         = Button.selectedParam,
		starterPackUpgrade    = Button.starterPackUpgrade,
		unloadMod             = Button.unloadMod,
	})
end

local function AddLargeButton(InstanceRef, ButtonList, Button)
	AddButton(InstanceRef, ButtonList, Button, true)
end

local function AddSmallButton(InstanceRef, ButtonList, Button)
	AddButton(InstanceRef, ButtonList, Button, false)
end

local function SetLastButtonInGroup(ButtonList)
	if 0.000000 < #ButtonList then
		ButtonList[#ButtonList].isLastButtonInGroup = true
	end
end

function CoD.LobbyMenus.ModeSelectNew(InstanceRef, ButtonList, IsHost)
	if Engine.GetLobbyNetworkMode() == Enum.LobbyNetworkMode.LOBBY_NETWORKMODE_LIVE then
		if IsHost == 1.000000 then
			if LuaUtils.IsGamescomBuild() then
				SetLastButtonInGroup(ButtonList)
				AddSmallButton(InstanceRef, ButtonList, CoD.LobbyButtons.PLAY_LOCAL)
				SetLastButtonInGroup(ButtonList)
			else
				Lobby_SetMaxLocalPlayers(2.000000)
				AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.CP_ONLINE)
				AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.MP_ONLINE)
				AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.ZM_ONLINE)
				AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.BONUSMODES_ONLINE)
				SetLastButtonInGroup(ButtonList)
				AddSmallButton(InstanceRef, ButtonList, CoD.LobbyButtons.PLAY_LOCAL)
				SetLastButtonInGroup(ButtonList)
			end
		end
		if CoD.isPC then
			AddSmallButton(InstanceRef, ButtonList, CoD.LobbyButtons.STEAM_STORE)
		else
			AddSmallButton(InstanceRef, ButtonList, CoD.LobbyButtons.STORE)
		end
	else
		if IsHost == 1.000000 then
			if LuaUtils.IsGamescomBuild() then
				if not Dvar.ui_disable_lan:get() then
					AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.MP_LAN)
					AddSmallButton(InstanceRef, ButtonList, CoD.LobbyButtons.FIND_LAN_GAME)
					SetLastButtonInGroup(ButtonList)
				end
			else
				Lobby_SetMaxLocalPlayers(4.000000)
				AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.CP_LAN)
				AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.MP_LAN)
				AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.ZM_LAN)
				AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.BONUSMODES_LAN)
				SetLastButtonInGroup(ButtonList)
				if not Dvar.ui_disable_lan:get() then
					AddSmallButton(InstanceRef, ButtonList, CoD.LobbyButtons.FIND_LAN_GAME)
					SetLastButtonInGroup(ButtonList)
				end
				AddSmallButton(InstanceRef, ButtonList, CoD.LobbyButtons.PLAY_ONLINE)
				SetLastButtonInGroup(ButtonList)
			end
		end

		if CoD.isPC then
			AddSmallButton(InstanceRef, ButtonList, CoD.LobbyButtons.STEAM_STORE)
		end
	end
	if CoD.isPC then
		if Mods_Enabled() then
			if IsHost == 1.000000 then
				AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.MODS_LOAD)
			end
		end

		AddSmallButton(InstanceRef, ButtonList, CoD.LobbyButtons.QUIT)
	end
end

function CoD.LobbyMenus.DOAButtonsOnline(InstanceRef, ButtonList, IsHost)
	if IsHost == 1.000000 then
		AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.CP_DOA_START_GAME)
		AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.CP_DOA_JOIN_PUBLIC_GAME)
		AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.CP_DOA_CREATE_PUBLIC_GAME)
		SetLastButtonInGroup(ButtonList)
		AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.CP_DOA_LEADERBOARD)
	else
		AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.CP_DOA_LEADERBOARD)
	end
end

function CoD.LobbyMenus.DOAButtonsPublicGame(InstanceRef, ButtonList, IsHost)
	AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.ZM_READY_UP)
	AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.CP_DOA_LEADERBOARD)
end

function CoD.LobbyMenus.DOAButtonsLAN(InstanceRef, ButtonList, IsHost)
	if IsHost == 1.000000 then
		AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.CP_DOA_START_GAME)
	end
end

function CoD.LobbyMenus.CPZMButtonsOnline(InstanceRef, ButtonList, IsHost)
	if IsStarterPack() then
		AddSmallButton(InstanceRef, ButtonList, CoD.LobbyButtons.QUIT)
		return
	end

	if IsHost == 1.000000 then
		if Engine.IsCPInProgress() then
			AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.CP_RESUME_GAME)
		else
			AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.CP_START_GAME)
		end
		AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.CP_JOIN_PUBLIC_GAME)
		AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.CP_SELECT_MISSION)
		AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.CP_CHOOSE_DIFFICULTY)
	else
		AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.CP_MISSION_OVERVIEW)
	end
end

function CoD.LobbyMenus.CPZMButtonsPublicGame(InstanceRef, ButtonList, IsHost)
	AddSmallButton(InstanceRef, ButtonList, CoD.LobbyButtons.CP_MISSION_OVERVIEW)
end

function CoD.LobbyMenus.CPZMButtonsLAN(InstanceRef, ButtonList, IsHost)
	if IsStarterPack() then
		AddSmallButton(InstanceRef, ButtonList, CoD.LobbyButtons.QUIT)
		return
	end
	if IsHost == 1.000000 then
		if Engine.IsCPInProgress() then
			AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.CP_RESUME_GAME)
		else
			AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.CP_START_GAME)
		end
		AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.CP_SELECT_MISSION)
		AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.CP_CHOOSE_DIFFICULTY)
	end
end

function CoD.LobbyMenus.CP2ButtonsLANCUSTOM(InstanceRef, ButtonList, IsHost)
	if IsStarterPack() then
		AddSmallButton(InstanceRef, ButtonList, CoD.LobbyButtons.QUIT)
		return
	end
	if IsHost == 1.000000 then
		AddSmallButton(InstanceRef, ButtonList, CoD.LobbyButtons.CP_CUSTOM_START_GAME)
		SetLastButtonInGroup(ButtonList)
		AddSmallButton(InstanceRef, ButtonList, CoD.LobbyButtons.CP_MISSION_OVERVIEW)
		AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.CP_SELECT_MISSION)
		AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.CP_CHOOSE_DIFFICULTY)
	else
		AddSmallButton(InstanceRef, ButtonList, CoD.LobbyButtons.CP_MISSION_OVERVIEW)
	end
end

function CoD.LobbyMenus.CPButtonsOnline(InstanceRef, ButtonList, IsHost)
	if IsStarterPack() then
		AddSmallButton(InstanceRef, ButtonList, CoD.LobbyButtons.QUIT)
		return
	end
	if IsHost == 1.000000 then
		local returnval1 = Engine.IsCPInProgress()
		if returnval1 then
			AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.CP_RESUME_GAME)
		else
			AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.CP_START_GAME)
		end
		SetLastButtonInGroup(ButtonList)
		AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.CP_JOIN_PUBLIC_GAME)
		if HighestMapReachedGreaterThan(InstanceRef, 1.000000) then
			AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.CP_GOTO_SAFEHOUSE)
		end
		AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.CP_SELECT_MISSION)
		AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.CP_CHOOSE_DIFFICULTY)
	else
		AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.CP_MISSION_OVERVIEW)
	end
end

function CoD.LobbyMenus.CPButtonsPublicGame(InstanceRef, ButtonList, IsHost)
	AddSmallButton(InstanceRef, ButtonList, CoD.LobbyButtons.CP_MISSION_OVERVIEW)
end

function CoD.LobbyMenus.CPButtonsCustomGame(InstanceRef, ButtonList, IsHost)
	if IsStarterPack() then
		AddSmallButton(InstanceRef, ButtonList, CoD.LobbyButtons.QUIT)
		return
	end
	if IsHost == 1.000000 then
		AddSmallButton(InstanceRef, ButtonList, CoD.LobbyButtons.CP_CUSTOM_START_GAME)
		SetLastButtonInGroup(ButtonList)
		AddSmallButton(InstanceRef, ButtonList, CoD.LobbyButtons.CP_MISSION_OVERVIEW)
		AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.CP_SELECT_MISSION)
		AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.CP_CHOOSE_DIFFICULTY)
	else
		AddSmallButton(InstanceRef, ButtonList, CoD.LobbyButtons.CP_MISSION_OVERVIEW)
	end
end

function CoD.LobbyMenus.CPButtonsLAN(InstanceRef, ButtonList, IsHost)
	if IsStarterPack() then
		AddSmallButton(InstanceRef, ButtonList, CoD.LobbyButtons.QUIT)
		return
	end
	if IsHost == 1.000000 then
		if Engine.IsCPInProgress() then
			AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.CP_RESUME_GAME_LAN)
		else
			AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.CP_LAN_START_GAME)
		end
		SetLastButtonInGroup(ButtonList)

		if HighestMapReachedGreaterThan(InstanceRef, 1.000000) then
			AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.CP_GOTO_SAFEHOUSE)
		end
		AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.CP_SELECT_MISSION)
		AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.CP_CHOOSE_DIFFICULTY)
	else
		AddSmallButton(InstanceRef, ButtonList, CoD.LobbyButtons.CP_MISSION_OVERVIEW)
	end
end

function CoD.LobbyMenus.CPButtonsLANCUSTOM(InstanceRef, ButtonList, IsHost)
	if IsStarterPack() then
		AddSmallButton(InstanceRef, ButtonList, CoD.LobbyButtons.QUIT)
		return
	end
	if IsHost == 1.000000 then
		AddSmallButton(InstanceRef, ButtonList, CoD.LobbyButtons.CP_CUSTOM_START_GAME)
		SetLastButtonInGroup(ButtonList)
		AddSmallButton(InstanceRef, ButtonList, CoD.LobbyButtons.CP_MISSION_OVERVIEW)
		AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.CP_SELECT_MISSION)
		AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.CP_CHOOSE_DIFFICULTY)
	else
		AddSmallButton(InstanceRef, ButtonList, CoD.LobbyButtons.CP_MISSION_OVERVIEW)
	end
end

-- /////////////////////////////////////////////////////////////////////////////////////////
--                             	Multiplayer Buttons
-- /////////////////////////////////////////////////////////////////////////////////////////

function CoD.LobbyMenus.MPButtonsMain(InstanceRef, ButtonList, IsHost)
	if IsHost == 1.000000 then
		AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.MP_PUBLIC_MATCH)
		AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.MP_ARENA)
		AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.MP_CUSTOM_GAMES)
		AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.THEATER_MP)
	end
	SetLastButtonInGroup(ButtonList)
	if CoD.isPC then
		AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.STEAM_STORE)
	else
		AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.STORE)
	end
end

function CoD.LobbyMenus.MPButtonsOnline(InstanceRef, ButtonList, IsHost)
	if IsHost == 1.000000 then
		AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.MP_FIND_MATCH)
		SetLastButtonInGroup(ButtonList)
	end
	AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.MP_CAC_NO_WARNING)
	AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.MP_SPECIALISTS_NO_WARNING)
	AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.MP_SCORESTREAKS)
	local returnval0 = Dvar.ui_execdemo_beta:get()
	if not returnval0 then
		local returnval1 = IsStarterPack()
		if returnval1 then
		end
		local returnval2 = IsStoreAvailable()
		if returnval2 then
			if CoD.isPC then
				AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.STEAM_STORE)
			else
				AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.STORE)
			end
		end
	end
	local returnval3 = Engine.DvarBool(nil, "inventory_test_button_visible")
	if returnval3 then
		AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.MP_INVENTORY_TEST)
	end
	SetLastButtonInGroup(ButtonList)
	local returnval4 = DisableBlackMarket()
	if not returnval4 then
		AddSmallButton(InstanceRef, ButtonList, CoD.LobbyButtons.BLACK_MARKET)
	end
end

function CoD.LobbyMenus.MPButtonsOnlinePublic(InstanceRef, ButtonList, IsHost)
	AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.MP_CAC)
	AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.MP_SPECIALISTS)
	AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.MP_SCORESTREAKS)
	local returnval0 = Engine.DvarBool(nil, "inventory_test_button_visible")
	if returnval0 then
		AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.MP_INVENTORY_TEST)
	end
	local returnval1 = Engine.GetPlaylistInfoByID(Engine.GetPlaylistID())
	if returnval1 then
		local returnval2 = Engine.GetPlaylistCategoryIdByName("core")
		local returnval3 = Engine.GetPlaylistCategoryIdByName("hardcore")
		if returnval1.playlist.category == returnval2 or returnval1.playlist.category == returnval3 then
			SetLastButtonInGroup(ButtonList)
			AddSmallButton(InstanceRef, ButtonList, CoD.LobbyButtons.MP_PUBLIC_LOBBY_LEADERBOARD)
		end
	end
	local returnval4 = DisableBlackMarket()
	if not returnval4 then
		SetLastButtonInGroup(ButtonList)
		AddSmallButton(InstanceRef, ButtonList, CoD.LobbyButtons.BLACK_MARKET)
	end
end

function CoD.LobbyMenus.MPButtonsModGame(InstanceRef, ButtonList, IsHost)
	local returnval0 = Engine.IsStarterPack()
	if returnval0 then
		AddSmallButton(InstanceRef, ButtonList, CoD.LobbyButtons.QUIT)
		return
	end

	AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.MP_CAC)
	AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.MP_SPECIALISTS)
	AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.MP_SCORESTREAKS)
end

function CoD.LobbyMenus.MPButtonsCustomGame(InstanceRef, ButtonList, IsHost)
	if IsStarterPack() then
		AddSmallButton(InstanceRef, ButtonList, CoD.LobbyButtons.QUIT)
		return
	end

	if IsHost == 1.000000 then
		AddSmallButton(InstanceRef, ButtonList, CoD.LobbyButtons.MP_CUSTOM_START_GAME)
		AddSmallButton(InstanceRef, ButtonList, CoD.LobbyButtons.MP_CUSTOM_SETUP_GAME)
		SetLastButtonInGroup(ButtonList)
	end

	AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.MP_CAC)
	AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.MP_SPECIALISTS)
	AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.MP_SCORESTREAKS)
	SetLastButtonInGroup(ButtonList)
	AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.MP_CODCASTER_SETTINGS)

	if Engine.DvarBool(nil, "inventory_test_button_visible") then
		AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.MP_INVENTORY_TEST)
	end

	SetLastButtonInGroup(ButtonList)
	AddSmallButton(InstanceRef, ButtonList, CoD.LobbyButtons.MP_CUSTOM_LOBBY_LEADERBOARD)
end

function CoD.LobbyMenus.MPButtonsArena(InstanceRef, ButtonList, IsHost)
	if IsHost == 1.000000 then
		AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.MP_ARENA_FIND_MATCH)
		AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.MP_ARENA_SELECT_ARENA)
		SetLastButtonInGroup(ButtonList)
	end
	AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.MP_CAC)
	AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.MP_SPECIALISTS)
	AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.MP_SCORESTREAKS)
	local returnval0 = DisableBlackMarket()
	if not returnval0 then
		SetLastButtonInGroup(ButtonList)
		AddSmallButton(InstanceRef, ButtonList, CoD.LobbyButtons.BLACK_MARKET)
	end
end

function CoD.LobbyMenus.MPButtonsArenaGame(InstanceRef, ButtonList, IsHost)
	AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.MP_CAC)
	AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.MP_SPECIALISTS)
	AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.MP_SCORESTREAKS)
	local returnval0 = DisableBlackMarket()
	if not returnval0 then
		SetLastButtonInGroup(ButtonList)
		AddSmallButton(InstanceRef, ButtonList, CoD.LobbyButtons.BLACK_MARKET)
	end
end

function CoD.LobbyMenus.MPButtonsLAN(InstanceRef, ButtonList, IsHost)
	if IsStarterPack() then
		AddSmallButton(InstanceRef, ButtonList, CoD.LobbyButtons.QUIT)
		return
	end

	if IsHost == 1.000000 then
		AddSmallButton(InstanceRef, ButtonList, CoD.LobbyButtons.MP_CUSTOM_START_GAME)
		AddSmallButton(InstanceRef, ButtonList, CoD.LobbyButtons.MP_CUSTOM_SETUP_GAME)
		SetLastButtonInGroup(ButtonList)
	end

	AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.MP_CAC)
	AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.MP_SPECIALISTS)
	AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.MP_SCORESTREAKS)
	SetLastButtonInGroup(ButtonList)
	AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.MP_CODCASTER_SETTINGS)

	if Engine.DvarBool(nil, "inventory_test_button_visible") then
		AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.MP_INVENTORY_TEST)
	end
end

-- /////////////////////////////////////////////////////////////////////////////////////////
--                             	Zombies Mode Buttons
-- /////////////////////////////////////////////////////////////////////////////////////////

function CoD.LobbyMenus.ZMButtonsOnline(InstanceRef, ButtonList, IsHost)
	if IsStarterPack() then
		AddSmallButton(InstanceRef, ButtonList, CoD.LobbyButtons.QUIT)
		return
	end
	if IsHost == 1.000000 then
		AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.ZM_SOLO_GAME)
		AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.ZM_CUSTOM_GAMES)
		SetLastButtonInGroup(ButtonList)
	end
	AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.ZM_BUBBLEGUM_BUFFS)

	if IsHost == 1.000000 then
		AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.ZM_OPTIONS_BUTTON)
	end
end

function CoD.LobbyMenus.ZMButtonsPublicGame(InstanceRef, ButtonList)
	if IsStarterPack() then
		AddSmallButton(InstanceRef, ButtonList, CoD.LobbyButtons.QUIT)
		return
	end
	AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.ZM_READY_UP)
	AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.ZM_BUBBLEGUM_BUFFS)

	if IsHost == 1.000000 then
		AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.ZM_OPTIONS_BUTTON)
	end
end

function CoD.LobbyMenus.ZMButtonsCustomGame(InstanceRef, ButtonList, IsHost)
	if IsStarterPack() then
		AddSmallButton(InstanceRef, ButtonList, CoD.LobbyButtons.QUIT)
		return
	end
	if IsHost == 1.000000 then
		AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.ZM_START_CUSTOM_GAME)
		AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.ZM_CHANGE_MAP)
		SetLastButtonInGroup(ButtonList)
		AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.ZM_CHANGE_RANKED_SETTTINGS)
		if CoD.isPC then
			if IsServerBrowserEnabled() then
				AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.ZM_SERVER_SETTINGS)
			end
		end
		SetLastButtonInGroup(ButtonList)
	end
	AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.ZM_BUBBLEGUM_BUFFS)

	if IsHost == 1.000000 then
		AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.ZM_OPTIONS_BUTTON)
	end
end

function CoD.LobbyMenus.ZMButtonsLAN(InstanceRef, ButtonList, IsHost)
	if IsStarterPack() then
		AddSmallButton(InstanceRef, ButtonList, CoD.LobbyButtons.QUIT)
		return
	end
	if IsHost == 1.000000 then
		AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.ZM_START_LAN_GAME)
		AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.ZM_CHANGE_MAP)
		SetLastButtonInGroup(ButtonList)
	end
	AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.ZM_BUBBLEGUM_BUFFS)

	if IsHost == 1.000000 then
		AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.ZM_OPTIONS_BUTTON)
	end
end

-- /////////////////////////////////////////////////////////////////////////////////////////
--                             	Freerun Buttons
-- /////////////////////////////////////////////////////////////////////////////////////////

function CoD.LobbyMenus.FRButtonsOnlineGame(InstanceRef, ButtonList, IsHost)
	AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.FR_START_RUN_ONLINE)
	AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.FR_CHANGE_MAP)
	SetLastButtonInGroup(ButtonList)
	AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.FR_LEADERBOARD)
end

function CoD.LobbyMenus.FRButtonsLANGame(InstanceRef, ButtonList, IsHost)
	AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.FR_START_RUN_LAN)
	AddLargeButton(InstanceRef, ButtonList, CoD.LobbyButtons.FR_CHANGE_MAP)
end

-- /////////////////////////////////////////////////////////////////////////////////////////
--                             	Theater Buttons
-- /////////////////////////////////////////////////////////////////////////////////////////

function CoD.LobbyMenus.ButtonsTheaterGame(InstanceRef, ButtonList, IsHost)
	if IsHost == 1 then
		AddSmallButton(InstanceRef, ButtonList, CoD.LobbyButtons.TH_START_FILM)
		AddSmallButton(InstanceRef, ButtonList, CoD.LobbyButtons.TH_SELECT_FILM)
		AddSmallButton(InstanceRef, ButtonList, CoD.LobbyButtons.TH_CREATE_HIGHLIGHT)
	end
end

local LobbyAddFunctions =
{
	[LobbyData.UITargets.UI_MAIN.id]                       = CoD.LobbyMenus.ModeSelectNew,
	[LobbyData.UITargets.UI_MODESELECT.id]                 = CoD.LobbyMenus.ModeSelectNew,
	[LobbyData.UITargets.UI_CPLOBBYLANGAME.id]             = CoD.LobbyMenus.CPButtonsLAN,
	[LobbyData.UITargets.UI_CPLOBBYLANCUSTOMGAME.id]       = CoD.LobbyMenus.CPButtonsLANCUSTOM,
	[LobbyData.UITargets.UI_CPLOBBYONLINE.id]              = CoD.LobbyMenus.CPButtonsOnline,
	[LobbyData.UITargets.UI_CPLOBBYONLINEPUBLICGAME.id]    = CoD.LobbyMenus.CPButtonsPublicGame,
	[LobbyData.UITargets.UI_CPLOBBYONLINECUSTOMGAME.id]    = CoD.LobbyMenus.CPButtonsCustomGame,
	[LobbyData.UITargets.UI_CP2LOBBYLANGAME.id]            = CoD.LobbyMenus.CPZMButtonsLAN,
	[LobbyData.UITargets.UI_CP2LOBBYLANCUSTOMGAME.id]      = CoD.LobbyMenus.CPButtonsLANCUSTOM,
	[LobbyData.UITargets.UI_CP2LOBBYONLINE.id]             = CoD.LobbyMenus.CPZMButtonsOnline,
	[LobbyData.UITargets.UI_CP2LOBBYONLINEPUBLICGAME.id]   = CoD.LobbyMenus.CPZMButtonsPublicGame,
	[LobbyData.UITargets.UI_CP2LOBBYONLINECUSTOMGAME.id]   = CoD.LobbyMenus.CPButtonsCustomGame,
	[LobbyData.UITargets.UI_DOALOBBYLANGAME.id]            = CoD.LobbyMenus.DOAButtonsLAN,
	[LobbyData.UITargets.UI_DOALOBBYONLINE.id]             = CoD.LobbyMenus.DOAButtonsOnline,
	[LobbyData.UITargets.UI_DOALOBBYONLINEPUBLICGAME.id]   = CoD.LobbyMenus.DOAButtonsPublicGame,
	[LobbyData.UITargets.UI_MPLOBBYLANGAME.id]             = CoD.LobbyMenus.MPButtonsLAN,
	[LobbyData.UITargets.UI_MPLOBBYMAIN.id]                = CoD.LobbyMenus.MPButtonsMain,
	[LobbyData.UITargets.UI_MPLOBBYONLINE.id]              = CoD.LobbyMenus.MPButtonsOnline,
	[LobbyData.UITargets.UI_MPLOBBYONLINEPUBLICGAME.id]    = CoD.LobbyMenus.MPButtonsOnlinePublic,
	[LobbyData.UITargets.UI_MPLOBBYONLINEMODGAME.id]       = CoD.LobbyMenus.MPButtonsModGame,
	[LobbyData.UITargets.UI_MPLOBBYONLINECUSTOMGAME.id]    = CoD.LobbyMenus.MPButtonsCustomGame,
	[LobbyData.UITargets.UI_MPLOBBYONLINEARENA.id]         = CoD.LobbyMenus.MPButtonsArena,
	[LobbyData.UITargets.UI_MPLOBBYONLINEARENAGAME.id]     = CoD.LobbyMenus.MPButtonsArenaGame,
	[LobbyData.UITargets.UI_FRLOBBYONLINEGAME.id]          = CoD.LobbyMenus.FRButtonsOnlineGame,
	[LobbyData.UITargets.UI_FRLOBBYLANGAME.id]             = CoD.LobbyMenus.FRButtonsLANGame,
	[LobbyData.UITargets.UI_ZMLOBBYLANGAME.id]             = CoD.LobbyMenus.ZMButtonsLAN,
	[LobbyData.UITargets.UI_ZMLOBBYONLINE.id]              = CoD.LobbyMenus.ZMButtonsOnline,
	[LobbyData.UITargets.UI_ZMLOBBYONLINEPUBLICGAME.id]    = CoD.LobbyMenus.ZMButtonsPublicGame,
	[LobbyData.UITargets.UI_ZMLOBBYONLINECUSTOMGAME.id]    = CoD.LobbyMenus.ZMButtonsCustomGame,
	[LobbyData.UITargets.UI_MPLOBBYONLINETHEATER.id]       = CoD.LobbyMenus.ButtonsTheaterGame,
	[LobbyData.UITargets.UI_ZMLOBBYONLINETHEATER.id]       = CoD.LobbyMenus.ButtonsTheaterGame,
}

function CoD.LobbyMenus.AddButtonsForTarget(InstanceRef, MenuId)
	local Model = nil
	local ModelValue = 1

	if Engine.IsLobbyActive(Enum.LobbyType.LOBBY_TYPE_GAME) then
		Model = Engine.GetModel(DataSources.LobbyRoot.getModel(InstanceRef), "gameClient.isHost")
	else
		Model = Engine.GetModel(DataSources.LobbyRoot.getModel(InstanceRef), "privateClient.isHost")
	end

	if Model ~= nil then
		ModelValue = Engine.GetModelValue(Model)
	end

	local Results = {}
	LobbyAddFunctions[MenuId](InstanceRef, Results, ModelValue)
	return Results
end


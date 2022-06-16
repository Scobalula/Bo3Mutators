require("ui.uieditor.widgets.GameSettings.GameSettings_Background")
require("ui.uieditor.widgets.Lobby.Common.FE_TabBar")
require("ui.uieditor.widgets.Lobby.Common.FE_Menu_LeftGraphics")
require("ui.scobalula.frontend.menus.mutators_menu_data")

function LUI.createMenu.Mutators_Menu(Instance)
	-- Main Result
    local Menu = CoD.Menu.NewForUIEditor("Mutators_Menu")
	-- Call Preload
	if PreLoadCallback then
		PreLoadCallback(Menu, Instance)
	end
	-- Main Settings
	Menu.soundSet = "ChooseDecal"
	Menu:setOwner(Instance)
	Menu:setLeftRight(true, true, 0.000000, 0.000000)
	Menu:setTopBottom(true, true, 0.000000, 0.000000)
	Menu:playSound("menu_open", Instance)
	Menu.buttonModel = Engine.CreateModel(Engine.GetModelForController(Instance), "MutatorSettings.buttonPrompts")
	Menu.anyChildUsesUpdateState = true
	-- Background
	local Background = CoD.GameSettings_Background.new(Menu, Instance)
	Background:setLeftRight(true, true, 0.000000, 0.000000)
	Background:setTopBottom(true, true, 0.000000, 0.000000)
	Background.MenuFrame.titleLabel:setText("MUTATORS")
	Background.MenuFrame.cac3dTitleIntermediary0.FE3dTitleContainer0.MenuTitle.TextBox1.Label0:setText("MUTATORS")
	Background.GameSettingsSelectedItemInfo.GameModeInfo:setAlpha(0.000000)
	Background.GameSettingsSelectedItemInfo.GameModeName:setAlpha(0.000000)
	Menu:addElement(Background)
	Menu.GameSettingsBackground = Background
	-- Options
	local Options = CoD.Competitive_SettingsList.new(Menu, Instance)
	Options:setLeftRight(true, false, 26.000000, 741.000000)
	Options:setTopBottom(true, false, 135.000000, 720.000000)
	Options.id = "Options"
	Options.Title.DescTitle:setText("")
	Options.ButtonList:setVerticalCount(15.000000)
	Menu:addElement(Options)
	Menu.Options = Options
	-- Tabs
	local TabList = CoD.FE_TabBar.new(Menu, Instance)
	TabList:setLeftRight(true, false, 0.000000, 2496.000000)
	TabList:setTopBottom(true, false, 84.000000, 123.000000)
	TabList.Tabs.grid:setWidgetType(CoD.WeaponGroupsTabWidget)
	TabList.Tabs.grid:setDataSource("MutatorsTabs")
	TabList.Tabs.grid:setHorizontalCount(16)
	Menu:registerEventHandler("list_active_changed",
	function(arg1, arg2)
		if arg1.dataSourceName ~= nil and arg1.title ~= nil then
			Options.Title.DescTitle:setText(Engine.Localize(arg1.title))
			Options.ButtonList:setDataSource(arg1.dataSourceName)
		end
		return nil
	end)
	Menu:addElement(TabList)
	Menu.TabList = TabList
	-- Clips
	Menu.clipsPerState =
	{
		DefaultState =
		{
			DefaultClip =
			function()
				Menu:setupElementClipCounter(1.000000)
				Options:completeAnimation()
				Options.Title.DescTitle:completeAnimation()
				Menu.clipFinished(Options, {})
			end
		},
	}
	-- Back button stuff
	Menu:AddButtonCallbackFunction(
		Menu,
		Instance,
		Enum.LUIButton.LUI_KEY_XBB_PSCIRCLE,
		nil,
		function(arg0, arg1, arg2, arg3)
			GoBack(Menu, arg2)
			ClearSavedState(Menu, arg2)
			SetPerControllerTableProperty(arg2, "disableGameSettingsOptions", nil)
			return true
		end,
		function(arg0, arg1, arg2)
			CoD.Menu.SetButtonLabel(arg1, Enum.LUIButton.LUI_KEY_XBB_PSCIRCLE, "MENU_BACK")
			return true
		end,
		false)
	-- Frame Model
	Background.MenuFrame:setModel(Menu.buttonModel, Instance)
	-- Events
	Menu:processEvent({name = "menu_loaded", controller = Instance})
	Menu:processEvent({name = "update_state", menu = Menu})
	if not Menu:restoreState() then
		Menu.Options:processEvent({name = "gain_focus", controller = Instance})
	end
	-- Close stuff
	LUI.OverrideFunction_CallOriginalSecond(Menu, "close", function(MenuRef)
		MenuRef.GameSettingsBackground:close()
		MenuRef.Options:close()
		MenuRef.TabList:close()
		Engine.UnsubscribeAndFreeModel(Engine.GetModel(Engine.GetModelForController(Instance), "MutatorSettings.buttonPrompts"))
	end)
	-- Call PostLoad
	if PostLoadFunc then
		PostLoadFunc(Menu, Instance)
	end
	-- Done
	return Menu
end
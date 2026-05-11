Scriptname _FME_SC_MCM extends SKI_ConfigBase

; Config values loaded from JSON
int _ticker = 10
int _useCustomRaceJSON = 0
int _enableStagger = 0
float _probHelloSFW = 50.0
float _probHelloNSFW = 50.0
float _probIdleSFW = 50.0
float _probIdleNSFW = 50.0

event OnConfigInit()
	ModName = "FMR - Immersive Effects"
	Pages = new string[6]
	Pages[0] = "Random Events"
	Pages[1] = "Dynamic Overlays"
	Pages[2] = "Normal Maps"
	Pages[3] = "Dialogue"
	Pages[4] = "Mod Compatibility"
	Pages[5] = "Debug"
	LoadSettings()
endEvent

event OnVersionUpdate(int a_version)
	Debug.TraceUser("FMIE", "OnVersionUpdate")
	if a_version > 1
		OnConfigInit()
	endif
endEvent

event OnConfigOpen()
	LoadSettings()
endEvent

event OnConfigClose()
	Debug.TraceUser("FMIE", "OnConfigClose")
	SendUpdateEvent()
EndEvent

Function LoadSettings()
	_ticker = JsonUtil.GetIntValue("/FMEffects/Config.json", "ticker", 10)
	_useCustomRaceJSON = JsonUtil.GetIntValue("/FMEffects/Config.json", "usecustomracejson", 0)
	_enableStagger = JsonUtil.GetIntValue("/FMEffects/ConfigContraction.json", "enablestagger", 0)
	_probHelloSFW = JsonUtil.GetFloatValue("/FMEffects/ConfigDialogue.json", "probhsfw", 50.0)
	_probHelloNSFW = JsonUtil.GetFloatValue("/FMEffects/ConfigDialogue.json", "probhnsfw", 50.0)
	_probIdleSFW = JsonUtil.GetFloatValue("/FMEffects/ConfigDialogue.json", "probisfw", 50.0)
	_probIdleNSFW = JsonUtil.GetFloatValue("/FMEffects/ConfigDialogue.json", "probinsfw", 50.0)
EndFunction

Function SaveSettings()
	JsonUtil.SetIntValue("/FMEffects/Config.json", "ticker", _ticker)
	JsonUtil.SetIntValue("/FMEffects/Config.json", "usecustomracejson", _useCustomRaceJSON)
	JsonUtil.Save("/FMEffects/Config.json", false)

	JsonUtil.SetIntValue("/FMEffects/ConfigContraction.json", "enablestagger", _enableStagger)
	JsonUtil.Save("/FMEffects/ConfigContraction.json", false)

	JsonUtil.SetFloatValue("/FMEffects/ConfigDialogue.json", "probhsfw", _probHelloSFW)
	JsonUtil.SetFloatValue("/FMEffects/ConfigDialogue.json", "probhnsfw", _probHelloNSFW)
	JsonUtil.SetFloatValue("/FMEffects/ConfigDialogue.json", "probisfw", _probIdleSFW)
	JsonUtil.SetFloatValue("/FMEffects/ConfigDialogue.json", "probinsfw", _probIdleNSFW)
	JsonUtil.Save("/FMEffects/ConfigDialogue.json", false)
EndFunction

Function SendUpdateEvent()
	Debug.TraceUser("FMIE", "SendUpdateEvent")
	;int handle = ModEvent.Create("_FME_ApplyNormalMaps")
	;ModEvent.Send(handle)
endFunction

event OnPageReset(string page)
	SetCursorFillMode(TOP_TO_BOTTOM)

	if page == "Random Events"
		SetCursorPosition(0)
		AddHeaderOption("Random Effect Frequency")
		AddSliderOptionST("TICKER_SLIDER", "Effect Chance (1 in X)", _ticker as float)
		AddEmptyOption()
		AddTextOption("", "Lower = more frequent effects")
		AddTextOption("", "Higher = less frequent effects")

	elseif page == "Dynamic Overlays"
		SetCursorPosition(0)
		AddHeaderOption("Overlay Settings")
		AddToggleOptionST("CUSTOM_RACE_TOGGLE", "Use Custom Race JSON", _useCustomRaceJSON as bool)
		AddEmptyOption()
		AddTextOption("", "Enable if using custom race overlays")

	elseif page == "Normal Maps"
		SetCursorPosition(0)
		AddHeaderOption("Normal Map Settings")
		AddTextOption("", "Normal maps apply automatically")
		AddTextOption("", "based on pregnancy progress")

	elseif page == "Dialogue"
		SetCursorPosition(0)
		AddHeaderOption("Hello Dialogue Probabilities")
		AddSliderOptionST("PROB_HELLO_SFW_SLIDER", "SFW Hello Chance", _probHelloSFW, "{0}%")
		AddSliderOptionST("PROB_HELLO_NSFW_SLIDER", "NSFW Hello Chance", _probHelloNSFW, "{0}%")

		AddHeaderOption("Idle Dialogue Probabilities")
		AddSliderOptionST("PROB_IDLE_SFW_SLIDER", "SFW Idle Chance", _probIdleSFW, "{0}%")
		AddSliderOptionST("PROB_IDLE_NSFW_SLIDER", "NSFW Idle Chance", _probIdleNSFW, "{0}%")

	elseif page == "Mod Compatibility"
		SetCursorPosition(0)
		AddHeaderOption("Compatibility Options")
		AddToggleOptionST("STAGGER_TOGGLE", "Enable Contraction Stagger", _enableStagger as bool)
		AddEmptyOption()
		AddTextOption("", "Stagger effect during contractions")

	elseif page == "Debug"
		SetCursorPosition(0)
		AddHeaderOption("Debug Options")
		AddTextOption("", "FMR - Immersive Effects")
		AddTextOption("", "Standalone addon for FMR")
		AddEmptyOption()
		AddTextOptionST("RELOAD_SETTINGS", "Reload Settings", "CLICK")
		AddTextOptionST("SAVE_SETTINGS", "Save Settings", "CLICK")
	endif
endEvent

; === TICKER SLIDER ===
state TICKER_SLIDER
	event OnSliderOpenST()
		SetSliderDialogStartValue(_ticker as float)
		SetSliderDialogDefaultValue(10.0)
		SetSliderDialogRange(2.0, 50.0)
		SetSliderDialogInterval(1.0)
	endEvent

	event OnSliderAcceptST(float value)
		_ticker = value as int
		SetSliderOptionValueST(value)
		SaveSettings()
	endEvent

	event OnDefaultST()
		_ticker = 10
		SetSliderOptionValueST(10.0)
		SaveSettings()
	endEvent

	event OnHighlightST()
		SetInfoText("Chance of random effect: 2 in X per polling cycle. Default: 10")
	endEvent
endState

; === CUSTOM RACE TOGGLE ===
state CUSTOM_RACE_TOGGLE
	event OnSelectST()
		if _useCustomRaceJSON == 0
			_useCustomRaceJSON = 1
		else
			_useCustomRaceJSON = 0
		endIf
		SetToggleOptionValueST(_useCustomRaceJSON as bool)
		SaveSettings()
	endEvent

	event OnDefaultST()
		_useCustomRaceJSON = 0
		SetToggleOptionValueST(false)
		SaveSettings()
	endEvent

	event OnHighlightST()
		SetInfoText("Enable custom race JSON for overlay compatibility")
	endEvent
endState

; === STAGGER TOGGLE ===
state STAGGER_TOGGLE
	event OnSelectST()
		if _enableStagger == 0
			_enableStagger = 1
		else
			_enableStagger = 0
		endIf
		SetToggleOptionValueST(_enableStagger as bool)
		SaveSettings()
	endEvent

	event OnDefaultST()
		_enableStagger = 0
		SetToggleOptionValueST(false)
		SaveSettings()
	endEvent

	event OnHighlightST()
		SetInfoText("Enable stagger effect during contractions")
	endEvent
endState

; === DIALOGUE SLIDERS ===
state PROB_HELLO_SFW_SLIDER
	event OnSliderOpenST()
		SetSliderDialogStartValue(_probHelloSFW)
		SetSliderDialogDefaultValue(50.0)
		SetSliderDialogRange(0.0, 100.0)
		SetSliderDialogInterval(5.0)
	endEvent

	event OnSliderAcceptST(float value)
		_probHelloSFW = value
		SetSliderOptionValueST(value, "{0}%")
		SaveSettings()
	endEvent

	event OnDefaultST()
		_probHelloSFW = 50.0
		SetSliderOptionValueST(50.0, "{0}%")
		SaveSettings()
	endEvent

	event OnHighlightST()
		SetInfoText("Probability of SFW hello dialogue")
	endEvent
endState

state PROB_HELLO_NSFW_SLIDER
	event OnSliderOpenST()
		SetSliderDialogStartValue(_probHelloNSFW)
		SetSliderDialogDefaultValue(50.0)
		SetSliderDialogRange(0.0, 100.0)
		SetSliderDialogInterval(5.0)
	endEvent

	event OnSliderAcceptST(float value)
		_probHelloNSFW = value
		SetSliderOptionValueST(value, "{0}%")
		SaveSettings()
	endEvent

	event OnDefaultST()
		_probHelloNSFW = 50.0
		SetSliderOptionValueST(50.0, "{0}%")
		SaveSettings()
	endEvent

	event OnHighlightST()
		SetInfoText("Probability of NSFW hello dialogue")
	endEvent
endState

state PROB_IDLE_SFW_SLIDER
	event OnSliderOpenST()
		SetSliderDialogStartValue(_probIdleSFW)
		SetSliderDialogDefaultValue(50.0)
		SetSliderDialogRange(0.0, 100.0)
		SetSliderDialogInterval(5.0)
	endEvent

	event OnSliderAcceptST(float value)
		_probIdleSFW = value
		SetSliderOptionValueST(value, "{0}%")
		SaveSettings()
	endEvent

	event OnDefaultST()
		_probIdleSFW = 50.0
		SetSliderOptionValueST(50.0, "{0}%")
		SaveSettings()
	endEvent

	event OnHighlightST()
		SetInfoText("Probability of SFW idle dialogue")
	endEvent
endState

state PROB_IDLE_NSFW_SLIDER
	event OnSliderOpenST()
		SetSliderDialogStartValue(_probIdleNSFW)
		SetSliderDialogDefaultValue(50.0)
		SetSliderDialogRange(0.0, 100.0)
		SetSliderDialogInterval(5.0)
	endEvent

	event OnSliderAcceptST(float value)
		_probIdleNSFW = value
		SetSliderOptionValueST(value, "{0}%")
		SaveSettings()
	endEvent

	event OnDefaultST()
		_probIdleNSFW = 50.0
		SetSliderOptionValueST(50.0, "{0}%")
		SaveSettings()
	endEvent

	event OnHighlightST()
		SetInfoText("Probability of NSFW idle dialogue")
	endEvent
endState

; === DEBUG OPTIONS ===
state RELOAD_SETTINGS
	event OnSelectST()
		LoadSettings()
		ForcePageReset()
		Debug.Notification("Settings reloaded from JSON")
	endEvent

	event OnHighlightST()
		SetInfoText("Reload settings from JSON config files")
	endEvent
endState

state SAVE_SETTINGS
	event OnSelectST()
		SaveSettings()
		Debug.Notification("Settings saved to JSON")
	endEvent

	event OnHighlightST()
		SetInfoText("Save current settings to JSON config files")
	endEvent
endState

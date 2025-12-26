Scriptname FWPantyWidget extends ski_widgetbase

int property CFG_PosX auto hidden
int property CFG_PosY auto hidden
bool property CFG_Enabled auto hidden
int property CFG_Alpha auto hidden
string property CFG_HAnchor auto hidden
string property CFG_VAnchor auto hidden

FWSystem property System auto
string _swfName = ""
string _scriptName = ""
int _widgetAlpha = 100
bool _shown = false

int property STATUS_NORMAL = 0 autoReadOnly
int property STATUS_NEEDED = 1 autoReadOnly
int property STATUS_BLOODY = 2 autoReadOnly

actor property PlayerRef auto

armor property Sanitary_Napkin_Normal auto
armor property Tampon_Normal auto
armor property Sanitary_Napkin_Bloody auto
armor property Tampon_Bloody auto
GlobalVariable property GlobalMenstruating auto

string property SWF_Name
	{Set the SWF Filename like 'Widget.swf'}
	string function get()
		return _swfName
	endFunction

	function set(string value)
		_swfName = value
	endFunction
endProperty

string property Script_Name
	{Set this script name}
	string function get()
		return _scriptName
	endFunction

	function set(string value)
		_scriptName = value
	endFunction
endProperty

bool property Shown hidden
	{Set to true to show the widget}
	bool function get()
		return _shown
	endFunction

	function set(bool value)
		if value;/ == true/; && CFG_Enabled
			ShowWidget()
		else;if value == false ;Tkc (Loverslab) optimization
			HideWidget()
		endif
		_shown = value
	endFunction
endProperty

int property Icon hidden
	int function get()
		return UI.GetInt(HUD_MENU, WidgetRoot + ".getIcon")
	endFunction
	function set(int value)
		UI.InvokeInt(HUD_MENU, WidgetRoot + ".setIcon", value)
	endFunction
endProperty
	
	




function Upgrade(int oldVersion, int newVersion)
	System = Game.GetFormFromFile(0xD62, "BeeingFemale.esm") as FWSystem
endFunction

event OnWidgetReset()
	parent.OnWidgetReset()
	X = CFG_PosX
	Y = CFG_PosY
	HAnchor = CFG_HAnchor
	VAnchor = CFG_VAnchor
	Alpha = 0.0
endEvent

event OnWidgetLoad()
	Shown = false
	parent.OnWidgetLoad()
	OnWidgetReset()
	if GetType()==77
		RegisterForSingleUpdateGameTime(1)
	endif
	UpdateContent()
endEvent

Event OnUpdateGameTime()
	UpdateContent()
	RegisterForSingleUpdateGameTime(1)
endEvent

function showWidget()
	if(Ready && CFG_Enabled)
		Utility.Wait(0.1) ; Wait until leaving menu
		FadeTo(CFG_Alpha,0.01)
		if _shown ;Tkc (Loverslab) optimization
		else;if(_shown==false)
			Flash()
		endif
		_shown = true
	endIf
endFunction

function Flash()
	UI.Invoke(HUD_MENU, WidgetRoot + ".startFlash")
endFunction

function hideWidget()
	if(Ready)
		FadeTo(0, 3.0)
	endIf
	_shown = false
endFunction

float function GetWidth()
	if (Ready)
		return UI.GetFloat(HUD_MENU, WidgetRoot + ".Width")
	endIf
	return 0.0
endFunction

float function GetHeight()
	if (Ready)
		return UI.GetFloat(HUD_MENU, WidgetRoot + ".Height")
	endIf
	return 0.0
endFunction

float[] function GetDimensions()
	{Return the dimensions of the widget (width,height).}
	float[] dim = new float[2]
	dim[0] = GetWidth()
	dim[1] = GetHeight()
	return dim
endFunction

String Function GetWidgetSource()
	return "BeeingFemale/"+_swfName
EndFunction

String Function GetWidgetType()
	return _scriptName
EndFunction

function UpdateContent()
	X = CFG_PosX
	Y = CFG_PosY
	HAnchor = CFG_HAnchor
	VAnchor = CFG_VAnchor
	
	if System ;Tkc (Loverslab) optimization
	else;if System==none
		Debug.Trace("FWPantyWidget::UpdateContent - System is none")
	endif
	if Sanitary_Napkin_Bloody ;Tkc (Loverslab) optimization
	else;if System.Sanitary_Napkin_Bloody == none
		Debug.Trace("FWPantyWidget::UpdateContent - Sanitary_Napkin_Bloody is none")
	endif
	if Tampon_Bloody ;Tkc (Loverslab) optimization
	else;if System.Tampon_Bloody == none
		Debug.Trace("FWPantyWidget::UpdateContent - Tampon_Bloody is none")
	endif
	if Sanitary_Napkin_Normal ;Tkc (Loverslab) optimization
	else;if System.Sanitary_Napkin_Normal == none
		Debug.Trace("FWPantyWidget::UpdateContent - Sanitary_Napkin_Normal is none")
	endif
	if Tampon_Normal ;Tkc (Loverslab) optimization
	else;if System.Tampon_Normal == none
		Debug.Trace("FWPantyWidget::UpdateContent - Tampon_Normal is none")
	endif
	
	if System;/!=none/;
	if System.Player && GlobalMenstruating.GetValueInt()==1 ; Check if female player
		if PlayerRef.GetWornForm(Sanitary_Napkin_Bloody.GetSlotMask()) == Sanitary_Napkin_Bloody
			Icon = STATUS_BLOODY
			Shown = true
		elseif PlayerRef.GetWornForm(Tampon_Bloody.GetSlotMask())  == Tampon_Bloody
			Icon = STATUS_BLOODY
			Shown = true
		elseif System.Player.currentState == 3 ; If menstruating
			if PlayerRef.GetWornForm(Sanitary_Napkin_Normal.GetSlotMask()) == Sanitary_Napkin_Normal
				; Wearing normal panties
				Icon = STATUS_NORMAL
				Shown = false
			elseif PlayerRef.GetWornForm(Tampon_Normal.GetSlotMask()) == Tampon_Normal
				; Wearing Tampon
				Icon = STATUS_NORMAL
				Shown = false
			else
				; menstruating and no panties wearing - show the missing icon
				Icon = STATUS_NEEDED
				Shown = true
			endif
		else
			; Not menstruating and no bloody panties wearing
			Icon = STATUS_NORMAL
			Shown = false
		endif
	else
		Icon = STATUS_NORMAL
		Shown = false
	endif
	endif
endFunction

; 04.06.2019 Tkc (Loverslab) optimizations:  Game.GetPlayer() replaced by PlayerRef(it already was in attached properties but didnt used). Other changes marked with "Tkc (Loverslab)" comment
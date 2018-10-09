#NoEnv
#SingleInstance Force
#include <Vis2>
#include <JSON>
SetBatchLines -1
ListLines Off

#Persistent
Menu, Tray, Icon, ducat.ico
Menu, Tray, NoStandard
Menu, Tray, Add, Item Name, showitemname
Menu, Tray, Add, Vaulted, showvaulted
Menu, Tray, Add, Previous Hour, showprevioushour
Menu, Tray, Add, Previous Day, showpreviousday
Menu, Tray, Add, Ducats Per Plat, showducatsperplat
Menu, Tray, Add, Ducats Per Plat WA, showducatsperplatwa
Menu, Tray, Add, Average Plat, showaverageplat
Menu, Tray, Add, Average Plat WA, showaverageplatwa
Menu, Tray, Add, Ducat Value, showducats
Menu, Tray, Add
Menu, Tray, Add, Task Time, tasktime
Menu, Tray, Add, Reload, Reload
Menu, Tray, Add, Exit, Exit
Menu, Tray, Tip, Ducat Kiosker
Menu, Tray, Click, 1

IniRead, showitemname, config.ini, TrayMenu, showitemname
IniRead, showvaulted, config.ini, TrayMenu, showvaulted
IniRead, showprevioushour, config.ini, TrayMenu, showprevioushour
IniRead, showpreviousday, config.ini, TrayMenu, showpreviousday
IniRead, showducatsperplat, config.ini, TrayMenu, showducatsperplat
IniRead, showducatsperplatwa, config.ini, TrayMenu, showducatsperplatwa
IniRead, showaverageplat, config.ini, TrayMenu, showaverageplat
IniRead, showaverageplatwa, config.ini, TrayMenu, showaverageplatwa
IniRead, showducats, config.ini, TrayMenu, showducats
IniRead, tasktime, config.ini, TrayMenu, tasktime

if(showitemname)
Menu,Tray,Togglecheck, Item Name
if(showvaulted)
Menu,Tray,Togglecheck, Vaulted 
if(showprevioushour)
Menu,Tray,Togglecheck, Previous Hour
if(showpreviousday)
Menu,Tray,Togglecheck, Previous Day
if(showducatsperplat)
Menu,Tray,Togglecheck, Ducats Per Plat
if(showducatsperplatwa)
Menu,Tray,Togglecheck, Ducats Per Plat WA
if(showaverageplat)
Menu,Tray,Togglecheck, Average Plat
if(showaverageplatwa)
Menu,Tray,Togglecheck, Average Plat WA
if(showducats)
Menu,Tray,Togglecheck, Ducat Value
if(tasktime)
Menu,Tray,Togglecheck, Task Time

ComObjError(0)
apirequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
apirequest.Open("GET","https://api.warframe.market/v1/items")
apirequest.Send()
if(apirequest.status = 200)
itemsjson := JSON.Load(apirequest.ResponseText)
else {
	MsgBox % "Error: " apirequest.status "`nScript will now exit"
	ExitApp
}

apirequest.Open("GET","https://api.warframe.market/v1/tools/ducats")
apirequest.Send()
if(apirequest.status = 200)
ducatsjson := JSON.Load(apirequest.ResponseText)
else {
	MsgBox % "Error: " apirequest.status "`nScript will now exit"
	ExitApp
}

Vaulted := ["Ash Prime","Ember Prime","Frost Prime","Loki Prime","Mag Prime","Nekros Prime","Nova Prime","Nyx Prime","Rhino Prime","Saryn Prime","Trinity Prime","Valkyr Prime","Vauban Prime","Volt Prime","Akstiletto Prime","Ankyros Prime","Bo Prime","Boar Prime","Boltor Prime","Cernos Prime","Dakra Prime","Dual Kamas Prime","Fragor Prime","Galatine Prime","Glaive Prime","Hikou Prime","Latron Prime","Nikana Prime","Reaper Prime","Scindo Prime","Sicarus Prime","Soma Prime","Spira Prime","Tigris Prime","Vasto Prime","Vectis Prime","Venka Prime","Carrier Prime","Odonata Prime","Kavasa Prime"]
theme := 1
~+z::
DllCall("QueryPerformanceCounter", "Int64*", CounterBefore)
msg := ""
themecheck := 1
ToolTip
Loop {
	ImageSearch, FoundX, FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, %theme%.png
	if (ErrorLevel = 0) {
		PixelGetColor, color, FoundX, FoundY
		PixelGetColor, color2, FoundX+210, FoundY+65
		if(color == color2) {
			item := StrReplace(OCR([FoundX, FoundY, 420, 68]), "`r`n", " ")
		}
		else {
			item := OCR([FoundX, FoundY, 420, 34])
		}
		
		if(!InStr(item,"PRIME BLUEPRINT")){
			StringReplace, item, item, %A_Space%BLUEPRINT,
		}
		
		SearchLoop:
		loop % itemsjson.payload.items.en.length() {
			if(InStr(itemsjson.payload.items.en[A_Index].item_name,item) | InStr(item,itemsjson.payload.items.en[A_Index].item_name) & estimation) {
				itemid := itemsjson.payload.items.en[A_Index].id
				if(showitemname)
				msg := msg itemsjson.payload.items.en[A_Index].item_name "`n"
				if(showpreviousday)
				{
					msg := msg "-Previous Day-`n"
					loop % ducatsjson.payload.previous_day.length() {
						if InStr(ducatsjson.payload.previous_day[A_Index].item,itemid) {
							if(showducats)
							msg := msg "Ducats: " ducatsjson.payload.previous_day[A_Index].ducats "`n"
							if(showducatsperplat)
							msg := msg "Ducats Per Plat: " ducatsjson.payload.previous_day[A_Index].ducats_per_platinum "`n"
							if(showducatsperplatwa)
							msg := msg "Ducats Per Plat WA: " ducatsjson.payload.previous_day[A_Index].ducats_per_platinum_wa "`n"
							if(showaverageplat)
							msg := msg "Average Plat: " ducatsjson.payload.previous_day[A_Index].median "`n"
							if(showaverageplat)
							msg := msg "Average Plat WA: " ducatsjson.payload.previous_day[A_Index].wa_price "`n"
							break
						}
					}
				}
				if(showprevioushour)
				{
					msg := msg "-Previous Hour-`n"
					loop % ducatsjson.payload.previous_hour.length() {
						if InStr(ducatsjson.payload.previous_hour[A_Index].item,itemid) {
							if(showducats)
							msg := msg "Ducats: " ducatsjson.payload.previous_hour[A_Index].ducats "`n"
							if(showducatsperplat)
							msg := msg "Ducats Per Plat: " ducatsjson.payload.previous_hour[A_Index].ducats_per_platinum "`n"
							if(showducatsperplatwa)
							msg := msg "Ducats Per Plat WA: " ducatsjson.payload.previous_hour[A_Index].ducats_per_platinum_wa "`n"
							if(showaverageplat)
							msg := msg "Average Plat: " ducatsjson.payload.previous_hour[A_Index].median "`n"
							if(showaverageplat)
							msg := msg "Average Plat WA: " ducatsjson.payload.previous_hour[A_Index].wa_price "`n"
							break
						}
					}
				}
				break
			}
			else if(A_Index = itemsjson.payload.items.en.length()) {
				if(!estimation) {
					estimation := 1
					GoTo, SearchLoop
				}
				else {
					break
				}
			}
		}
		
		vaultext := "Vaulted: No`n"
		loop % vaulted.length() {
			if InStr(item, vaulted[A_Index]) {
				vaultext := "Vaulted: Yes`n"
				break
			}
		}
		if(showvaulted)
		msg := msg vaultext
		break
	}
	else if (ErrorLevel = 1) {
		if(themecheck) {
			;msg := msg "Theme change detected!`n"
			themecheck := 0
			theme := 1
		}
		else if(theme != 10) {
			theme++
		}
		else {
			msg := "Could not find text`n"
			break
		}
	}
	else if (ErrorLevel = 2) {
		msg := "Could not start the search`n"
		break
	}
}
DllCall("QueryPerformanceCounter", "Int64*", CounterAfter)
DllCall("QueryPerformanceFrequency", "Int64*", Frequency)
if(tasktime)
msg := msg "Task completed in " Ceil((CounterAfter - CounterBefore)*1000/Frequency) " ms"
MouseGetPos, xpos, ypos
ToolTip % msg, xpos+25, ypos
active := 1
SetTimer End, 12000
return

End:
ToolTip
active := 0
SetTimer End, Off
return

if(active)
~LButton::
ToolTip
active := 0
return


showitemname:
Menu,Tray,Togglecheck, Item Name
showitemname := !showitemname
IniWrite, %showitemname%, config.ini, TrayMenu, showitemname
return

showducats:
Menu,Tray,Togglecheck, Ducat Value
showducats := !showducats
IniWrite, %showducats%, config.ini, TrayMenu, showducats
return

showvaulted:
Menu,Tray,Togglecheck, Vaulted
showvaulted := !showvaulted
IniWrite, %showvaulted%, config.ini, TrayMenu, showvaulted
return

showprevioushour:
Menu,Tray,Togglecheck, Previous Hour
showprevioushour := !showprevioushour
IniWrite, %showprevioushour%, config.ini, TrayMenu, showprevioushour
return

showpreviousday:
Menu,Tray,Togglecheck, Previous Day
showpreviousday := !showpreviousday
IniWrite, %showpreviousday%, config.ini, TrayMenu, showpreviousday
return

showducatsperplat:
Menu,Tray,Togglecheck, Ducats Per Plat
showducatsperplat := !showducatsperplat
IniWrite, %showducatsperplat%, config.ini, TrayMenu, showducatsperplat
return

showducatsperplatwa:
Menu,Tray,Togglecheck, Ducats Per Plat WA
showducatsperplatwa := !showducatsperplatwa
IniWrite, %showducatsperplatwa%, config.ini, TrayMenu, showducatsperplatwa
return

showaverageplat:
Menu,Tray,Togglecheck, Average Plat
showaverageplat := !showaverageplat
IniWrite, %showaverageplat%, config.ini, TrayMenu, showaverageplat
return

showaverageplatwa:
Menu,Tray,Togglecheck, Average Plat WA
showaverageplatwa := !showaverageplatwa
IniWrite, %showaverageplatwa%, config.ini, TrayMenu, showaverageplatwa
return

tasktime:
Menu,Tray,Togglecheck, Task Time
tasktime := !tasktime
IniWrite, %tasktime%, config.ini, TrayMenu, tasktime
return

Reload:
Reload
return

Exit:
ExitApp
return

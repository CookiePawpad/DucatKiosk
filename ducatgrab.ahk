#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#include <Vis2>
#include <JSON>
Vaulted := []
Vaulted := ["Ash Prime","Ember Prime","Frost Prime","Loki Prime","Mag Prime","Nekros Prime","Nova Prime","Nyx Prime","Rhino Prime","Saryn Prime","Trinity Prime","Valkyr Prime","Vauban Prime","Volt Prime","Akstiletto Prime","Ankyros Prime","Bo Prime","Boar Prime","Boltor Prime","Cernos Prime","Dakra Prime","Dual Kamas Prime","Fragor Prime","Galatine Prime","Glaive Prime","Hikou Prime","Latron Prime","Nikana Prime","Reaper Prime","Scindo Prime","Sicarus Prime","Soma Prime","Spira Prime","Tigris Prime","Vasto Prime","Vectis Prime","Venka Prime","Carrier Prime","Odonata Prime","Kavasa Prime"]
UrlDownloadToFile, https://api.warframe.market/v1/items, items.txt
FileRead, itemsjson, items.txt
if not ErrorLevel {
	itemsjsonerror := "items.txt incorrect format, api may be offline`n"
	failed := 1
	itemsjson := JSON.Load(itemsjson)
	if(itemsjson.payload.items.en.length()) {
		failed := 0
		itemsjsonerror := ""
		UrlDownloadToFile, https://api.warframe.market/v1/tools/ducats, ducats.txt
		FileRead, ducatsjson, ducats.txt
		if not ErrorLevel {
			ducatsjsonerror := "ducats.txt incorrect format, api may be offline`n"
			failed := 1
			ducatsjson := JSON.Load(ducatsjson)
			if(ducatsjson.payload.previous_day.length()) {
				failed := 0
				ducatsjsonerror := ""
			}
		}
		else {
			ducatsfileerror := "Unable to access ducats.txt the file may not exist or cannot be accessed`n"
			failed := 1
		}
	}
}
else {
	itemsfileerror := "Unable to access items.txt the file may not exist or cannot be accessed`n"
	failed := 1
}

if(failed){
	MsgBox % itemsjsonerror ducatsjsonerror itemsfileerror ducatsfileerror "Script will now exit"
	ExitApp
}

theme := 1

~9::
if(failed){
	MsgBox % itemsjsonerror ducatsjsonerror itemsfileerror ducatsfileerror "Script will now exit"
	ExitApp
}
else {
	DllCall("QueryPerformanceCounter", "Int64*", CounterBefore)
	msg := ""
	themecheck := 1
	ToolTip
	Loop {
		ImageSearch, FoundX, FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, %theme%.png
		if (ErrorLevel == 0) {
			PixelGetColor, color, FoundX, FoundY
			PixelGetColor, color2, FoundX+210, FoundY+65
			if(color == color2) { ;is the image two lined?
				item := StrReplace(OCR([FoundX, FoundY, 420, 68]), "`r`n", " ")
			}
			else {
				item := OCR([FoundX, FoundY, 420, 34])
			}
			
			;msg := "identified: " item
			if(!InStr(item,"PRIME BLUEPRINT")){
				StringReplace, item, item, %A_Space%BLUEPRINT,
				;msg := msg "`ndeprecated: " item
			}
			estimation := 1
			loop % itemsjson.payload.items.en.length() {
				if InStr(itemsjson.payload.items.en[A_Index].item_name,item) {
					estimation := 0
					itemid := itemsjson.payload.items.en[A_Index].id
					msg := msg itemsjson.payload.items.en[A_Index].item_name ;"`nid: " itemid
					loop % ducatsjson.payload.previous_day.length() {
						if InStr(ducatsjson.payload.previous_day[A_Index].item,itemid) {
							msg := msg "`nDucats: " ducatsjson.payload.previous_day[A_Index].ducats
							msg := msg "`nRatio: " ducatsjson.payload.previous_day[A_Index].ducats_per_platinum
							break
						}
					}
					break
				}
			}
			;msg := msg "`nestimated: " estimation 
			if(estimation) { ;Same loop as above except this is best match based and not complete match, only happens if complete match isnt found
				loop % itemsjson.payload.items.en.length() {
					if InStr(item,itemsjson.payload.items.en[A_Index].item_name) {
						itemid := itemsjson.payload.items.en[A_Index].id
						msg := msg itemsjson.payload.items.en[A_Index].item_name ;"`nid: " itemid
						loop % ducatsjson.payload.previous_day.length() {
							if InStr(ducatsjson.payload.previous_day[A_Index].item,itemid) {
								msg := msg "`nDucats: " ducatsjson.payload.previous_day[A_Index].ducats
								msg := msg "`nRatio: " ducatsjson.payload.previous_day[A_Index].ducats_per_platinum
								break
							}
						}
						break
					}
				}
			}
			vaultext := "`nVaulted: No"
			loop % vaulted.length() {
				if InStr(item, vaulted[A_Index]) {
					vaultext := "`nVaulted: Yes"
					break
				}
			}
			msg := msg vaultext
			break
		}
		else if (ErrorLevel == 1) {
			if(themecheck) {
				;msg := msg "Theme change detected!`n"
				themecheck := 0
				theme := 1
			}
			else if(theme != 10) {
				theme++
			}
			else {
				msg := "Could not find text!`n"
				break
			}
		}
		else if (ErrorLevel == 2) {
			msg := "Could not start the search!`n"
			break
		}
	}
	MouseGetPos, xpos, ypos
	DllCall("QueryPerformanceCounter", "Int64*", CounterAfter)
	DllCall("QueryPerformanceFrequency", "Int64*", Frequency)
	ToolTip % msg "`nTask completed in " Ceil((CounterAfter - CounterBefore)*1000/Frequency) "ms", xpos, ypos
	Clipboard := msg "`nTask completed in " Ceil((CounterAfter - CounterBefore)*1000/Frequency) "ms"
	SetTimer End, 10000
}
return
End:
ToolTip
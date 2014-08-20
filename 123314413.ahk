#include Edit.ahk
#SingleInstance, Force
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
coordmode, mouse, screen
global howbigami = 1				;global variables because lazy
global howbigami2 = 1
global sleeptime = 120000
global maxWins = 33
global currentWins = 0
global remainingWins := maxWins
global HCpath




Gui, Add, text, y5 x5,HearthCrawler Location:
Gui, Add, Edit, r1 vpath +ReadOnly w315 x5 y20
ifexist, Relogger.ini
{
	iniread, HCpath, Relogger.ini, Hearthcrawler, path
	GuiControl,, path, %HCpath%
}

Gui, Add, Button,x325 y19 ggetpath, ...
Gui, Add, Button,x5 y325 w340 gstartbot vstartbutton, Start
Gui, Add, Button,x5 y325 w340 gstopbot vstopbutton, Stop
guicontrol, hide, stopbutton 


gui, add, edit, r20 vMyEdit +ReadOnly h200 w340 x5 y50 hWndhEdit
ifexist, lastsession.txt
{
FileRead, previoussession,lastsession.txt
GuiControl,, MyEdit, %previoussession%
FileDelete, lastsession.txt
}

Gui, Color, 0xFFFFFF


Gui, Show, x760 y198 h355 w350,  
return


MainLoop:
Loop {
		logcheck1()
		hasanythingcrashed()
		botfrozen()
		addtolog("Everything's fine")
		addtolog("Waiting 2 minutes before preforming further error checks")
		sleep, %sleeptime%
		logcheck2()
		comparefilesize()
		hasanythingcrashed()
		botfrozen()
		addtolog("Everything's fine")
		addtolog("Waiting 2 minutes before preforming further error checks")
		sleep, %sleeptime%

	}
Return



getpath:
{
	FileSelectFolder, Selectedfolder, ::{20d04fe0-3aea-1069-a2d8-08002b30309d}
	GuiControl,, path, %Selectedfolder%
	iniwrite, %Selectedfolder%, Relogger.ini, Hearthcrawler, path
	HCpath = %Selectedfolder%
}
return

startbot:
{
	;guicontrol,Disable, startbutton  ;don't need if we're gonna hide the button and show a stop button
	;guicontrol,text, startbutton, Monitoring...
	guicontrol, hide, startbutton
	guicontrol, show, stopbutton
	addtolog("Starting...")
	amibotting = 1
	initiallaunch()

}
return

stopbot:
{
	 amibotting = 0
	 guicontrol, hide, stopbutton
	 guicontrol, show, startbutton
	 Global hEdit
	addtolog("stopping...")
	edit_savefile(hEdit, "lastsession.txt")
	reload
	
}
return

addtolog(message)
{
	Global hEdit
	LastPos:=Edit_GetTextLength(hEdit)
	Edit_SetSel(hEdit,LastPos,LastPos)
	FormatTime, timestamp,, hh:mm:ss
	Edit_ReplaceSel(hEdit,"[" . timestamp . "] " . message . "`r`n",False)
}

initiallaunch()
{
	addtolog("Killing Hearthstone and Hearthcrawler if they exist")
    process, close, HearthStone.exe
	sleep, 100
	process, close, Hearthcrawler.exe
	sleep, 100
	addtolog("Delete old HearthCrawler logs")
	FileRemoveDir,%HCpath%\Logs, 1
	sleep, 100
	FileCreateDir, %HCpath%\Logs
	sleep, 100
	
	if (maxWins > 0)
	{
		addtolog("Writing specified max wins to SmartCC.xml")
		IniWrite, %maxWins%, %HCpath%\Common\Settings.ini, SmartCC.xml, smartcc.MaxWins   ; write specified maxwins to the settings.ini file of hearthcrawler
	}
	sleep, 100
	addtolog("Activating and moving/resizing Battle.net window")
	WinActivate, Battle.net
	winmove, Battle.net, , 0, 0
	addtolog("Waiting for PLAY button to activate.")
	sleep, 9000
	addtolog("Clicking play")
	mouseclick, left, 287, 478, 1, 0 	;play -> open hearthstone
	addtolog("Waiting 20 seconds for Hearthstone to open")
	sleep, 20000
	addtolog("Moving and resizing Hearthstone window")
	winmove, Hearthstone, , 0, 0
	addtolog("Clicking in Hearthstone window to close popups")
	mouseclick, left, 527, 427, 1, 0 ; close last game popup?
	sleep, 1000
	mouseclick, left, 527, 427, 1, 0	;cclick again to close quest popup shit
	sleep, 1000
	addtolog("Running Hearthcrawler")
	run, %HCpath%\Hearthcrawler.exe
	addtolog("Waiting 10 seconds for it to open.")
	sleep, 10000
	addtolog("Moving Hearthcrawler window")
	winmove, Hearthcrawler ahk_class QWidget,, 0, 0
	sleep, 1000
	addtolog("Clicking the refresh process button")
	mouseclick, left, 694, 162, 1, 0	;refresh button for hearthstone process
	sleep, 1000
	addtolog("Clicking connect bot")
	mouseclick, left, 575, 415, 1, 0	;connect bot
	sleep, 5000
	;mouseclick, left, 1265, 581, 1, 0 ; deck drop down
	;sleep, 1000
	;mouseclick, left, 1145, 595, 1, 0 ; select first deck
	;sleep, 1000
	addtolog("Clicking start bot")
	mouseclick, left, 575, 415, 1, 0	;start bot	
	addtolog("Waiting 2 minutes before preforming error checks")
	sleep, %sleeptime%						; wait the time
	Gosub, MainLoop
}


launchstuff()
{
	addtolog("Delete old HearthCrawler logs")
	FileRemoveDir,%HCpath%\Logs, 1
	sleep, 100
	FileCreateDir, %HCpath%\Logs
	sleep, 100
	if (maxWins > 0)
	{
		addtolog("Setting remaining wins to max wins in SmartCC.xml")
		IniWrite, %remainingWins%, C:\Users\galonsky\Desktop\HS bot\Common\Settings.ini, SmartCC.xml, smartcc.MaxWins ; write remaining wins to the maxwins key in smartcc
	}
	sleep, 100
	addtolog("Activating and moving/resizing Battle.net window")
	WinActivate, Battle.net
	winmove, Battle.net, , 0, 0
	addtolog("Waiting for PLAY button to activate.")
	sleep, 9000
	addtolog("Clicking play")
	mouseclick, left, 287, 478, 1, 0 	;play -> open hearthstone
	addtolog("Waiting 20 seconds for Hearthstone to open")
	sleep, 20000
	addtolog("Moving and resizing Hearthstone window")
	winmove, Hearthstone, , 0, 0
	addtolog("Clicking in Hearthstone window to close popups")
	mouseclick, left, 527, 427, 1, 0 ; close last game popup?
	sleep, 1000
	mouseclick, left, 527, 427, 1, 0	;cclick again to close quest popup shit
	sleep, 1000
	addtolog("Running Hearthcrawler")
	run, %HCpath%\Hearthcrawler.exe
	addtolog("Waiting 10 seconds for it to open.")
	sleep, 10000
	addtolog("Moving Hearthcrawler window")
	winmove, Hearthcrawler ahk_class QWidget,, 0, 0
	sleep, 1000
	addtolog("Clicking the refresh process button")
	mouseclick, left, 694, 162, 1, 0	;refresh button for hearthstone process
	sleep, 1000
	addtolog("Clicking connect bot")
	mouseclick, left, 575, 415, 1, 0	;connect bot
	sleep, 5000
	;mouseclick, left, 1265, 581, 1, 0 ; deck drop down
	;sleep, 1000
	;mouseclick, left, 1145, 595, 1, 0 ; select first deck
	;sleep, 1000
	addtolog("Clicking start bot")
	mouseclick, left, 575, 415, 1, 0	;start bot	
	addtolog("Waiting 3 minutes before preforming error checks")
	sleep, %sleeptime%						; wait the time
	Gosub, MainLoop
}



logcheck1()
{
	addtolog("Checking current log")
	FileList =
	Loop, C:\Users\galonsky\Desktop\HS bot\Logs\*.*, 1 ; finds all files in log folder
		FileList = %FileList%%A_LoopFileFullPath%`n				; provides the full path
	Sort, FileList, R  ; Sort by date.							; sorts by newest created first
	Loop, parse, FileList, `n									; goes through the list of files 1 by 1
	{
		fileread, logfile, %A_LoopField%						;reads the file
		if A_LoopField != 										;ignores the blank entry at the end of the list
		{
		addtolog("Recording filesize")
		filegetsize, howbigamI, %A_LoopField%					;checks how big logfile is
		addtolog("Checking if Relogger text is found")
		IfInString, logfile, relogger is required				; if relogger text found then will relog
			{
				addtolog("Relogger is required text found in log")
				addtolog("Restarting")
				closestuff()
				launchstuff()
				
			}
		if (maxWins > 0)
		{
			addtolog("Checking if win limit reached")	
			IfInString, logfile, Wins limit reached
				{
					addtolog("Win limit reached")
					gosub, stopbot

				}
				
			}
		}
	}
	
}


logcheck2()
{
	addtolog("Checking current log")
	FileList =
	Loop, C:\Users\galonsky\Desktop\HS bot\Logs\*.*, 1 ; finds all files in log folder
		FileList = %FileList%%A_LoopFileFullPath%`n				; provides the full path
	Sort, FileList, R  ; Sort by date.							; sorts by newest created first
	Loop, parse, FileList, `n									; goes through the list of files 1 by 1
	{
		fileread, logfile, %A_LoopField%						;reads the file
		if A_LoopField != 										;ignores the blank entry at the end of the list
		{
		addtolog("Recording filesize again")
		filegetsize, howbigamI2, %A_LoopField%					;checks how big logfile is
		addtolog("Checking if Relogger text is found")
		IfInString, logfile, relogger is required				; if relogger text found then will relog
			{
				addtolog("Relogger is required text found in log")
				addtolog("Restarting")
				closestuff()
				launchstuff()
				
			}
		if (maxWins > 0)
		{
			addtolog("Checking if win limit reached")		
			IfInString, logfile, Wins limit reached
				{
					addtolog("Win limit reached")
					gosub, stopbot
				}	
			}
		}
	}
	
}

comparefilesize()
{	
	addtolog("Comparing log filesizes")
	if (howbigami == howbigami2)
	{
		addtolog("Log hasn't increased in size in 3 minutes")
		addtolog("Restarting")
		closestuff()
		launchstuff()
	}

}

closestuff()
{
	addtolog("Closing Hearthstone and Heathcrawler")
	process, close, HearthStone.exe
	sleep, 100
	process, close, Hearthcrawler.exe
	sleep, 100
	howManyTimesHaveIWon()
	
}

hasanythingcrashed()
{
	addtolog("Checking if Hearthstone.exe exists")
	Process, exist, HearthStone.exe
	if errorlevel = 0
	{
		addtolog("Hearthstone.exe not found")
		addtolog("Restarting")
		closestuff()
		launchstuff()
	}
	addtolog("Checking if Hearthcrawler.exe exists")
	Process, exist, Hearthcrawler.exe
	if errorlevel = 0
	{
		addtolog("Heathcrawler,exe not found")
		addtolog("Restarting")
		closestuff()
		launchstuff()
	}
}

botfrozen()
{
	addtolog("Checking if APPCRASH is found in windowtext")
	ifwinexist, Hearthcrawler, APPCRASH
	{
		addtolog("Found APPCRASH in a window's visible text")
		addtolog("Restarting")
		closestuff()
		launchstuff()
	}
	addtolog("Checking if WerFault.exe exists")
	Process, exist, WerFault.exe
	if errorlevel != 0
	{
		addtolog("Found WerFault.exe running")
		addtolog("Restarting")
		process, close, WerFault.exe
		closestuff()
		launchstuff()
	}
}

howManyTimesHaveIWon()
{
	if (maxWins > 0)
	{
		addtolog("Reading current wins from SmartCC.xml")
		IniRead, currentWins, C:\Users\galonsky\Desktop\HS bot\Common\Settings.ini, SmartCC.xml, smartcc.Wins		;reads current wins from settings.ini
		remainingWins := remainingWins - currentWins																;subtracts current wins from remaining wins, since remaining wins is set to = maxwins at beginning this works on first iteration as well as subsequent iterations
		addtolog("Writing new maxwins to SmartCC.xml")
		IniWrite, 0, C:\Users\galonsky\Desktop\HS bot\Common\Settings.ini, SmartCC.xml, smartcc.Wins 				;sets current wins to 0 now that we've seen what it was, this is incase it somehow crashes again before startbotting is hit, which resets the counter to 0
		
		if (remainingWins <= 0)
		{
			addtolog("Win limit reached")
			gosub, stopbot
		}
	}
	
}


GUIEscape:
GUIClose:
ExitApp 


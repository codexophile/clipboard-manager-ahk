#Requires AutoHotkey v2.0
#SingleInstance Force
TraySetIcon 'D:\Mega\IDEs\AutoHotkey v2\#stuff\clipboard.ico'

#Include ..\#lib\GuiButtonIcon.ahk
#Include ..\#lib\Functions.ahk
#Include notifs-subs.ahk
#Include notifs.ahk
#Include manager.ahk

OnClipboardChange(DisplayNotificationGui, 1)
OnClipboardChange(PutIntoContainers, 1)
#Requires AutoHotkey v2.0
#SingleInstance Force
TraySetIcon 'D:\Mega\IDEs\AutoHotkey v2\#stuff\clipboard.ico'

#Include ..\#lib\GuiButtonIcon.ahk
#Include ..\#lib\Functions.ahk
#Include notifs-subs.ahk
#Include notifs.ahk
#Include manager.ahk

OnClipboardChange(ClipboardChangeHandler)

ClipboardChangeHandler(DataType) {

    if (InStr(A_Clipboard, 'global-document-ready-')) {
        try {
            WinActivate StrReplace(A_Clipboard, 'global-document-ready-', '')
        }
        ; Revert to the previous item in the Containers array
        if (Containers.Length > 0) {
            OnClipboardChange(ClipboardChangeHandler, 0)
            A_Clipboard := Containers[1]
            OnClipboardChange(ClipboardChangeHandler)
        }
        return
    }

    DisplayNotificationGui(DataType)
    if (!InStr(A_Clipboard, 'global-document-ready-')) {
        PutIntoContainers(DataType)
    }
}
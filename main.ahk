﻿#Requires AutoHotkey v2.0
#SingleInstance Force
TraySetIcon 'D:\Mega\IDEs\AutoHotkey v2\#stuff\clipboard.ico'

#Include ..\#lib\GuiButtonIcon.ahk
#Include ..\#lib\Functions.ahk
#Include notifs-subs.ahk
#Include notifs.ahk
#Include manager.ahk

OnClipboardChange(ClipboardChangeHandler)

ClipboardChangeHandler(DataType) {

  ;* Auto activate browser on page load
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

  ;* initiate ytdlp
  if (InStr(A_Clipboard, 'initiate-ytdlp:')) {
    RegExMatch(A_Clipboard, '::(.+?)::(.+?)$', &Matches)
    if (!Matches)
      return

    VideoTitle := StrReplace(Trim(Matches[1]), ' ', '-')
    VideoTitle := StrReplace(VideoTitle, '&', 'and')

    VideoUrl := Trim(Matches[2])
    Ytdlp(VideoUrl, 'Quick', '-GivenName `"' VideoTitle '`"')
    return
  }

  DisplayNotificationGui(DataType)
  PutIntoContainers(DataType)

}

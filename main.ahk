#Requires AutoHotkey v2.0
#SingleInstance Force
TraySetIcon 'C:\Mega\IDEs\AutoHotkey v2\#stuff\clipboard.ico'

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
      ; Revert to the previous item in the Containers array
      if (Containers.Length > 0) {
        OnClipboardChange(ClipboardChangeHandler, 0)
        A_Clipboard := Containers[1]
        OnClipboardChange(ClipboardChangeHandler)
      }
      return
    }
    return
  }

  ;* initiate ytdlp
  if (InStr(A_Clipboard, 'initiate-ytdlp:')) {
    RegExMatch(A_Clipboard, '::(.+?)::(.+?)$', &Matches)
    if (!Matches)
      return

    ; Create a map of characters to replace
    replacements := Map(
      " • [Browser:Private-profile]", "",
      "(", "-",
      ")", "-",
      " ", "-",
      "'", "-",
      '"', "-",
      "&", "and"
    )

    ; Apply all replacements in one go
    VideoTitle := Trim(Matches[1])
    for search, replace in replacements
      VideoTitle := StrReplace(VideoTitle, search, replace)

    VideoUrl := Trim(Matches[2])
    Ytdlp(VideoUrl, 'Quick', '-GivenName `"' VideoTitle '`"')
    return
  }

  DisplayNotificationGui(DataType)
  PutIntoContainers(DataType)

}

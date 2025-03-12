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
        ClipWait
        OnClipboardChange(ClipboardChangeHandler)
      }
      return
    }
    return
  }

  ;* initiate ytdlp
  if (InStr(A_Clipboard, 'initiate-ytdlp:')) {

    RegExMatch(A_Clipboard, ':title:(.+?)::', &TitleMatches)
    RegExMatch(A_Clipboard, ':url:(.+?)::', &UrlMatches)

    if !UrlMatches
      return

    ; Create a map of characters to replace
    replacements := Map(
      " • [Browser:Private-profile]", "",
      '|', '-'
      ;   "(", "-",
      ;   ")", "-",
      ;   " ", "-",
      ;   "'", "-",
      ;   '"', "-",
      ;   "&", "and"
    )

    if (TitleMatches) {
      ; Apply all replacements in one go
      VideoTitle := Trim(TitleMatches[1])
      for search, replace in replacements
        VideoTitle := StrReplace(VideoTitle, search, replace)
    }
    else {
      VideoTitle := ':default:'
    }

    VideoUrl := Trim(UrlMatches[1])
    Ytdlp(VideoUrl, 'Quick', '-GivenName "' videoTitle '"')
    return
  }

  if (InStr(A_Clipboard, 'mouse-click::')) {
    RegExMatch(A_Clipboard, 'mouse-move::(.+?),(.+?)::', &Matches)
    if !Matches
      return
    Send('{Alt Up}')
    Click(Matches[1], Matches[2])
    return
  }

  DisplayNotificationGui(DataType)
  PutIntoContainers(DataType)

}
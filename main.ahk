#Requires AutoHotkey v2.0
#SingleInstance Force
TraySetIcon 'C:\Mega\IDEs\AutoHotkey v2\#stuff\clipboard.ico'

#Include ..\#lib\GuiButtonIcon.ahk
#Include ..\#lib\Functions.ahk
#Include notifs-subs.ahk
#Include notifs.ahk
#Include manager.ahk

; ========================================
; Constants
; ========================================
TRIGGER_BROWSER_ACTIVATION := 'global-document-ready-'
TRIGGER_YTDLP_INSTANT := 'initiate-ytdlp-instant:'
TRIGGER_YTDLP_FULL := 'initiate-ytdlp:'
TRIGGER_GALLERYDL := 'initiate-gallerydl:'
TRIGGER_CODE_EXECUTOR := '::code-executor::'

; ========================================
; Utility Functions
; ========================================

GetVideoTitleReplacements() {
  return Map(
    " • [Browser:Private-profile]", "",
    '|', '-'
  )
}

ExtractRegexMatches(clipboard, patterns) {
  matches := Map()
  for key, pattern in patterns {
    RegExMatch(clipboard, pattern, &result)
    if (result)
      matches[key] := Trim(result[1])
  }
  return matches
}

ApplyReplacements(text, replacements) {
  for search, replace in replacements
    text := StrReplace(text, search, replace)
  return text
}

; ========================================
; Handler Functions
; ========================================

HandleBrowserActivation(clipboardContent) {
  try {
    winTitle := StrReplace(clipboardContent, TRIGGER_BROWSER_ACTIVATION, '')
    WinActivate(winTitle)

    ; Revert to the previous item in the Containers array
    if (Containers.Length > 0) {
      OnClipboardChange(ClipboardChangeHandler, 0)
      A_Clipboard := Containers[1]
      ClipWait 1
      OnClipboardChange(ClipboardChangeHandler)
    }
  }
}

HandleYtdlpInstant(clipboardContent) {
  patterns := Map('url', ':url:(.+?)::')
  matches := ExtractRegexMatches(clipboardContent, patterns)

  if !matches.Has('url')
    return

  Ytdlp(matches['url'], 'Instant')
}

HandleDownload(clipboardContent) {
  patterns := Map(
    'title', ':title:(.+?)::',
    'url', ':url:(.+?)::',
    'dest', ':dest:(.+?)::',
    'mode', ':mode:(.+?)::',
    'browser', ':browser:(.+?)::',
    'profile', ':profile:(.+?)::'
  )

  matches := ExtractRegexMatches(clipboardContent, patterns)

  if !matches.Has('url')
    return

  videoTitle := matches.Has('title') ? matches['title'] : ':default:'
  videoTitle := ApplyReplacements(videoTitle, GetVideoTitleReplacements())

  destination := matches.Has('dest') ? matches['dest'] : ':default:'
  mode := matches.Has('mode') ? matches['mode'] : 'Quick'
  videoUrl := matches['url']

  params := '-Destination "' destination '"'

  if (matches.Has('title'))
    params .= ' -GivenName "' videoTitle '"'

  if (matches.Has('browser'))
    params .= ' -Browser "' matches['browser'] '"'

  if (matches.Has('profile'))
    params .= ' -BrowserProfile "' matches['profile'] '"'

  if (InStr(clipboardContent, TRIGGER_YTDLP_FULL))
    Ytdlp(videoUrl, mode, params)
  else if (InStr(clipboardContent, TRIGGER_GALLERYDL)) {
    InvokeGallerydl(videoUrl, destination, mode)
  }
}

HandleCodeExecutor(clipboardContent) {
  RegExMatch(clipboardContent, '::code-executor::((.|\n)+?)::', &CodeMatches)

  if !CodeMatches
    return

  try {
    RunDynamicAHK(CodeMatches[1])
  } catch (error) {
    MsgBox("Error: " error)
  }
}

DispatchClipboardHandler(clipboardContent) {
  if (InStr(clipboardContent, TRIGGER_BROWSER_ACTIVATION)) {
    HandleBrowserActivation(clipboardContent)
    return true
  }

  if (InStr(clipboardContent, TRIGGER_YTDLP_INSTANT)) {
    HandleYtdlpInstant(clipboardContent)
    return true
  }

  if (
    InStr(clipboardContent, TRIGGER_YTDLP_FULL) OR
    InStr(clipboardContent, TRIGGER_GALLERYDL)
  ) {
    HandleDownload(clipboardContent)
    return true
  }

  if (InStr(clipboardContent, TRIGGER_CODE_EXECUTOR)) {
    HandleCodeExecutor(clipboardContent)
    return true
  }

  return false
}

; ========================================
; Main Handler
; ========================================

OnClipboardChange(ClipboardChangeHandler)

ClipboardChangeHandler(DataType) {
  ; Try to handle special clipboard triggers first
  if (DispatchClipboardHandler(A_Clipboard))
    return

  ; Default behavior for regular clipboard items
  DisplayNotificationGui(DataType)
  PutIntoContainers(DataType)
}

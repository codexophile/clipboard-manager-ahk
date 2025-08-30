#Requires AutoHotkey v2.0

; Initialize Monitor Information
MonitorCount := MonitorGetCount()
Monitors := []
loop MonitorCount {
  MonitorGet(A_Index, &Left, &Top, &Right, &Bottom)
  Monitors.Push({ Left: Left, Top: Top, Right: Right, Bottom: Bottom
  })
}

WhichMonitor := MonitorCount > 1 ? 2 : 1
MainWidth := 315
DisplayForMS := 10000

buttonCount := 0
buttonWidth := 60
; buttonHeight := 25

VivaldiPath := "C:\Program Files\Vivaldi\Application\Vivaldi.exe"
YtDlpPath := "B:\Program Files - Portable\youtube-dl\yt-dlp.exe"

DisplayNotificationGui(Type) {
  global buttonCount, SavedClipboard, SavedClipboardQuoted
  static GuiUniqueId, NotificationGui
  local NotificationTitle, hBitmap

  try {
    ActiveWindowTitle := WinGetTitle("A")
    ActiveWindowId := WinGetID("A")
    ActiveWindowClass := WinGetClass("A")
  }

  ;* Do nothing
  if (WinActive(' ━ Visual Studio Code') and RegExMatch(A_Clipboard, "\w:\\(.+?\\)+.+?$"))
    return

  ; Play Notification Sound
  SoundPlay("..\#stuff\AutoHotkey-clipboard-Speech-Misrecognition.wav")

  SavedClipboard := A_Clipboard
  SavedClipboardQuoted := '"' SavedClipboard '"'
  NotificationTitle := ''

  if (IsSet(NotificationGui))
    NotificationGui.Destroy()
  ; Create Notification GUI
  NotificationGui := Gui("-SysMenu +AlwaysOnTop +LastFound") ; -Caption
  NotificationGui.MarginX := 3
  CloseBtn := NotificationGui.Add("Button", , "❌")
  CloseBtn.OnEvent("Click", EndGui)

  switch Type {

    case 0:
      if (WinActive("ahk_class PotPlayer64"))
        return
      NotificationTitle := "Clipboard cleared!"

    case 1:
      NotificationTitle := "Text"
      TextToBeDisplayed := SubStr(SavedClipboard, 1, 1000)
      NotificationGui.Add("Edit", "-Wrap W" MainWidth, TextToBeDisplayed)

      AddButton(NotificationGui, "Speak", "speak")
      AddButton(NotificationGui, 'Define', 'define')
      AddButton(NotificationGui, 'Google', 'google')
      AddButton(NotificationGui, 'Save as ...', 'save-as')
      AddButton(NotificationGui, '', 'everything', 'C:\Program Files\Everything 1.5a\Everything64.exe')

      ; url
      if (RegExMatch(SavedClipboard, "^https?:\/\/")) {
        NotificationTitle := "Web URL"
        AddButton(NotificationGui, 'Open ↗️', 'open-in-browser')
        AddButton(NotificationGui, 'List', 'yt-dlp-list', YtDlpPath)
        AddButton(NotificationGui, '', 'yt-dlp-download', YtDlpPath)
        AddButton(NotificationGui, 'Quick', 'yt-dlp-quick', YtDlpPath)
        AddButton(NotificationGui, 'Check', 'yt-dlp-check', YtDlpPath)
        AddButton(NotificationGui, 'MPV', 'mpv', '..\#stuff\mpv.ico')
      }

      ; File path
      if (RegExMatch(SavedClipboard, "\w:\\(.+?\\)+.+?$")) {

        NotificationTitle := "File path"
        AddButton(NotificationGui, 'Tag', 'tag')

        if (RegExMatch(SavedClipboard, "im)\.(mp4|mkv|webm|video|ts|gif|avi|mov|part)$")) {
          ButtonsForVideos()
        }

        CopiedFilesArray := StrSplit(Trim(SavedClipboard, '`r`n'), "`r`n")
        if (CopiedFilesArray.Length = 1) {
          ; copy , tag
          AddButton(NotificationGui, 'Copy Content', 'copy-cont')
          AddButton(NotificationGui, 'Run/Open', 'run-open')
          AddButton(NotificationGui, 'Open parent', 'open-parent')
        }

        ;* automatically copy image generation prompt
        SplitPath(SavedClipboard, , &ImageDir, , &ImageFileName)
        PromptFileFullName := ImageDir '\' ImageFileName '.txt'
        if (ImageDir = 'w:\Pic\AI') {
          if (FileExist(PromptFileFullName)) {
            ImagePrompt := FileRead(ImageDir '\' ImageFileName '.txt')
            A_Clipboard := ImagePrompt
          } else
            MsgBox 'No prompt file'
        }
      }

      if (ActiveWindowTitle = '<New userscript> - Vivaldi') {
        AddButton(NotificationGui, 'Boilerplate', 'boilerplate')
      }

    case 2:
      NotificationTitle := "Other"
      hBitmap := GetClipboardBitmap()
      if (hBitmap) {
        NotificationGui.Add("Picture", "w" MainWidth " h-1", "HBITMAP:*" hBitmap)
      }
    default:
      return
  }

  NotificationGui.Title := NotificationTitle
  NotificationGui.Add('Text', 'x0 w' MainWidth ' 0x10')
  ; Add Title and Progress Bar
  NotificationGui.Add("Progress", "Xm " "W" MainWidth " H2 vTimerProgress Range-0-" DisplayForMS)

  NotificationGui.SetFont("S12 bold")
  CharacterCount := StrLen(SavedClipboard)
  LineCount := StrSplit(SavedClipboard, "`n", "`r").Length
  NotificationGui.Add('Text', , 'Character count: ' CharacterCount ' Line count: ' LineCount)

  RightEdgeOffset := 8 * NotificationGui.MarginX
  ManualOffset := 50
  ; Show hidden first so AutoSize can calculate dimensions
  NotificationGui.Show("AutoSize Hide")
  monitor := Monitors[WhichMonitor]
  ; Get actual gui size (may differ from MainWidth due to margins / scrollbars)
  NotificationGui.GetPos(, , &GuiWidth, &GuiHeight)
  X := monitor.Right - GuiWidth - RightEdgeOffset - ManualOffset
  ; Clamp horizontally so it never goes off the left edge
  MinX := monitor.Left + RightEdgeOffset
  if (X < MinX)
    X := MinX
  buttonCount := 0
  GuiUniqueId := WinExist()

  ; Correct vertical centering using monitor bounds
  monitorHeight := monitor.Bottom - monitor.Top
  newY := monitor.Top + (monitorHeight - GuiHeight) / 2
  ; Clamp in case of weird DPI math producing fractions
  newY := Round(newY)
  NotificationGui.Show("X" X " Y" newY " NoActivate")
  WinGetPos(, , , &GuiHeight, "ahk_id " GuiUniqueId)
  ; WinMove(, newY, , , "ahk_id" GuiUniqueId)
  ; AnimateWindowMove('ahk_id' GuiUniqueId, X, newY, 10, 1000)

  ; Start Timer Function
  SetTimer(TimerFunction, 100)

  TimerFunction() {

    MouseGetPos(, , &WinUnderMouse)

    try {
      if (GuiUniqueId = WinUnderMouse)
        NotificationGui["TimerProgress"].Value := 0
      else
        NotificationGui["TimerProgress"].Value += 100

      if (NotificationGui["TimerProgress"].Value >= DisplayForMS) {
        EndGui()
      }
    }
  }

  EndGui(*) {
    SetTimer TimerFunction, 0
    NotificationGui.Destroy()
  }

  AddButton(guiObj, Text, ControlName, PathToIcon := "") {
    global buttonCount, buttonWidth, MainWidth

    MarginWidth := guiObj.MarginX
    maxButtonsPerRow := Floor(MainWidth / (buttonWidth + MarginWidth))

    buttonCount++
    isNewRow := Mod(buttonCount, maxButtonsPerRow) = 1

    buttonOptions := isNewRow
      ? Format("xm y+m w{1} v{2}", buttonWidth, ControlName)
      : Format("x+m wp hp v{1}", ControlName)

    newButton := guiObj.Add("Button", buttonOptions, Text)
    newButton.OnEvent("Click", ButtonClicked)

    if (Text)
      IconOptions := 'A0 L5'
    else
      IconOptions := 'L5'

    if (PathToIcon != "")
      GuiButtonIcon(newButton, PathToIcon, , IconOptions)
  }

  ButtonsForVideos() {

    if (GetShowMovieInfo(SavedClipboard)) {
      if ( Not InStr(SavedClipboard, '[w]'))
        AddButton(NotificationGui, 'W', 'mark-as-watched')
      AddButton(NotificationGui, "", "Ratingraph", '..\#stuff\ratingraph.ico')
      AddButton(NotificationGui, "", "Trakt", '..\#stuff\trakt.ico')
      AddButton(NotificationGui, '', 'imdb', '..\#stuff\imdb.ico')
      AddButton(NotificationGui, 'Google', 'google-movie')
      AddButton(NotificationGui, '', 'does-the-dog-die', '..\#stuff\ddd.ico')
      AddButton(NotificationGui, '', 'yify-subtitles', '..\#stuff\yify-subs.ico')
      AddButton(NotificationGui, '', 'letterboxd', '..\#stuff\letterboxd.ico')
    }

    if (RegExMatch(SavedClipboard, '\(\S+\)(\S+)')) {
      AddButton(NotificationGui, 'Op', 'op')
      AddButton(NotificationGui, 'Source', 'source')
    }

    AddButton(NotificationGui, "Convert", 'Convert')
    AddButton(NotificationGui, "720p", '720p')
    AddButton(NotificationGui, "Concat", 'Concat')
    AddButton(NotificationGui, "Decimate", 'Decimate')
    AddButton(NotificationGui, "Stabilize", 'Stabilize')
    AddButton(NotificationGui, "", 'Avidemux', 'C:\Program Files\Avidemux\avidemux.exe')

  }
}

; Function to Retrieve Bitmap from Clipboard
GetClipboardBitmap() {
  local hBitmap := 0

  if (DllCall("OpenClipboard", "ptr", 0)) {
    if (DllCall("IsClipboardFormatAvailable", "uint", 2)) {
      hBitmap := DllCall("GetClipboardData", "uint", 2, "ptr")
    }
    DllCall("CloseClipboard")
  }
  return hBitmap
}
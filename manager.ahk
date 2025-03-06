#Requires AutoHotkey v2.0

Containers := ['test', 'value', 'text']
NumberOfContainers := 10
ModifierKey := 'RCtrl'
OtherModifierKey := 'NumpadIns'
global currentWindowHwnd := 0

; Create the main GUI
ClipboardGui := Gui("+AlwaysOnTop +ToolWindow", "Clipboard Contents")
ClipboardGui.SetFont("s10", "Segoe UI")
ClipboardGui.MarginX := 10
ClipboardGui.MarginY := 10

; Create text controls for each container
ContentControls := Map()
loop NumberOfContainers {
  ContentControls[A_Index] := ClipboardGui.Add("Edit", "r3 w400 ReadOnly vContainer" A_Index)
}

ClipboardGui.OnEvent("Escape", (*) => ClipboardGui.Hide())

Hotkey(ModifierKey ' & ' OtherModifierKey, DisableKeys)
Hotkey(OtherModifierKey ' & ' ModifierKey, DisableKeys)
DisableKeys(*) {
  return
}

PutIntoContainers(Type) {
  if (Type != 1) {
    return
  }
  if (InStr(A_Clipboard, 'global-document-ready-')) {
    return
  }

  newValue := A_Clipboard

  ; Check for and remove any existing duplicate
  index := 1
  while (index <= Containers.Length) {
    if (Containers[index] = newValue) {
      Containers.RemoveAt(index)
      break
    }
    index++
  }

  ; Remove last item if we've reached capacity
  if (Containers.Length >= NumberOfContainers) {
    Containers.RemoveAt(NumberOfContainers)
  }

  ; Insert new item at the beginning
  Containers.InsertAt(1, newValue)
  UpdateGuiContents()
}

UpdateGuiContents() {
  for index, control in ContentControls {
    if (index <= Containers.Length) {
      preview := SubStr(Containers[index], 1, 300)
      preview := index ": " preview
      control.Value := preview
    } else {
      control.Value := index ": <empty>"
    }
  }
}

loop NumberOfContainers {
  Index := (A_Index < 10) ? A_Index : 0
  Hotkey('' OtherModifierKey ' & ' Index, HotKeyFunc)
}

HotKeyFunc(HKey) {
  if !(GetKeyState(ModifierKey, 'P'))
    return
  global currentWindowHwnd
  Key := StrReplace(HKey, OtherModifierKey ' & ', '')
  KeyWait ModifierKey
  KeyWait OtherModifierKey
  ; OnClipboardChange(PutIntoContainers, 0)
  A_Clipboard := ''
  A_Clipboard := Containers[Key]
  ; OnClipboardChange(PutIntoContainers)
  ClipWait
  WinActivate('ahk_id ' currentWindowHwnd)
  Send '^v'
}

Hotkey(OtherModifierKey ' & ' ModifierKey, ShowContainers)
Hotkey(ModifierKey ' & ' OtherModifierKey, ShowContainers)
ShowContainers(*) {
  global currentWindowHwnd
  static Fired := False
  if (!Fired) {
    currentWindowHwnd := WinGetID('A')
    UpdateGuiContents()
    ClipboardGui.Show()
    Fired := True
    KeyWait "Shift"
    KeyWait "Ctrl"
    ClipboardGui.Hide()
    Fired := False
  }
}
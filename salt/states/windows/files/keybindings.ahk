; setup
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Recommended for catching common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance, Force
#Persistent
#NoTrayIcon

; globals
pipWindows := {}
EnvGet, USERPROFILE, USERPROFILE
alacritty := "alacritty --working-directory " USERPROFILE

; keybindings
; - open sublime (super + o)
#o::Run "C:\Program Files\Sublime Text 3\sublime_text.exe"
; - open alacritty (super + t)
#t::Run %alacritty%
; - open explorer in my home directory (super + enter)
#Return::Run "%USERPROFILE%"
; - open explorer in This PC (super + shift + enter)
#+Return::Run "shell:::{20D04FE0-3AEA-1069-A2D8-08002B30309D}"
; - reload script (ctrl + super + r)
^#r::Relo()

Relo() {
    Gui Color, 0xFF0000
    Gui Font, s10

    Gui +E0x20 -Caption +LastFound +ToolWindow +AlwaysOnTop
    Gui, Add, Text, w190 +Wrap +Center, Config Reloaded

    WinSet, Transparent, 100

    Gui Show, NoActivate, w200 h200
    Sleep 500
    Reload
}

; - pip (super + z)
#z::TogglePip()

; - debug (super + g)
#g::Debug()

; - borderless windowed
#F12::ToggleFakeFullscreen()

/**
 * GetMonitorIndexFromWindow retrieves the HWND (unique ID) of a given window.
 * @param {Uint} windowHandle
 * @author shinywong
 * @link http://www.autohotkey.com/board/topic/69464-how-to-determine-a-window-is-in-which-monitor/?p=440355
 */
GetMonitorIndexFromWindow(windowHandle) {
    ; Starts with 1.
    monitorIndex := 1
    VarSetCapacity(monitorInfo, 40)
    NumPut(40, monitorInfo)
    if (monitorHandle := DllCall("MonitorFromWindow", "uint", windowHandle, "uint", 0x2))
        && DllCall("GetMonitorInfo", "uint", monitorHandle, "uint", &monitorInfo) {
        monitorLeft   := NumGet(monitorInfo,  4, "Int")
        monitorTop    := NumGet(monitorInfo,  8, "Int")
        monitorRight  := NumGet(monitorInfo, 12, "Int")
        monitorBottom := NumGet(monitorInfo, 16, "Int")
        workLeft      := NumGet(monitorInfo, 20, "Int")
        workTop       := NumGet(monitorInfo, 24, "Int")
        workRight     := NumGet(monitorInfo, 28, "Int")
        workBottom    := NumGet(monitorInfo, 32, "Int")
        isPrimary     := NumGet(monitorInfo, 36, "Int") & 1
        SysGet, monitorCount, MonitorCount
        Loop, %monitorCount% {
            SysGet, tempMon, Monitor, %A_Index%
            ; Compare location to determine the monitor index.
            if ((monitorLeft = tempMonLeft) and (monitorTop = tempMonTop)
                and (monitorRight = tempMonRight) and (monitorBottom = tempMonBottom)) {
                monitorIndex := A_Index
                break
            }
        }
    }
    return %monitorIndex%
}

TogglePip() {
    global pipWindows

    ; get window id
    WinGet, windowId, ID, A

    if (pipWindows.HasKey(windowId)) {
        ; pop pip state
        originalDetails := pipWindows.Delete(windowId)

        ; undo pip
        WinMove, A, , originalDetails["x"], originalDetails["y"], originalDetails["width"], originalDetails["height"]
        ; Send {F11}
        WinSet, AlwaysOnTop, off, A
    }
    else {
        ; get details
        ; - window
        WinGetPos, x, y, width, height, A
        ; - monitor
        monitorIndex := GetMonitorIndexFromWindow(windowId)
        SysGet, monitor, Monitor, %monitorIndex%
        monitorWidth := (MonitorRight - MonitorLeft) + 7
        monitorHeight := (MonitorBottom - MonitorTop) + 7
        newWidth := monitorWidth / 4
        newHeight := monitorHeight / 3
        ; TODO: make smarter
        newWidth := 800
        newHeight := 550
        newX := monitorWidth - newWidth
        newY := monitorHeight - newHeight

        ; store original details
        pipWindows[windowId] := {x: x, y: y, width: width, height: height}

        ; make pip
        WinSet, AlwaysOnTop, on, A
        ; Send {F11}
        WinMove, A, , newX, newY, newWidth, newHeight
    }
}

Debug() {
    ; get window id
    WinGet, windowId, ID, A
    ; get window title
    WinGetTitle, windowTitle, A
    ; get window class
    WinGetClass, windowClass, A

    ; display info
    MsgBox, 0, Debug, %windowTitle%
    MsgBox, 0, Debug, %windowClass%
}

ToggleFakeFullscreen()
{
    CoordMode Screen, Window
    static WINDOW_STYLE_UNDECORATED := -0xC40000
    static savedInfo := Object() ;; Associative array!
    WinGet, id, ID, A
    if (savedInfo[id])
    {
        inf := savedInfo[id]
        WinSet, Style, % inf["style"], ahk_id %id%
        WinMove, ahk_id %id%,, % inf["x"], % inf["y"], % inf["width"], % inf["height"]
        savedInfo[id] := ""
    }
    else
    {
        savedInfo[id] := inf := Object()
        WinGet, ltmp, Style, A
        inf["style"] := ltmp
        WinGetPos, ltmpX, ltmpY, ltmpWidth, ltmpHeight, ahk_id %id%
        inf["x"] := ltmpX
        inf["y"] := ltmpY
        inf["width"] := ltmpWidth
        inf["height"] := ltmpHeight
        WinSet, Style, %WINDOW_STYLE_UNDECORATED%, ahk_id %id%
        mon := GetMonitorActiveWindow()
        SysGet, mon, Monitor, %mon%
        WinMove, A,, %monLeft%, %monTop%, % monRight-monLeft, % monBottom-monTop
    }
}

GetMonitorAtPos(x,y)
{
    ;; Monitor number at position x,y or -1 if x,y outside monitors.
    SysGet monitorCount, MonitorCount
    i := 0
    while(i < monitorCount)
    {
        SysGet area, Monitor, %i%
        if ( areaLeft <= x && x <= areaRight && areaTop <= y && y <= areaBottom )
        {
            return i
        }
        i := i+1
    }
    return -1
}

GetMonitorActiveWindow()
{
    ;; Get Monitor number at the center position of the Active window.
    WinGetPos x,y,width,height, A
    return GetMonitorAtPos(x+width/2, y+height/2)
}

#Requires AutoHotkey v2.0

ButtonClicked(Control, null) {

    global savedClipboard, SavedClipboardQuoted

    switch Control.Name {

        ;//ANCHOR - Text

        case 'boilerplate':
            WinActivate('<New userscript>')
            A_Clipboard := ''
            Send '^a^c'
            if !ClipWait(1) {
                MsgBox 'Text copying error'
                return
            }
            OriginalTemplate := A_Clipboard
            RegEx := 'm)\/\/ @match\s+https?:\/\/(.+?\.)?(.+?)\..+?\/'
            RegExMatch(OriginalTemplate, RegEx, &SuggestedNameMatches)
            SuggestedName := SuggestedNameMatches[2]
            InputBoxResult := InputBox(, , , SuggestedName)
            ScriptName := '[tm] ' InputBoxResult.Value

            Includes := '
(     
// @require      https://code.jquery.com/jquery-3.7.1.js
// @require      file://D:\Mega\IDEs\JavaScript\[fun] vanilla.js
// @require      file://D:\Mega\IDEs\JavaScript\[fun] vanilla - presets.js
// @require      file://D:\Mega\IDEs\JavaScript\{ScriptName}.user.js
)'

            NewTemplate := StrReplace(OriginalTemplate, 'New Userscript', ScriptName)
            NewTemplate := StrReplace(NewTemplate, '// @author       You', '// @author       Codexophile')
            NewTemplate := StrReplace(NewTemplate, '// @grant        none', '`n// @grant        none`n')
            NewTemplate := StrReplace(NewTemplate, '// ==UserScript==', '// ==UserScript==`n')
            NewTemplate := StrReplace(NewTemplate, '// ==/UserScript==', includes '`n`n// ==/UserScript==')
            NewTemplate := StrReplace(NewTemplate, '{ScriptName}', ScriptName)

            A_Clipboard := NewTemplate
            Send '^v'

            JsFullPath := 'D:\Mega\IDEs\JavaScript\' ScriptName '.user.js'
            if !FileExist(JsFullPath) {
                if (MsgBox('Create file?', , 'YesNo Icon?') = 'Yes') {
                    JsFileContent :=
                        "( function () {`n'use strict'`nif ( window.top != window.self) return; //don't run on frames or iframes`n`n`n`n} )()"
                    FileAppend(JsFileContent, JsFullPath)
                } else return
            }
            if (MsgBox('Open file?', , 'YesNo Icon?') = 'Yes')
                Run 'C:\Users\xq151\AppData\Local\Programs\Microsoft VS Code\Code.exe "' JsFullPath '"'

        case 'mark-as-watched':
            Run '..\mpv-assistant.ahk ' SavedClipboardQuoted

        case 'letterboxd':
            GetShowMovieInfo(savedClipboard, &ShowMovieName, ,)
            GoogleIflSiteSearch('letterboxd.com', ShowMovieName)

        case 'Trakt':
            SplitPath(savedClipboard, , , , &FilenameNoExt)
            openInTrakt(FilenameNoExt)

        case 'Ratingraph':
            GetShowMovieInfo(savedClipboard, &ShowMovieName, ,)
            GoogleIflSiteSearch('ratingraph.com', ShowMovieName)

        case 'imdb':
            GetShowMovieInfo(savedClipboard, &ShowMovieName, ,)
            GoogleIflSiteSearch('imdb.com', ShowMovieName)

        case 'google-movie':
            GetShowMovieInfo(savedClipboard, &ShowMovieName, ,)
            Run 'https://www.google.com/search?q=' ShowMovieName

        case 'does-the-dog-die':
            GetShowMovieInfo(savedClipboard, &ShowMovieName, ,)
            GoogleIflSiteSearch('doesthedogdie.com', ShowMovieName)

        case 'yify-subtitles':
            GetShowMovieInfo(savedClipboard, &ShowMovieName, ,)
            GoogleIflSiteSearch('yifysubtitles.ch', ShowMovieName)

        case 'op':
            RegExMatch(SavedClipboard, '.+\\(\S+) ?-.+\((\S+)\)', &OpInfo)
            OpUsername := OpInfo.1
            Extractor := OpInfo.2
            FindOp(OpUsername, Extractor)

        case 'source':
            RegExMatch(savedClipboard, '\((\S+)\)(\S+)', &VideoInfo)
            Extractor := VideoInfo.1
            VideoId := VideoInfo.2
            FindSource(VideoId, Extractor)

        case 'speak':
            savedClipboard := StrReplace(savedClipboard, "”", "`"")
            savedClipboard := StrReplace(savedClipboard, "“", "`"")
            savedClipboard := StrReplace(savedClipboard, "’", "'")
            FileDelete 'D:\Mega\IDEs\powershell\edge-playback.txt'
            FileAppend(savedClipboard, 'D:\Mega\IDEs\powershell\edge-playback.txt')
            Run 'D:\Mega\IDEs\powershell\edge-playback.ps1'

        case 'define':
            GoogleQuery := StrReplace(savedClipboard, ' ', '+')
            Run 'https://www.google.com/search?q=define ' GoogleQuery

        case 'google':
            SplitPath(savedClipboard, , , , &FilenameNoExt, &Drive)
            if (Drive)
                GoogleQuery := StrReplace(FilenameNoExt, ' ', '+')
            else
                GoogleQuery := StrReplace(savedClipboard, ' ', '+')
            Run 'https://www.google.com/search?q=' GoogleQuery

        case 'save-as':
            NewFileContent := savedClipboard
            SelectedFile := FileSelect('s16')
            if FileExist(SelectedFile)
                FileRecycle SelectedFile
            FileAppend(NewFileContent, SelectedFile)

        case 'everything':
            Run '"C:\Program Files\Everything 1.5a\Everything64.exe" -s ' SavedClipboardQuoted

            ;//ANCHOR - Web url

        case 'open-in-browser':
            Run VivaldiPath ' ' SavedClipboardQuoted

        case 'yt-dlp-list':
            Ytdlp(SavedClipboardQuoted, "list")

        case 'yt-dlp-download':
            Ytdlp(SavedClipboardQuoted, "max")

        case 'yt-dlp-auto':
            Ytdlp(SavedClipboardQuoted, "quick")

        case 'mpv':
            Run '"D:\Program Files - Portable\mpv\mpv.exe" ' . SavedClipboardQuoted . ' --load-auto-profiles=no'

            ;//ANCHOR - File path

        case 'copy-cont':
            FileSize := FileGetSize(savedClipboard, 'K')
            if (FileSize > 512) {
                Response := MsgBox("File too big (" FileSize " KB).Proceed ?", , 4)
                if (Response = "No")
                    return
            }
            A_Clipboard := FileRead(SavedClipboard)

        case 'open-parent':
            SplitPath(savedClipboard, , &ParentDir)
            Run ParentDir

        case 'run-open':
            Run Trim(savedClipboard, ' `n`r')
            ;//ANCHOR - Video files
        case 'Convert':
            MediaFullName := GetMediaFullName()
            parameters := MediaFullName " -ACodec -VCodec"
            Run "pwsh -noExit D:\Mega\IDEs\powershell\ffmpeg\ffmpeg-convert.ps1 " parameters
        case '720p':
            MediaFullName := GetMediaFullName()
            parameters := MediaFullName " -720p"
            Run "pwsh -noExit D:\Mega\IDEs\powershell\ffmpeg-convert.ps1 " parameters
        case 'Stabilize':
            Run 'pwsh -noExit D:\Mega\IDEs\powershell\ffmpeg-stabilize.ps1 ' SavedClipboardQuoted
        case 'Avidemux':
            AvidemuxPath := 'C:\Program Files\Avidemux\avidemux.exe'
            VideoFilePath := RegExReplace(SavedClipboardQuoted, '\r|\n', '')
            Run(AvidemuxPath ' ' VideoFilePath)
        case 'tag':
            Run "D:\Mega\IDEs\Electron\file-tagger\node_modules\electron\dist\electron.exe D:\Mega\IDEs\Electron\file-tagger " SavedClipboardQuoted,
            "D:\Mega\IDEs\Electron\file-tagger"
        default:
    }
}

FindSource(VideoId, Extractor) {
    switch Extractor, 'Off' {
        case 'pornhub':
            Url := 'https://www.pornhub.com/view_video.php?viewkey=' VideoId
    }
    if (Url)
        RunInPrivateProfile(Url)

}

FindOp(OpUsername, Extractor) {
    switch Extractor, 'off' {
        case 'facebook':
            Url := 'https://www.facebook.com/' OpUsername
        case 'instagram':
            Url := 'https://www.instagram.com/' OpUsername
        case 'pornhub':
            OpUsername := StrReplace(OpUsername, '?', '/')
            Url := 'https://www.pornhub.com' OpUsername '/videos'
        case 'twitter':
            Url := 'https://twitter.com/' OpUsername
        case 'youtube':
            Url := 'https://www.youtube.com/' OpUsername '/videos/'
        default:
    }
    if (Url)
        RunInPrivateProfile(Url)
}

RunInPrivateProfile(Url) {
    browserPath := GetVivaldiPath()
    if (!browserPath) {
        MsgBox 'Vivaldi not found'
        return
    }
    BrowserCommandLine := browserPath " --profile-directory=`"Profile 1`" --disable-features=LockProfileCookieDatabase"
    Run browserPath ' ' Url
}

GetMediaFullName() {
    if (InStr(savedClipboard, '`n'))
        return savedClipboard
    else if FileExist(savedClipboard)
        return savedClipboard
    else
        return GetCurrentMediaFileName()
}
Ytdlp(Url, Mode) {
    url := StrReplace(url, "&", "``&")
    url := StrReplace(url, "(", "``(")
    url := StrReplace(url, ")", "``)")
    PowerShell('D:\Mega\IDEs\powershell\yt-dlp\yt-dlp.ps1 -mode ' mode ' ' url)
}

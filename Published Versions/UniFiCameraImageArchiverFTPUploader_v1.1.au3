#include <Array.au3>
#include <File.au3>
#include <FTPEx.au3>
#include <Date.au3>
#include <GDIPlus.au3>
#include <Inet.au3>
#include <InetConstants.au3>
#include <MsgBoxConstants.au3>
#include <WinAPIHObj.au3>

#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Resources\phoenixtray.ico
#AutoIt3Wrapper_Outfile=Builds\UniFiCameraImageArchiverFTPUploader_v1.1.exe
#AutoIt3Wrapper_Res_Comment=UniFi Camera Image Archiver & FTP Uploader by Phoenix125.com
#AutoIt3Wrapper_Res_Description=UniFi Camera Image Archiver & FTP Uploader
#AutoIt3Wrapper_Res_Fileversion=1.1
#AutoIt3Wrapper_Res_ProductName=UniFi Camera Image Archiver & FTP Uploader
#AutoIt3Wrapper_Res_ProductVersion=1.1
#AutoIt3Wrapper_Res_CompanyName=http://www.Phoenix125.com
#AutoIt3Wrapper_Res_LegalCopyright=http://www.Phoenix125.com
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_Run_AU3Check=n
#AutoIt3Wrapper_Run_Tidy=y
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/mo
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

Local $tExit = False
Global $aUtilName = "UniFiCameraImageArchiverFTPUploader"
Global $aUtilVersion = "v1.1"
Global $aUtilVerNumber = 0 ; New number assigned for each config file change. Used to write temp update script so that users are not forced to update config.
Global $aIniFile = @ScriptDir & "\" & $aUtilName & ".ini"
Global $aUtilCFGFile = @ScriptDir & "\" & $aUtilName & "_cfg.ini"
Global $aFolderTemp = ""
Global $aUtilUpdateLinkVer = "http://www.phoenix125.com/share/" & StringLower($aUtilName) & "/latestver.txt"
Global $aUtilUpdateLinkDL = "http://www.phoenix125.com/share/" & StringLower($aUtilName) & "/" & $aUtilName & ".zip"
Global $aUtilReadMeLink = "http://www.phoenix125.com/share/" & StringLower($aUtilName) & "/ReadMe.pdf"
Global $aUtilUpdateFile = @ScriptDir & "\__UTIL_UPDATE_AVAILABLE___.txt"
Global $aStartText = $aUtilName & " " & $aUtilVersion & " starting . . ." & @CRLF & @CRLF
Global $aSplash = _Splash($aStartText, 0, 475)
Global $aCFGLastVerNumber = IniRead($aUtilCFGFile, "CFG", "aCFGLastVerNumber", $aUtilVerNumber)
ReadCFG()
ControlSetText($aSplash, "", "Static1", $aStartText & "Creating startup batch file")
CreateStartupBatchFile()
ControlSetText($aSplash, "", "Static1", $aStartText & "Importing config settings")
Local $tChanged = ReadIni()
For $x = 0 To ($aNumberOfEntries - 1)
	If $xIntervalSave[$x] <= $xIntervalFTP[$x] Then
		$tGetImageInterval[$x] = $xIntervalSave[$x]
	Else
		$tGetImageInterval[$x] = $xIntervalFTP[$x]
	EndIf
	$cIntervalGetImage[$x] = _NowCalc()
	$cIntervalFTP[$x] = _NowCalc()
	$cIntervalSave[$x] = _NowCalc()
Next
If $aLogLevel < 3 Then LogWrite("----- ===== " & $aUtilName & " started ===== -----")
ControlSetText($aSplash, "", "Static1", $aStartText & "Creating tray icon menu")
Opt("TrayMenuMode", 3) ; The default tray menu items will not be shown and items are not checked when selected. These are options 1 and 2 for TrayMenuMode.
Opt("TrayOnEventMode", 1)
Local $iTrayVersion = TrayCreateItem($aUtilName & " " & $aUtilVersion)
TrayItemSetOnEvent(-1, "TrayAbout")
TrayCreateItem("")
Local $iTrayAbout = TrayCreateItem("About")
TrayItemSetOnEvent(-1, "TrayAbout")
Local $iTrayUpdateUtilCheck = TrayCreateItem("Check for Update")
TrayItemSetOnEvent(-1, "TrayUpdateUtilCheck")
Local $iTrayUpdateUtilCheck = TrayCreateItem("Restart")
TrayItemSetOnEvent(-1, "TrayRestartUtil")
Local $iTrayUpdateUtilCheck = TrayCreateItem("Open ReadMe")
TrayItemSetOnEvent(-1, "TrayOpenReadMe")
TrayCreateItem("")
Local $iTrayExitCloseN = TrayCreateItem("Open LOG (Latest)")
TrayItemSetOnEvent(-1, "TrayOpenLog")
Local $iTrayExitCloseN = TrayCreateItem("Open CONFIG")
TrayItemSetOnEvent(-1, "TrayOpenConfig")
Local $iTrayExitCloseN = TrayCreateItem("Open IMAGE folder")
TrayItemSetOnEvent(-1, "TrayOpenImageFolder")
TrayCreateItem("")
Local $iTrayUpdateUtilPause = TrayCreateItem("Pause")
TrayItemSetOnEvent(-1, "TrayUpdatePause")
TrayCreateItem("")
Local $iTrayExitCloseY = TrayCreateItem("Exit")
TrayItemSetOnEvent(-1, "TrayExit")
ControlSetText($aSplash, "", "Static1", $aStartText & "Saving config settings")
WriteINI()
If $tChanged = "new" Then
	ShellExecute($aIniFile)
	Sleep(1000)
	SplashOff()
	MsgBox(0, $aUtilName, "Welcome! Please make changes to the " & $aUtilName & ".ini file.")
	_ExitUtil()
ElseIf $tChanged = "changed" Then
	ReadIni()
	WriteINI()
	ShellExecute($aIniFile)
	Sleep(1000)
	SplashOff()
	MsgBox(0, $aUtilName, "Number of cameras changed in config. Please make changes to the " & $aUtilName & ".ini file.")
	_ExitUtil()
EndIf
ControlSetText($aSplash, "", "Static1", $aStartText & "Checking for updates")
If $aUtilCheckForUpdateYN <> "no" Then
	UtilUpdate($aUtilUpdateLinkVer, $aUtilUpdateLinkDL, $aUtilVersion, $aUtilName, $aSplash, "show", "yes")
Else
	FileDelete($aUtilUpdateFile)
EndIf
Local $tDiffSave = True
Local $tDiffFTP = True
Local $tDiffGetImage = True
Local $tErrorImageSave = False
;~ Local $tGetImageInterval = 0
Local $xFileName1 = ""
Local $tDiffSec = ""
For $x = 0 To ($aNumberOfEntries - 1)
	$cTimerGetImage[$x] = TimerInit()
	$cTimerRestartSave[$x] = TimerInit()
	$cTimerRestartFTP[$x] = TimerInit()
Next
;~ Local $cTimerIniChanges = TimerInit()

;~ If $aIntervalSave <= $aIntervalFTP Then
;~ 	$tGetImageInterval = $aIntervalSave
;~ Else
;~ 	$tGetImageInterval = $aIntervalFTP
;~ EndIf
ControlSetText($aSplash, "", "Static1", $aStartText & "Startup complete.")
Sleep(2500)
SplashOff()
FileDelete($aFolderTemp & $aUtilName & "_Delay_Restart.bat")
Do
;~ 	If $aScanForChangesSec > 0 Then
;~ 		If TimerDiff($cTimerIniChanges) > $aScanForChangesSec * 1000 Then
;~ 			$cTimerIniChanges = TimerInit()
;~ 			$aNumberOfEntries = IniRead($aIniFile, " --------------- " & StringUpper($aUtilName) & " --------------- ", "Number of cameras/files to manage (1-100) ###", "1")
;~ 			$aPreviousNumberOfEntries = IniRead($aIniFile, " --------------- " & StringUpper($aUtilName) & " OPTIONS --------------- ", "System Use: Previous number of entries ###", "0")
;~ 			If $aNumberOfEntries <> $aPreviousNumberOfEntries Then
;~ 				Sleep(1000)
;~ 				$aNumberOfEntries = IniRead($aIniFile, " --------------- " & StringUpper($aUtilName) & " --------------- ", "Number of cameras/files to manage (1-100) ###", "1")
;~ 				$aPreviousNumberOfEntries = IniRead($aIniFile, " --------------- " & StringUpper($aUtilName) & " OPTIONS --------------- ", "System Use: Previous number of entries ###", "0")
;~ 				If $aNumberOfEntries <> $aPreviousNumberOfEntries Then
;~ 					ReadIni()
;~ 					WriteINI()
;~ 					ShellExecute($aIniFile)
;~ 					Sleep(1000)
;~ 					MsgBox(0, $aUtilName, "Number of cameras changed. Please make changes to the " & $aUtilName & ".ini file.", 30)
;~ 					_RestartProgram()
;~ 				EndIf
;~ 			EndIf
;~ 		EndIf
;~ 	EndIf
	For $xCam = 0 To ($aNumberOfEntries - 1)
		If TimerDiff($cTimerRestartSave[$xCam]) > $xIntervalSave[$xCam] * 1000 Then
			$tDiffSave = True
			$cTimerRestartSave[$xCam] = TimerInit()
		EndIf
		If TimerDiff($cTimerRestartFTP[$xCam]) > $xIntervalFTP[$xCam] * 1000 Then
			$tDiffFTP = True
			$cTimerRestartFTP[$xCam] = TimerInit()
		EndIf
		If TimerDiff($cTimerGetImage[$xCam]) > $tGetImageInterval[$xCam] * 1000 Then
			$tDiffGetImage = True
			$cTimerGetImage[$xCam] = TimerInit()
		EndIf
		If $tDiffGetImage Then
			$tDiffGetImage = False
;~ 			For $x = 0 To (UBound($xFileNameOriginal) - 1)
			Local $tImageSize = 0
			Local $sFile = $aFolderImage & $xFileNameOriginal[$xCam]
			Local $tGet = InetGet($xURL[$xCam], $sFile, $INET_FORCERELOAD)
			Local $tImageSize = FileGetSize($sFile)
			If $tImageSize < 10000 Then
				$tErrorImageSave = True
				If $aLogLevel < 3 Then LogWrite("[ERROR] File failed to download from camera:" & $xURL[$xCam])
			Else
				$tErrorImageSave = False
				If $xResizeImageSize[$xCam] <> "" Then
					Local $xImageSplit = StringSplit($xResizeImageSize[$xCam], "x", 2)
					Local $tResizeX = Abs($xImageSplit[0])
					Local $tResizeY = Abs($xImageSplit[1])
					_ImageResizer($sFile, $aFolderImage & $xFileNameResized[$xCam], $tResizeX, $tResizeY)
				EndIf
			EndIf
;~ 			Next
		EndIf
		If $tDiffSave And $tErrorImageSave = False Then
			$tDiffSave = False
;~ 			For $x = 0 To (UBound($xFileNameOriginal) - 1)
			If StringInStr($xSaveType[$xCam], "B") Or StringInStr($xSaveType[$xCam], "F") Then
				Local $xFileNameSplit = _PathSplit($aFolderImage & $xFileNameOriginal[$xCam], "", "", "", "")
				If $xSaveFileNumberYN[$xCam] = "no" Then
					$tFileNameSave = $xFileNameSplit[3] & "_" & @YEAR & "-" & @MON & "-" & @MDAY & "_" & @HOUR & @MIN & @SEC & $xFileNameSplit[4]
				Else
					Local $tFileNameNumber = IniRead($aUtilCFGFile, "CFG", "aCFGCam(" & $xCam & ")FileNameNumberF", 0)
					$tFileNameNumber += 1
					Local $tFileNameExt = _AddLeadingZeros($tFileNameNumber, 6)
					$tFileNameSave = _LettersOnly($xFileNameSplit[3]) & "_" & $tFileNameExt & $xFileNameSplit[4]
					IniWrite($aUtilCFGFile, "CFG", "aCFGCam(" & $xCam & ")FileNameNumberF", $tFileNameNumber)
				EndIf
				DirCreate($aFolderImage & $xFileNameSplit[3])
				FileCopy($aFolderImage & $xFileNameOriginal[$xCam], $aFolderImage & $xFileNameSplit[3] & "\" & $tFileNameSave)
			EndIf
			If (StringInStr($xSaveType[$xCam], "B") Or StringInStr($xSaveType[$xCam], "R")) And $xResizeImageSize[$xCam] <> "" Then
				Local $xFileNameSplit = _PathSplit($aFolderImage & $xFileNameResized[$xCam], "", "", "", "")
				If $xSaveFileNumberYN[$xCam] = "no" Then
					$tFileNameSave = $xFileNameSplit[3] & "_" & @YEAR & "-" & @MON & "-" & @MDAY & "_" & @HOUR & @MIN & @SEC & $xFileNameSplit[4]
				Else
					Local $tFileNameNumber = IniRead($aUtilCFGFile, "CFG", "aCFGCam(" & $xCam & ")FileNameNumberR", 0)
					$tFileNameNumber += 1
					Local $tFileNameExt = _AddLeadingZeros($tFileNameNumber, 6)
					$tFileNameSave = _LettersOnly($xFileNameSplit[3]) & "_" & $tFileNameExt & $xFileNameSplit[4]
					IniWrite($aUtilCFGFile, "CFG", "aCFGCam(" & $xCam & ")FileNameNumberR", $tFileNameNumber)
				EndIf
				FileCopy($aFolderImage & $xFileNameResized[$xCam], $aFolderImage & $xFileNameSplit[3] & "\" & $tFileNameSave)
			EndIf
;~ 			Next
		EndIf
		If $tDiffFTP And $tErrorImageSave = False Then
			$tDiffFTP = False
;~ 			For $x = 0 To (UBound($xFileNameOriginal) - 1)
			Local $tTimerUpload = TimerInit()
			If (StringInStr($xFTPUploadType[$xCam], "B") Or StringInStr($xFTPUploadType[$xCam], "F")) Then
				Local $tError = FTPFiles($aFolderImage & $xFileNameOriginal[$xCam], $xFTPFolder[$xCam], $xFTPURL[$xCam], $xUserID[$xCam], $xPwd[$xCam])
				$tDiffSec = StringFormat("%.2f", TimerDiff($tTimerUpload) / 1000, 2)
				If $tError = 0 Then
					If $aLogLevel = 1 Then LogWrite("[OK] Code[" & $tError & "] Time[" & $tDiffSec & "s] Upload successful [" & $xFileNameOriginal[$xCam] & "] FTP[" & $xFTPURL[$xCam] & "] UserID[" & $xUserID[$xCam] & "] Pwd[" & $xPwd[$xCam] & "]")
				Else
					If $aLogLevel < 3 Then LogWrite("[ERROR] Code[" & $tError & "] Time[" & $tDiffSec & "s] Upload FAILED. [" & $xFileNameOriginal[$xCam] & "] FTP[" & $xFTPURL[$xCam] & "] UserID[" & $xUserID[$xCam] & "] Pwd[" & $xPwd[$xCam] & "]")
				EndIf
			EndIf
			If (StringInStr($xFTPUploadType[$xCam], "B") Or StringInStr($xFTPUploadType[$xCam], "R")) And $xResizeImageSize[$xCam] <> "" Then
				Local $tError = FTPFiles($aFolderImage & $xFileNameResized[$xCam], $xFTPFolder[$xCam], $xFTPURL[$xCam], $xUserID[$xCam], $xPwd[$xCam])
				$tDiffSec = StringFormat("%.2f", TimerDiff($tTimerUpload) / 1000, 2)
				If $tError = 0 Then
					If $aLogLevel = 1 Then LogWrite("[OK] Code[" & $tError & "] Time[" & $tDiffSec & "s] Upload successful [" & $xFileNameResized[$xCam] & "] FTP[" & $xFTPURL[$xCam] & "] UserID[" & $xUserID[$xCam] & "] Pwd[" & $xPwd[$xCam] & "]")
				Else
					If $aLogLevel < 3 Then LogWrite("[ERROR] Code[" & $tError & "] Time[" & $tDiffSec & "s] Upload FAILED. [" & $xFileNameResized[$xCam] & "] FTP[" & $xFTPURL[$xCam] & "] UserID[" & $xUserID[$xCam] & "] Pwd[" & $xPwd[$xCam] & "]")
				EndIf
			EndIf
;~ 			Next
		EndIf
	Next
	Sleep(500)
Until $tExit
Func _AddLeadingZeros($tTxt3, $tDigits = 8, $tTrimTF = True)
	Local $t2Len = StringLen($tTxt3)
	If $t2Len < $tDigits Then
		Local $t2Txt = ""
		For $t2t = 1 To ($tDigits - $t2Len)
			$t2Txt &= "0"
		Next
		$t2Txt &= $tTxt3
		Return $t2Txt
	ElseIf $t2Len > $tDigits And $tTrimTF Then
		Return StringRight($tTxt3, $tDigits)
	Else
		Return $tTxt3
	EndIf
EndFunc   ;==>_AddLeadingZeros
Func ReadIni()
	Local $tChanged = "nope"
	Local $iniCheck = ""
	Local $aChar[3]
	For $i = 1 To 13
		$aChar[0] = Chr(Random(97, 122, 1)) ;a-z
		$aChar[1] = Chr(Random(48, 57, 1)) ;0-9
		$iniCheck &= $aChar[Random(0, 1, 1)]
	Next
	Global $aNumberOfEntries = IniRead($aIniFile, " --------------- " & StringUpper($aUtilName) & " --------------- ", "Number of cameras/files to manage (1-100) ###", $iniCheck)
;~ 	Global $aIntervalFTP = IniRead($aIniFile, " --------------- " & StringUpper($aUtilName) & " OPTIONS --------------- ", "Number of seconds between FTP uploads (5-86400) ###", "60")
;~ 	Global $aIntervalSave = IniRead($aIniFile, " --------------- " & StringUpper($aUtilName) & " OPTIONS --------------- ", "Number of seconds between archive images (5-86400) ###", "60")
	Global $aFolderLog = IniRead($aIniFile, " --------------- " & StringUpper($aUtilName) & " OPTIONS --------------- ", "Log folder ###", @ScriptDir & "\Logs\")
	Global $aFolderImage = IniRead($aIniFile, " --------------- " & StringUpper($aUtilName) & " OPTIONS --------------- ", "Images folder ###", @ScriptDir & "\Images\")
	Global $aLogLevel = IniRead($aIniFile, " --------------- " & StringUpper($aUtilName) & " OPTIONS --------------- ", "Log Level 1-All, 2-Fails, 3-None (1-3) ###", "1")
;~ 	Global $aScanForChangesSec = IniRead($aIniFile, " --------------- " & StringUpper($aUtilName) & " OPTIONS --------------- ", "Scan for changes in number of cameras every _ seconds (0 to disable) (0-600) ###", "0")
	Global $aUtilCheckForUpdateYN = IniRead($aIniFile, " --------------- " & StringUpper($aUtilName) & " OPTIONS --------------- ", "Check for updates at program start? (yes/no) ###", "yes")
	Global $aPreviousNumberOfEntries = IniRead($aIniFile, " --------------- " & StringUpper($aUtilName) & " OPTIONS --------------- ", "System Use: Previous number of entries ###", "0")
	If $aNumberOfEntries = $iniCheck Then
		$aNumberOfEntries = 1
		$tChanged = "new"
	Else
		If $aNumberOfEntries <> $aPreviousNumberOfEntries Then $tChanged = "changed"
	EndIf
	If $aNumberOfEntries < 1 Then $aNumberOfEntries = 1
	If $aNumberOfEntries > 100 Then $aNumberOfEntries = 100
;~ 	If $aIntervalFTP < 5 Then $aIntervalFTP = 5
;~ 	If $aIntervalFTP > 86400 Then $aIntervalFTP = 86400
;~ 	If $aIntervalSave < 5 Then $aIntervalSave = 5
;~ 	If $aIntervalSave > 86400 Then $aIntervalSave = 86400
	If $aLogLevel < 1 Then $aLogLevel = 1
	If $aLogLevel > 3 Then $aLogLevel = 3
;~ 	If $aScanForChangesSec < 0 Then $aScanForChangesSec = 0
;~ 	If $aScanForChangesSec > 600 Then $aScanForChangesSec = 600
	DirCreate($aFolderLog)
	DirCreate($aFolderImage)
	Global $cIntervalFTP[$aNumberOfEntries]
	Global $cIntervalSave[$aNumberOfEntries]
	Global $cIntervalGetImage[$aNumberOfEntries]
	Global $tGetImageInterval[$aNumberOfEntries]
	Global $cTimerGetImage[$aNumberOfEntries]
	Global $cTimerRestartSave[$aNumberOfEntries]
	Global $cTimerRestartFTP[$aNumberOfEntries]
	Global $xNotes[$aNumberOfEntries]
	Global $xIntervalFTP[$aNumberOfEntries]
	Global $xIntervalSave[$aNumberOfEntries]
	Global $xURL[$aNumberOfEntries]
	Global $xFileNameOriginal[$aNumberOfEntries]
	Global $xFileNameResized[$aNumberOfEntries]
	Global $xUserID[$aNumberOfEntries]
	Global $xPwd[$aNumberOfEntries]
	Global $xFTPURL[$aNumberOfEntries]
	Global $xFTPFolder[$aNumberOfEntries]
	Global $xResizeImageSize[$aNumberOfEntries]
	Global $xSaveType[$aNumberOfEntries]
	Global $xFTPUploadType[$aNumberOfEntries]
	Global $xSaveFileNumberYN[$aNumberOfEntries]
	For $x = 0 To ($aNumberOfEntries - 1)
		$xNotes[$x] = IniRead($aIniFile, " --------------- CAMERA " & $x + 1 & " --------------- ", "Note (optional for comment in this config file) ###", "")
		$xIntervalFTP[$x] = IniRead($aIniFile, " --------------- CAMERA " & $x + 1 & " --------------- ", "Number of seconds between FTP uploads (5-86400) ###", "60")
		$xIntervalSave[$x] = IniRead($aIniFile, " --------------- CAMERA " & $x + 1 & " --------------- ", "Number of seconds between archive images (5-86400) ###", "60")
		$xURL[$x] = IniRead($aIniFile, " --------------- CAMERA " & $x + 1 & " --------------- ", "Image URL from camera (ex. http://192.168.1.5/snap.jpeg) ###", "http://192.168.1.5/snap.jpeg")
		$xFileNameOriginal[$x] = IniRead($aIniFile, " --------------- CAMERA " & $x + 1 & " --------------- ", "Full-size image filename (ex. camerawest.jpg) ###", "camera" & $x + 1 & ".jpg")
		$xFileNameResized[$x] = IniRead($aIniFile, " --------------- CAMERA " & $x + 1 & " --------------- ", "Resized image filename (leave blank if not resizing image) ###", "")
		$xFTPURL[$x] = IniRead($aIniFile, " --------------- CAMERA " & $x + 1 & " --------------- ", "FTP URL (for Wunderground, use webcam.wunderground.com) ###", "webcam.wunderground.com")
		$xFTPFolder[$x] = IniRead($aIniFile, " --------------- CAMERA " & $x + 1 & " --------------- ", "FTP folder (for Wunderground, leave blank) ###", "")
		$xUserID[$x] = IniRead($aIniFile, " --------------- CAMERA " & $x + 1 & " --------------- ", "FTP userName (for Wunderground, use camera ID, ex. WU_7883133CAM3) ###", "")
		$xPwd[$x] = IniRead($aIniFile, " --------------- CAMERA " & $x + 1 & " --------------- ", "FTP password (for Wunderground, use key, ex. QqOQqKRy) ###", "")
		$xResizeImageSize[$x] = IniRead($aIniFile, " --------------- CAMERA " & $x + 1 & " --------------- ", "Resize image size: Leave blank to disable (ex. 1280x720) ###", "")
		$xSaveType[$x] = IniRead($aIniFile, " --------------- CAMERA " & $x + 1 & " --------------- ", "Archive image: (F)ull-size (R)esized (B)oth (N)one (FRBN)###", "B")
		$xFTPUploadType[$x] = IniRead($aIniFile, " --------------- CAMERA " & $x + 1 & " --------------- ", "FTP Upload image: (F)ull-size (R)esized (B)oth (N)one (FRBN)###", "R")
		$xSaveFileNumberYN[$x] = IniRead($aIniFile, " --------------- CAMERA " & $x + 1 & " --------------- ", "Filename for archived image(s): Use sequential numbers (00000-99999) instead of date? (yes/no) ###", "no")
		If $xResizeImageSize[$x] <> "" Then
			Local $xImageSplit = StringSplit($xResizeImageSize[$x], "x", 2)
			If StringInStr($xResizeImageSize[$x], "x") = 0 Or UBound($xImageSplit) <> 2 Then LogWrite("[Error] Resize image dimension for camera " & $x + 1 & " formated improperly. [" & $xResizeImageSize[$x] & "]")
		EndIf
		If $xIntervalFTP[$x] < 5 Then $xIntervalFTP[$x] = 5
		If $xIntervalFTP[$x] > 86400 Then $xIntervalFTP[$x] = 86400
		If $xIntervalSave[$x] < 5 Then $xIntervalSave[$x] = 5
		If $xIntervalSave[$x] > 86400 Then $xIntervalSave[$x] = 86400
	Next
	Return $tChanged
EndFunc   ;==>ReadIni
Func WriteINI()
	FileDelete($aIniFile)
	IniWrite($aIniFile, " --------------- " & StringUpper($aUtilName) & " --------------- ", "Number of cameras/files to manage (1-100) ###", $aNumberOfEntries)
	FileWriteLine($aIniFile, "(Changes to the number above will require restarting the program so that it can add or remove entries)")
	FileWriteLine($aIniFile, "")
;~ 	IniWrite($aIniFile, " --------------- " & StringUpper($aUtilName) & " OPTIONS --------------- ", "Number of seconds between FTP uploads (5-86400) ###", $aIntervalFTP)
;~ 	IniWrite($aIniFile, " --------------- " & StringUpper($aUtilName) & " OPTIONS --------------- ", "Number of seconds between archive images (5-86400) ###", $aIntervalSave)
	IniWrite($aIniFile, " --------------- " & StringUpper($aUtilName) & " OPTIONS --------------- ", "Log folder ###", $aFolderLog)
	IniWrite($aIniFile, " --------------- " & StringUpper($aUtilName) & " OPTIONS --------------- ", "Images folder ###", $aFolderImage)
	IniWrite($aIniFile, " --------------- " & StringUpper($aUtilName) & " OPTIONS --------------- ", "Log Level 1-All, 2-Fails, 3-None (1-3) ###", $aLogLevel)
;~ 	IniWrite($aIniFile, " --------------- " & StringUpper($aUtilName) & " OPTIONS --------------- ", "Scan for changes in number of cameras every _ seconds (0 to disable) (0-600) ###", $aScanForChangesSec)
	IniWrite($aIniFile, " --------------- " & StringUpper($aUtilName) & " OPTIONS --------------- ", "Check for updates at program start? (yes/no) ###", $aUtilCheckForUpdateYN)
	IniWrite($aIniFile, " --------------- " & StringUpper($aUtilName) & " OPTIONS --------------- ", "System Use: Previous number of entries ###", $aNumberOfEntries)
	For $x = 0 To ($aNumberOfEntries - 1)
		FileWriteLine($aIniFile, "")
		IniWrite($aIniFile, " --------------- CAMERA " & $x + 1 & " --------------- ", "Note (optional for comment in this config file) ###", $xNotes[$x])
		IniWrite($aIniFile, " --------------- CAMERA " & $x + 1 & " --------------- ", "Number of seconds between FTP uploads (5-86400) ###", $xIntervalFTP[$x])
		IniWrite($aIniFile, " --------------- CAMERA " & $x + 1 & " --------------- ", "Number of seconds between archive images (5-86400) ###", $xIntervalSave[$x])
		IniWrite($aIniFile, " --------------- CAMERA " & $x + 1 & " --------------- ", "Image URL from camera (ex. http://192.168.1.5/snap.jpeg) ###", $xURL[$x])
		IniWrite($aIniFile, " --------------- CAMERA " & $x + 1 & " --------------- ", "Full-size image filename (ex. camerawest.jpg) ###", $xFileNameOriginal[$x])
		IniWrite($aIniFile, " --------------- CAMERA " & $x + 1 & " --------------- ", "Resized image filename (leave blank if not resizing image) ###", $xFileNameResized[$x])
		IniWrite($aIniFile, " --------------- CAMERA " & $x + 1 & " --------------- ", "FTP URL (for Wunderground, use webcam.wunderground.com) ###", $xFTPURL[$x])
		IniWrite($aIniFile, " --------------- CAMERA " & $x + 1 & " --------------- ", "FTP folder (for Wunderground, leave blank) ###", $xFTPFolder[$x])
		IniWrite($aIniFile, " --------------- CAMERA " & $x + 1 & " --------------- ", "FTP userName (for Wunderground, use camera ID, ex. WU_7883133CAM3) ###", $xUserID[$x])
		IniWrite($aIniFile, " --------------- CAMERA " & $x + 1 & " --------------- ", "FTP password (for Wunderground, use key, ex. QqOQqKRy) ###", $xPwd[$x])
		IniWrite($aIniFile, " --------------- CAMERA " & $x + 1 & " --------------- ", "Resize image size: Leave blank to disable (ex. 1280x720) ###", $xResizeImageSize[$x])
		IniWrite($aIniFile, " --------------- CAMERA " & $x + 1 & " --------------- ", "Archive image: (F)ull-size (R)esized (B)oth (N)one (FRBN)###", $xSaveType[$x])
		IniWrite($aIniFile, " --------------- CAMERA " & $x + 1 & " --------------- ", "FTP Upload image: (F)ull-size (R)esized (B)oth (N)one (FRBN)###", $xFTPUploadType[$x])
		IniWrite($aIniFile, " --------------- CAMERA " & $x + 1 & " --------------- ", "Filename for archived image(s): Use sequential numbers (00000-99999) instead of date? (yes/no) ###", $xSaveFileNumberYN[$x])
	Next
EndFunc   ;==>WriteINI
Func FTPFiles($tFile, $tFTP_Folder, $tFTP_URL, $tFTP_UserName, $tFPT_Pwd)
	Local $hFTPOpen = _FTP_Open("website")
	Local $hFTPConn = _FTP_Connect($hFTPOpen, $tFTP_URL, $tFTP_UserName, $tFPT_Pwd)
	Local $hFTPDir = _FTP_DirSetCurrent($hFTPConn, $tFTP_Folder)
	Local $xFileName = _PathSplit($tFile, "", "", "", "")
	Local $tFileName = $xFileName[3] & $xFileName[4]
	_FTP_FilePut($hFTPConn, $tFile, $tFileName)
	Local $tERR = @error
	$tFTPClose = _FTP_Close($hFTPOpen)
	Return $tERR
EndFunc   ;==>FTPFiles
Func LogWrite($Msg, $msgdebug = -1)
	$aLogFile = $aFolderLog & $aUtilName & "_Log_" & @YEAR & "-" & @MON & "-" & @MDAY & ".txt"
	Local $tFileSize = FileGetSize($aLogFile)
	If $tFileSize > 10000000 Then
		FileMove($aLogFile, $aFolderLog & $aUtilName & "_Log_" & @YEAR & "-" & @MON & "-" & @MDAY & "-Part1.txt")
		FileWriteLine($aLogFile, _NowCalc() & " Log File Split.  First file:" & $aFolderLog & $aUtilName & "_Log_" & @YEAR & "-" & @MON & "-" & @MDAY & "-Part1.txt")
	EndIf
	If $tFileSize > 10000000 Then FileWriteLine($aLogFile, _NowCalc() & " Log File Split.  First file:" & $aFolderLog & $aUtilName & "_LogFull_" & @YEAR & "-" & @MON & "-" & @MDAY & "-Part1.txt")
	If $Msg <> "" Then FileWriteLine($aLogFile, _NowCalc() & " " & $Msg)
EndFunc   ;==>LogWrite
Func _ImageResizer($tFileBefore, $tFileAfter, $tWidth = 16, $tHeight = 16) ; By Phoenix125.com
	_GDIPlus_Startup()
	Local $GDIpBmpLarge, $GDIpBmpResized, $GDIbmp
	$GDIpBmpLarge = _GDIPlus_ImageLoadFromFile($tFileBefore)
	$GDIpBmpResized = _GDIPlus_ImageResize($GDIpBmpLarge, $tWidth, $tHeight)
	_GDIPlus_ImageSaveToFile($GDIpBmpResized, $tFileAfter)
	_GDIPlus_ImageDispose($GDIpBmpLarge)
	_GDIPlus_ImageDispose($GDIpBmpResized)
	_GDIPlus_Shutdown()
EndFunc   ;==>_ImageResizer
Func _RestartProgram() ; By UP_NORTH
	If @Compiled = 1 Then
		Run(FileGetShortName(@ScriptFullPath))
	Else
		Run(FileGetShortName(@AutoItExe) & " " & FileGetShortName(@ScriptFullPath))
	EndIf
	Exit
EndFunc   ;==>_RestartProgram
Func _Splash($tTxt, $tTime = 0, $tWidth = 400, $tHeight = 125)
	Local $tPID = SplashTextOn($aUtilName, $tTxt, $tWidth, $tHeight, -1, -1, $DLG_MOVEABLE, "")
	If $tTime > 0 Then
		Sleep($tTime)
		SplashOff()
	EndIf
	Return $tPID
EndFunc   ;==>_Splash
Func ReadCFG()
	Local $iIniFail = 0
	Local $iniCheck = ""
	Local $aChar[3]
	For $i = 1 To 13
		$aChar[0] = Chr(Random(97, 122, 1)) ;a-z
		$aChar[1] = Chr(Random(48, 57, 1)) ;0-9
		$iniCheck &= $aChar[Random(0, 1, 1)]
	Next
	Global $aCFGLastVersion = IniRead($aUtilCFGFile, "CFG", "aCFGLastVersion", $iniCheck)
	Global $aCFGLastVerNumber = IniRead($aUtilCFGFile, "CFG", "aCFGLastVerNumber", $iniCheck)
	If $iniCheck = $aCFGLastVersion Then
		$aCFGLastVersion = $aUtilVersion
		IniWrite($aUtilCFGFile, "CFG", "aCFGLastVersion", $aCFGLastVersion)
	EndIf
	If $iniCheck = $aCFGLastVerNumber Then
		$aCFGLastVerNumber = $aUtilVerNumber
		IniWrite($aUtilCFGFile, "CFG", "aCFGLastVerNumber", $aCFGLastVerNumber)
	EndIf
	IniWrite($aUtilCFGFile, "CFG", "aCFGLastVersion", $aUtilVersion)
	IniWrite($aUtilCFGFile, "CFG", "aCFGLastVerNumber", $aUtilVerNumber)
EndFunc   ;==>ReadCFG

Func TrayAbout()
	MsgBox($MB_SYSTEMMODAL, $aUtilName, $aUtilName & @CRLF & "Version: " & $aUtilVersion & @CRLF & @CRLF & "Install Path: " & @ScriptDir & @CRLF & @CRLF & "Discord: http://discord.gg/EU7pzPs" & @CRLF & "Website: http://www.phoenix125.com", 15)
EndFunc   ;==>TrayAbout
Func TrayUpdateUtilCheck()
	UtilUpdate($aUtilUpdateLinkVer, $aUtilUpdateLinkDL, $aUtilVersion, $aUtilName, 0, "show")
	SplashOff()
EndFunc   ;==>TrayUpdateUtilCheck
Func TrayRestartUtil()
	_RestartUtil()
EndFunc   ;==>TrayRestartUtil
Func TrayOpenReadMe()
	ShellExecute($aUtilReadMeLink)
EndFunc   ;==>TrayOpenReadMe
Func TrayOpenLog()
	ShellExecute($aFolderLog & $aUtilName & "_Log_" & @YEAR & "-" & @MON & "-" & @MDAY & ".txt")
EndFunc   ;==>TrayOpenLog
Func TrayOpenConfig()
	ShellExecute($aIniFile)
EndFunc   ;==>TrayOpenConfig
Func TrayOpenImageFolder()
	ShellExecute($aFolderImage)
EndFunc   ;==>TrayOpenImageFolder
Func TrayUpdatePause()
	MsgBox($MB_OK, $aUtilName, $aUtilName & " Paused.  Press OK to resume.")
EndFunc   ;==>TrayUpdatePause
Func TrayExit()
	LogWrite("----- ===== " & $aUtilName & " exited ===== -----")
	MsgBox(0, $aUtilName, "For more programs, visit phoenix125.com" & @CRLF & "Thank you!", 10)
	Exit
EndFunc   ;==>TrayExit
Func CreateStartupBatchFile()
	Global $aServerBatchFile = @ScriptDir & "\_start_" & $aUtilName & ".bat"
	If @AutoItX64 = 1 Then
		Global $aUtilExe = $aUtilName & "_" & $aUtilVersion & "_64-bit(x64).exe"
	Else
		Global $aUtilExe = $aUtilName & "_" & $aUtilVersion & ".exe"
	EndIf
	FileDelete($aServerBatchFile)
	FileWrite($aServerBatchFile, '@echo off' & @CRLF & 'START "' & $aUtilName & '" "' & @ScriptDir & '\' & $aUtilExe & '"' & @CRLF & "EXIT")
EndFunc   ;==>CreateStartupBatchFile
Func _RestartUtil($fQuickRebootTF = True, $tAdmin = False) ; Thanks Yashied!  https://www.autoitscript.com/forum/topic/111215-restart-udf/
	Local $Pid
	Local $xArray[13]
	$xArray[0] = '@echo off'
	$xArray[1] = 'echo --------------------------------------------'
	$xArray[2] = 'echo  Waiting 5 seconds for shutdown to complete'
	$xArray[3] = 'echo --------------------------------------------'
	$xArray[4] = 'timeout 5'
	$xArray[5] = 'start "Starting ' & $aUtilName & '" "' & $aServerBatchFile & '"'
	$xArray[6] = 'echo --------------------------------------------'
	$xArray[7] = 'echo  ' & $aUtilName & ' started . . .'
	$xArray[8] = 'echo --------------------------------------------'
	$xArray[9] = 'timeout 3'
	$xArray[10] = 'exit'
	Local $tBatFile = $aFolderTemp & $aUtilName & "_Delay_Restart.bat"
	FileDelete($tBatFile)
	_FileWriteFromArray($tBatFile, $xArray)
	If @Compiled Then
		If $tAdmin Then
			ShellExecute($tBatFile, "", "", "runas")
		Else
			$Pid = Run($tBatFile, "", @SW_HIDE)
		EndIf
	Else
		If $tAdmin Then
			_Splash("Run as administrator selected", 2000)
			ShellExecute(@AutoItExe & ' "' & @ScriptFullPath & '" ' & $CmdLineRaw, "", "", "runas")
		Else
			$Pid = Run(@AutoItExe & ' "' & @ScriptFullPath & '" ' & $CmdLineRaw, @ScriptDir, Default, 1)
		EndIf
		If @error Then
			Return SetError(@error, 0, 0)
		EndIf
		StdinWrite($Pid, @AutoItPID)
	EndIf
	Sleep(50)
	_ExitUtil()
EndFunc   ;==>_RestartUtil
Func _ExitUtil()
	Exit
EndFunc   ;==>_ExitUtil
Func _LettersOnly($tTxt)
	Return StringRegExpReplace($tTxt, "[^a-z]", "")
EndFunc   ;==>_LettersOnly
Func UtilUpdate($tLink, $tDL, $tUtil, $tUtilName, $tSplash = 0, $tUpdate = "show", $tShowStartupTextYN = "no")
	$tUtilUpdateAvailableTF = False
	If $tUpdate = "show" Then
		If $tShowStartupTextYN = "yes" Then
			Local $tTxt = $aStartText & "Checking for updates."
		Else
			Local $tTxt = "Checking for updates."
		EndIf
		If $tSplash > 0 Then
			ControlSetText($tSplash, "", "Static1", $tTxt)
		Else
			$tSplash = _Splash($tTxt)
		EndIf
	EndIf
	Local $tVer[2]
	Local $sFilePath = $aFolderTemp & $aUtilName & "_latest_ver.tmp"
	$iGet = _InetGetMulti(20, $sFilePath, $tLink)
	If $iGet = "Error" Then
		LogWrite(" [Util] Update check failed to download latest version: " & $tLink)
		If $tUpdate = "show" Then
			If $tShowStartupTextYN = "yes" Then
				Local $tTxt = $aStartText & "Update check failed." & @CRLF & "Please try again later."
			Else
				Local $tTxt = "Update check failed." & @CRLF & "Please try again later."
			EndIf
			If $tSplash > 0 Then
				ControlSetText($tSplash, "", "Static1", $tTxt)
			Else
				_Splash($tTxt)
			EndIf
			Sleep(4000)
		EndIf
	Else
		$tVer = StringSplit($iGet, "^", 2)
		If UBound($tVer) < 2 Then Return False
		Local $tTxt1 = ReplaceCRLF(ReplaceCRwithCRLF($tVer[1]))
		If $tVer[0] = $tUtil Then
			$tUtilUpdateAvailableTF = False
			LogWrite(" [Util] " & $tUtilName & " up to date. Version: " & $tVer[0], " [Util] " & $tUtilName & " up to date. Version : " & $tVer[0] & ", Notes : " & $tTxt1)
			If FileExists($aUtilUpdateFile) Then FileDelete($aUtilUpdateFile)
			If $tUpdate = "show" Then
				If $tShowStartupTextYN = "yes" Then
					Local $tTxt = $aStartText & "No update available." & @CRLF & "Installed version: " & $tUtil & @CRLF & "Latest version: " & $tVer[0]
				Else
					Local $tTxt = "No update available." & @CRLF & @CRLF & "Installed version: " & $tUtil & @CRLF & "Latest version: " & $tVer[0]
				EndIf
				If $tSplash > 0 Then
					ControlSetText($tSplash, "", "Static1", $tTxt)
				Else
					_Splash($tTxt)
				EndIf
				Sleep(2000)
			EndIf
		Else
			$tUtilUpdateAvailableTF = True
			LogWrite("[Update] !!! New " & $aUtilName & " update available. Installed version: " & $tUtil & ", Latest version: " & $tVer[0], "[Update] New " & $aUtilName & _
					" update available. Installed version: " & $tUtil & ", Latest version: " & $tVer[0] & ", Notes: " & $tTxt1)
			FileWrite($aUtilUpdateFile, _NowCalc() & " [Util] New " & $aUtilName & " update available. Installed version: " & $tUtil & ", Latest version: " & $tVer[0] & ", Notes: " & $tTxt1)
			If ($tUpdate = "show") Or ($tUpdate = "auto") Then
				SplashOff()
				If ($tUpdate = "Auto") And ($aUpdateAutoUtil = "yes") Then
					Local $tMB = 6
				Else
					Local $tMB = MsgBox($MB_YESNOCANCEL, $aUtilName, "New " & $aUtilName & " update available. " & @CRLF & "Installed version: " & $tUtil & @CRLF & "Latest version: " & $tVer[0] & @CRLF & @CRLF & _
							"Notes: " & @CRLF & $tVer[1] & @CRLF & @CRLF & _
							"Click (YES) to download update to " & @CRLF & @ScriptDir & @CRLF & _
							"Click (NO) to stop checking for updates." & @CRLF & _
							"Click (CANCEL) to skip this update check.", 15)
				EndIf
				If $tMB = 6 Then
					_Splash(" Downloading latest version of " & @CRLF & $tUtilName)
					Local $tZIP = @ScriptDir & "\" & $tUtilName & "_" & $tVer[0] & ".zip"
					If FileExists($tZIP) Then
						FileDelete($tZIP)
					EndIf
					If FileExists($tUtilName & "_" & $tVer[0] & ".exe") Then
						FileDelete($tUtilName & "_" & $tVer[0] & ".exe")
					EndIf
					If FileExists($tUtilName & "_" & $tVer[0] & "_64-bit(x64).exe") Then
						FileDelete($tUtilName & "_" & $tVer[0] & "_64-bit(x64).exe")
					EndIf
					If FileExists(@ScriptDir & "\readme.txt") Then
						FileDelete(@ScriptDir & "\readme.txt")
					EndIf
					InetGet($tDL, $tZIP, 1)
					_ExtractZipAll($tZIP, @ScriptDir)
					If Not FileExists(@ScriptDir & "\" & $tUtilName & "_" & $tVer[0] & ".exe") Then
						LogWrite("[Update] ERROR! " & $tUtilName & ".exe download failed.")
						SplashOff()
						$tMB = MsgBox($MB_OKCANCEL, $aUtilName, "Utility update download failed . . . " & @CRLF & "Go to """ & $tLink & """ to download latest version." & @CRLF & @CRLF & "Click (OK), (CANCEL), or wait 60 seconds, to resume current version.", 60)
					Else
						SplashOff()
						If ($tUpdate = "Auto") And ($aUpdateAutoUtil = "yes") Then
							$tMB = MsgBox($MB_OKCANCEL, $aUtilName, "Auto utility update download complete. . . " & @CRLF & @CRLF & "Click (OK) to run new version or wait 60 seconds (servers will remain running) OR" & @CRLF & "Click (CANCEL) to resume current version.", 60)
							If $tMB = 1 Then     ; OK

							ElseIf $tMB = -1 Then
								$tMB = 1     ; OK
							ElseIf $tMB = 2 Then     ; CANCEL

							EndIf
						Else
							$tMB = MsgBox($MB_OKCANCEL, $aUtilName, "Utility update download complete. . . " & @CRLF & @CRLF & "Click (OK) to run new version (servers will remain running) OR" & @CRLF & "Click (CANCEL), or wait 15 seconds, to resume current version.", 15)
						EndIf
						If $tMB = 1 Then
							LogWrite("[Update] Update download complete. Shutting down current version and starting new version. Initiated by User or Auto Update.")
							Local $xArray[13]
							$xArray[0] = '@echo off'
							$xArray[1] = 'echo --------------------------------------------'
							$xArray[2] = 'echo  Waiting 5 seconds for shutdown to complete'
							$xArray[3] = 'echo --------------------------------------------'
							$xArray[4] = 'timeout 5'
							If @AutoItX64 = 1 Then
								$xArray[5] = 'start "Starting ' & $aUtilName & '" "' & @ScriptDir & "\" & $tUtilName & "_" & $tVer[0] & "_64-bit(x64).exe" & '"'
							Else
								$xArray[5] = 'start "Starting ' & $aUtilName & '" "' & @ScriptDir & "\" & $tUtilName & "_" & $tVer[0] & ".exe" & '"'
							EndIf
							$xArray[6] = 'echo --------------------------------------------'
							$xArray[7] = 'echo  ' & $aUtilName & ' started . . .'
							$xArray[8] = 'echo --------------------------------------------'
							$xArray[9] = 'timeout 3'
							$xArray[10] = 'exit'
							Local $tBatFile = $aFolderTemp & $aUtilName & "_Delay_Restart.bat"
							FileDelete($tBatFile)
							_FileWriteFromArray($tBatFile, $xArray)
							If FileExists($tBatFile) Then
								Run($tBatFile)
							Else
								Run(@ScriptDir & "\" & $tUtilName & "_" & $tVer[0] & ".exe")
							EndIf
							Exit
						Else
							LogWrite("[Update] Update download complete. Per user request, continuing to run current version. Resuming utility . . .")
							_Splash("Update check canceled by user." & @CRLF & "Resuming utility . . .", 2000)
						EndIf
					EndIf
				ElseIf $tMB = 7 Then
					$aUtilCheckForUpdateYN = "no"
					IniWrite($aIniFile, " --------------- " & StringUpper($aUtilName) & " OPTIONS --------------- ", "Check for updates at program start? (yes/no) ###", $aUtilCheckForUpdateYN)
					LogWrite("[Update] " & "Update check at startup disabled. To enable, change [Check for updates at program start? (yes/no) ###=yes] in the config.")
					_Splash("Update check at startup disabled." & @CRLF & "To enable update check, change" & @CRLF & "[Check for updates at program start? (yes/no) ###=yes]" & @CRLF & "in the config.", 5000, 500)
				ElseIf $tMB = 2 Then
					LogWrite("[Update] Update check canceled by user. Resuming utility . . .")
					_Splash("Update check canceled by user." & @CRLF & "Resuming utility . . .", 2000)
				EndIf
			EndIf
		EndIf
	EndIf
	FileDelete($sFilePath)
	Return $tUtilUpdateAvailableTF
EndFunc   ;==>UtilUpdate
Func _InetGetMulti($tCnt, $tFile, $tLink1, $tLink2 = "0")
	FileDelete($tFile)
	Local $i = 0
	Local $tTmp1 = InetGet($tLink1, $tFile, $INET_FORCERELOAD, $INET_DOWNLOADBACKGROUND)
	Do
		Sleep(100)
		$i += 1
	Until InetGetInfo($tTmp1, $INET_DOWNLOADCOMPLETE) Or $i = $tCnt
	InetClose($tTmp1)
	If $i = $tCnt And $tLink2 <> "0" Then
		$tTmp2 = InetGet($tLink2, $tFile, $INET_FORCERELOAD, $INET_DOWNLOADBACKGROUND)
		Do
			Sleep(100)
			$i += 1
		Until InetGetInfo($tTmp2, $INET_DOWNLOADCOMPLETE) Or $i = $tCnt
		InetClose($tTmp2)
	EndIf
	Local $hFileOpen = FileOpen($tFile, 0)
	Local $hFileRead = FileRead($hFileOpen, 100000000)
	If $hFileOpen = -1 Then
		InetClose($tTmp1)
		Sleep(200)
		FileClose($hFileOpen)
		Local $hFileRead = _INetGetSource($tLink1)
		If @error Then
			If $tLink2 <> "0" Then
				$hFileRead = _INetGetSource($tLink2)
				If @error Then
					Return "Error"     ; Error
				Else
					FileClose($hFileOpen)
					FileDelete($tFile)
					FileWrite($tFile, $hFileRead)
				EndIf
			Else
				Return True     ; Error
			EndIf
		Else
			FileClose($hFileOpen)
			FileDelete($tFile)
			FileWrite($tFile, $hFileRead)
		EndIf
	Else
		FileClose($hFileOpen)
	EndIf
	Return $hFileRead     ; No error
EndFunc   ;==>_InetGetMulti
Func ReplaceCRLF($tMsg0)
	Return StringReplace($tMsg0, @CRLF, "|")
EndFunc   ;==>ReplaceCRLF
Func ReplaceCRwithCRLF($sString)     ; Initial Regular expression by Melba23 with a new suggestion by Ascend4nt and modified By guinness.
	Return StringRegExpReplace($sString, '(*BSR_ANYCRLF)\R', @CRLF)     ; Idea by Ascend4nt
EndFunc   ;==>ReplaceCRwithCRLF
Func _ExtractZipAll($sZipFile, $sDestinationFolder, $sFolderStructure = "")
	Local $i
	Do
		$i += 1
		$sTempZipFolder = @TempDir & "\Temporary Directory " & $i & " for " & StringRegExpReplace($sZipFile, ".*\\", "")
	Until Not FileExists($sTempZipFolder)     ; this folder will be created during extraction
	Local $oShell = ObjCreate("Shell.Application")
	If Not IsObj($oShell) Then
		Return SetError(1, 0, 0)     ; highly unlikely but could happen
	EndIf
	Local $oDestinationFolder = $oShell.NameSpace($sDestinationFolder)
	If Not IsObj($oDestinationFolder) Then
		DirCreate($sDestinationFolder)
	EndIf
	Local $oOriginFolder = $oShell.NameSpace($sZipFile & "\" & $sFolderStructure)     ; FolderStructure is overstatement because of the available depth
	If Not IsObj($oOriginFolder) Then
		Return SetError(3, 0, 0)     ; unavailable location
	EndIf
	Local $oOriginFile = $oOriginFolder.Items()     ;get all items
	If Not IsObj($oOriginFile) Then
		Return SetError(4, 0, 0)     ; no such file in ZIP file
	EndIf
	$oDestinationFolder.CopyHere($oOriginFile, 20)     ; 20 means 4 and 16, replaces files if asked
	DirRemove($sTempZipFolder, 1)     ; clean temp dir
	Return 1     ; All OK!
EndFunc   ;==>_ExtractZipAll

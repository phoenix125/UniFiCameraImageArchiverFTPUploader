#include <Array.au3>
#include <ButtonConstants.au3>
#include <Date.au3>
#include <EditConstants.au3>
#include <File.au3>
#include <FTPEx.au3>
#include <GDIPlus.au3>
#include <GUIConstantsEx.au3>
#include <Inet.au3>
#include <InetConstants.au3>
#include <MsgBoxConstants.au3>
#include <StaticConstants.au3>
#include <WinAPIHObj.au3>
#include <WindowsConstants.au3>

#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Resources\phoenixtray.ico
#AutoIt3Wrapper_Outfile=Builds\UniFiCameraImageArchiverFTPUploader_v1.2.exe
#AutoIt3Wrapper_Res_Comment=UniFi Camera Image Archiver & FTP Uploader by Phoenix125.com
#AutoIt3Wrapper_Res_Description=UniFi Camera Image Archiver & FTP Uploader
#AutoIt3Wrapper_Res_Fileversion=1.2
#AutoIt3Wrapper_Res_ProductName=UniFi Camera Image Archiver & FTP Uploader
#AutoIt3Wrapper_Res_ProductVersion=1.2
#AutoIt3Wrapper_Res_CompanyName=http://www.Phoenix125.com
#AutoIt3Wrapper_Res_LegalCopyright=http://www.Phoenix125.com
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_Run_AU3Check=n
#AutoIt3Wrapper_Run_Tidy=y
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/mo
#AutoIt3Wrapper_Res_Icon_Add=Resources\discord.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\info.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\forum.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\manual.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\refresh.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\refreshnotice.ico
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
Global $aUtilName = "UniFiCameraImageArchiverFTPUploader"
Global $aUtilFileName = StringStripWS($aUtilName, 8)
Global $aFolderTemp = @ScriptDir & "\" & $aUtilFileName & "UtilFiles\"
If Not FileExists($aFolderTemp) Then
	Do
		DirCreate($aFolderTemp)
	Until FileExists($aFolderTemp)
EndIf
FileInstall("K:\AutoIT\_MyProgs\UniFiCameraImageArchiverFTPUploader\Resources\phoenixlogo.jpg", $aFolderTemp, 0)
If @Compiled = 0 Then
	Global $aIconFile = @ScriptDir & "\" & $aUtilFileName & "Icons.exe"
Else
	Global $aIconFile = @ScriptFullPath
EndIf
Global $cButtonDefaultBackground = "0xDEDEDE" ; Light Gray
Global $cRedFaded = "0xB89B9B" ; Faded Red
Global $cYellowHighlight = "0xFFFF00"
Global $cGreenFaded = "0xA5B89B"
Global $cBackgroundGray = "0x808080"
Global $cGreenLime = "0x00FF00"

Opt("GUIOnEventMode", 1)
Local $tExit = False
Global $aUtilVersion = "v1.2"
Global $aUtilVer = $aUtilVersion
Global $aUtilVerNumber = 0 ; New number assigned for each config file change. Used to write temp update script so that users are not forced to update config.
Global $aIniFile = @ScriptDir & "\" & $aUtilName & ".ini"
Global $aUtilCFGFile = $aFolderTemp & $aUtilName & "_cfg.ini"
Global $aUtilUpdateLinkVer = "http://www.phoenix125.com/share/" & StringLower($aUtilName) & "/latestver.txt"
Global $aUtilUpdateLinkDL = "http://www.phoenix125.com/share/" & StringLower($aUtilName) & "/" & $aUtilName & ".zip"
Global $aUtilReadMeLink = "http://www.phoenix125.com/share/" & StringLower($aUtilName) & "/ReadMe.pdf"
Global $aUtilUpdateFile = @ScriptDir & "\__UTIL_UPDATE_AVAILABLE___.txt"
Global $aStartText = $aUtilName & " " & $aUtilVersion & " starting . . ." & @CRLF & @CRLF
Global $aSplash = _Splash($aStartText, 0, 475)
Global $aCFGLastVerNumber = IniRead($aUtilCFGFile, "CFG", "aCFGLastVerNumber", $aUtilVerNumber)
Global $aExitGUIG = False
Global $aLastCam = 0
Global $W_ConfigWindow = 999999
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
	_GUI_Config()
	P_HelpClick()
	MsgBox(0, $aUtilName, "Welcome! For help, see ReadMe.pdf.", 10)
ElseIf $tChanged = "changed" Then
	_GUI_Config()
EndIf
ControlSetText($aSplash, "", "Static1", $aStartText & "Checking for updates")
If $aUtilCheckForUpdateYN <> "no" Then
	If IniRead($aUtilCFGFile, "CFG", "aRestartQuickYN", "no") <> "yes" Then UtilUpdate($aUtilUpdateLinkVer, $aUtilUpdateLinkDL, $aUtilVersion, $aUtilName, $aSplash, "show", "yes")
Else
	FileDelete($aUtilUpdateFile)
EndIf
IniWrite($aUtilCFGFile, "CFG", "aRestartQuickYN", "no")
Local $tDiffSave = True
Local $tDiffFTP = True
Local $tDiffGetImage = True
Local $tErrorImageSave = False
Local $xFileName1 = ""
Local $tDiffSec = ""
For $x = 0 To ($aNumberOfEntries - 1)
	$cTimerGetImage[$x] = TimerInit()
	$cTimerRestartSave[$x] = TimerInit()
	$cTimerRestartFTP[$x] = TimerInit()
Next
ControlSetText($aSplash, "", "Static1", $aStartText & "Startup complete.")
SplashOff()
FileDelete($aFolderTemp & $aUtilName & "_Delay_Restart.bat")

Do
	For $xCam = 0 To ($aNumberOfEntries - 1)
		If $xCameraEnableYN[$xCam] = "yes" Then
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
				Local $tImageSize = 0
				Local $sFile = $aFolderImage & "\" & $xFileNameOriginal[$xCam]
				Local $tGet = InetGet($xURL[$xCam], $sFile, $INET_FORCERELOAD)
				Local $tImageSize = FileGetSize($sFile)
				If $tImageSize < 10000 Then
					$tErrorImageSave = True
					If $aLogLevel < 3 Then LogWrite("[ERROR] File failed to download from camera:" & $xURL[$xCam])
				Else
					$tErrorImageSave = False
					If $xResizeImageYN[$xCam] = "yes" Then
						Local $xImageSplit = StringSplit($xResizeImageSize[$xCam], "x", 2)
						Local $tResizeX = Abs($xImageSplit[0])
						Local $tResizeY = Abs($xImageSplit[1])
						_ImageResizer($sFile, $aFolderImage & "\" & $xFileNameResized[$xCam], $tResizeX, $tResizeY)
					EndIf
				EndIf
			EndIf
			If $tDiffSave And $tErrorImageSave = False Then
				$tDiffSave = False
				If StringInStr($xSaveType[$xCam], "B") Or StringInStr($xSaveType[$xCam], "F") Then
					Local $xFileNameSplit = _PathSplit($aFolderImage & "\" & $xFileNameOriginal[$xCam], "", "", "", "")
					If $xSaveFileNumberYN[$xCam] = "no" Then
						$tFileNameSave = $xFileNameSplit[3] & "_" & @YEAR & "-" & @MON & "-" & @MDAY & "_" & @HOUR & @MIN & @SEC & $xFileNameSplit[4]
					Else
						Local $tFileNameNumber = IniRead($aUtilCFGFile, "CFG", "aCFGCam(" & $xCam & ")FileNameNumberF", 0)
						$tFileNameNumber += 1
						Local $tFileNameExt = _AddLeadingZeros($tFileNameNumber, 6)
						$tFileNameSave = _LettersOnly($xFileNameSplit[3]) & "_" & $tFileNameExt & $xFileNameSplit[4]
						IniWrite($aUtilCFGFile, "CFG", "aCFGCam(" & $xCam & ")FileNameNumberF", $tFileNameNumber)
					EndIf
					DirCreate($xSaveFolder[$xCam])
					FileCopy($aFolderImage & "\" & $xFileNameOriginal[$xCam], $xSaveFolder[$xCam] & $tFileNameSave)
				EndIf
				If (StringInStr($xSaveType[$xCam], "B") Or StringInStr($xSaveType[$xCam], "R")) And $xResizeImageYN[$xCam] = "yes" Then
					Local $xFileNameSplit = _PathSplit($aFolderImage & "\" & $xFileNameResized[$xCam], "", "", "", "")
					If $xSaveFileNumberYN[$xCam] = "no" Then
						$tFileNameSave = $xFileNameSplit[3] & "_" & @YEAR & "-" & @MON & "-" & @MDAY & "_" & @HOUR & @MIN & @SEC & $xFileNameSplit[4]
					Else
						Local $tFileNameNumber = IniRead($aUtilCFGFile, "CFG", "aCFGCam(" & $xCam & ")FileNameNumberR", 0)
						$tFileNameNumber += 1
						Local $tFileNameExt = _AddLeadingZeros($tFileNameNumber, 6)
						$tFileNameSave = _LettersOnly($xFileNameSplit[3]) & "_" & $tFileNameExt & $xFileNameSplit[4]
						IniWrite($aUtilCFGFile, "CFG", "aCFGCam(" & $xCam & ")FileNameNumberR", $tFileNameNumber)
					EndIf
					FileCopy($aFolderImage & "\" & $xFileNameResized[$xCam], $xSaveFolder[$xCam] & $tFileNameSave)
				EndIf
			EndIf
			If $tDiffFTP And $tErrorImageSave = False Then
				$tDiffFTP = False
				Local $tTimerUpload = TimerInit()
				If (StringInStr($xFTPUploadType[$xCam], "B") Or StringInStr($xFTPUploadType[$xCam], "F")) Then
					If $xFTPURL[$xCam] <> "" Then
						Local $tError = FTPFiles($aFolderImage & "\" & $xFileNameOriginal[$xCam], $xFTPFolder[$xCam], $xFTPURL[$xCam], $xUserID[$xCam], $xPwd[$xCam])
						$tDiffSec = StringFormat("%.2f", TimerDiff($tTimerUpload) / 1000, 2)
						If $tError = 0 Then
							If $aLogLevel = 1 Then LogWrite("[OK] Code[" & $tError & "] Time[" & $tDiffSec & "s] Upload successful [" & $xFileNameOriginal[$xCam] & "] FTP[" & $xFTPURL[$xCam] & "] UserID[" & $xUserID[$xCam] & "] Pwd[" & $xPwd[$xCam] & "]")
						Else
							If $aLogLevel < 3 Then LogWrite("[ERROR] Code[" & $tError & "] Time[" & $tDiffSec & "s] Upload FAILED. [" & $xFileNameOriginal[$xCam] & "] FTP[" & $xFTPURL[$xCam] & "] UserID[" & $xUserID[$xCam] & "] Pwd[" & $xPwd[$xCam] & "]")
						EndIf
					EndIf
				EndIf
				If (StringInStr($xFTPUploadType[$xCam], "B") Or StringInStr($xFTPUploadType[$xCam], "R")) And $xResizeImageYN[$xCam] = "yes" Then
					If $xFTPURL[$xCam] <> "" Then
						Local $tError = FTPFiles($aFolderImage & "\" & $xFileNameResized[$xCam], $xFTPFolder[$xCam], $xFTPURL[$xCam], $xUserID[$xCam], $xPwd[$xCam])
						$tDiffSec = StringFormat("%.2f", TimerDiff($tTimerUpload) / 1000, 2)
						If $tError = 0 Then
							If $aLogLevel = 1 Then LogWrite("[OK] Code[" & $tError & "] Time[" & $tDiffSec & "s] Upload successful [" & $xFileNameResized[$xCam] & "] FTP[" & $xFTPURL[$xCam] & "] UserID[" & $xUserID[$xCam] & "] Pwd[" & $xPwd[$xCam] & "]")
						Else
							If $aLogLevel < 3 Then LogWrite("[ERROR] Code[" & $tError & "] Time[" & $tDiffSec & "s] Upload FAILED. [" & $xFileNameResized[$xCam] & "] FTP[" & $xFTPURL[$xCam] & "] UserID[" & $xUserID[$xCam] & "] Pwd[" & $xPwd[$xCam] & "]")
						EndIf
					EndIf
				EndIf
			EndIf
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
	Global $aFolderLog = IniRead($aIniFile, " --------------- " & StringUpper($aUtilName) & " OPTIONS --------------- ", "Log folder ###", @ScriptDir & "\Logs\")
	Global $aFolderImage = IniRead($aIniFile, " --------------- " & StringUpper($aUtilName) & " OPTIONS --------------- ", "Images temp folder ###", @ScriptDir & "\Images")
	$aFolderImage = _RemoveTrailingSlash($aFolderImage)
	Global $aLogLevel = IniRead($aIniFile, " --------------- " & StringUpper($aUtilName) & " OPTIONS --------------- ", "Log Level 1-All, 2-Fails, 3-None (1-3) ###", "1")
	Global $aUtilCheckForUpdateYN = IniRead($aIniFile, " --------------- " & StringUpper($aUtilName) & " OPTIONS --------------- ", "Check for updates at program start? (yes/no) ###", "yes")
	Global $aPreviousNumberOfEntries = IniRead($aUtilCFGFile, "CFG", "Previous number of entries ###", $iniCheck)
	If $aNumberOfEntries = $iniCheck Then
		$aNumberOfEntries = 2
		$tChanged = "new"
	Else
		If $aNumberOfEntries <> $aPreviousNumberOfEntries Then $tChanged = "changed"
	EndIf
	If $aNumberOfEntries < 1 Then $aNumberOfEntries = 1
	If $aNumberOfEntries > 100 Then $aNumberOfEntries = 100
	If $aLogLevel < 1 Then $aLogLevel = 1
	If $aLogLevel > 3 Then $aLogLevel = 3
	DirCreate($aFolderLog)
	DirCreate($aFolderImage & "\")
	Global $cIntervalFTP[$aNumberOfEntries]
	Global $cIntervalSave[$aNumberOfEntries]
	Global $cIntervalGetImage[$aNumberOfEntries]
	Global $tGetImageInterval[$aNumberOfEntries]
	Global $cTimerGetImage[$aNumberOfEntries]
	Global $cTimerRestartSave[$aNumberOfEntries]
	Global $cTimerRestartFTP[$aNumberOfEntries]
	Global $xNotes[$aNumberOfEntries]
	Global $xCameraEnableYN[$aNumberOfEntries]
	Global $xIntervalFTP[$aNumberOfEntries]
	Global $xIntervalSave[$aNumberOfEntries]
	Global $xURL[$aNumberOfEntries]
	Global $xFileNameOriginal[$aNumberOfEntries]
	Global $xFileNameResized[$aNumberOfEntries]
	Global $xUserID[$aNumberOfEntries]
	Global $xPwd[$aNumberOfEntries]
	Global $xFTPURL[$aNumberOfEntries]
	Global $xFTPFolder[$aNumberOfEntries]
	Global $xResizeImageYN[$aNumberOfEntries]
	Global $xResizeImageSize[$aNumberOfEntries]
	Global $xSaveType[$aNumberOfEntries]
	Global $xFTPUploadType[$aNumberOfEntries]
	Global $xSaveFileNumberYN[$aNumberOfEntries]
	Global $xSaveFolder[$aNumberOfEntries]
	For $x = 0 To ($aNumberOfEntries - 1)
		$xNotes[$x] = IniRead($aIniFile, " --------------- CAMERA " & $x + 1 & " --------------- ", "Note (optional for comment in this config file) ###", "Camera " & $x + 1)
		$xCameraEnableYN[$x] = IniRead($aIniFile, " --------------- CAMERA " & $x + 1 & " --------------- ", "Camera Enabled (yes/no) ###", "no")
		$xIntervalFTP[$x] = IniRead($aIniFile, " --------------- CAMERA " & $x + 1 & " --------------- ", "Number of seconds between FTP uploads (5-86400) ###", "60")
		$xIntervalSave[$x] = IniRead($aIniFile, " --------------- CAMERA " & $x + 1 & " --------------- ", "Number of seconds between archive images (5-86400) ###", "60")
		$xURL[$x] = IniRead($aIniFile, " --------------- CAMERA " & $x + 1 & " --------------- ", "Image URL from camera (ex. http://192.168.1.5/snap.jpeg) ###", "http://192.168.1.5/snap.jpeg")
		$xFileNameOriginal[$x] = IniRead($aIniFile, " --------------- CAMERA " & $x + 1 & " --------------- ", "Full-size image filename (ex. camerawest.jpg) ###", "Camera" & $x + 1 & "_Full.jpg")
		$xFileNameResized[$x] = IniRead($aIniFile, " --------------- CAMERA " & $x + 1 & " --------------- ", "Resized image filename (leave blank if not resizing image) ###", "Camera" & $x + 1 & "_853x480.jpg")
		$xFTPURL[$x] = IniRead($aIniFile, " --------------- CAMERA " & $x + 1 & " --------------- ", "FTP URL (for Wunderground, use webcam.wunderground.com) ###", "webcam.wunderground.com")
		$xFTPFolder[$x] = IniRead($aIniFile, " --------------- CAMERA " & $x + 1 & " --------------- ", "FTP folder (for Wunderground, leave blank) ###", "")
		$xUserID[$x] = IniRead($aIniFile, " --------------- CAMERA " & $x + 1 & " --------------- ", "FTP userName (for Wunderground, use camera ID, ex. WU_7883133CAM3) ###", "")
		$xPwd[$x] = IniRead($aIniFile, " --------------- CAMERA " & $x + 1 & " --------------- ", "FTP password (for Wunderground, use key, ex. QqOQqKRy) ###", "")
		$xResizeImageYN[$x] = IniRead($aIniFile, " --------------- CAMERA " & $x + 1 & " --------------- ", "Create resize image? (yes/no) ###", "no")
		$xResizeImageSize[$x] = IniRead($aIniFile, " --------------- CAMERA " & $x + 1 & " --------------- ", "Resize image size: (ex. 1280x720) ###", "853x480")
		$xSaveType[$x] = IniRead($aIniFile, " --------------- CAMERA " & $x + 1 & " --------------- ", "Archive image: (F)ull-size (R)esized (B)oth (N)one (FRBN)###", "F")
		$xFTPUploadType[$x] = IniRead($aIniFile, " --------------- CAMERA " & $x + 1 & " --------------- ", "FTP Upload image: (F)ull-size (R)esized (B)oth (N)one (FRBN)###", "N")
		$xSaveFileNumberYN[$x] = IniRead($aIniFile, " --------------- CAMERA " & $x + 1 & " --------------- ", "For archived images filename, use sequential numbers (i.e. 00000-99999) instead of date? (yes/no) ###", "no")
		$xSaveFolder[$x] = IniRead($aIniFile, " --------------- CAMERA " & $x + 1 & " --------------- ", "Save Folder for archived image(s) ###", @ScriptDir & "\Images\")
		$xSaveFolder[$x] = _RemoveTrailingSlash($xSaveFolder[$x]) & "\"
		DirCreate($xSaveFolder[$x])
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
	IniWrite($aIniFile, " --------------- " & StringUpper($aUtilName) & " OPTIONS --------------- ", "Log folder ###", $aFolderLog)
	IniWrite($aIniFile, " --------------- " & StringUpper($aUtilName) & " OPTIONS --------------- ", "Images temp folder ###", $aFolderImage)
	IniWrite($aIniFile, " --------------- " & StringUpper($aUtilName) & " OPTIONS --------------- ", "Log Level 1-All, 2-Fails, 3-None (1-3) ###", $aLogLevel)
	IniWrite($aIniFile, " --------------- " & StringUpper($aUtilName) & " OPTIONS --------------- ", "Check for updates at program start? (yes/no) ###", $aUtilCheckForUpdateYN)
	IniWrite($aUtilCFGFile, "CFG", "Previous number of entries ###", $aNumberOfEntries)
	For $x = 0 To ($aNumberOfEntries - 1)
		FileWriteLine($aIniFile, "")
		IniWrite($aIniFile, " --------------- CAMERA " & $x + 1 & " --------------- ", "Note (optional for comment in this config file) ###", $xNotes[$x])
		IniWrite($aIniFile, " --------------- CAMERA " & $x + 1 & " --------------- ", "Camera Enabled (yes/no) ###", $xCameraEnableYN[$x])
		IniWrite($aIniFile, " --------------- CAMERA " & $x + 1 & " --------------- ", "Number of seconds between FTP uploads (5-86400) ###", $xIntervalFTP[$x])
		IniWrite($aIniFile, " --------------- CAMERA " & $x + 1 & " --------------- ", "Number of seconds between archive images (5-86400) ###", $xIntervalSave[$x])
		IniWrite($aIniFile, " --------------- CAMERA " & $x + 1 & " --------------- ", "Image URL from camera (ex. http://192.168.1.5/snap.jpeg) ###", $xURL[$x])
		IniWrite($aIniFile, " --------------- CAMERA " & $x + 1 & " --------------- ", "Full-size image filename (ex. camerawest.jpg) ###", $xFileNameOriginal[$x])
		IniWrite($aIniFile, " --------------- CAMERA " & $x + 1 & " --------------- ", "Resized image filename (leave blank if not resizing image) ###", $xFileNameResized[$x])
		IniWrite($aIniFile, " --------------- CAMERA " & $x + 1 & " --------------- ", "FTP URL (for Wunderground, use webcam.wunderground.com) ###", $xFTPURL[$x])
		IniWrite($aIniFile, " --------------- CAMERA " & $x + 1 & " --------------- ", "FTP folder (for Wunderground, leave blank) ###", $xFTPFolder[$x])
		IniWrite($aIniFile, " --------------- CAMERA " & $x + 1 & " --------------- ", "FTP userName (for Wunderground, use camera ID, ex. WU_7883133CAM3) ###", $xUserID[$x])
		IniWrite($aIniFile, " --------------- CAMERA " & $x + 1 & " --------------- ", "FTP password (for Wunderground, use key, ex. QqOQqKRy) ###", $xPwd[$x])
		IniWrite($aIniFile, " --------------- CAMERA " & $x + 1 & " --------------- ", "Create resize image? (yes/no) ###", $xResizeImageYN[$x])
		IniWrite($aIniFile, " --------------- CAMERA " & $x + 1 & " --------------- ", "Resize image size: (ex. 1280x720) ###", $xResizeImageSize[$x])
		IniWrite($aIniFile, " --------------- CAMERA " & $x + 1 & " --------------- ", "Archive image: (F)ull-size (R)esized (B)oth (N)one (FRBN)###", $xSaveType[$x])
		IniWrite($aIniFile, " --------------- CAMERA " & $x + 1 & " --------------- ", "FTP Upload image: (F)ull-size (R)esized (B)oth (N)one (FRBN)###", $xFTPUploadType[$x])
		IniWrite($aIniFile, " --------------- CAMERA " & $x + 1 & " --------------- ", "For archived images filename, use sequential numbers (i.e. 00000-99999) instead of date? (yes/no) ###", $xSaveFileNumberYN[$x])
		IniWrite($aIniFile, " --------------- CAMERA " & $x + 1 & " --------------- ", "Save Folder for archived image(s) ###", $xSaveFolder[$x])
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
	_GUI_Config()
EndFunc   ;==>TrayOpenConfig
Func TrayOpenImageFolder()
	ShellExecute($aFolderImage & "\")
EndFunc   ;==>TrayOpenImageFolder
Func TrayUpdatePause()
	MsgBox($MB_OK, $aUtilName, $aUtilName & " Paused.  Press OK to resume.")
EndFunc   ;==>TrayUpdatePause
Func TrayExit()
	If WinExists($W_ConfigWindow) Then GUIDelete($W_ConfigWindow)
	LogWrite("----- ===== " & $aUtilName & " exited ===== -----")
	MsgBox(0, $aUtilName, "Thank you!" & @CRLF & @CRLF & "For more programs, visit phoenix125.com", 15)
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
Func _RemoveTrailingSlash($aString)
	Local $bString = StringRight($aString, 1)
	If $bString = "\" Then $aString = StringTrimRight($aString, 1)
	Return $aString
EndFunc   ;==>_RemoveTrailingSlash
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
Func _GUI_Config()
	If Not WinExists($W_ConfigWindow) Then
		Opt("GUIResizeMode", $GUI_DOCKLEFT + $GUI_DOCKTOP)
		#Region ### START Koda GUI section ### Form=K:\AutoIT\_MyProgs\UniFiCameraImageArchiverFTPUploader\Koda GUIs\UniFiCameraImage_v1.1(b3).kxf
		Local $gBXstart = 58, $gBYstart = 43, $gBGapX = 1, $gBGapY = 1, $gBinaRow = 25, $gBW = 27, $gBH = 25, $gY = -20 ; Baseline Parameters
		For $i = 0 To ($aNumberOfEntries - 1)
			If Mod($i + 1, $gBinaRow) = 0 And $i < ($aNumberOfEntries - 1) Then $gY += $gBH + $gBGapY ; Lowers tab window by number of grid tab rows.
		Next
		Global $tY = $gY
		$W_ConfigWindow = GUICreate("UniFi Camera Image Archiver FTP Uploader", 900, 716 + $tY, -1, -1, BitOR($GUI_SS_DEFAULT_GUI, $WS_SIZEBOX, $WS_THICKFRAME))
		GUISetIcon($aIconFile, 99)
		GUISetBkColor($cBackgroundGray)
		_DisableCloseButton($W_ConfigWindow)
		GUISetOnEvent($GUI_EVENT_CLOSE, "W_ConfigWindowClose")
		GUISetOnEvent($GUI_EVENT_MINIMIZE, "W_ConfigWindowMinimize")
		GUISetOnEvent($GUI_EVENT_MAXIMIZE, "W_ConfigWindowMaximize")
		GUISetOnEvent($GUI_EVENT_RESTORE, "W_ConfigWindowRestore")
		Global $G_B_CameraButtons[$aNumberOfEntries]
		Local $gBXnow = $gBXstart, $gBYnow = $gBYstart
		If $aNumberOfEntries < 26 Then
			Local $gBYLabel = $gBYstart - 5
		Else
			Local $gBYLabel = $gBYstart
		EndIf
		Global $G_L_CameraSelect = GUICtrlCreateLabel("Select", 12, $gBYLabel, 44, 17)
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		GUICtrlSetColor(-1, $cGreenLime)
		GUICtrlSetOnEvent(-1, "F_L_UploadFreqCommentClick")
		Global $G_L_CameraSelect = GUICtrlCreateLabel("Camera:", 12, $gBYLabel + 17, 44, 17)
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		GUICtrlSetColor(-1, $cGreenLime)
		GUICtrlSetOnEvent(-1, "F_L_UploadFreqCommentClick")
		For $i = 0 To ($aNumberOfEntries - 1)
			$G_B_CameraButtons[$i] = GUICtrlCreateButton($i + 1, $gBXnow, $gBYnow, $gBW, $gBH)
			GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
			GUICtrlSetOnEvent(-1, "G_B_CameraClicked")
			If Mod($i + 1, $gBinaRow) = 0 Then
				$gBYnow += $gBH + $gBGapY     ; Lowers tab window by number of grid tab rows.
				$gBXnow = $gBXstart
			Else
				$gBXnow += $gBW + $gBGapX
			EndIf
		Next
		Global $B_AddCamera = GUICtrlCreateButton("+1 Cam", 802, $gBYstart, $gBW + 20, $gBH)
		GUICtrlSetBkColor(-1, $cYellowHighlight)
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		GUICtrlSetTip(-1, "Add a camera.  Note: Program will be restarted.")
		GUICtrlSetOnEvent(-1, "B_AddCameraClick")
		Global $B_RemoveCamera = GUICtrlCreateButton("-1 Cam", 802 + $gBW + 20 + $gBGapX, $gBYstart, $gBW + 20, $gBH)
		GUICtrlSetBkColor(-1, $cYellowHighlight)
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		GUICtrlSetTip(-1, "Remove the LAST camera.  Note: Program will be restarted.")
		GUICtrlSetOnEvent(-1, "B_RemoveCamera")
		Global $G_ConfigWindow = GUICtrlCreateGroup("", 4, 85 + $tY, 891, 626)
		GUICtrlSetFont(-1, 12, 800, 0, "MS Sans Serif")
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		Global $G_W_B_Close = GUICtrlCreateButton("X", 865, 5, 27, 25)
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		GUICtrlSetTip(-1, "Close config window.  Program will continue to run.")
		GUICtrlSetBkColor(-1, $cRedFaded)
		GUICtrlSetOnEvent(-1, "B_Close")
		Global $G_FTP = GUICtrlCreateGroup("FTP", 19, 407 + $tY, 859, 165)
		GUICtrlSetFont(-1, 9, 400, 0, "MS Sans Serif")
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		Global $F_L_UploadFreq = GUICtrlCreateLabel("Upload frequency", 312, 430 + $tY, 88, 17)
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		GUICtrlSetTip(-1, "How often images are uploaded (in seconds)")
		GUICtrlSetColor(-1, $cYellowHighlight)
		GUICtrlSetOnEvent(-1, "F_L_UploadFreqClick")
		Global $F_L_URL = GUICtrlCreateLabel("URL", 219, 457 + $tY, 26, 17)
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		GUICtrlSetTip(-1, "URL for FTP uploaded image.  For Wunderground, use webcam.wunderground.com")
		GUICtrlSetColor(-1, $cYellowHighlight)
		GUICtrlSetOnEvent(-1, "F_L_URLClick")
		Global $F_L_URLComment = GUICtrlCreateLabel("for Wunderground, use webcam.wunderground.com", 486, 459 + $tY, 250, 17)
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		GUICtrlSetTip(-1, "URL for FTP uploaded image.  For Wunderground, use webcam.wunderground.com")
		GUICtrlSetColor(-1, $cGreenLime)
		GUICtrlSetOnEvent(-1, "F_L_URLCommentClick")
		Global $F_L_UploadFreqComment = GUICtrlCreateLabel("seconds (5-86400)", 485, 433 + $tY, 100, 17)
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		GUICtrlSetTip(-1, "How often images are uploaded (in seconds)")
		GUICtrlSetColor(-1, $cGreenLime)
		GUICtrlSetOnEvent(-1, "F_L_UploadFreqCommentClick")
		Global $F_I_UploadFreq = GUICtrlCreateInput("F_I_UploadFreq", 405, 428 + $tY, 75, 21)
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		GUICtrlSetTip(-1, "How often images are uploaded (in seconds)")
		GUICtrlSetOnEvent(-1, "F_I_UploadFreqChange")
		Global $F_U_UploadFreq = GUICtrlCreateUpdown($F_I_UploadFreq)
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		GUICtrlSetTip(-1, "How often images are uploaded (in seconds)")
		GUICtrlSetLimit(-1, 86400, 5)
		GUICtrlSetOnEvent(-1, "F_U_UploadFreqChange")
		Global $F_I_URL = GUICtrlCreateInput("F_I_URL", 252, 454 + $tY, 229, 21)
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		GUICtrlSetTip(-1, "URL for FTP Uploaded image.  For Wunderground, use webcam.wunderground.com")
		GUICtrlSetOnEvent(-1, "F_I_URLChange")
		Global $F_L_Username = GUICtrlCreateLabel("Username", 218, 486 + $tY, 52, 17)
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		GUICtrlSetTip(-1, "Username for FTP account. For Wunderground, use camera ID. i.e. WU_7886163CAM3")
		GUICtrlSetColor(-1, $cYellowHighlight)
		GUICtrlSetOnEvent(-1, "F_L_UsernameClick")
		Global $F_I_Username = GUICtrlCreateInput("", 276, 484 + $tY, 205, 21)
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		GUICtrlSetTip(-1, "Username for FTP account. For Wunderground, use camera ID. i.e. WU_7886163CAM3")
		GUICtrlSetOnEvent(-1, "F_I_UsernameChange")
		Global $F_L_UsernameComment = GUICtrlCreateLabel("for Wunderground, use camera ID.  i.e. WU_7886163CAM3", 486, 487 + $tY, 287, 17)
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		GUICtrlSetTip(-1, "Username for FTP account. For Wunderground, use camera ID. i.e. WU_7886163CAM3")
		GUICtrlSetColor(-1, $cGreenLime)
		GUICtrlSetOnEvent(-1, "F_L_UsernameCommentClick")
		Global $F_L_Password = GUICtrlCreateLabel("Password", 218, 512 + $tY, 50, 17)
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		GUICtrlSetTip(-1, "Password for FTP account. For Wunderground, use key. i.e. QqOQqKRy")
		GUICtrlSetColor(-1, $cYellowHighlight)
		GUICtrlSetOnEvent(-1, "F_L_PasswordClick")
		Global $F_I_Password = GUICtrlCreateInput("", 276, 510 + $tY, 205, 21)
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		GUICtrlSetTip(-1, "Password for FTP account. For Wunderground, use key. i.e. QqOQqKRy")
		GUICtrlSetOnEvent(-1, "F_I_PasswordChange")
		Global $F_L_PasswordComment = GUICtrlCreateLabel("for Wunderground, use key. i.e. QqOQqKRy", 486, 513 + $tY, 212, 17)
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		GUICtrlSetTip(-1, "Password for FTP account. For Wunderground, use key. i.e. QqOQqKRy")
		GUICtrlSetColor(-1, $cGreenLime)
		GUICtrlSetOnEvent(-1, "F_L_PasswordCommentClick")
		Global $F_L_FTPFolder = GUICtrlCreateLabel("FTP Folder", 215, 538 + $tY, 56, 17)
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		GUICtrlSetTip(-1, "FTP folder to upload images. For Wunderground, leave blank.")
		GUICtrlSetColor(-1, $cYellowHighlight)
		GUICtrlSetOnEvent(-1, "F_L_FTPFolderClick")
		Global $F_I_FTPFolder = GUICtrlCreateInput("", 276, 536 + $tY, 205, 21)
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		GUICtrlSetTip(-1, "FTP folder to upload images. For Wunderground, leave blank.")
		GUICtrlSetOnEvent(-1, "F_I_FTPFolderChange")
		Global $F_L_FTPFolderComment = GUICtrlCreateLabel("for Wunderground, leave blank", 486, 539 + $tY, 151, 17)
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		GUICtrlSetColor(-1, $cGreenLime)
		GUICtrlSetTip(-1, "FTP folder to upload images. For Wunderground, leave blank.")
		GUICtrlSetOnEvent(-1, "F_L_FTPFolderCommentClick")
		Global $F_C_UploadFullSize = GUICtrlCreateCheckbox("Upload Full Size Images", 34, 434 + $tY, 137, 17)
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		GUICtrlSetTip(-1, "FTP upload full size images")
		GUICtrlSetOnEvent(-1, "F_C_UploadFullSizeClick")
		Global $F_C_UploadResized = GUICtrlCreateCheckbox("Upload Resized Images", 34, 454 + $tY, 130, 17)
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		GUICtrlSetTip(-1, "FTP upload resized images")
		GUICtrlSetOnEvent(-1, "F_C_UploadResizedClick")
		GUICtrlCreateGroup("", -99, -99, 1, 1)
		Global $G_FinishGroup = GUICtrlCreateGroup("Finish", 380, 586 + $tY, 203, 61)
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		GUICtrlSetFont(-1, 9, 400, 0, "MS Sans Serif")
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		Global $B_Exit = GUICtrlCreateButton("Exit Program", 489, 607 + $tY, 80, 29)
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		GUICtrlSetBkColor(-1, $cRedFaded)
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		GUICtrlSetTip(-1, "Exit program. Images will NOT be archived or uploaded.")
		GUICtrlSetOnEvent(-1, "B_ExitClick")
		Global $B_CloseConfig = GUICtrlCreateButton("Close Config", 395, 607 + $tY, 88, 29)
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
		GUICtrlSetBkColor(-1, $cGreenLime)
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		GUICtrlSetTip(-1, "Close config window.  Program will continue to run.")
		GUICtrlSetOnEvent(-1, "B_CloseConfig")
		GUICtrlCreateGroup("", -99, -99, 1, 1)
		Global $G_OptionsGroup = GUICtrlCreateGroup("Options", 18, 586 + $tY, 349, 115)
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		GUICtrlSetFont(-1, 9, 400, 0, "MS Sans Serif")
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		Global $O_C_CheckForUpdates = GUICtrlCreateCheckbox("Check for updates at program start", 148, 611 + $tY, 201, 17)
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		GUICtrlSetOnEvent(-1, "O_C_CheckForUpdatesClick")
		Global $O_G_Log = GUICtrlCreateGroup("Log", 28, 605 + $tY, 109, 83)
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		Global $O_R_LogAll = GUICtrlCreateRadio("All", 50, 622 + $tY, 41, 17)
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		GUICtrlSetTip(-1, "Log all archive progress, upload progress, and other comments")
		GUICtrlSetOnEvent(-1, "O_R_LogAllClick")
		Global $O_R_LogFails = GUICtrlCreateRadio("Fails Only", 50, 642 + $tY, 71, 17)
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		GUICtrlSetTip(-1, "Log archive and upload failures only")
		GUICtrlSetOnEvent(-1, "O_R_LogFailsClick")
		Global $O_R_LogNone = GUICtrlCreateRadio("None", 50, 662 + $tY, 60, 17)
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		GUICtrlSetOnEvent(-1, "O_R_LogNoneClick")
		GUICtrlSetTip(-1, "Do NOT create a log file")
		GUICtrlCreateGroup("", -99, -99, 1, 1)
		GUICtrlCreateGroup("", -99, -99, 1, 1)
		Global $L_FooterPhoenixURL = GUICtrlCreateLabel("http://www.Phoenix125.com", 642, 652 + $tY, 168, 20)
		GUICtrlSetFont(-1, 10, 400, 0, "Tahoma")
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		GUICtrlSetTip(-1, "Click to visit http://www.phoenix125.com")
		GUICtrlSetOnEvent(-1, "L_FooterPhoenixURLClick")
		Global $L_FooterProgName = GUICtrlCreateLabel($aUtilName & " " & $aUtilVer, 569, 675 + $tY, 241, 20, $SS_RIGHT)
		GUICtrlSetTip(-1, "Click to visit website")
		GUICtrlSetFont(-1, 10, 400, 0, "Tahoma")
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		GUICtrlSetOnEvent(-1, "L_FooterProgNameClick")
		Global $P_PhoenixLogo = GUICtrlCreatePic($aFolderTemp & "phoenixlogo.jpg", 816, 635 + $tY, 60, 60)
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		GUICtrlSetTip(-1, "Click to visit http://www.phoenix125.com")
		GUICtrlSetOnEvent(-1, "P_PhoenixLogoClick")
		Global $P_About = GUICtrlCreateIcon($aIconFile, 202, 532, 671 + $tY, 24, 24)
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		GUICtrlSetTip(-1, "About")
		GUICtrlSetOnEvent(-1, "P_AboutClick")
		Global $P_Discord = GUICtrlCreateIcon($aIconFile, 201, 499, 671 + $tY, 24, 24)
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		GUICtrlSetTip(-1, "Discord Page")
		GUICtrlSetOnEvent(-1, "P_DiscordClick")
		Global $P_Discussion = GUICtrlCreateIcon($aIconFile, 203, 467, 671 + $tY, 24, 24)
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		GUICtrlSetTip(-1, "Discussion Forum")
		GUICtrlSetOnEvent(-1, "P_DiscussionClick")
		Global $P_Help = GUICtrlCreateIcon($aIconFile, 204, 435, 671 + $tY, 24, 24)
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		GUICtrlSetTip(-1, "Online Help")
		GUICtrlSetOnEvent(-1, "P_HelpClick")
		Global $P_Update = GUICtrlCreateIcon($aIconFile, 205, 387, 671 + $tY, 24, 24)
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		GUICtrlSetTip(-1, "Check for updates")
		GUICtrlSetOnEvent(-1, "P_UpdateClick")
		Global $G_ArchiveGroup = GUICtrlCreateGroup("Archive (Save Images)", 18, 296 + $tY, 859, 93)
		GUICtrlSetFont(-1, 9, 400, 0, "MS Sans Serif")
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		Global $A_L_Frequency = GUICtrlCreateLabel("Archive frequency", 193, 321 + $tY, 90, 17)
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		GUICtrlSetTip(-1, "How often images are archived (in seconds)")
		GUICtrlSetColor(-1, $cYellowHighlight)
		GUICtrlSetOnEvent(-1, "A_L_FrequencyClick")
		Global $A_L_SaveFolder = GUICtrlCreateLabel("Save Folder", 219, 348 + $tY, 61, 17)
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		GUICtrlSetTip(-1, "Folder to save archived images")
		GUICtrlSetColor(-1, $cYellowHighlight)
		GUICtrlSetOnEvent(-1, "A_L_SaveFolderClick")
		Global $A_L_FrequencyComment = GUICtrlCreateLabel("seconds (5-86400)", 366, 322 + $tY, 100, 17)
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		GUICtrlSetTip(-1, "How often images are archived (in seconds)")
		GUICtrlSetColor(-1, $cGreenLime)
		GUICtrlSetOnEvent(-1, "A_L_FrequencyCommentClick")
		Global $A_I_Frequency = GUICtrlCreateInput("", 286, 319 + $tY, 75, 21)
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		GUICtrlSetTip(-1, "How often images are archived (in seconds)")
		GUICtrlSetOnEvent(-1, "A_I_FrequencyChange")
		Global $A_U_Frequency = GUICtrlCreateUpdown($A_I_Frequency)
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		GUICtrlSetTip(-1, "How often images are archived (in seconds)")
		GUICtrlSetLimit(-1, 86400, 5)
		GUICtrlSetOnEvent(-1, "A_U_FrequencyChange")
		Global $A_I_SaveFolder = GUICtrlCreateInput("", 286, 345 + $tY, 505, 21)
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		GUICtrlSetTip(-1, "Folder to save archived images")
		GUICtrlSetOnEvent(-1, "A_I_SaveFolderChange")
		Global $A_C_ArchiveFullSize = GUICtrlCreateCheckbox("Archive Full Size Images", 32, 320 + $tY, 137, 17)
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		GUICtrlSetTip(-1, "Archive (save a copy of) full-size images. Date or sequential number will be added to end of filename.")
		GUICtrlSetOnEvent(-1, "A_C_ArchiveFullSizeClick")
		Global $A_C_ArchiveResized = GUICtrlCreateCheckbox("Archive Resized Images", 32, 340 + $tY, 130, 17)
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		GUICtrlSetTip(-1, "Archive (save a copy of) resized images. Date or sequential number will be added to end of filename.")
		GUICtrlSetOnEvent(-1, "A_C_ArchiveResizedClick")
		Global $A_B_SelectSaveFolder = GUICtrlCreateButton("Select Folder", 792, 342 + $tY, 75, 25)
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		GUICtrlSetTip(-1, "Folder to save archived images")
		GUICtrlSetOnEvent(-1, "A_B_SelectSaveFolderClick")
		Global $A_C_AddSequentialNumbers = GUICtrlCreateCheckbox("Add sequential numbers to filename (00000-99999) instead of date", 516, 316 + $tY, 349, 17)
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		GUICtrlSetTip(-1, "By default, the date is added to end of filename.  Enable this to add sequential numbers to filename (00000-99999) instead of date.")
		GUICtrlSetOnEvent(-1, "A_C_AddSequentialNumbersClick")
		GUICtrlCreateGroup("", -99, -99, 1, 1)
		Global $G_CameraSource = GUICtrlCreateGroup("Camera Source", 18, 108 + $tY, 861, 173)
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		GUICtrlSetFont(-1, 9, 400, 0, "MS Sans Serif")
		Global $C_L_CameraURL = GUICtrlCreateLabel("Camera URL", 30, 166 + $tY, 65, 17)
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		GUICtrlSetTip(-1, "Enter camera's snapshot URL. i.e. http://192.168.1.5/snap.jpeg.")
		GUICtrlSetColor(-1, $cYellowHighlight)
		GUICtrlSetOnEvent(-1, "C_L_CameraURLClick")
		Global $C_L_CameraURLComment = GUICtrlCreateLabel("i.e. http://192.168.1.5/snap.jpeg", 473, 168 + $tY, 160, 17)
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		GUICtrlSetTip(-1, "Enter camera's snapshot URL. i.e. http://192.168.1.5/snap.jpeg.")
		GUICtrlSetColor(-1, $cGreenLime)
		GUICtrlSetOnEvent(-1, "C_L_CameraURLCommentClick")
		Global $C_I_CameraURL = GUICtrlCreateInput("", 103, 163 + $tY, 366, 21)
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		GUICtrlSetTip(-1, "Enter camera's snapshot URL. i.e. http://192.168.1.5/snap.jpeg.")
		GUICtrlSetOnEvent(-1, "C_I_CameraURLChange")
		Global $C_L_CameraName = GUICtrlCreateLabel("Camera Name / Notes", 155, 132 + $tY, 110, 17)
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		GUICtrlSetTip(-1, "Set camera name or notes. Used for reference only.")
		GUICtrlSetColor(-1, $cYellowHighlight)
		GUICtrlSetOnEvent(-1, "C_L_CameraNameClick")
		Global $C_I_CameraName = GUICtrlCreateInput("", 269, 130 + $tY, 495, 21)
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		GUICtrlSetTip(-1, "Set camera name or notes. Used for reference only.")
		GUICtrlSetOnEvent(-1, "C_I_CameraNameChange")
		Global $C_L_CameraNameComment = GUICtrlCreateLabel("for reference only", 766, 134 + $tY, 86, 17)
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		GUICtrlSetTip(-1, "Set camera name or notes. Used for reference only.")
		GUICtrlSetColor(-1, $cGreenLime)
		GUICtrlSetOnEvent(-1, "C_L_CameraNameCommentClick")
		Global $C_L_CreateFullSizeFilename = GUICtrlCreateLabel("Filename", 189, 195 + $tY, 46, 17)
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		GUICtrlSetTip(-1, "Enter filename for full-size image. i.e. Driveway_Full.jpg")
		GUICtrlSetColor(-1, $cYellowHighlight)
		GUICtrlSetOnEvent(-1, "C_L_CreateFullSizeFilenameClick")
		Global $C_L_CreateFullSizeFilenameComment = GUICtrlCreateLabel("i.e. Driveway_Full.jpg", 473, 195 + $tY, 120, 17)
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		GUICtrlSetTip(-1, "Enter filename for full-size image. i.e. Driveway_Full.jpg")
		GUICtrlSetColor(-1, $cGreenLime)
		GUICtrlSetOnEvent(-1, "C_L_CreateFullSizeFilenameCommentClick")
		Global $C_I_CreateFullSizeFilename = GUICtrlCreateInput("Input2", 240, 192 + $tY, 229, 21)
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		GUICtrlSetTip(-1, "Enter filename for full-size image. i.e. Driveway_Full.jpg")
		GUICtrlSetOnEvent(-1, "C_I_CreateFullSizeFilenameChange")
		Global $C_C_CreateResized = GUICtrlCreateCheckbox("Create Resized Image", 57, 223 + $tY, 127, 17)
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		GUICtrlSetTip(-1, "Enable to create a resized version of image")
		GUICtrlSetOnEvent(-1, "C_C_CreateResizedClick")
		Global $C_L_CreateResized = GUICtrlCreateLabel("Filename", 189, 225 + $tY, 46, 17)
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		GUICtrlSetTip(-1, "Enter filename for resized image. i.e. Driveway_853x480.jpg")
		GUICtrlSetColor(-1, $cYellowHighlight)
		GUICtrlSetOnEvent(-1, "C_L_CreateResizedClick")
		Global $C_L_CreateResizedComment = GUICtrlCreateLabel("i.e. Driveway_853x480.jpg", 473, 225 + $tY, 130, 17)
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		GUICtrlSetTip(-1, "Enter filename for resized image. i.e. Driveway_853x480.jpg")
		GUICtrlSetColor(-1, $cGreenLime)
		GUICtrlSetOnEvent(-1, "C_L_CreateResizedCommentClick")
		Global $C_I_CreateResizedFilename = GUICtrlCreateInput("Input2", 240, 222 + $tY, 229, 21)
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		GUICtrlSetTip(-1, "Enter filename for resized image. i.e. Driveway_853x480.jpg")
		GUICtrlSetOnEvent(-1, "C_I_CreateResizedFilenameChange")
		Global $C_L_CreateResizedImageSize = GUICtrlCreateLabel("Image Size", 180, 249 + $tY, 56, 17)
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		GUICtrlSetTip(-1, "Enter image size as Width x Height in pixel size. i.e. 853x480")
		GUICtrlSetColor(-1, $cYellowHighlight)
		GUICtrlSetOnEvent(-1, "C_L_CreateResizedImageSizeClick")
		Global $C_L_CreateResizedImageSizeComment = GUICtrlCreateLabel("i.e. 853x480", 473, 249 + $tY, 68, 17)
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		GUICtrlSetTip(-1, "Enter image size as Width x Height in pixel size. i.e. 853x480")
		GUICtrlSetColor(-1, $cGreenLime)
		GUICtrlSetOnEvent(-1, "C_L_CreateResizedImageSizeCommentClick")
		Global $C_I_CreateResizedImageSize = GUICtrlCreateInput("Input2", 240, 246 + $tY, 229, 21)
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		GUICtrlSetTip(-1, "Enter image size as Width x Height in pixel size. i.e. 853x480")
		GUICtrlSetOnEvent(-1, "C_I_CreateResizedImageSizeChange")
		Global $C_C_Enable = GUICtrlCreateCheckbox("Enable", 35, 130 + $tY, 95, 17)
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		GUICtrlSetTip(-1, "Checkmark to enable this camera. If not enabled, this camera will be skipped.")
		GUICtrlSetFont(-1, 16, 800, 0, "MS Sans Serif")
		GUICtrlSetColor(-1, $cYellowHighlight)
		GUICtrlSetBkColor(-1, 0xFF00FF)
		GUICtrlSetOnEvent(-1, "C_C_EnableClick")
		GUICtrlCreateGroup("", -99, -99, 1, 1)
		GUICtrlCreateGroup("", -99, -99, 1, 1)
		Global $L_Title = GUICtrlCreateLabel("UniFi Camera Image Archiver FTP Uploader", 159, 7, 572, 36)
		GUICtrlSetFont(-1, 20, 800, 0, "MS Sans Serif")
		GUICtrlSetColor(-1, 0xFF0000)
		GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
		GUICtrlSetTip(-1, "Click to open the website.")
		GUICtrlSetOnEvent(-1, "L_TitleClick")
		GUISetState(@SW_SHOW)
		_UpdateFields()
		#EndRegion ### END Koda GUI section ###
	EndIf
EndFunc   ;==>_GUI_Config
Func _UpdateFields($tCam = $aLastCam)
	For $i = 0 To ($aNumberOfEntries - 1)
		If $xCameraEnableYN[$i] = "yes" Then
			GUICtrlSetBkColor($G_B_CameraButtons[$i], $cGreenFaded)
		Else
			GUICtrlSetBkColor($G_B_CameraButtons[$i], $cRedFaded)
		EndIf
	Next
	GUICtrlSetBkColor($G_B_CameraButtons[$aLastCam], $cYellowHighlight)
	If $xCameraEnableYN[$tCam] = "yes" Then
		GUICtrlSetState($C_C_Enable, $GUI_CHECKED)
		GUICtrlSetBkColor($C_C_Enable, $cGreenFaded)
	Else
		GUICtrlSetState($C_C_Enable, $GUI_UNCHECKED)
		GUICtrlSetBkColor($C_C_Enable, $cRedFaded)
	EndIf
	GUICtrlSetData($C_I_CameraName, $xNotes[$aLastCam])
	GUICtrlSetData($C_I_CameraURL, $xURL[$aLastCam])
	GUICtrlSetData($F_I_URL, $xFTPURL[$aLastCam])
	GUICtrlSetData($C_I_CreateFullSizeFilename, $xFileNameOriginal[$aLastCam])
	GUICtrlSetData($C_I_CreateResizedFilename, $xFileNameResized[$aLastCam])
	GUICtrlSetData($C_I_CreateResizedImageSize, $xResizeImageSize[$aLastCam])
	GUICtrlSetData($A_I_Frequency, $xIntervalSave[$aLastCam])
	GUICtrlSetData($A_I_SaveFolder, $xSaveFolder[$aLastCam])
	GUICtrlSetData($F_I_UploadFreq, $xIntervalFTP[$aLastCam])
	GUICtrlSetData($F_I_FTPFolder, $xFTPFolder[$aLastCam])
	GUICtrlSetData($F_I_Password, $xPwd[$aLastCam])
	GUICtrlSetData($F_I_Username, $xUserID[$aLastCam])
	If $aLogLevel = 1 Then
		GUICtrlSetState($O_R_LogAll, $GUI_CHECKED)
	ElseIf $aLogLevel = 2 Then
		GUICtrlSetState($O_R_LogFails, $GUI_CHECKED)
	Else
		GUICtrlSetState($O_R_LogNone, $GUI_CHECKED)
	EndIf
	If $xSaveFileNumberYN[$tCam] = "yes" Then
		GUICtrlSetState($A_C_AddSequentialNumbers, $GUI_CHECKED)
	Else
		GUICtrlSetState($A_C_AddSequentialNumbers, $GUI_UNCHECKED)
	EndIf
	If $xResizeImageYN[$aLastCam] = "yes" Then
		GUICtrlSetState($C_C_CreateResized, $GUI_CHECKED)
	Else
		GUICtrlSetState($C_C_CreateResized, $GUI_UNCHECKED)
	EndIf
	If $aUtilCheckForUpdateYN = "yes" Then
		GUICtrlSetState($O_C_CheckForUpdates, $GUI_CHECKED)
	Else
		GUICtrlSetState($O_C_CheckForUpdates, $GUI_UNCHECKED)
	EndIf
	If $xSaveType[$aLastCam] = "B" Then
		GUICtrlSetState($A_C_ArchiveFullSize, $GUI_CHECKED)
		GUICtrlSetState($A_C_ArchiveResized, $GUI_CHECKED)
	ElseIf $xSaveType[$aLastCam] = "F" Then
		GUICtrlSetState($A_C_ArchiveFullSize, $GUI_CHECKED)
		GUICtrlSetState($A_C_ArchiveResized, $GUI_UNCHECKED)
	ElseIf $xSaveType[$aLastCam] = "R" Then
		GUICtrlSetState($A_C_ArchiveFullSize, $GUI_UNCHECKED)
		GUICtrlSetState($A_C_ArchiveResized, $GUI_CHECKED)
	Else
		GUICtrlSetState($A_C_ArchiveFullSize, $GUI_UNCHECKED)
		GUICtrlSetState($A_C_ArchiveResized, $GUI_UNCHECKED)
	EndIf
	If $xFTPUploadType[$aLastCam] = "B" Then
		GUICtrlSetState($F_C_UploadFullSize, $GUI_CHECKED)
		GUICtrlSetState($F_C_UploadResized, $GUI_CHECKED)
	ElseIf $xFTPUploadType[$aLastCam] = "F" Then
		GUICtrlSetState($F_C_UploadFullSize, $GUI_CHECKED)
		GUICtrlSetState($F_C_UploadResized, $GUI_UNCHECKED)
	ElseIf $xFTPUploadType[$aLastCam] = "R" Then
		GUICtrlSetState($F_C_UploadFullSize, $GUI_UNCHECKED)
		GUICtrlSetState($F_C_UploadResized, $GUI_CHECKED)
	Else
		GUICtrlSetState($F_C_UploadFullSize, $GUI_UNCHECKED)
		GUICtrlSetState($F_C_UploadResized, $GUI_UNCHECKED)
	EndIf
EndFunc   ;==>_UpdateFields
Func G_B_CameraClicked()
	Local $tGID = @GUI_CtrlId
	For $i = 0 To ($aNumberOfEntries - 1)
		If $tGID = $G_B_CameraButtons[$i] Then
			$tCamActive = $i
			ExitLoop
		EndIf
	Next
	GUICtrlSetBkColor($G_B_CameraButtons[$aLastCam], $cButtonDefaultBackground)
	$aLastCam = $tCamActive
	GUICtrlSetBkColor($G_B_CameraButtons[$aLastCam], $cYellowHighlight)
	_UpdateFields()
EndFunc   ;==>G_B_CameraClicked
Func _RestartQuick() ; Thanks UP_NORTH
	IniWrite($aUtilCFGFile, "CFG", "aRestartQuickYN", "yes")
	If @Compiled = 1 Then
		Run(FileGetShortName(@ScriptFullPath))
	Else
		Run(FileGetShortName(@AutoItExe) & ' "' & FileGetShortName(@ScriptFullPath) & '"')
	EndIf
	Exit
EndFunc   ;==>_RestartQuick
Func A_B_SelectSaveFolderClick()
	Local $tSaveFolder = FileSelectFolder("Please select folder to save archive images.", $xSaveFolder[$aLastCam])
	If @error Then
		GUICtrlSetData($A_I_SaveFolder, $xSaveFolder[$aLastCam])
	Else
		$xSaveFolder[$aLastCam] = $tSaveFolder
	EndIf
	$xSaveFolder[$aLastCam] = _RemoveTrailingSlash($xSaveFolder[$aLastCam]) & "\"
	GUICtrlSetData($A_I_SaveFolder, $xSaveFolder[$aLastCam])
	IniWrite($aIniFile, " --------------- CAMERA " & $aLastCam + 1 & " --------------- ", "Save Folder for archived image(s) ###", $xSaveFolder[$aLastCam])
EndFunc   ;==>A_B_SelectSaveFolderClick
Func A_C_AddSequentialNumbersClick()
	If GUICtrlRead($A_C_AddSequentialNumbers) = $GUI_CHECKED Then
		$xSaveFileNumberYN[$aLastCam] = "yes"
	Else
		$xSaveFileNumberYN[$aLastCam] = "no"
	EndIf
	IniWrite($aIniFile, " --------------- CAMERA " & $aLastCam + 1 & " --------------- ", "For archived images filename, use sequential numbers (i.e. 00000-99999) instead of date? (yes/no) ###", $xSaveFileNumberYN[$aLastCam])
EndFunc   ;==>A_C_AddSequentialNumbersClick
Func A_C_ArchiveFullSizeClick()
	If GUICtrlRead($A_C_ArchiveFullSize) = $GUI_CHECKED Then
		If $xSaveType[$aLastCam] = "N" Then $xSaveType[$aLastCam] = "F"
		If $xSaveType[$aLastCam] = "R" Then $xSaveType[$aLastCam] = "B"
	Else
		If $xSaveType[$aLastCam] = "F" Then $xSaveType[$aLastCam] = "N"
		If $xSaveType[$aLastCam] = "B" Then $xSaveType[$aLastCam] = "R"
	EndIf
	IniWrite($aIniFile, " --------------- CAMERA " & $aLastCam + 1 & " --------------- ", "Archive image: (F)ull-size (R)esized (B)oth (N)one (FRBN)###", $xSaveType[$aLastCam])
EndFunc   ;==>A_C_ArchiveFullSizeClick
Func A_C_ArchiveResizedClick()
	If GUICtrlRead($A_C_ArchiveResized) = $GUI_CHECKED Then
		If $xSaveType[$aLastCam] = "N" Then $xSaveType[$aLastCam] = "R"
		If $xSaveType[$aLastCam] = "F" Then $xSaveType[$aLastCam] = "B"
	Else
		If $xSaveType[$aLastCam] = "R" Then $xSaveType[$aLastCam] = "N"
		If $xSaveType[$aLastCam] = "B" Then $xSaveType[$aLastCam] = "F"
	EndIf
	IniWrite($aIniFile, " --------------- CAMERA " & $aLastCam + 1 & " --------------- ", "Archive image: (F)ull-size (R)esized (B)oth (N)one (FRBN)###", $xSaveType[$aLastCam])
EndFunc   ;==>A_C_ArchiveResizedClick
Func A_I_FrequencyChange()
	Local $tTxt = GUICtrlRead($A_I_Frequency)
	$xIntervalSave[$aLastCam] = $tTxt
	If $xIntervalSave[$aLastCam] < 5 Then $xIntervalSave[$aLastCam] = 5
	If $xIntervalSave[$aLastCam] > 86400 Then $xIntervalSave[$aLastCam] = 86400
	GUICtrlSetData($A_I_Frequency, $xIntervalSave[$aLastCam])
	IniWrite($aIniFile, " --------------- CAMERA " & $aLastCam + 1 & " --------------- ", "Number of seconds between archive images (5-86400) ###", $xIntervalSave[$aLastCam])
EndFunc   ;==>A_I_FrequencyChange
Func A_I_SaveFolderChange()
	Local $tTxt = GUICtrlRead($A_I_SaveFolder)
	$xSaveFolder[$aLastCam] = _RemoveTrailingSlash($tTxt) & "\"
	GUICtrlSetData($A_I_SaveFolder, $xSaveFolder[$aLastCam])
	IniWrite($aIniFile, " --------------- CAMERA " & $aLastCam + 1 & " --------------- ", "Save Folder for archived image(s) ###", $xSaveFolder[$aLastCam])
EndFunc   ;==>A_I_SaveFolderChange
Func A_L_FrequencyClick()
EndFunc   ;==>A_L_FrequencyClick
Func A_L_FrequencyCommentClick()
EndFunc   ;==>A_L_FrequencyCommentClick
Func A_L_SaveFolderClick()
EndFunc   ;==>A_L_SaveFolderClick
Func B_AddCameraClick()
	$aNumberOfEntries += 1
	IniWrite($aIniFile, " --------------- " & StringUpper($aUtilName) & " --------------- ", "Number of cameras/files to manage (1-100) ###", $aNumberOfEntries)
	_RestartQuick()
EndFunc   ;==>B_AddCameraClick
Func B_RemoveCamera()
	Local $tMB = MsgBox($MB_OKCANCEL, $aUtilName, "Warning! Will delete last camera: " & @CRLF & $xNotes[$aNumberOfEntries - 1] & @CRLF & @CRLF & "Click OK to DELETE." & @CRLF & "Click Cancel to cancel")
	If $tMB = 1 Then ; OK
		$aNumberOfEntries -= 1
		IniWrite($aIniFile, " --------------- " & StringUpper($aUtilName) & " --------------- ", "Number of cameras/files to manage (1-100) ###", $aNumberOfEntries)
		_RestartQuick()
	Else
		_Splash("Cancelled", 1500, 200, 70)
	EndIf
EndFunc   ;==>B_RemoveCamera
Func B_ExitClick()
	TrayExit()
EndFunc   ;==>B_ExitClick
Func B_Close()
	B_CloseConfig()
EndFunc   ;==>B_Close
Func B_CloseConfig()
	GUIDelete($W_ConfigWindow)
	_Splash("Settings saved.", 1500, 200, 70)
EndFunc   ;==>B_CloseConfig
Func C_C_CreateResizedClick()
	If GUICtrlRead($C_C_CreateResized) = $GUI_CHECKED Then
		$xResizeImageYN[$aLastCam] = "yes"
	Else
		$xResizeImageYN[$aLastCam] = "no"
	EndIf
	IniWrite($aIniFile, " --------------- CAMERA " & $aLastCam + 1 & " --------------- ", "Create resize image? (yes/no) ###", $xResizeImageYN[$aLastCam])
EndFunc   ;==>C_C_CreateResizedClick
Func C_C_EnableClick()
	If GUICtrlRead($C_C_Enable) = $GUI_CHECKED Then
		$xCameraEnableYN[$aLastCam] = "yes"
	Else
		$xCameraEnableYN[$aLastCam] = "no"
	EndIf
	IniWrite($aIniFile, " --------------- CAMERA " & $aLastCam + 1 & " --------------- ", "Camera Enabled (yes/no) ###", $xCameraEnableYN[$aLastCam])
	_UpdateFields()
EndFunc   ;==>C_C_EnableClick
Func C_I_CameraNameChange()
	Local $tTxt = GUICtrlRead($C_I_CameraName)
	If $tTxt <> "" Then
		$xNotes[$aLastCam] = $tTxt
		IniWrite($aIniFile, " --------------- CAMERA " & $aLastCam + 1 & " --------------- ", "Note (optional for comment in this config file) ###", $xNotes[$aLastCam])
	EndIf
EndFunc   ;==>C_I_CameraNameChange
Func C_I_CameraURLChange()
	Local $tTxt = GUICtrlRead($C_I_CameraURL)
	If $tTxt <> "" Then
		$xURL[$aLastCam] = $tTxt
		IniWrite($aIniFile, " --------------- CAMERA " & $aLastCam + 1 & " --------------- ", "Image URL from camera (ex. http://192.168.1.5/snap.jpeg) ###", $xURL[$x])
	EndIf
EndFunc   ;==>C_I_CameraURLChange
Func C_I_CreateFullSizeFilenameChange()
	Local $tTxt = GUICtrlRead($C_I_CreateFullSizeFilename)
	If $tTxt <> "" Then
		$xFileNameOriginal[$aLastCam] = $tTxt
		IniWrite($aIniFile, " --------------- CAMERA " & $aLastCam + 1 & " --------------- ", "Full-size image filename (ex. camerawest.jpg) ###", $xFileNameOriginal[$aLastCam])
	EndIf
EndFunc   ;==>C_I_CreateFullSizeFilenameChange
Func C_I_CreateResizedFilenameChange()
	Local $tTxt = GUICtrlRead($C_I_CreateResizedFilename)
	If $tTxt <> "" Then
		$xFileNameResized[$aLastCam] = $tTxt
		IniWrite($aIniFile, " --------------- CAMERA " & $aLastCam + 1 & " --------------- ", "Resized image filename (leave blank if not resizing image) ###", $xFileNameResized[$aLastCam])
	EndIf
EndFunc   ;==>C_I_CreateResizedFilenameChange
Func C_I_CreateResizedImageSizeChange()
	Local $tTxt = GUICtrlRead($C_I_CreateResizedImageSize)
	If $tTxt <> "" Then
		Local $xImageSplit = StringSplit($tTxt, "x", 2)
		If StringInStr($tTxt, "x") = 0 Or UBound($xImageSplit) <> 2 Then
			GUICtrlSetData($C_I_CreateResizedImageSize, $xResizeImageSize[$aLastCam])
			MsgBox($MB_OK, "ERROR", "Wrong format. Please format dimentions as WidthxHeight.  Ex. 1280x720", 30)
		Else
			$xResizeImageSize[$aLastCam] = $tTxt
			IniWrite($aIniFile, " --------------- CAMERA " & $aLastCam + 1 & " --------------- ", "Resize image size: (ex. 1280x720) ###", $xResizeImageSize[$aLastCam])
		EndIf
	EndIf
EndFunc   ;==>C_I_CreateResizedImageSizeChange
Func C_L_CameraNameClick()
EndFunc   ;==>C_L_CameraNameClick
Func C_L_CameraNameCommentClick()
EndFunc   ;==>C_L_CameraNameCommentClick
Func C_L_CameraURLClick()
EndFunc   ;==>C_L_CameraURLClick
Func C_L_CameraURLCommentClick()
EndFunc   ;==>C_L_CameraURLCommentClick
Func C_L_CreateFullSizeFilenameClick()
EndFunc   ;==>C_L_CreateFullSizeFilenameClick
Func C_L_CreateFullSizeFilenameCommentClick()
EndFunc   ;==>C_L_CreateFullSizeFilenameCommentClick
Func C_L_CreateResizedClick()
EndFunc   ;==>C_L_CreateResizedClick
Func C_L_CreateResizedCommentClick()
EndFunc   ;==>C_L_CreateResizedCommentClick
Func C_L_CreateResizedImageSizeClick()
EndFunc   ;==>C_L_CreateResizedImageSizeClick
Func C_L_CreateResizedImageSizeCommentClick()
EndFunc   ;==>C_L_CreateResizedImageSizeCommentClick
Func F_C_UploadFullSizeClick()
	If GUICtrlRead($F_C_UploadFullSize) = $GUI_CHECKED Then
		If $xFTPUploadType[$aLastCam] = "N" Then $xFTPUploadType[$aLastCam] = "F"
		If $xFTPUploadType[$aLastCam] = "R" Then $xFTPUploadType[$aLastCam] = "B"
	Else
		If $xFTPUploadType[$aLastCam] = "F" Then $xFTPUploadType[$aLastCam] = "N"
		If $xFTPUploadType[$aLastCam] = "B" Then $xFTPUploadType[$aLastCam] = "R"
	EndIf
	IniWrite($aIniFile, " --------------- CAMERA " & $aLastCam + 1 & " --------------- ", "FTP Upload image: (F)ull-size (R)esized (B)oth (N)one (FRBN)###", $xFTPUploadType[$aLastCam])
EndFunc   ;==>F_C_UploadFullSizeClick
Func F_C_UploadResizedClick()
	If GUICtrlRead($F_C_UploadResized) = $GUI_CHECKED Then
		If $xFTPUploadType[$aLastCam] = "N" Then $xFTPUploadType[$aLastCam] = "R"
		If $xFTPUploadType[$aLastCam] = "F" Then $xFTPUploadType[$aLastCam] = "B"
	Else
		If $xFTPUploadType[$aLastCam] = "R" Then $xFTPUploadType[$aLastCam] = "N"
		If $xFTPUploadType[$aLastCam] = "B" Then $xFTPUploadType[$aLastCam] = "F"
	EndIf
	IniWrite($aIniFile, " --------------- CAMERA " & $aLastCam + 1 & " --------------- ", "FTP Upload image: (F)ull-size (R)esized (B)oth (N)one (FRBN)###", $xFTPUploadType[$aLastCam])
EndFunc   ;==>F_C_UploadResizedClick
Func F_I_FTPFolderChange()
	Local $tTxt = GUICtrlRead($F_I_FTPFolder)
	$xFTPFolder[$aLastCam] = $tTxt
	IniWrite($aIniFile, " --------------- CAMERA " & $aLastCam + 1 & " --------------- ", "FTP folder (for Wunderground, leave blank) ###", $xFTPFolder[$aLastCam])
EndFunc   ;==>F_I_FTPFolderChange
Func F_I_PasswordChange()
	Local $tTxt = GUICtrlRead($F_I_Password)
	$xPwd[$aLastCam] = $tTxt
	IniWrite($aIniFile, " --------------- CAMERA " & $aLastCam + 1 & " --------------- ", "FTP password (for Wunderground, use key, ex. QqOQqKRy) ###", $xPwd[$aLastCam])
EndFunc   ;==>F_I_PasswordChange
Func F_I_UploadFreqChange()
	Local $tTxt = GUICtrlRead($F_I_UploadFreq)
	$xIntervalFTP[$aLastCam] = $tTxt
	If $xIntervalFTP[$aLastCam] < 5 Then $xIntervalFTP[$aLastCam] = 5
	If $xIntervalFTP[$aLastCam] > 86400 Then $xIntervalFTP[$aLastCam] = 86400
	GUICtrlSetData($F_I_UploadFreq, $xIntervalFTP[$aLastCam])
	IniWrite($aIniFile, " --------------- CAMERA " & $aLastCam + 1 & " --------------- ", "Number of seconds between FTP uploads (5-86400) ###", $xIntervalFTP[$aLastCam])
EndFunc   ;==>F_I_UploadFreqChange
Func F_I_URLChange()
	Local $tTxt = GUICtrlRead($F_I_URLChange)
	If $tTxt <> "" Then
		$xFTPURL[$aLastCam] = $tTxt
		IniWrite($aIniFile, " --------------- CAMERA " & $aLastCam + 1 & " --------------- ", "FTP URL (for Wunderground, use webcam.wunderground.com) ###", $xFTPURL[$aLastCam])
	EndIf
EndFunc   ;==>F_I_URLChange
Func F_I_UsernameChange()
	Local $tTxt = GUICtrlRead($F_I_Username)
	$xUserID[$aLastCam] = $tTxt
	IniWrite($aIniFile, " --------------- CAMERA " & $aLastCam + 1 & " --------------- ", "FTP userName (for Wunderground, use camera ID, ex. WU_7883133CAM3) ###", $xUserID[$aLastCam])
EndFunc   ;==>F_I_UsernameChange
Func F_L_FTPFolderClick()
EndFunc   ;==>F_L_FTPFolderClick
Func F_L_FTPFolderCommentClick()
EndFunc   ;==>F_L_FTPFolderCommentClick
Func F_L_PasswordClick()
EndFunc   ;==>F_L_PasswordClick
Func F_L_PasswordCommentClick()
EndFunc   ;==>F_L_PasswordCommentClick
Func F_L_UploadFreqClick()
EndFunc   ;==>F_L_UploadFreqClick
Func F_L_UploadFreqCommentClick()
EndFunc   ;==>F_L_UploadFreqCommentClick
Func F_L_URLClick()
EndFunc   ;==>F_L_URLClick
Func F_L_URLCommentClick()
EndFunc   ;==>F_L_URLCommentClick
Func F_L_UsernameClick()
EndFunc   ;==>F_L_UsernameClick
Func F_L_UsernameCommentClick()
EndFunc   ;==>F_L_UsernameCommentClick
Func F_U_UploadFreqChange()
EndFunc   ;==>F_U_UploadFreqChange
Func A_U_FrequencyChange()
EndFunc   ;==>A_U_FrequencyChange
Func L_FooterPhoenixURLClick()
	P_PhoenixLogoClick()
EndFunc   ;==>L_FooterPhoenixURLClick
Func L_FooterProgNameClick()
	ShellExecute("http://www.phoenix125.com/UniFiCameraImageArchiverFTPUploader.html")
EndFunc   ;==>L_FooterProgNameClick
Func L_TitleClick()
	ShellExecute("http://www.phoenix125.com/UniFiCameraImageArchiverFTPUploader.html")
EndFunc   ;==>L_TitleClick
Func O_C_CheckForUpdatesClick()
	If GUICtrlRead($O_C_CheckForUpdates) = $GUI_CHECKED Then
		$aUtilCheckForUpdateYN = "yes"
	Else
		$aUtilCheckForUpdateYN = "no"
	EndIf
	IniWrite($aIniFile, " --------------- " & StringUpper($aUtilName) & " OPTIONS --------------- ", "Check for updates at program start? (yes/no) ###", $aUtilCheckForUpdateYN)
EndFunc   ;==>O_C_CheckForUpdatesClick
Func O_R_LogAllClick()
	If GUICtrlRead($O_R_LogAll) = $GUI_CHECKED Then $aLogLevel = 1
	IniWrite($aIniFile, " --------------- " & StringUpper($aUtilName) & " OPTIONS --------------- ", "Log Level 1-All, 2-Fails, 3-None (1-3) ###", $aLogLevel)
EndFunc   ;==>O_R_LogAllClick
Func O_R_LogFailsClick()
	If GUICtrlRead($O_R_LogFails) = $GUI_CHECKED Then $aLogLevel = 2
	IniWrite($aIniFile, " --------------- " & StringUpper($aUtilName) & " OPTIONS --------------- ", "Log Level 1-All, 2-Fails, 3-None (1-3) ###", $aLogLevel)
EndFunc   ;==>O_R_LogFailsClick
Func O_R_LogNoneClick()
	If GUICtrlRead($O_R_LogNone) = $GUI_CHECKED Then $aLogLevel = 3
	IniWrite($aIniFile, " --------------- " & StringUpper($aUtilName) & " OPTIONS --------------- ", "Log Level 1-All, 2-Fails, 3-None (1-3) ###", $aLogLevel)
EndFunc   ;==>O_R_LogNoneClick
Func P_AboutClick()
	MsgBox($MB_SYSTEMMODAL, $aUtilName, $aUtilName & @CRLF & "Version: " & $aUtilVer & @CRLF & @CRLF & "Install Path: " & @ScriptDir & _
			@CRLF & @CRLF & "Discord: http://discord.gg/EU7pzPs" & @CRLF & "Website: http://www.phoenix125.com", 15)
EndFunc   ;==>P_AboutClick
Func P_DiscordClick()
	ShellExecute("http://discord.gg/EU7pzPs")
EndFunc   ;==>P_DiscordClick
Func P_DiscussionClick()
	ShellExecute("https://phoenix125.createaforum.com/unificameraimagearchiverftpuploader-discussion/")
EndFunc   ;==>P_DiscussionClick
Func P_HelpClick()
	ShellExecute("http://phoenix125.com/share/unificameraimagearchiverftpuploader/ReadMe.pdf")
EndFunc   ;==>P_HelpClick
Func P_PhoenixLogoClick()
	ShellExecute("http://www.phoenix125.com")
EndFunc   ;==>P_PhoenixLogoClick
Func P_UpdateClick()
	TrayUpdateUtilCheck()
EndFunc   ;==>P_UpdateClick
Func W_ConfigWindowClose()
EndFunc   ;==>W_ConfigWindowClose
Func W_ConfigWindowMaximize()
EndFunc   ;==>W_ConfigWindowMaximize
Func W_ConfigWindowMinimize()
EndFunc   ;==>W_ConfigWindowMinimize
Func W_ConfigWindowRestore()
EndFunc   ;==>W_ConfigWindowRestore
Func _DisableCloseButton($tHwd)
	$aSysMenu = DllCall("User32.dll", "hwnd", "GetSystemMenu", "hwnd", $tHwd, "int", 0)
	$hSysMenu = $aSysMenu[0]
	DllCall("User32.dll", "int", "RemoveMenu", "hwnd", $hSysMenu, "int", 0xF060, "int", 0) ; 0=Disable, 1=Enable, CLOSE = 0xF060, MOVE = 0xF010, MAXIMIZE = 0xF030, MINIMIZE = 0xF020, SIZE = 0xF000, RESTORE = 0xF120
	DllCall("User32.dll", "int", "DrawMenuBar", "hwnd", $tHwd)
EndFunc   ;==>_DisableCloseButton

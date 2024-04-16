!include WinMessages.nsh
!include "MUI2.nsh"
!include WinMessages.nsh

; Define installer name
Outfile "InstallOCaml.exe"
Name "OCaml"
Unicode True

; Define default installation directory
InstallDir $PROGRAMFILES64\OCaml

!define STARTMENU_FOLDER "OCaml"

; Include Modern UI
!include "MUI2.nsh"

; Interface settings
!define MUI_ABORTWARNING

; Pages
!insertmacro MUI_PAGE_LICENSE "LICENSE"
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

; Languages
!insertmacro MUI_LANGUAGE "English"

Section "Install"
    SetOutPath $INSTDIR

    ; Copy files from dune/_build/install/default
    File /r "..\dune\_build\install\default\*.*"

    ; Copy files from ocaml/_ocaml-prefix
    File /r "..\ocaml\_ocaml-prefix\*.*"

    EnVar::Check "Path" "NULL"
    Pop $0
    DetailPrint "EnVar::Check write access HKCU returned=|$0|"


    EnVar::SetHKCU
    EnVar::Check "Path" "$INSTDIR"
    Pop $0
    ${If} $0 = 0
	DetailPrint "Already in Path"
    ${Else}
	EnVar::AddValue "Path" "$INSTDIR"
	EnVar::Update "HKCU" "Path"
	Pop $0 ; 0 on success
	DetailPrint "Added to Path"
    ${EndIf}

    SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000

    ; Add to PATH
    WriteRegStr HKLM "SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "Path" "$INSTDIR\bin"
    WriteRegStr HKCU "Software\OCaml" "" "$INSTDIR\bin"

    ; Write uninstall information
    WriteUninstaller $INSTDIR\UninstallOCaml.exe
SectionEnd

Section "Uninstall"
    ; Remove files
    RMDir /r $INSTDIR

    EnVar::SetHKCU
    EnVar::DeleteValue "Path" "$INSTDIR"
    EnVar::Update "HKCU" "Path"
    SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000

    ; Remove from PATH - This part is more complex in a real scenario because you need to 
    ; carefully remove your path without disrupting other entries. This example simply reverts 
    ; to an empty path for demonstration purposes.
    DeleteRegKey HKCU "Software\OCaml"
    DeleteRegKey HKLM "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"

    ; Remove uninstaller
    Delete $INSTDIR\UninstallOCaml.exe
SectionEnd

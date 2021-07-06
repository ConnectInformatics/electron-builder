!include x64.nsh
!include WinVer.nsh

BrandingText "${PRODUCT_NAME} ${VERSION}"

ShowInstDetails nevershow
SpaceTexts none
!ifdef BUILD_UNINSTALLER
  ShowUninstDetails nevershow
!endif
FileBufSize 64

Var /GLOBAL appTitle
Name $appTitle
!define PRODUCT_NAME $appTitle
!define PRODUCT_FILENAME ${PRODUCT_NAME}
!define APP_FILENAME ${PRODUCT_NAME}
!define APP_DESCRIPTION ""
; !define APP_ID ${PRODUCT_NAME}
!define APP_PACKAGE_NAME ${PRODUCT_NAME}
!define APP_PRODUCT_FILENAME ${PRODUCT_NAME}
!define UNINSTALL_DISPLAY_NAME "${PRODUCT_NAME} ${VERSION}"
!define SHORTCUT_NAME ${PRODUCT_NAME}
!define APP_EXECUTABLE_FILENAME "${PRODUCT_FILENAME}.exe"
!define UNINSTALL_FILENAME "Uninstall ${PRODUCT_FILENAME}.exe"
!define INSTALL_REGISTRY_KEY "Software\${PRODUCT_NAME}"
!define UNINSTALL_REGISTRY_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"


!define MUI_ICON   "C:/S/CNET.Equipe2.Angular/CNET.Equipe2.Acco.App/out/icon.ico";
!define MUI_UNICON "C:/S/CNET.Equipe2.Angular/CNET.Equipe2.Acco.App/out/icon.ico";
Icon "C:/S/CNET.Equipe2.Angular/CNET.Equipe2.Acco.App/out/icon.ico"

!macro check64BitAndSetRegView
  # https://github.com/electron-userland/electron-builder/issues/2420
  ${If} ${IsWin2000}
  ${OrIf} ${IsWinME}
  ${OrIf} ${IsWinXP}
  ${OrIf} ${IsWinVista}
    MessageBox MB_OK "$(win7Required)"
    Quit
  ${EndIf}

  !ifdef APP_ARM64
    ${If} ${RunningX64}
      SetRegView 64
    ${EndIf}
    ${If} ${IsNativeARM64}
      SetRegView 64
    ${EndIf}
  !else
    !ifdef APP_64
      ${If} ${RunningX64}
        SetRegView 64
      ${Else}
        !ifndef APP_32
          MessageBox MB_OK|MB_ICONEXCLAMATION "$(x64WinRequired)"
          Quit
        !endif
      ${EndIf}
    !endif
  !endif
!macroend

# avoid exit code 2
!macro quitSuccess
  SetErrorLevel 0
  Quit
!macroend

!macro setLinkVars

  # old desktop shortcut (could exist or not since the user might has selected to delete it)
  ReadRegStr $oldShortcutName SHELL_CONTEXT "${INSTALL_REGISTRY_KEY}" ShortcutName
  ${if} $oldShortcutName == ""
    StrCpy $oldShortcutName "${PRODUCT_FILENAME}"
  ${endIf}
  StrCpy $oldDesktopLink "$DESKTOP\$oldShortcutName.lnk"

  # new desktop shortcut (will be created/renamed in case of a fresh installation or if the user haven't deleted the initial one)
  StrCpy $newDesktopLink "$DESKTOP\${SHORTCUT_NAME}.lnk"

  ReadRegStr $oldMenuDirectory SHELL_CONTEXT "${INSTALL_REGISTRY_KEY}" MenuDirectory
  ${if} $oldMenuDirectory == ""
    StrCpy $oldStartMenuLink "$SMPROGRAMS\$oldShortcutName.lnk"
  ${else}
    StrCpy $oldStartMenuLink "$SMPROGRAMS\$oldMenuDirectory\$oldShortcutName.lnk"
  ${endIf}

  # new menu shortcut (will be created/renamed in case of a fresh installation or if the user haven't deleted the initial one)
  !ifdef MENU_FILENAME
    StrCpy $newStartMenuLink "$SMPROGRAMS\${MENU_FILENAME}\${SHORTCUT_NAME}.lnk"
  !else
    StrCpy $newStartMenuLink "$SMPROGRAMS\${SHORTCUT_NAME}.lnk"
  !endif
!macroend

!macro skipPageIfUpdated
  !define UniqueID ${__LINE__}

  Function skipPageIfUpdated_${UniqueID}
    ${if} ${isUpdated}
      Abort
    ${endif}
  FunctionEnd

  !define MUI_PAGE_CUSTOMFUNCTION_PRE skipPageIfUpdated_${UniqueID}
  !undef UniqueID
!macroend

!macro StartApp
  Var /GLOBAL startAppArgs
  ${if} ${isUpdated}
    StrCpy $startAppArgs "--updated"
  ${else}
    StrCpy $startAppArgs ""
  ${endif}

  ${StdUtils.ExecShellAsUser} $0 "$launchLink" "open" "$startAppArgs"
!macroend

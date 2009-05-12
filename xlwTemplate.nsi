	!include "MUI2.nsh"
	!include ".\version.nsh"
	!include "LogicLib.nsh"


;------------------------------------------------------------------------------------------------------------------------
;------------------------------------------------------------------------------------------------------------------------
;Definitions

    !define APP "xlwTemplateExtractor"
	 Name "${APP}"
     OutFile "${APP}.exe"
	 
	 !define MUI_ICON "xlw\docs\images\xlw_32x32.ico"

	 RequestExecutionLevel user
	 
	 InstallDir $DOCUMENTS

     !define MUI_HEADERIMAGE_BITMAP "xlw-site\images\logo.bmp"
	 !define MUI_HEADERIMAGE
	 
	!define MUI_WELCOMEFINISHPAGE_BITMAP   "xlw-site\images\header.bmp"
	!define MUI_WELCOMEPAGE_TITLE "Welcome to the installer of xlw 4.0"
	 
	 
	 Page custom ExtractorPage ;Custom page
	 !define MUI_DIRECTORYPAGE_TEXT_TOP "Select the directory where the template project will be placed"

	 !insertmacro MUI_PAGE_DIRECTORY
     !insertmacro MUI_PAGE_INSTFILES





Var DIALOG
Var HEADLINE
Var TEXT
Var IMAGECTL
Var IMAGE
Var DIRECTORY
Var FREESPACE

Var HEADLINE_FONT
Var STATE
	
Var VC9
Var VC8
Var VC71
Var CODEBLOCKS
Var DEVCPP
Var GCC

Var VC9_STATE
Var VC8_STATE
Var VC71_STATE
Var CODEBLOCKS_STATE
Var DEVCPP_STATE
Var GCC_STATE



	
Function ExtractorPage

	GetDlgItem $0 $HWNDPARENT 1
	EnableWindow $0 0

	nsDialogs::Create 1018
	Pop $DIALOG

	nsDialogs::CreateControl STATIC ${WS_VISIBLE}|${WS_CHILD}|${WS_CLIPSIBLINGS}|${SS_CENTER} 0 0 0 100% 30 "XLW Template Extractor"
	Pop $HEADLINE

	SendMessage $HEADLINE ${WM_SETFONT} $HEADLINE_FONT 0

	nsDialogs::CreateControl STATIC ${WS_VISIBLE}|${WS_CHILD}|${WS_CLIPSIBLINGS} 50 30 30 100% 30 "Select the Dev enviroment for which the template project is to be extracted"
	Pop $TEXT

	GetFunctionAddress $0 RadioChanged
	
	${NSD_CreateRadioButton} 100 70 100% 10% "Visual C++ 2008 (VC9)"    
	Pop $VC9
	nsDialogs::OnClick  $VC9 $0
    ${NSD_CreateRadioButton} 100 90 100% 10% "Visual C++ 2005 (VC8)" 
	Pop $VC8
	nsDialogs::OnClick  $VC8 $0
	${NSD_CreateRadioButton} 100 110 100% 10% "Visual C++ 2003 (VC7.1)" 
	Pop $VC71
	nsDialogs::OnClick  $VC71 $0
	${NSD_CreateRadioButton} 100 130 100% 10% "Code::Blocks(MingW)"
	Pop $CODEBLOCKS
	nsDialogs::OnClick  $CODEBLOCKS $0
	${NSD_CreateRadioButton} 100 150 100% 10% "Dev-C++"
	Pop $DEVCPP
	nsDialogs::OnClick  $DEVCPP $0
	${NSD_CreateRadioButton} 100 170 100% 10% "GCC/Make"
	Pop $GCC
	nsDialogs::OnClick  $GCC $0
	
	nsDialogs::Show

FunctionEnd

Var RadioStatus

Function RadioChanged
	Pop $0 # dir hwnd

	GetDlgItem $0 $HWNDPARENT 1
	EnableWindow $0 1

	${NSD_GetState} $GCC $GCC_STATE
	${NSD_GetState} $VC9 $VC9_STATE
	${NSD_GetState} $VC8 $VC8_STATE
	${NSD_GetState} $VC71 $VC71_STATE
	${NSD_GetState} $CODEBLOCKS $CODEBLOCKS_STATE
	${NSD_GetState} $DEVCPP $DEVCPP_STATE
	
	
FunctionEnd

Var DIR

!macro projectfiles dir
		SetOutPath "$INSTDIR\${dir}"
		File /nonfatal /r "xlw\Template_Projects\${dir}\*.vcproj"
		File /nonfatal /r "xlw\Template_Projects\${dir}\*.csproj"
		File /nonfatal /r "xlw\Template_Projects\${dir}\*.sln"
		File /nonfatal /r "xlw\Template_Projects\${dir}\*.mak"
		File /nonfatal /r "xlw\Template_Projects\${dir}\Makefile.RELEASE"
		File /nonfatal /r "xlw\Template_Projects\${dir}\Makefile"
		File /nonfatal /r "xlw\Template_Projects\${dir}\*.dev"
		File /nonfatal /r "xlw\Template_Projects\${dir}\*.cbp"
		File /nonfatal /r "xlw\Template_Projects\${dir}\*.workspace"
		CreateDirectory  "$INSTDIR\${dir}\AutoGeneratedSource"
	!macroend
	
		
	!macro sourcefiles dir
		SetOutPath "$INSTDIR\${dir}"
		File /nonfatal /r "xlw\Template_Projects\${dir}\*.cpp"
		File /nonfatal /r "xlw\Template_Projects\${dir}\*.h"
		File /nonfatal /r "xlw\Template_Projects\${dir}\*.cs"
		File /nonfatal /r "xlw\Template_Projects\${dir}\*.snk"
	!macroend



!macro GETDIR  STATEFLAG TDIR

	${If} ${STATEFLAG} ==  ${BST_CHECKED}

			!insertmacro projectfiles ${TDIR}
			!insertmacro sourcefiles  ${TDIR}
	${Endif}


!macroend

Section #
	!insertmacro GETDIR $VC9_STATE "vc9"
	!insertmacro GETDIR $VC8_STATE "vc8"
	!insertmacro GETDIR $VC71_STATE "vc7"
	!insertmacro GETDIR $GCC_STATE "gcc-make"
	!insertmacro GETDIR $CODEBLOCKS_STATE "codeblocks-gcc"
	!insertmacro GETDIR $DEVCPP_STATE "devcpp"	 
SectionEnd 











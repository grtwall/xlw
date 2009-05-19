

	!define DEV_OR_RELEASE "- This is a development version - alpha release"  ; uncomment on development version
	;!define DEV_OR_RELEASE ""                                ; uncomment on release version

;------------------------------------------------------------------------------------------------------------------------
;------------------------------------------------------------------------------------------------------------------------
;Include Modern UI

    !include "MUI2.nsh"
	!include ".\version.nsh"
	!include "LogicLib.nsh"
	!include "winmessages.nsh"


;------------------------------------------------------------------------------------------------------------------------
;------------------------------------------------------------------------------------------------------------------------
;Definitions

    !define APP "xlw"
    !define APP_VER ${APP}-${XLW_VERSION}
	 

;------------------------------------------------------------------------------------------------------------------------
;------------------------------------------------------------------------------------------------------------------------
;General

    ;Name and file
    Name "${APP}"
    OutFile "${APP_VER}.exe"


	
	LicenseForceSelection radiobuttons "I Accept" "I Decline"
	BrandingText "${APP_VER}  ${DEV_OR_RELEASE}"

    ;Default installation folder
    InstallDir $PROGRAMFILES\XLW\${APP_VER}
    ;InstallDir C:\TEMP\${APP_VER}

    ;Get installation folder from registry if available
    InstallDirRegKey HKCU "Software\XLW\${XLW_VERSION}" "InstallDir"

	
	
    ;Request application privileges for Windows Vista
    RequestExecutionLevel admin
	
	
	

;------------------------------------------------------------------------------------------------------------------------
;------------------------------------------------------------------------------------------------------------------------
;Interface Settings

    !define MUI_ABORTWARNING
    !define MUI_ICON "xlw\docs\images\xlw_32x32.ico"
    !define MUI_UNICON "xlw\docs\images\xlw_32x32.ico"
	!define MUI_HEADERIMAGE

	!define MUI_HEADERIMAGE_BITMAP "xlw-site\images\logo.bmp"
	!define MUI_WELCOMEFINISHPAGE_BITMAP   "xlw-site\images\header.bmp"
	!define MUI_WELCOMEPAGE_TITLE "Welcome to the installer of xlw 4.0"
	
	



;------------------------------------------------------------------------------------------------------------------------
;------------------------------------------------------------------------------------------------------------------------
;Pages
    !insertmacro MUI_PAGE_WELCOME
    !insertmacro MUI_PAGE_LICENSE "xlwLICENSE.rtf"

	Page custom DevEnvironFinder ;Custom page
	Page custom PlatformSDK ;Custom page
    !insertmacro MUI_PAGE_COMPONENTS
    !insertmacro MUI_PAGE_DIRECTORY
    !insertmacro MUI_PAGE_INSTFILES

    !insertmacro MUI_UNPAGE_CONFIRM
    !insertmacro MUI_UNPAGE_INSTFILES
	

;------------------------------------------------------------------------------------------------------------------------
;------------------------------------------------------------------------------------------------------------------------
;Languages

    !insertmacro MUI_LANGUAGE "English"
	
;------------------------------------------------------------------------------------------------------------------------
;------------------------------------------------------------------------------------------------------------------------
;Global Status Vaiables

	 Var VS2003_Saved
	 Var VS2005_Saved
	 Var VS2008_Saved
	 Var DEVCPP_Saved
	 Var CODEBLOCKS_Saved
	 Var GCCMAKE_Saved
	 
	 Var VS2005DotNet_Saved
	 Var VS2008DotNet_Saved
	 
	Var Dialog
	Var Label
	Var ListBox
	Var VS2008PRO_CPP_INST
	Var VS2008PRO_CSharp_INST
	Var VS2008EXP_CPP_INST
	Var VS2008EXP_CSharp_INST
	Var VS2005PRO_CPP_INST
	Var VS2005PRO_CSharp_INST
	Var VS2005EXP_CPP_INST
	Var VS2005EXP_CSharp_INST
	Var VS2003PRO_CPP_INST
	Var CodeBlocks_INST
	Var DEVCPP_INST
	Var PSDK
	
	Var CPP_DETECTED

;------------------------------------------------------------------------------------------------------------------------
;------------------------------------------------------------------------------------------------------------------------
; macros
	!macro projectfiles dir
		SetOutPath "$INSTDIR\${dir}"
		File /nonfatal /r "${dir}\*.vcproj"
		File /nonfatal /r "${dir}\*.csproj"
		File /nonfatal /r "${dir}\*.sln"
		File /nonfatal /r "${dir}\*.mak"
		File /nonfatal /r "${dir}\Makefile.RELEASE"
		File /nonfatal /r "${dir}\Makefile"
		File /nonfatal /r "${dir}\*.dev"
		File /nonfatal /r "${dir}\*.cbp"
		File /nonfatal /r "${dir}\*.workspace"
		CreateDirectory  "$INSTDIR\${dir}\AutoGeneratedSource"
	!macroend
	
		
	!macro sourcefiles dir
		SetOutPath "$INSTDIR\${dir}"
		File /nonfatal /r "${dir}\*.cpp"
		File /nonfatal /r "${dir}\*.h"
		File /nonfatal /r "${dir}\*.cs"
		File /nonfatal /r "${dir}\*.snk"
	!macroend
	
	!macro addsource
			SetOutPath "$INSTDIR\xlw\src"
			File /r "xlw\src\*.cpp"
			File /nonfatal /r "xlw\src\*.h"
			SetOutPath "$INSTDIR\xlw\InterfaceGenerator"
			File /r "xlw\InterfaceGenerator\*.cpp"
			File /r "xlw\InterfaceGenerator\*.h"
	!macroend
	

	!macro buildfiles  dir
		!insertmacro projectfiles "xlw\build\${dir}"
		!insertmacro addsource
	!macroend

	Var X
	
	!macro insertline
		${NSD_LB_AddString} $ListBox_right ""
	!macroend
	
	!macro FINDENV root key subkey env
		ReadRegStr $X  ${root} "${key}"  "${subkey}" 
		${If} $X != ""
			${NSD_LB_AddString} $ListBox_right "Detected ${env}"
			!insertmacro insertline
		${EndIf}
		Push $X
	!macroend
	
	!macro DotNetbuildfiles  dir
		SetOutPath "$INSTDIR\xlwDotNet\xlwDotNet"
		File  "xlwDotNet\xlwDotNet\*.cpp"

		SetOutPath "$INSTDIR\xlwDotNet\build\${dir}"
		File /r "xlwDotNet\build\${dir}\*.sln"
		File /r "xlwDotNet\build\${dir}\*.vcproj"
		File /r "xlwDotNet\build\${dir}\*.csproj"
	
	!macroend
	
	!macro DotNetHeaders
			SetOutPath "$INSTDIR\xlwDotNet\xlwDotNet"
			File  "xlwDotNet\xlwDotNet\*.h"
			File  "xlwDotNet\xlwDotNet\*.snk"
			
			SetOutPath "$INSTDIR\xlwDotNet\vc_common"
			File  "xlwDotNet\vc_common\*.nmake"
	
	!macroend
	
	!macro dotNetInterfaceGenSource
			SetOutPath "$INSTDIR\xlwDotNet\DotNetInterfaceGenerator"
			File  /r "xlwDotNet\DotNetInterfaceGenerator\*.cs"
	!macroend	
	
	!macro DotNetInterfaceGenerator  dir
			SetOutPath "$INSTDIR\xlwDotNet\build\${dir}\Debug"
			File  "xlwDotNet\build\${dir}\Debug\*.dll"
			File  "xlwDotNet\build\${dir}\Debug\*.exe"
			File  "xlwDotNet\build\${dir}\Debug\*.pdb"
			
			SetOutPath "$INSTDIR\xlwDotNet\build\${dir}\Release"
			File  "xlwDotNet\build\${dir}\Release\*.dll"
			File  "xlwDotNet\build\${dir}\Release\*.exe"
			
			!insertmacro DotNetHeaders
	!macroend
	
	!macro InterfaceGenerator  dir
			SetOutPath "$INSTDIR\xlw\build\${dir}\Debug"
			File  "xlw\build\${dir}\Debug\*.exe"
			File  "xlw\build\${dir}\Debug\*.pdb"
			
			SetOutPath "$INSTDIR\xlw\build\${dir}\Release"
			File  "xlw\build\${dir}\Release\*.exe"
			
	!macroend
	
	!macro doExamplVCHelper dir
	
			SetOutPath "$INSTDIR\${dir}"
			File  /nonfatal /r "${dir}\*.cpp"
			File  /nonfatal /r "${dir}\*.h"
			File  /nonfatal /r "${dir}\*.vcproj"
			File  /nonfatal /r "${dir}\*.csproj"
			File  /nonfatal /r "${dir}\*.sln"
			File  /nonfatal /r "${dir}\*.nmake"
			CreateDirectory  "$INSTDIR\${dir}\AutoGeneratedSource"
	!macroend
	
	!macro doExample dir
			Push $0
			
			SetOutPath "$INSTDIR\${dir}"
			File  /nonfatal /r "${dir}\*.xls"
			File  /nonfatal /r "${dir}\*.txt"
			
			SetOutPath "$INSTDIR\${dir}\common_source"
			File  /nonfatal /r "${dir}\common_source\*.cpp"
			File  /nonfatal /r "${dir}\common_source\*.h"
			
			
			
			SectionGetFlags ${VS2003} $0 
			${If} $0 == "1"
				!insertmacro doExamplVCHelper "${dir}\vc7"
			${EndIf}
			
			SectionGetFlags ${VS2005} $0 
			${If} $0 == "1"
				!insertmacro doExamplVCHelper "${dir}\vc8"
			${EndIf}
			
			SectionGetFlags ${VS2008} $0 
			${If} $0 == "1"
				!insertmacro doExamplVCHelper "${dir}\vc9"
			${EndIf}
			
			SectionGetFlags ${VS2008} $0 
			${If} $0 == "1"
				!insertmacro doExamplVCHelper "${dir}\vc9"
			${EndIf}
			
			SectionGetFlags ${CODEBLOCKS} $0 
			${If} $0 == "1"
				SetOutPath "$INSTDIR\${dir}\codeblocks-gcc"
				File  /nonfatal /r "${dir}\codeblocks-gcc\*.cbp"
				File  /nonfatal /r "${dir}\codeblocks-gcc\*.mak"
				File  /nonfatal /r "${dir}\codeblocks-gcc\*.workspace"
			${EndIf}
			
			SectionGetFlags ${GCCMAKE} $0 
			${If} $0 == "1"
				SetOutPath "$INSTDIR\${dir}\gcc-make"
				File  /nonfatal /r "${dir}\gcc-make\Makefile"
				File  /nonfatal /r "${dir}\gcc-make\*.mak"
			${EndIf}
			
			SectionGetFlags ${DEVCPP} $0 
			${If} $0 == "1"
				SetOutPath "$INSTDIR\${dir}\devcpp"
				File  /nonfatal /r "${dir}\devcpp\*.mak"
				File  /nonfatal /r "${dir}\devcpp\*.dev"
			${EndIf}
			
			Pop $0
	!macroend
	
	!macro doDotNetExample dir
			Push $0
			
			SetOutPath "$INSTDIR\${dir}"
			File  /nonfatal /r "${dir}\*.xls"
			File  /nonfatal /r "${dir}\*.txt"
			
			SetOutPath "$INSTDIR\${dir}\common_source"
			File  /nonfatal /r "${dir}\common_source\*.cs"
			File  /nonfatal /r "${dir}\common_source\*.snk"
			

			SectionGetFlags ${VS2005DotNet} $0 
			${If} $0 == "1"
				!insertmacro doExamplVCHelper "${dir}\vS8"
			${EndIf}
			
			SectionGetFlags ${VS2008DotNet} $0 
			${If} $0 == "1"
				!insertmacro doExamplVCHelper "${dir}\vS9"
			${EndIf}
			

			Pop $0
	!macroend
	
	!macro xlwDotNetReadMes
		SetOutPath "$INSTDIR\xlwDotNet"
		File "xlwDotNet\*.txt"
	!macroend


;------------------------------------------------------------------------------------------------------------------------
;------------------------------------------------------------------------------------------------------------------------
;Installer Sections

Section #
        SetOutPath "$INSTDIR\xlw"
		File "xlw\*.txt"
    
		SetOutPath "$INSTDIR\xlw\include"
		File /r "xlw\include\*.h"
		File /r "xlw\include\*.inl"
		
		SetOutPath "$INSTDIR\xlw\make"
		File  "xlw\make\*.*"
		
		SetOutPath "$INSTDIR\TemplateExtractors"
		File  ".\xlwTemplateExtractor.exe"
		File  ".\xlwDotNetTemplateExtractor.exe"
		
		SetOutPath "$INSTDIR"
		File "xlwLICENSE.rtf"
		
		SetOutPath "$INSTDIR"
		File "Doc-4.0.0alpha1.TXT"
		
		
		!insertmacro xlwDotNetReadMes
		
		WriteUninstaller $INSTDIR\Uninstall.exe
		
		CreateDirectory "$SMPROGRAMS\XLW\${APP_VER}\xlw"
		CreateShortCut  "$SMPROGRAMS\XLW\${APP_VER}\xlw\Extract XLW xll template.lnk " "$INSTDIR\TemplateExtractors\xlwTemplateExtractor.exe"
		CreateShortCut  "$SMPROGRAMS\XLW\${APP_VER}\Getting Started.lnk " "$INSTDIR\Doc-4.0.0alpha0.TXT"
		CreateShortCut  "$SMPROGRAMS\XLW\${APP_VER}\XLW License.lnk " "$INSTDIR\xlwLICENSE.rtf"
		CreateShortCut  "$SMPROGRAMS\XLW\${APP_VER}\Uninstall XLW.lnk " "$INSTDIR\Uninstall.exe"
		
	
		
	
SectionEnd

;--------------------------------------------------
; xlw
SubSection "xlw" xlw

    ; vanilla xlw
	SectionGroup "Libraries" Libraries
	
		Section "VS2003"  VS2003
			SetOutPath "$INSTDIR\xlw\lib"
			File  "xlw\lib\xlw-vc71*.lib"
			File  "xlw\lib\xlw-vc71*.pdb"
			!insertmacro InterfaceGenerator vc7
			
		SectionEnd
		
		Section "VS2005" VS2005
			SetOutPath "$INSTDIR\xlw\lib"
			File "xlw\lib\xlw-vc80*.lib"
			File "xlw\lib\xlw-vc80*.pdb"
			!insertmacro InterfaceGenerator vc8
		SectionEnd
		
		Section "VS2008" VS2008
			SetOutPath "$INSTDIR\xlw\lib"
			File  "xlw\lib\xlw-vc90*.lib"
			File  "xlw\lib\xlw-vc90*.pdb"
			File  "xlw\lib\xlw-vc80*.pdb"
			!insertmacro InterfaceGenerator vc9
		SectionEnd
		
		Section "Dev-C++" DEVCPP
			SetOutPath "$INSTDIR\xlw\lib"
			File  "xlw\lib\libxlw-devcpp*.a"
			SetOutPath "$INSTDIR\xlw\lib"
			File  "xlw\lib\XlOpenClose*.o"
			File  "xlw\lib\xlw-vc80*.pdb"
			SetOutPath "$INSTDIR\xlw\build\devcpp"
			File /r "xlw\build\devcpp\*.exe"
		SectionEnd
		
		Section "Code::Blocks(mingw)" CODEBLOCKS
			SetOutPath "$INSTDIR\xlw\lib"
			File  "xlw\lib\libxlw-gcc*.a"
			SetOutPath "$INSTDIR\xlw\build\codeblocks-gcc\bin"
			File /r "xlw\build\codeblocks-gcc\bin\*.exe"
		SectionEnd
		
		Section "make(mingw)" GCCMAKE
			SetOutPath "$INSTDIR\xlw\lib"
			File  "xlw\lib\libxlw-gcc*.a"
			SetOutPath "$INSTDIR\xlw\build\gcc-make"
			File /r "xlw\build\gcc-make\*.exe"
		SectionEnd
		
	SectionGroupEnd
	

    
	Section "Examples"
	
		!insertmacro doExample "xlw\examples\Example"
		!insertmacro doExample "xlw\examples\Handwritten"
		CreateShortCut  "$SMPROGRAMS\XLW\${APP_VER}\xlw\Examples.lnk " "$INSTDIR\xlw\Examples"
	SectionEnd
	
	; vanilla xlw sources
	SectionGroup "Source" Source
	


		Section "VS2003" VS2003_SRC
			!insertmacro buildfiles "vc7"
			!insertmacro projectfiles "xlw\Template_Projects\vc7"
			!insertmacro sourcefiles  "xlw\Template_Projects\vc7"

		SectionEnd
		
		Section "VS2005" VS2005_SRC
			!insertmacro buildfiles "vc8"
			!insertmacro projectfiles "xlw\Template_Projects\vc8"
			!insertmacro sourcefiles  "xlw\Template_Projects\vc8"
		SectionEnd
		
		
		Section "VS2008" VS2008_SRC
			!insertmacro buildfiles "vc9"
			!insertmacro projectfiles "xlw\Template_Projects\vc9"
			!insertmacro sourcefiles  "xlw\Template_Projects\vc9"
		SectionEnd
		
		Section "Dev-C++" DEVCPP_SRC
			!insertmacro buildfiles "devcpp"
			!insertmacro projectfiles "xlw\Template_Projects\devcpp"
			!insertmacro sourcefiles  "xlw\Template_Projects\devcpp"
		SectionEnd
		
		Section "Code::Blocks(mingw)" CODEBLOCKS_SRC
			!insertmacro buildfiles "codeblocks-gcc"
			!insertmacro projectfiles "xlw\Template_Projects\codeblocks-gcc"
			!insertmacro sourcefiles  "xlw\Template_Projects\codeblocks-gcc"
		SectionEnd
		
		Section "make(mingw)" GCCMAKE_SRC
			!insertmacro buildfiles "gcc-make"
			!insertmacro projectfiles "xlw\Template_Projects\gcc-make"
			!insertmacro sourcefiles  "xlw\Template_Projects\gcc-make"
		SectionEnd
		
	SectionGroupEnd
SubSectionEnd

;--------------------------------------------------
; xlwDotNet
SubSection "xlwDotNet" xlwDotNet

		
    ; vanilla xlw
	SectionGroup "Libraries" xlwDotNetLibraries
	
		Section "VS2005" VS2005DotNet
			SetOutPath "$INSTDIR\xlwDotNet\lib"
			File "xlwDotNet\lib\xlwDotNet-vc80*.dll"
			File "xlwDotNet\lib\xlwDotNet-vc80*.pdb"
			!insertmacro DotNetInterfaceGenerator VS8
			CreateDirectory "$SMPROGRAMS\XLW\${APP_VER}\xlwDotNet"
			CreateShortCut  "$SMPROGRAMS\XLW\${APP_VER}\xlwDotNet\Extract XLW .NET xll template.lnk " "$INSTDIR\TemplateExtractors\xlwDotNetTemplateExtractor.exe"

		SectionEnd
		
		Section "VS2008" VS2008DotNet
			SetOutPath "$INSTDIR\xlwDotNet\lib"
			File "xlwDotNet\lib\xlwDotNet-vc90*.dll"
			File "xlwDotNet\lib\xlwDotNet-vc90*.pdb"
			!insertmacro DotNetInterfaceGenerator VS9
			!insertmacro projectfiles "xlwDotNet\Template_Projects\VS9"
			!insertmacro sourcefiles  "xlwDotNet\Template_Projects\VS9"
			CreateDirectory "$SMPROGRAMS\XLW\${APP_VER}\xlwDotNet"
			CreateShortCut  "$SMPROGRAMS\XLW\${APP_VER}\xlwDotNet\Extract XLW .NET xll template.lnk " "$INSTDIR\TemplateExtractors\xlwDotNetTemplateExtractor.exe"
		SectionEnd
		

	SectionGroupEnd
	
	
  
	Section "Examples" xlwDotNextExamples
	
		!insertmacro xlwDotNetReadMes
		!insertmacro doDotNetExample "xlwDotNet\Example" 
		!insertmacro doDotNetExample "xlwDotNet\XtraExamples\NonPassive"
		!insertmacro doDotNetExample "xlwDotNet\XtraExamples\Python"
		!insertmacro doDotNetExample "xlwDotNet\XtraExamples\RTDExample"
		CreateShortCut  "$SMPROGRAMS\XLW\${APP_VER}\xlwDotNet\Examples.lnk " "$INSTDIR\xlwDotNet\Example"
		CreateShortCut  "$SMPROGRAMS\XLW\${APP_VER}\xlwDotNet\More Examples.lnk " "$INSTDIR\xlwDotNet\XtraExamples"
		
	SectionEnd
	
	; vanilla xlw sources
	SectionGroup "Source" DotNetSource

		Section "VS2005" VS2005DotNet_SRC
			!insertmacro DotNetbuildfiles "VS8"
			!insertmacro DotNetHeaders
			!insertmacro dotNetInterfaceGenSource
			!insertmacro projectfiles "xlwDotNet\Template_Projects\VS8"
			!insertmacro sourcefiles  "xlwDotNet\Template_Projects\VS8"
			${If} VS2005PRO_CSharp_INST != ""  
				!insertmacro projectfiles "xlwDotNet\Template_Projects\Hybrid_Cpp_CSharp_XLLs\VS8_PRO"
				!insertmacro sourcefiles  "xlwDotNet\Template_Projects\Hybrid_Cpp_CSharp_XLLs\VS8_PRO"
			${EndIf}
		SectionEnd
		
		Section "VS2008" VS2008DotNet_SRC
			!insertmacro DotNetbuildfiles "VS9"
			!insertmacro DotNetHeaders
			!insertmacro dotNetInterfaceGenSource
			${If} VS2008PRO_CSharp_INST != ""  
				!insertmacro projectfiles "xlwDotNet\Template_Projects\Hybrid_Cpp_CSharp_XLLs\VS9_PRO"
				!insertmacro sourcefiles  "xlwDotNet\Template_Projects\Hybrid_Cpp_CSharp_XLLs\VS9_PRO"
			${EndIf}
		SectionEnd
		

	SectionGroupEnd
SubSectionEnd


;----------------------------------------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------------------------------------
;Uninstaller Section

Section "Uninstall"

	Delete $INSTDIR\Uninstall.exe
	RMDir /r $INSTDIR
	DeleteRegKey HKCU "Environment\XLW"
    ; make sure windows knows about the change
    SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000
	
	RMDir /r "$SMPROGRAMS\XLW\${APP_VER}"
	RMDir  "$SMPROGRAMS\XLW"
    

SectionEnd

;------------------------------------------------------------------------------------------------------------------------
;------------------------------------------------------------------------------------------------------------------------
; Functions 
Function .onInit 
	
    InitPluginsDir
	SetOutPath $TEMP
    File /oname=logo.bmp "xlw\docs\images\logo.bmp"

    advsplash::show 1000 1000 2000 0xFF6410 $TEMP\logo

    Delete $TEMP\logo.bmp

FunctionEnd


Function .onSelChange

	SectionGetFlags ${VS2003} $0 
	StrCmp $0 1 ThereIs1
	SectionGetFlags ${VS2005} $0 
    StrCmp $0 1 ThereIs1
    SectionGetFlags ${VS2008} $0 
    StrCmp $0 1 ThereIs1
	SectionGetFlags ${DEVCPP} $0 
    StrCmp $0 1 ThereIs1
	SectionGetFlags ${CODEBLOCKS} $0 
    StrCmp $0 1 ThereIs1
	SectionGetFlags ${GCCMAKE} $0 
    StrCmp $0 1 ThereIs1
	
    Call ReloadSections

	Goto End
	
ThereIs1: 
	SectionGetFlags ${VS2005DotNet} $0 
	${If} $0 == "1"
		SectionSetFlags ${VS2005} 1 
	${EndIf}
	SectionGetFlags ${VS2008DotNet} $0 
    ${If} $0 == "1"
		SectionSetFlags ${VS2008} 1 
	${EndIf}
	

	Call SaveSections 
	
End:
FunctionEnd



Function SaveSections 
    SectionGetFlags ${VS2003}  $VS2003_Saved 
	SectionGetFlags ${VS2005}  $VS2005_Saved 
	SectionGetFlags ${VS2008}  $VS2008_Saved 
	SectionGetFlags ${DEVCPP}  $DEVCPP_Saved 
	SectionGetFlags ${CODEBLOCKS}  $CODEBLOCKS_Saved 
	SectionGetFlags ${GCCMAKE}  $GCCMAKE_Saved 
FunctionEnd

Function ReloadSections 
    
    SectionSetFlags ${VS2003} $VS2003_Saved 
	SectionSetFlags ${VS2005} $VS2005_Saved 
	SectionSetFlags ${VS2008} $VS2008_Saved 
	SectionSetFlags ${DEVCPP} $DEVCPP_Saved 
	SectionSetFlags ${CODEBLOCKS} $CODEBLOCKS_Saved 
	SectionSetFlags ${GCCMAKE} $GCCMAKE_Saved 
FunctionEnd


!macro GetPlatformSDKs
	${NSD_LB_AddString} $ListBox_right " Checking for Platform SDK required for Visual Studio Express 2005" 
	StrCpy $0 0
	StrCpy $2 ""
	loop:
	  EnumRegKey $1 HKLM "SOFTWARE\Microsoft\Microsoft SDKs\Windows" $0
	  StrCmp $1 "" done
	  StrCpy $2 $1
	  IntOp $0 $0 + 1
	  ${NSD_LB_AddString} $ListBox " ... Detected Microsoft Platform SDK $2 " 
	  Goto loop
	done:
	${NSD_LB_AddString} $ListBox "" 
	Push $2
!macroend



Function DevEnvironFinder

	StrCpy $PSDK  ""
    nsDialogs::Create 1018
	Pop $Dialog

	${If} $Dialog == error
		Abort
	${EndIf}

	${NSD_CreateLabel} 0 0 100% 12u "Installed Development Enviroments"
	Pop $Label

	${NSD_CreateListBox} 2u 12u 100% 100% " "
	Pop $ListBox
	
	# Visual Studio 2003
 	
	!insertmacro FINDENV HKLM "Software\Microsoft\VisualStudio\7.1\InstalledProducts\VisualC++" "Package"  "Visual Studio 2003 C++"
	Pop $VS2003PRO_CPP_INST

	# Visual Studio 2005
	
	!insertmacro FINDENV HKLM "Software\Microsoft\VisualStudio\8.0\InstalledProducts\Microsoft Visual C++" "Package"  "Visual Studio 2005 C++"
	Pop $VS2005PRO_CPP_INST
	
	!insertmacro FINDENV HKLM "Software\Microsoft\VisualStudio\8.0\InstalledProducts\Microsoft Visual C#" "Package"  "Visual Studio 2005 C#"
	Pop $VS2005PRO_CSharp_INST
	
	# Visual Studio 2008
	
	!insertmacro FINDENV HKLM "Software\Microsoft\VisualStudio\9.0\InstalledProducts\Microsoft Visual C++" "Package"  "Visual Studio 2008 C++"
	Pop $VS2008PRO_CPP_INST
	
	!insertmacro FINDENV HKLM "Software\Microsoft\VisualStudio\9.0\InstalledProducts\Microsoft Visual C#" "Package"  "Visual Studio 2008 C#"
	Pop $VS2008PRO_CSharp_INST
	
	# Visual Studio Express 2005 
	
	!insertmacro FINDENV HKLM "Software\Microsoft\VCExpress\8.0\InstalledProducts\Microsoft Visual C++" "Package"  "Visual Studio Express 2005 C++"
	Pop $VS2005EXP_CPP_INST
	
	!insertmacro FINDENV HKLM "Software\Microsoft\VCSExpress\8.0\InstalledProducts\Microsoft Visual C#" "Package"  "Visual Studio Express 2005 C#"
	Pop $VS2005EXP_CSharp_INST
	
	${If} $VS2005EXP_CPP_INST != ""
		!insertmacro GetPlatformSDKs
		Pop $PSDK
	${EndIf}
	
	# Visual Studio Express 2008 
	
	!insertmacro FINDENV HKLM "Software\Microsoft\VCExpress\9.0\InstalledProducts\Microsoft Visual C++" "Package"  "Visual Studio Express 2008 C++"
	Pop $VS2008EXP_CPP_INST
	
	!insertmacro FINDENV HKLM "Software\Microsoft\VCSExpress\9.0\InstalledProducts\Microsoft Visual C#" "Package"  "Visual Studio Express 2008 C#"
	Pop $VS2008EXP_CSharp_INST
	

	# gcc
	
	!insertmacro FINDENV HKLM "Software\Dev-C++" "Install_Dir"  "Dev-C++"
	Pop $DEVCPP_INST
	
	!insertmacro FINDENV HKCU "Software\CodeBlocks\Components" "MinGW Compiler Suite"  "Code::Blocks(MingW)"
	Pop $CodeBlocks_INST


	nsDialogs::Show


FunctionEnd

Function SetUpInfo

	SectionSetFlags ${VS2003_SRC} 0
	SectionSetFlags ${VS2005_SRC} 0
	SectionSetFlags ${VS2008_SRC} 0
	SectionSetFlags ${DEVCPP_SRC} 0			
 	SectionSetFlags ${CODEBLOCKS_SRC} 0
	SectionSetFlags ${GCCMAKE_SRC} 0
	
	SectionSetFlags ${VS2005DotNet_SRC} 0
	SectionSetFlags ${VS2008DotNet_SRC} 0
	
	SectionSetFlags ${VS2003} 0
	SectionSetFlags ${VS2005} 0
	SectionSetFlags ${VS2008} 0
	SectionSetFlags ${DEVCPP} 0			
 	SectionSetFlags ${CODEBLOCKS} 0
	SectionSetFlags ${GCCMAKE} 0
	
	SectionSetFlags ${VS2005DotNet} 0
	SectionSetFlags ${VS2008DotNet} 0


	${If} $VS2008PRO_CPP_INST != "" 
		StrCpy $CPP_DETECTED  "1"
		SectionSetFlags ${VS2008} 1
	${EndIf}
	
	${If} $VS2008EXP_CPP_INST != ""  
		SectionSetFlags ${VS2008} 1
		StrCpy $CPP_DETECTED  "1"
	${EndIf}
	
	${If} $VS2005PRO_CPP_INST != "" 
		SectionSetFlags ${VS2005} 1
		StrCpy $CPP_DETECTED  "1"
	${EndIf}
	
	${If} $VS2005EXP_CPP_INST != "" 
		SectionSetFlags ${VS2005} 1
		StrCpy $CPP_DETECTED  "1"
	${EndIf}
	
	${If} $VS2003PRO_CPP_INST != "" 
		SectionSetFlags ${VS2003} 1
		StrCpy $CPP_DETECTED  "1"
	${EndIf}
	
	${If} $CodeBlocks_INST != "" 
		SectionSetFlags ${CODEBLOCKS} 1
		StrCpy $CPP_DETECTED  "1"
	${EndIf}
	
	${If}  $DEVCPP_INST != ""  
		SectionSetFlags ${DEVCPP} 1
		StrCpy $CPP_DETECTED  "1"
	${EndIf}
	
	
	SectionSetFlags ${VS2008DotNet} 1
	SectionSetFlags ${VS2005DotNet} 1
	
	
	${If} $VS2008PRO_CSharp_INST == "" 
		${If} $VS2008EXP_CSharp_INST == ""  
			SectionSetFlags ${VS2008DotNet} 0
		${EndIf}
	${EndIf}
	

	${If} $VS2005PRO_CSharp_INST == "" 
		${If} $VS2005EXP_CSharp_INST == ""  
			SectionSetFlags ${VS2005DotNet} 0
		${EndIf}
	${EndIf}

	
	
	${If} $VS2008PRO_CPP_INST == "" 
		${If} $VS2008EXP_CPP_INST == ""  
			SectionSetFlags ${VS2008} 0
			SectionSetFlags ${VS2008DotNet} 0
		${EndIf}
	${EndIf}
	
	${If} $VS2005PRO_CPP_INST == "" 
		${If} $VS2005EXP_CPP_INST == ""  
			SectionSetFlags ${VS2005} 0
			SectionSetFlags ${VS2005DotNet} 0
		${EndIf}
	${EndIf}
	

	StrCpy $PSDK  ""
	
	Call SaveSections 



FunctionEnd 


Function PlatformSDK

	Push $0
	Push $1
	Push $3
	
	StrCpy $1 ""
	Call  SetUpInfo
	
	
	nsDialogs::Create /NOUNLOAD 1018
	Pop $0

	nsDialogs::CreateControl /NOUNLOAD ${__NSD_Text_CLASS} ${DEFAULT_STYLES}|\
	${WS_TABSTOP}|${ES_AUTOHSCROLL}|${ES_MULTILINE}|${WS_VSCROLL} ${__NSD_Text_EXSTYLE} \
	0 13u 100% -13u
	Pop $0
	${If} $CPP_DETECTED == ""
		StrCpy $3 "1"
		StrCpy $1  "$1$\r$\nA C++ build environment not detected but required for xlw$\r$\n"
	${Endif}
	
	${If} $VS2005EXP_CSharp_INST == "1"
		${If} PSDK == ""
		StrCpy $3 "1"
		StrCpy $1 "$1$\r$\nVisual C++ Express 2005 detected but the installer could not detect the"
		StrCpy $1 "$1$\r$\nMicrosoft Platform SDK which is a pre-requisite for xlw under Visual C++ Express 2005$\r$\n"
		${Endif}
	${Endif}
	

	${If} $3 == "1"
		StrCpy $1 "$1$\r$\n$\r$\nTo ABORT installation and install pre-requisites press CANCEL"
		StrCpy $1 "$1$\r$\nTo CONTINUE installation and install  pre-requisites later press NEXT"
		SendMessage $0 ${WM_SETTEXT} 0 "STR:$1"
		nsDialogs::Show
	${EndIF}

	
	Pop $3
	Pop $1
    Pop $0


FunctionEnd

 !define env_hkcu 'HKCU "Environment"'  
   
Function .OnInstSuccess

   
   WriteRegExpandStr HKCU "Environment" "XLW" $INSTDIR
   ; make sure windows knows about the change
   SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000

FunctionEnd



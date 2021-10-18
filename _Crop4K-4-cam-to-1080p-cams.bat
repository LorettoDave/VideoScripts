@echo off
rem *************************************************************************************
rem *  This batch script iterates through the mp4 and mkv files in a directory,         *
rem *  uses ffmpeg to crop each "4K tiled" video into four 1080P videos, and then       *
rem *  moves the original video into a subfolder. It assumes you have recorded four     *
rem *  1920x1080 video streams -- camera(s), desktop(s), microscope(s), etc. -- into    *
rem *  a single, tiled 4K video. It also assumes the defined subfolders already exist   *
rem *  and that you have ffmpeg.exe in your PATH.                                       *
rem *************************************************************************************


rem +-------------------------------------------+
rem + Adjust these variables as needed:         +
rem +-------------------------------------------+

rem File extensions to process:
set videoExtensions=*.mp4,*.mkv

rem Input and output folders:
set outputFolderOriginal=_multicam
set outputFolderSingleCam=_singlecam

rem Stop processing after a set timespan:
rem (Don't set the value if not needed.)
rem set timeDuration=-t 16:25


rem +-------------------------------------------+
rem + Main logic: If no filename is passed in,  +
rem + loop through files and process all. Else, +
rem + only process the specified filename.      +
rem +-------------------------------------------+
IF "%~1" == "" (
	echo .
	echo . Processing all files in current directory.
	echo .
	for %%f in (%videoExtensions%) do (
		CALL :ProcessFile "%%~f","%%~nf"
	)
) ELSE (
	echo .
	echo . Processing files passed in on the command line.
	echo .
	for %%f in (%*) do (
		CALL :ProcessFile "%%~f","%%~nf"
	)
)
EXIT /B %ERRORLEVEL%


rem +-------------------------------------------+
rem + Functions                                 +
rem +-------------------------------------------+
:ProcessFile
	echo ===========================================================
	echo Starting %~1
	echo ===========================================================

	echo -----------------------------------------------------------
	echo %~1 cam 1:
	echo -----------------------------------------------------------
	CALL :RunFfmpeg "%~1","%~2","crop=1920:1080:0:0","cam1"

	echo -----------------------------------------------------------
	echo %~1 cam 2:
	echo -----------------------------------------------------------
	CALL :RunFfmpeg "%~1","%~2","crop=1920:1080:1920:0","cam2"

	echo -----------------------------------------------------------
	echo %~1 cam 3:
	echo -----------------------------------------------------------
	CALL :RunFfmpeg "%~1","%~2","crop=1920:1080:0:1080","cam3"

	echo -----------------------------------------------------------
	echo %~1 cam 4:
	echo -----------------------------------------------------------
	CALL :RunFfmpeg "%~1","%~2","crop=1920:1080:1920:1080","cam4"

	echo MOVING FILE using command: move "%~1" "%outputFolderOriginal%/%~n1%~x1"
	move "%~1" "%outputFolderOriginal%/%~n1%~x1"

	echo .
	echo %~1 done.
	echo .
	echo .
EXIT /B 0


:RunFfmpeg
	echo RUNNING ffmpeg
	ffmpeg %timeDuration% -i "%~1" -filter:v "%~3" -c:a copy "%outputFolderSingleCam%/%~2-%~4.mp4"	
EXIT /B 0

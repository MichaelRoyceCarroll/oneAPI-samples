param (
    [string]$d = "null",
    [switch]$k = $false,
    [switch]$s = $false,
    [switch]$h = $true
)
$TARGET_DIR_ADMIN_DEFAULT = "C:\Program Files (x86)\Intel\renderkit"
$TARGET_DIR_USER_DEFAULT = "%USERPROFILE%\renderkit"

#URL Base
$GITHUB_BASE_URL="https://github.com/RenderKit"
$ISPC_BASE_URL="https://github.com/ispc"

#Versions for Q32024
$RELEASE_VERSION="2024Q3"
$EMBREE_VERSION="4.3.1"
$OPENVKL_VERSION="2.0.1"
$OIDN_VERSION="2.2.2"
$ISPC_VERSION="1.23.0"
$OSPRAY_VERSION="3.1.0"
$OSPRAYSTUDIO_VERSION="1.0.0"
$TBB_DOWNLOAD_VERSION="2021.11.0"

#Download URLS
$EMBREE_FILE="embree-$EMBREE_VERSION.sycl.x64.windows.zip"
$EMBREE_URL="$GITHUB_BASE_URL/embree/releases/download/v$EMBREE_VERSION/$EMBREE_FILE"
$OPENVKL_FILE="openvkl-$OPENVKL_VERSION.sycl.x86_64.windows.zip"
$OPENVKL_URL="$GITHUB_BASE_URL/openvkl/releases/download/v$OPENVKL_VERSION/$OPENVKL_FILE"
$OIDN_FILE="oidn-$OIDN_VERSION.x64.windows.zip"
$OIDN_URL="https://github.com/OpenImageDenoise/oidn/releases/download/v$OIDN_VERSION/$OIDN_FILE"
$ISPC_FILE="ispc-v$ISPC_VERSION-windows.zip"
$ISPC_URL="$ISPC_BASE_URL/ispc/releases/download/v$ISPC_VERSION/$ISPC_FILE"
$OSPRAY_FILE="ospray-$OSPRAY_VERSION.x86_64.windows.zip"
$OSPRAY_URL="$GITHUB_BASE_URL/ospray/releases/download/v$OSPRAY_VERSION/$OSPRAY_FILE"
$OSPRAYSTUDIO_FILE="ospray_studio-$OSPRAYSTUDIO_VERSION.x86_64.windows.zip"
$OSPRAYSTUDIO_URL="$GITHUB_BASE_URL/ospray-studio/releases/download/v$OSPRAYSTUDIO_VERSION/$OSPRAYSTUDIO_FILE"


$TBB_DOWNLOAD_VERSION=2021.11.0
$TBB_SHA="02f0e93600fba69bb1c00e5dd3f66ae58f56e5410342f6155455a95ba373b1b6"
$TBB_FILE="oneapi-tbb-$TBB_DOWNLOAD_VERSION-lin.tgz"
$TBB_URL="https://github.com/oneapi-src/oneTBB/releases/download/v$TBB_DOWNLOAD_VERSION/oneapi-tbb-$TBB_DOWNLOAD_VERSION-win.zip"
$RKCOMMON_SRC_SHA="8ae9f911420085ceeca36e1f16d1316a77befbf6bf6de2a186d65440ac66ff1f"

if ($d -eq "null") {
  $h=$true
} else {
  $h=$false
}

$helpmsg=@'
  Intel(R) Rendering Toolkit (RenderKit) Deploy Script v{0}
  -------------------------------------
  
  This script downloads and deploys Intel Rendering Toolkit libraries for use in development
  You may use these libraries to build:
    1) your own client programs, linked against one of the RenderKit libraries
    2) developer content from the Intel(R) oneAPI samples repository and/or saved from the Intel(R) Developer Cloud
  
  This script will download RenderKit libraries and place them into <target_directory>/renderkit.
  
  Script Usage:
  -------------------------------------
  
    default,-h                 : Show this help message.
    -d <destination directory> : specify writable directory to place RenderKit libraries and install. This toggle will delete and overwrite the destination contents.
    -s                         : silent mode. This mode disables echo report of install. The default directory for install is the present working directory for the script execution, ex: {1}. Change the default directory with -d <destination>. This toggle will delete and overwrite the destination contents.
    -k                         : keep all downloaded archives when finished (do not clean up files).
'@ -f $RELEASE_VERSION, $TARGET_DIR_USER_DEFAULT
if ( $h ) {
Write-Output $helpmsg

exit
}

dir "$d\renderkit"
if (!(Test-Path "$d\renderkit" -PathType "Container")) {
  New-Item -Path "$d\renderkit" -Force -ItemType "Directory"
}

$NUM_ARCHIVES=6
$URL_LIST=@("$EMBREE_URL","$OPENVKL_URL","$OIDN_URL","$ISPC_URL","$OSPRAY_URL","$OSPRAYSTUDIO_URL")
$FILE_LIST=@("$EMBREE_FILE","$OPENVKL_FILE","$OIDN_FILE","$ISPC_FILE","$OSPRAY_FILE","$OSPRAYSTUDIO_FILE")
$FOLDER_LIST=@("embree","openvkl","oidn","ispc","ospray","ospray-studio")
#Do not do the GUI update for Download (improves speed)
$ProgressPreference="SilentlyContinue"

for($i=0; $i -lt $NUM_ARCHIVES; $i++) {
  $fn=$FILE_LIST[$i]
  $folder=$FOLDER_LIST[$i]
  # Download Archive
  Write-Output "Downloading $fn..."
  Invoke-WebRequest $URL_LIST[$i] -OutFile "$d\renderkit\$fn"
  #CRC Check
  #Extract Archive
  Expand-Archive -LiteralPath "$d\renderkit\$fn" -DestinationPath "$d\renderkit\$folder"
}


$EMBREE_VARS=@'
@echo off
REM ======================================================================== 
REM Copyright 2020 Intel Corporation                                         
REM                                                                          
REM Licensed under the Apache License, Version 2.0 (the "License");          
REM you may not use this file except in compliance with the License.         
REM You may obtain a copy of the License at                                  
REM                                                                         
REM     http://www.apache.org/licenses/LICENSE-2.0                           
REM                                                                          
REM Unless required by applicable law or agreed to in writing, software      
REM distributed under the License is distributed on an "AS IS" BASIS,        
REM WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
REM See the License for the specific language governing permissions and      
REM limitations under the License.                                           
REM ======================================================================== 

REM This script configures environment vars for Intel(R) Embree


SET "RENDERKIT_EMBREE_BIN=%~dp0..\bin"

IF NOT EXIST "%RENDERKIT_EMBREE_BIN%" (
    echo "ERROR:  Could not find bin dir %RENDERKIT_EMBREE_BIN%."
    REM  Cleanup
    SET "RENDERKIT_EMBREE_BIN="
    exit /B 1
)

SET "PATH=%RENDERKIT_EMBREE_BIN%;%PATH%"

REM cleanup
SET "RENDERKIT_EMBREE_BIN="

@REM exit /B 0
'@

$OPENVKL_VARS=@'
@echo off
REM ========================================================================
REM Copyright 2020 Intel Corporation
REM
REM Licensed under the Apache License, Version 2.0 (the "License");
REM you may not use this file except in compliance with the License.
REM You may obtain a copy of the License at
REM
REM     http://www.apache.org/licenses/LICENSE-2.0
REM
REM Unless required by applicable law or agreed to in writing, software
REM distributed under the License is distributed on an "AS IS" BASIS,
REM WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
REM See the License for the specific language governing permissions and
REM limitations under the License.
REM ========================================================================

REM This script configures environment vars for Intel(R) Open VKL

SET "RENDERKIT_OPENVKL_BIN=%~dp0..\bin"

IF NOT EXIST "%RENDERKIT_OPENVKL_BIN%" (
    echo "ERROR:  Could not find bin dir %RENDERKIT_OPENVKL_BIN%."
    REM  Cleanup
    SET "RENDERKIT_OPENVKL_BIN="
    exit /B 1
)

SET "PATH=%RENDERKIT_OPENVKL_BIN%;%PATH%"

REM cleanup
SET "RENDERKIT_OPENVKL_BIN="

@REM exit /B 0
'@

$OIDN_VARS=@'
@echo off
REM ======================================================================== 
REM Copyright 2020 Intel Corporation                                         
REM                                                                          
REM Licensed under the Apache License, Version 2.0 (the "License");          
REM you may not use this file except in compliance with the License.         
REM You may obtain a copy of the License at                                  
REM                                                                         
REM     http://www.apache.org/licenses/LICENSE-2.0                           
REM                                                                          
REM Unless required by applicable law or agreed to in writing, software      
REM distributed under the License is distributed on an "AS IS" BASIS,        
REM WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
REM See the License for the specific language governing permissions and      
REM limitations under the License.                                           
REM ======================================================================== 


REM This script configures environment vars for Intel(R) Open Image Denoise

SET "RENDERKIT_OIDN_BIN=%~dp0..\bin"


IF NOT EXIST "%RENDERKIT_OIDN_BIN%" (
    echo "ERROR:  Could not find bin dir %RENDERKIT_OIDN_BIN%."
    REM  Cleanup
    SET "RENDERKIT_OIDN_BIN="
    exit /B 1
)

SET "PATH=%RENDERKIT_OIDN_BIN%;%PATH%"

REM cleanup
SET "RENDERKIT_OIDN_BIN="

@REM exit /B 0
'@

$OSPRAY_VARS=@'
@echo off
REM ========================================================================
REM Copyright 2020 Intel Corporation
REM
REM Licensed under the Apache License, Version 2.0 (the "License");
REM you may not use this file except in compliance with the License.
REM You may obtain a copy of the License at
REM
REM     http://www.apache.org/licenses/LICENSE-2.0
REM
REM Unless required by applicable law or agreed to in writing, software
REM distributed under the License is distributed on an "AS IS" BASIS,
REM WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
REM See the License for the specific language governing permissions and
REM limitations under the License.
REM ========================================================================

REM This script configures environment vars for Intel(R) OSPRay
SET "RENDERKIT_OSPRAY_BIN=%~dp0..\bin"

IF NOT EXIST "%RENDERKIT_OSPRAY_BIN%" (
    echo "ERROR:  Could not find bin dir %RENDERKIT_OSPRAY_BIN%."
    REM  Cleanup
    SET "RENDERKIT_OSPRAY_BIN="
    exit /B 1
)

SET "PATH=%RENDERKIT_OSPRAY_BIN%;%PATH%"

REM cleanup
SET "RENDERKIT_OSPRAY_BIN="

@REM exit /B 0
'@

$OSPRAYSTUDIO_VARS=@'
@echo off
REM ========================================================================
REM Copyright 2020 Intel Corporation
REM
REM Licensed under the Apache License, Version 2.0 (the "License");
REM you may not use this file except in compliance with the License.
REM You may obtain a copy of the License at
REM
REM     http://www.apache.org/licenses/LICENSE-2.0
REM
REM Unless required by applicable law or agreed to in writing, software
REM distributed under the License is distributed on an "AS IS" BASIS,
REM WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
REM See the License for the specific language governing permissions and
REM limitations under the License.
REM ========================================================================

REM This script configures environment vars for Intel(R) OSPRay Studio
SET "RENDERKIT_OSPRAY_STUDIO_BIN=%~dp0..\bin"

IF NOT EXIST "%RENDERKIT_OSPRAY_STUDIO_BIN%" (
    echo "ERROR:  Could not find bin dir %RENDERKIT_OSPRAY_STUDIO_BIN%."
    REM  Cleanup
    SET "RENDERKIT_OSPRAY_STUDIO_BIN="
    exit /B 1
)

SET "PATH=%RENDERKIT_OSPRAY_STUDIO_BIN%;%PATH%"
SET "PYTHONPATH=%RENDERKIT_OSPRAY_STUDIO_BIN%;%PYTHONPATH%"

REM cleanup
SET "RENDERKIT_OSPRAY_STUDIO_BIN="

@REM exit /B 0
'@

$TBB_VARS=@'
@echo off
REM
REM Copyright (c) 2005-2023 Intel Corporation
REM
REM Licensed under the Apache License, Version 2.0 (the "License");
REM you may not use this file except in compliance with the License.
REM You may obtain a copy of the License at
REM
REM     http://www.apache.org/licenses/LICENSE-2.0
REM
REM Unless required by applicable law or agreed to in writing, software
REM distributed under the License is distributed on an "AS IS" BASIS,
REM WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
REM See the License for the specific language governing permissions and
REM limitations under the License.
REM

REM Syntax:
REM  %SCRIPT_NAME% [^<arch^>] [^<vs^>]
REM    ^<arch^> should be one of the following
REM        ia32         : Set up for IA-32  architecture
REM        intel64      : Set up for Intel(R) 64  architecture
REM    if ^<arch^> is not set Intel(R) 64 architecture will be used
REM    ^<vs^> should be one of the following
REM        vs2019      : Set to use with Microsoft Visual Studio 2019 runtime DLLs
REM        vs2022      : Set to use with Microsoft Visual Studio 2022 runtime DLLs
REM        all         : Set to use oneTBB statically linked with Microsoft Visual C++ runtime
REM    if ^<vs^> is not set oneTBB dynamically linked with Microsoft Visual C++ runtime will be used.

set "SCRIPT_NAME=%~nx0"
set "TBB_SCRIPT_DIR=%~d0%~p0"
set "TBBROOT=%TBB_SCRIPT_DIR%.."

:: Set the default arguments
set TBB_TARGET_ARCH=intel64
set TBB_ARCH_SUFFIX=
set TBB_TARGET_VS=vc14

:ParseArgs
:: Parse the incoming arguments
if /i "%1"==""             goto ParseLayout
if /i "%1"=="ia32"         (set TBB_TARGET_ARCH=ia32)     & shift & goto ParseArgs
if /i "%1"=="intel64"      (set TBB_TARGET_ARCH=intel64)  & shift & goto ParseArgs
if /i "%1"=="vs2019"       (set TBB_TARGET_VS=vc14)       & shift & goto ParseArgs
if /i "%1"=="vs2022"       (set TBB_TARGET_VS=vc14)       & shift & goto ParseArgs
if /i "%1"=="all"          (set TBB_TARGET_VS=vc_mt)      & shift & goto ParseArgs

:ParseLayout
if exist "%TBBROOT%\redist\" (
    set "TBB_BIN_DIR=%TBBROOT%\redist"
    set "TBB_SUBDIR=%TBB_TARGET_ARCH%"
    goto SetEnv
)

if "%TBB_TARGET_ARCH%" == "ia32" (
    set TBB_ARCH_SUFFIX=32
)
if exist "%TBBROOT%\bin%TBB_ARCH_SUFFIX%" (
    set "TBB_BIN_DIR=%TBBROOT%\bin%TBB_ARCH_SUFFIX%"
    if "%TBB_TARGET_VS%" == "vc14" (
        set TBB_TARGET_VS=
    )
    goto SetEnv
)
:: Couldn't parse TBBROOT/bin, unset variable
set TBB_ARCH_SUFFIX=

if exist "%TBBROOT%\..\redist\" (
    set "TBB_BIN_DIR=%TBBROOT%\..\redist"
    set "TBB_SUBDIR=%TBB_TARGET_ARCH%\tbb"
    goto SetEnv
)

:SetEnv
if exist "%TBB_BIN_DIR%\%TBB_SUBDIR%\%TBB_TARGET_VS%\tbb12.dll" (
    set "TBB_DLL_PATH=%TBB_BIN_DIR%\%TBB_SUBDIR%\%TBB_TARGET_VS%"
) else (
    echo:
    echo :: ERROR: tbb12.dll library does not exist in "%TBB_BIN_DIR%\%TBB_SUBDIR%\%TBB_TARGET_VS%\"
    echo:
    exit /b 255
)

set "PATH=%TBB_DLL_PATH%;%PATH%"

set "LIB=%TBBROOT%\lib%TBB_ARCH_SUFFIX%\%TBB_SUBDIR%\%TBB_TARGET_VS%;%LIB%"
set "INCLUDE=%TBBROOT%\include;%INCLUDE%"
set "CPATH=%TBBROOT%\include;%CPATH%"
set "CMAKE_PREFIX_PATH=%TBBROOT%;%CMAKE_PREFIX_PATH%"
set "PKG_CONFIG_PATH=%TBBROOT%\lib%TBB_ARCH_SUFFIX%\pkgconfig;%PKG_CONFIG_PATH%"

:End
exit /B 0
'@

$RKCOMMON_VARS=@'
@echo off
REM ========================================================================
REM Copyright 2020 Intel Corporation
REM
REM Licensed under the Apache License, Version 2.0 (the "License");
REM you may not use this file except in compliance with the License.
REM You may obtain a copy of the License at
REM
REM     http://www.apache.org/licenses/LICENSE-2.0
REM
REM Unless required by applicable law or agreed to in writing, software
REM distributed under the License is distributed on an "AS IS" BASIS,
REM WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
REM See the License for the specific language governing permissions and
REM limitations under the License.
REM ========================================================================

REM This script configures environment vars for the rkcommon shared library


SET "RENDERKIT_RKCOMMON_BIN=%~dp0..\bin"

IF NOT EXIST "%RENDERKIT_RKCOMMON_BIN%" (
    echo "ERROR:  Could not find bin dir %RENDERKIT_RKCOMMON_BIN%."
    REM  Cleanup
    SET "RENDERKIT_RKCOMMON_BIN="
    exit /B 1
)

SET "PATH=%RENDERKIT_RKCOMMON_BIN%;%PATH%"

REM cleanup
SET "RENDERKIT_RKCOMMON_BIN="

@REM exit /B 0
'@

# Write the environment variable scripts to disk for each component
Out-File -FilePath "$d/renderkit/embree/rk-embree-vars.bat" -InputObject $EMBREE_VARS -Encoding ASCII
Out-File -FilePath "$d/renderkit/openvkl/rk-openvkl-vars.bat" -InputObject $OPENVKL_VARS -Encoding ASCII
Out-File -FilePath "$d/renderkit/oidn/rk-oidn-vars.bat" -InputObject $OIDN_VARS -Encoding ASCII
Out-File -FilePath "$d/renderkit/ispc/rk-ispc-vars.bat" -InputObject $ISPC_VARS -Encoding ASCII
Out-File -FilePath "$d/renderkit/ospray/rk-ospray-vars.bat" -InputObject $OSPRAY_VARS -Encoding ASCII
Out-File -FilePath "$d/renderkit/ospray-studio/rk-ospray-studio-vars.bat" -InputObject $OSPRAYSTUDIO_VARS -Encoding ASCII
Out-File -FilePath "$d/renderkit/rkcommon/rk-rkcommon-vars.bat" -InputObject $RKCOMMON_VARS -Encoding ASCII
Out-File -FilePath "$d/renderkit/tbb/rk-tbb-vars.bat" -InputObject $TBB_VARS -Encoding ASCII

dir "$d\renderkit"

#echo "The stuff"
#exit 0

#set input parameters

#say help if no parameter or help is specified 


#Set File SHAs

#Construct file list

#Check Hashes of existing files


# if ($h || (!$k && !$s

# write-output $server
# write-output $password
# write-output $force

#$currentHash = Get-FileHash $file | Select-Object Hash
# Do not download if file is present
#$currentHash.Hash -eq $publishedHash






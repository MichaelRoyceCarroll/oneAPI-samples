#!/usr/bin/bash
## Copyright 2024 Intel Corporation
## SPDX-License-Identifier: Apache-2.0
 
#Versions for Q32024
RELEASE_VERSION=2024Q3
EMBREE_VERSION=4.3.1
OPENVKL_VERSION=2.0.1
OIDN_VERSION=2.2.2
ISPC_VERSION=1.23.0
OSPRAY_VERSION=3.1.0
OSPRAYSTUDIO_VERSION=1.0.0
TBB_DOWNLOAD_VERSION=2021.11.0

#URL Base
GITHUB_BASE_URL=https://github.com/RenderKit
ISPC_BASE_URL=https://github.com/ispc

#Download URLS
EMBREE_FILE=embree-${EMBREE_VERSION}.sycl.x86_64.linux.tar.gz
EMBREE_URL=${GITHUB_BASE_URL}/embree/releases/download/v${EMBREE_VERSION}/${EMBREE_FILE}
OPENVKL_FILE=openvkl-${OPENVKL_VERSION}.sycl.x86_64.linux.tar.gz
OPENVKL_URL=${GITHUB_BASE_URL}/openvkl/releases/download/v${OPENVKL_VERSION}/${OPENVKL_FILE}
OIDN_FILE=oidn-${OIDN_VERSION}.x86_64.linux.tar.gz
OIDN_URL=https://github.com/OpenImageDenoise/oidn/releases/download/v${OIDN_VERSION}/${OIDN_FILE}
ISPC_FILE=ispc-v${ISPC_VERSION}-linux.tar.gz
ISPC_URL=${ISPC_BASE_URL}/ispc/releases/download/v${ISPC_VERSION}/${ISPC_FILE}
OSPRAY_FILE=ospray-${OSPRAY_VERSION}.x86_64.linux.tar.gz
OSPRAY_URL=${GITHUB_BASE_URL}/ospray/releases/download/v${OSPRAY_VERSION}/${OSPRAY_FILE}
OSPRAYSTUDIO_FILE=ospray_studio-${OSPRAYSTUDIO_VERSION}.x86_64.linux.tar.gz
OSPRAYSTUDIO_URL=${GITHUB_BASE_URL}/ospray-studio/releases/download/v${OSPRAYSTUDIO_VERSION}/${OSPRAYSTUDIO_FILE}

#rkcommon
TBB_FILE="oneapi-tbb-${TBB_DOWNLOAD_VERSION}-lin.tgz"

#SHA256
EMBREE_SHA="f4e5d36be8b3cd2d3f57fab885ffb769e071f5ce7d2a9ddfba61dae69c18693b"
EMBREE_SHACHK="${EMBREE_SHA} *${EMBREE_FILE}"
OPENVKL_SHA="74939c835ec533c9de7af975e5cd0ee6db74a748388d89c915e3a08ebf274ad0"
OPENVKL_SHACHK="${OPENVKL_SHA} *${OPENVKL_FILE}"
OIDN_SHA="e844b560f9d53f6cf906ea410c9101e9fb1948f91a6a1108133d40321344a977"
OIDN_SHACHK="${OIDN_SHA} *${OIDN_FILE}"
ISPC_SHA="fc31f53f77a67cb5b465727b70af7d6cde8f38012c4ca0f1678b174a955cb5a8"
ISPC_SHACHK="${ISPC_SHA} *${ISPC_FILE}"
OSPRAY_SHA="3cd6b3786efd6f2be78cf32655f46f77f05ee7cc44f9052fe1de410232aecf70"
OSPRAY_SHACHK="${OSPRAY_SHA} *${OSPRAY_FILE}"
OSPRAYSTUDIO_SHA="6256a35bccc73c8ea4865a39d71ffe2f1e1292228d6b5ecda89bc1ff4c9b0284"
OSPRAYSTUDIO_SHACHK="${OSPRAYSTUDIO_SHA} *${OSPRAYSTUDIO_FILE}"

#ext
TBB_SHA="95659f4d7b1711c41ffa190561d4e5b6841efc8091549661c7a2e6207e0fa79b"
RKCOMMON_SRC_SHA="8ae9f911420085ceeca36e1f16d1316a77befbf6bf6de2a186d65440ac66ff1f"

#Target Directory
TARGET_DIR_DEFAULT=$(pwd)
TARGET_DIR=${TARGET_DIR_DEFAULT}
SILENT_MODE=0
HELP_MODE=1
DELETE_TMP=1
 
while getopts d:shk FLAG
do
    case "${FLAG}" in
        d) TARGET_DIR=${OPTARG};HELP_MODE=0;;
        s) SILENT_MODE=1;HELP_MODE=0;;
	h) ;;
	k) DELETE_TMP=0;;
    esac
done
 
if [ "${HELP_MODE}" -eq 1 ]; then
  echo "Intel(R) Rendering Toolkit (RenderKit) Deploy Script v${RELEASE_VERSION}"
  echo "-------------------------------------"
  echo ""
  echo "This script downloads and deploys Intel Rendering Toolkit libraries for use in development"
  echo "You may use these libraries to build:"
  echo "  1) your own client programs, linked against one of the RenderKit libraries"
  echo "  2) developer content from the Intel(R) oneAPI samples repository and/or saved from the Intel(R) Developer Cloud"
  echo ""
  echo "This script will download RenderKit libraries and place them into <target_directory>/renderkit."
  echo ""
  echo "Script Usage:"
  echo "-------------------------------------"
  echo ""
  echo "  default,-h                 : Show this help message."
  echo "  -d <destination directory> : specify writable directory to place RenderKit libraries and install. This toggle will delete and overwrite the destination contents."
  echo "  -s                         : silent mode. This mode disables echo report of install. The default directory for install is the present working directory for the script execution, ex: ${TARGET_DIR_DEFAULT}. Change the default directory with -d <destination>. This toggle will delete and overwrite the destination contents."
  echo "  -k                         : keep all downloaded archives when finished (do not clean up files)."
  exit 0
fi
 
 
# PROCEED WITH INSTALL
FOLDER_LIST=(embree openvkl oidn ispc ospray ospray-studio)
# offsets to avoid tar bomb (per folder)
FOLDER_OFFSET=(0 1 1 1 1 1)
 
for FOLDER in "${FOLDER_LIST}"; do
  if [ -d "${TARGET_DIR}/renderkit/${FOLDER}" ]; then
    rm -rf "${TARGET_DIR}/renderkit/${FOLDER}"
  fi
done
 
if [ ${SILENT_MODE} -eq "0" ]; then
   echo "STATUS: Deploying to ${TARGET_DIR}/renderkit"
fi
 
if [ ! -d "${TARGET_DIR}/renderkit" ]; then
  mkdir -p "${TARGET_DIR}/renderkit"
  if [ ! -d "${TARGET_DIR}/renderkit" ]; then
    echo "ERROR: Can not create ${TARGET_DIR}/renderkit... Check permissions? Exiting..." >&2
    exit -1  
  fi
fi

echo "${EMBREE_SHACHK}" > "${TARGET_DIR}/renderkit/SHA256SUMS"
echo "${OPENVKL_SHACHK}" >> "${TARGET_DIR}/renderkit/SHA256SUMS"
echo "${OIDN_SHACHK}" >> "${TARGET_DIR}/renderkit/SHA256SUMS"
echo "${ISPC_SHACHK}" >> "${TARGET_DIR}/renderkit/SHA256SUMS"
echo "${OSPRAY_SHACHK}" >> "${TARGET_DIR}/renderkit/SHA256SUMS"
echo "${OSPRAYSTUDIO_SHACHK}" >> "${TARGET_DIR}/renderkit/SHA256SUMS"

VERSION_FILE="${TARGET_DIR}/renderkit/VERSION"
echo "${RELEASE_VERSION}" > ${VERSION_FILE}
echo "EMBREE        : ${EMBREE_VERSION}" >> ${VERSION_FILE}
echo "OPENVKL       : ${OPENVKL_VERSION}" >> ${VERSION_FILE}
echo "OIDN          : ${OIDN_VERSION}" >> ${VERSION_FILE}
echo "ISPC          : ${ISPC_VERSION}" >> ${VERSION_FILE}
echo "OSPRAY        : ${OSPRAY_VERSION}" >> ${VERSION_FILE}
echo "OSPRAYSTUDIO  : ${OSPRAYSTUDIO_VERSION}" >> ${VERSION_FILE}
echo ""
echo "Find updated versions of the downloader script at https://github.com/oneAPI-src/oneAPI-samples/RenderingToolkit" >> ${VERSION_FILE}
echo "Report issues to the Intel Rendering Toolkit forums at https://community.intel.com/t5/Intel-Rendering-Toolkit/bd-p/oneapi-rendering-toolkit" >> ${VERSION_FILE}
 
if [ ${SILENT_MODE} -eq "0" ]; then
  cat "${VERSION_FILE}"
  echo "------------------------------------"
  echo ""
fi
 
URL_LIST=(${EMBREE_URL} ${OPENVKL_URL} ${OIDN_URL} ${ISPC_URL} ${OSPRAY_URL} ${OSPRAYSTUDIO_URL})
FILE_LIST=(${EMBREE_FILE} ${OPENVKL_FILE} ${OIDN_FILE} ${ISPC_FILE} ${OSPRAY_FILE} ${OSPRAYSTUDIO_FILE})
SHA256SUM_LIST=(${EMBREE_SHA} ${OPENVKL_SHA} ${OIDN_SHA} ${ISPC_SHA} ${OSPRAY_SHA} ${OSPRAYSTUDIO_SHA})
DL_IDX=0
NUM_COMPONENTS="${#FOLDER_LIST[@]}"

for (( DL_IDX=0; DL_IDX<${NUM_COMPONENTS}; DL_IDX++ )); do
  DOWNLOAD=1
  if [ -f "${TARGET_DIR}/renderkit/${FILE_LIST[${DL_IDX}]}" ]; then
    echo "${SHA256SUM_LIST[${DL_IDX}]} ${TARGET_DIR}/renderkit/${FILE_LIST[${DL_IDX}]}" | sha256sum --check > "${TARGET_DIR}/renderkit/${FILE_LIST[${DL_IDX}]}.chkresult" 2>&1
#    sha256sum -c "${TARGET_DIR}/renderkit/SHA256SUMS" "${TARGET_DIR}/renderkit/${FILE_LIST[${DL_IDX}]}" 2>&1 > /dev/null
    #CURRENT_SUM=$(sha256sum "${TARGET_DIR}/renderkit/${FILE_LIST[${DL_IDX}]}")
    if [ $? -eq 0 ]; then
      DOWNLOAD=0	  
      if [ "${SILENT_MODE}" -eq "0" ]; then
        echo "OK   : SHA256SUM of ${FILE_LIST[${DL_IDX}]}" 	  
      fi	
    else
      echo "ERROR: Bad SHA256SUM of ${FILE_LIST[${DL_IDX}]}... Delete all files in ${TARGET_DIR}/renderkit and try again" >&2
      exit -1      
    fi
  fi

  if [ -d "${TARGET_DIR}/renderkit/${FOLDER_LIST[${DL_IDX}]}" ]; then
    rm -rf "${TARGET_DIR}/renderkit/${FOLDER_LIST[${DL_IDX}]}"
  fi 
  mkdir "${TARGET_DIR}/renderkit/${FOLDER_LIST[${DL_IDX}]}"

  if [ ${DOWNLOAD} -eq 1 ]; then  
    if [ "${SILENT_MODE}" -eq "0" ]; then
      echo "STATUS: Downloading ${FILE_LIST[${DL_IDX}]}"
    fi
    
    if [ "${SILENT_MODE}" -eq "0" ]; then
      wget -O ${TARGET_DIR}/renderkit/${FILE_LIST[${DL_IDX}]} ${URL_LIST[${DL_IDX}]}
    else
      wget -O ${TARGET_DIR}/renderkit/${FILE_LIST[${DL_IDX}]} -q ${URL_LIST[${DL_IDX}]}
    fi

    if [ $? -ne 0 ]; then  
      echo "ERROR: Problem with 'wget' exiting... Check internet connection/proxy" >&2
      exit -1  
    fi
    
    if [ ! -f "${TARGET_DIR}/renderkit/${FILE_LIST[${DL_IDX}]}" ]; then
      echo "ERROR: Could not download ${FILE_LIST[${DL_IDX}]}. Exiting..." >&2
      exit -1
    fi
  
    if [ "${SILENT_MODE}" -eq "0" ]; then
      echo "STATUS: Downloaded ${FILE_LIST[${DL_IDX}]}" 	  
    fi
  
    echo "${SHA256SUM_LIST[${DL_IDX}]} ${TARGET_DIR}/renderkit/${FILE_LIST[${DL_IDX}]}" | sha256sum --check > "${TARGET_DIR}/renderkit/${FILE_LIST[${DL_IDX}]}.chkresult" 2>&1
    if [ $? -ne 0 ]; then  
      echo "ERROR: Failed to check validity of ${FILE_LIST[${DL_IDX}]}. Detail:" >&2
      cat "${TARGET_DIR}/renderkit/${FILE_LIST[${DL_IDX}]}.chkresult" >&2
      echo "Exiting..." >&2
      exit -1
    fi

    if [ "${SILENT_MODE}" -eq "0" ]; then
      cat "${TARGET_DIR}/renderkit/${FILE_LIST[${DL_IDX}]}.chkresult" | sed 's/^/OK   : /g'
    fi
  fi

  FOLDER=${FOLDER_LIST[${DL_IDX}]}
  OFFSET=${FOLDER_OFFSET[${DL_IDX}]} 
  EXTRACTSTRIP_DIR=""
  if [ ${OFFSET} -ne 0 ]; then
    EXTRACTSTRIP_DIR="--strip-components=${OFFSET}"
  fi

  if [ "${SILENT_MODE}" -eq "0" ]; then
    tar -xvf "${TARGET_DIR}/renderkit/${FILE_LIST[${DL_IDX}]}" -C "${TARGET_DIR}/renderkit/${FOLDER}" ${EXTRACTSTRIP_DIR} | sed 's/^/  /g'
    echo "OK   : ${FILE_LIST[${DL_IDX}]} extracted"
  else
    tar -xf "${TARGET_DIR}/renderkit/${FILE_LIST[${DL_IDX}]}" -C "${TARGET_DIR}/renderkit/${FOLDER}" ${EXTRACTSTRIP_DIR}
  fi
 
 
  if [ "${DELETE_TMP}" -ne "0" ]; then
    rm -rf "${TARGET_DIR}/renderkit/${FILE_LIST[${DL_IDX}]}"
    if [ "${SILENT_MODE}" -eq "0" ]; then
      echo "STATUS: ${TARGET_DIR}/renderkit/${FILE_LIST[${DL_IDX}]} removed"
    fi
  fi
done

#################################################
#
# Below the env variable files are generated and written to folders

read -d '\0' VARS_HEADER <<- EOM
	#!/bin/sh
	# shellcheck shell=sh
	
	# Copyright Intel Corporation
	# SPDX-License-Identifier: MIT
	# https://opensource.org/licenses/MIT
	
	
	# ############################################################################
	
	# Copy and include at the top of your \`env/vars.sh\` script (don't forget to
	# remove the test/example code at the end of this file). See the test/example
	# code at the end of this file for more help.
	
	
	# ############################################################################
	
	# Get absolute path to this script.
	# Uses \`readlink\` to remove links and \`pwd -P\` to turn into an absolute path.
	
	# Usage:
	#   script_dir=\$(get_script_path "\$script_rel_path")
	#
	# Inputs:
	#   script/relative/pathname/scriptname
	#
	# Outputs:
	#   /script/absolute/pathname
	
	# executing function in a *subshell* to localize vars and effects on \`cd\`
	get_script_path() (
	  script="\$1"
	  while [ -L "\$script" ] ; do
	    # combining next two lines fails in zsh shell
	    script_dir=\$(command dirname -- "\$script")
	    script_dir=\$(cd "\$script_dir" && command pwd -P)
	    script="\$(readlink "\$script")"
	    case \$script in
	      (/*) ;;
	       (*) script="\$script_dir/\$script" ;;
	    esac
	  done
	  # combining next two lines fails in zsh shell
	  script_dir=\$(command dirname -- "\$script")
	  script_dir=\$(cd "\$script_dir" && command pwd -P)
	  printf "%s" "\$script_dir"
	)
	
	
	# ############################################################################
	
	# Determine if we are being executed or sourced. Need to detect being sourced
	# within an executed script, which can happen on a CI system. We also must
	# detect being sourced at a shell prompt (CLI). The setvars.sh script will
	# always source this script, but this script can also be called directly.
	
	# We are assuming we know the name of this script, which is a reasonable
	# assumption. This script _must_ be named "vars.sh" or it will not work
	# with the top-level setvars.sh script. Making this assumption simplifies
	# the process of detecting if the script has been sourced or executed. It
	# also simplifies the process of detecting the location of this script.
	
	# Using \`readlink\` to remove possible symlinks in the name of the script.
	# Also, "ps -o comm=" is limited to a 15 character result, but it works
	# fine here, because we are only looking for the name of this script or the
	# name of the execution shell, both always fit into fifteen characters.
	
	# TODO: Edge cases exist when executed by way of "/bin/sh setvars.sh"
	# Most shells detect or fall thru to error message, sometimes ksh does not.
	# This is an odd and unusual situation; not a high priority issue.
	
	_vars_get_proc_name() {
	  if [ -n "\${ZSH_VERSION:-}" ] ; then
	    script="\$(ps -p "\$\$" -o comm=)"
	  else
	    script="\$1"
	    while [ -L "\$script" ] ; do
	      script="\$(readlink "\$script")"
	    done
	  fi
	  basename -- "\$script"
	}
	
	_vars_this_script_name="vars.sh"
	if [ "\$_vars_this_script_name" = "\$(_vars_get_proc_name "\$0")" ] ; then
	  echo "   ERROR: Incorrect usage: this script must be sourced."
	  echo "   Usage: . path/to/\${_vars_this_script_name}"
	  return 255 2>/dev/null || exit 255
	fi
	
	
	# ############################################################################
	
	# Prepend path segment(s) to path-like env vars (PATH, CPATH, etc.).
	
	# prepend_path() avoids dangling ":" that affects some env vars (PATH and CPATH)
	# prepend_manpath() includes dangling ":" needed by MANPATH.
	# PATH > https://www.gnu.org/software/libc/manual/html_node/Standard-Environment.html
	# MANPATH > https://manpages.debian.org/stretch/man-db/manpath.1.en.html
	
	# Usage:
	#   env_var=\$(prepend_path "\$prepend_to_var" "\$existing_env_var")
	#   export env_var
	#
	#   env_var=\$(prepend_manpath "\$prepend_to_var" "\$existing_env_var")
	#   export env_var
	#
	# Inputs:
	#   \$1 == path segment to be prepended to \$2
	#   \$2 == value of existing path-like environment variable
	
	prepend_path() (
	  path_to_add="\$1"
	  path_is_now="\$2"
	
	  if [ "" = "\${path_is_now}" ] ; then   # avoid dangling ":"
	    printf "%s" "\${path_to_add}"
	  else
	    printf "%s" "\${path_to_add}:\${path_is_now}"
	  fi
	)
	
	prepend_manpath() (
	  path_to_add="\$1"
	  path_is_now="\$2"
	
	  if [ "" = "\${path_is_now}" ] ; then   # include dangling ":"
	    printf "%s" "\${path_to_add}:"
	  else
	    printf "%s" "\${path_to_add}:\${path_is_now}"
	  fi
	)
	
	
	# ############################################################################
	
	# Extract the name and location of this sourced script.
	
	# Generally, "ps -o comm=" is limited to a 15 character result, but it works
	# fine for this usage, because we are primarily interested in finding the name
	# of the execution shell, not the name of any calling script.
	
	vars_script_name=""
	vars_script_shell="\$(ps -p "\$\$" -o comm=)"
	# \${var:-} needed to pass "set -eu" checks
	# see https://unix.stackexchange.com/a/381465/103967
	# see https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_06_02
	if [ -n "\${ZSH_VERSION:-}" ] && [ -n "\${ZSH_EVAL_CONTEXT:-}" ] ; then     # zsh 5.x and later
	  # shellcheck disable=2249
	  case \$ZSH_EVAL_CONTEXT in (*:file*) vars_script_name="\${(%):-%x}" ;; esac ;
	elif [ -n "\${KSH_VERSION:-}" ] ; then                                     # ksh, mksh or lksh
	  if [ "\$(set | grep -Fq "KSH_VERSION=.sh.version" ; echo \$?)" -eq 0 ] ; then # ksh
	    vars_script_name="\${.sh.file}" ;
	  else # mksh or lksh or [lm]ksh masquerading as ksh or sh
	    # force [lm]ksh to issue error msg; which contains this script's path/filename, e.g.:
	    # mksh: /home/ubuntu/intel/oneapi/vars.sh[137]: \${.sh.file}: bad substitution
	    vars_script_name="\$( (echo "\${.sh.file}") 2>&1 )" || : ;
	    vars_script_name="\$(expr "\${vars_script_name:-}" : '^.*sh: \\\(.*\\\)\\\[[0-9]*\\\]:')" ;
	  fi
	elif [ -n "\${BASH_VERSION:-}" ] ; then        # bash
	  # shellcheck disable=2128
	  (return 0 2>/dev/null) && vars_script_name="\${BASH_SOURCE}" ;
	elif [ "dash" = "\$vars_script_shell" ] ; then # dash
	  # force dash to issue error msg; which contains this script's rel/path/filename, e.g.:
	  # dash: 146: /home/ubuntu/intel/oneapi/vars.sh: Bad substitution
	  vars_script_name="\$( (echo "\${.sh.file}") 2>&1 )" || : ;
	  vars_script_name="\$(expr "\${vars_script_name:-}" : '^.*dash: [0-9]*: \\\(.*\\\):')" ;
	elif [ "sh" = "\$vars_script_shell" ] ; then   # could be dash masquerading as /bin/sh
	  # force a shell error msg; which should contain this script's path/filename
	  # sample error msg shown; assume this file is named "vars.sh"; as required by setvars.sh
	  vars_script_name="\$( (echo "\${.sh.file}") 2>&1 )" || : ;
	  if [ "\$(printf "%s" "\$vars_script_name" | grep -Eq "sh: [0-9]+: .*vars\.sh: " ; echo \$?)" -eq 0 ] ; then # dash as sh
	    # sh: 155: /home/ubuntu/intel/oneapi/vars.sh: Bad substitution
	    vars_script_name="\$(expr "\${vars_script_name:-}" : '^.*sh: [0-9]*: \\\(.*\\\):')" ;
	  fi
	else  # unrecognized shell or dash being sourced from within a user's script
	  # force a shell error msg; which should contain this script's path/filename
	  # sample error msg shown; assume this file is named "vars.sh"; as required by setvars.sh
	  vars_script_name="\$( (echo "\${.sh.file}") 2>&1 )" || : ;
	  if [ "\$(printf "%s" "\$vars_script_name" | grep -Eq "^.+: [0-9]+: .*vars\.sh: " ; echo \$?)" -eq 0 ] ; then # dash
	    # .*: 164: intel/oneapi/vars.sh: Bad substitution
	    vars_script_name="\$(expr "\${vars_script_name:-}" : '^.*: [0-9]*: \\\(.*\\\):')" ;
	  else
	    vars_script_name="" ;
	  fi
	fi
	
	if [ "" = "\$vars_script_name" ] ; then
	  >&2 echo "   ERROR: Unable to proceed: possible causes listed below."
	  >&2 echo "   This script must be sourced. Did you execute or source this script?" ;
	  >&2 echo "   Unrecognized/unsupported shell (supported: bash, zsh, ksh, m/lksh, dash)." ;
	  >&2 echo "   May fail in dash if you rename this script (assumes \"vars.sh\")." ;
	  >&2 echo "   Can be caused by sourcing from ZSH version 4.x or older." ;
	  return 255 2>/dev/null || exit 255
	fi
	
	
	# ############################################################################
	
	
	
EOM

read -d '\0' EMBREE_VARS_FOOTER <<- EOM
	# ############################################################################

	# Get the absolute path to this vars.sh script
	RENDERKIT_EMBREE_SCRIPT_PATH=\$(get_script_path "\${vars_script_name:-}")
	RENDERKIT_EMBREE_ROOT="\${RENDERKIT_EMBREE_SCRIPT_PATH}"
	
	if [ -d "\${RENDERKIT_EMBREE_ROOT}/lib" ] ; then 
	    LD_LIBRARY_PATH=\$(prepend_path "\${RENDERKIT_EMBREE_ROOT}/lib" "\${LD_LIBRARY_PATH:-}") ; export LD_LIBRARY_PATH
	    CMAKE_PREFIX_PATH=\$(prepend_path "\${RENDERKIT_EMBREE_ROOT}/lib/cmake/embree" "\${CMAKE_PREFIX_PATH:-}") ; export CMAKE_PREFIX_PATH
	else
	    echo "ERROR:  Could not find \$RENDERKIT_EMBREE_ROOT/lib.  Please install Intel(R) Embree."  
	fi 
	
	if [ -d "\${RENDERKIT_EMBREE_ROOT}/bin" ] ; then 
	
	    # Add component bin folder to the system PATH, using prepend_path() function.
	    PATH=\$(prepend_path "\${RENDERKIT_EMBREE_ROOT}/bin" "\${PATH:-}") ; export PATH
	
	else
	    echo "ERROR:  Could not find \$RENDERKIT_EMBREE_ROOT/bin.  Please install Intel(R) Embree."  
	fi 
	
	if [ -d "\${RENDERKIT_EMBREE_ROOT}/share/man" ] ; then
	
	    MANPATH=\$(prepend_manpath "\${RENDERKIT_EMBREE_ROOT}/share/man" "\${MANPATH:-}") ; export MANPATH
	fi
	
	if [ -d "\${RENDERKIT_EMBREE_ROOT}/lib/pkgconfig" ] ; then
	    PKG_CONFIG_PATH=\$(prepend_path "\${RENDERKIT_EMBREE_ROOT}/lib/pkgconfig" "\${PKG_CONFIG_PATH:-}") ; export PKG_CONFIG_PATH
	fi

EOM
read -d '\0' OPENVKL_VARS_FOOTER <<- EOM
	# ############################################################################


	# Get the absolute path to this vars.sh script
	RENDERKIT_OPENVKL_SCRIPT_PATH=\$(get_script_path "\${vars_script_name:-}")
	RENDERKIT_OPENVKL_ROOT="\${RENDERKIT_OPENVKL_SCRIPT_PATH}"
	
	if [ -d "\${RENDERKIT_OPENVKL_ROOT}/lib" ] ; then
	    LD_LIBRARY_PATH=\$(prepend_path "\${RENDERKIT_OPENVKL_ROOT}/lib" "\${LD_LIBRARY_PATH:-}") ; export LD_LIBRARY_PATH
	    CMAKE_PREFIX_PATH=\$(prepend_path "\${RENDERKIT_OPENVKL_ROOT}/lib/cmake/openvkl" "\${CMAKE_PREFIX_PATH:-}") ; export CMAKE_PREFIX_PATH
	else
	    echo "ERROR:  Could not find \$RENDERKIT_OPENVKL_ROOT/lib.  Please install Intel(R) Open VKL."
	fi
	
	if [ -d "\${RENDERKIT_OPENVKL_ROOT}/bin" ] ; then
	
	    # Add component bin folder to the system PATH, using prepend_path() function.
	    PATH=\$(prepend_path "\${RENDERKIT_OPENVKL_ROOT}/bin" "\${PATH:-}") ; export PATH
	
	else
	    echo "ERROR:  Could not find \$RENDERKIT_OPENVKL_ROOT/bin.  Please install Intel(R) Open VKL."
	fi
	
	if [ -d "\${RENDERKIT_OPENVKL_ROOT}/lib/pkgconfig" ] ; then
	    PKG_CONFIG_PATH=\$(prepend_path "\${RENDERKIT_OPENVKL_ROOT}/lib/pkgconfig" "\${PKG_CONFIG_PATH:-}") ; export PKG_CONFIG_PATH
	fi

EOM
read -d '\0' OIDN_VARS_FOOTER <<- EOM
	# ############################################################################


	# Get the absolute path to this vars.sh script
	RENDERKIT_OIDN_SCRIPT_PATH=\$(get_script_path "\${vars_script_name:-}")
	RENDERKIT_OIDN_ROOT="\${RENDERKIT_OIDN_SCRIPT_PATH}"
	
	if [ -d "\${RENDERKIT_OIDN_ROOT}/lib" ] ; then
	    LD_LIBRARY_PATH=\$(prepend_path "\${RENDERKIT_OIDN_ROOT}/lib" "\${LD_LIBRARY_PATH:-}") ; export LD_LIBRARY_PATH
	    CMAKE_PREFIX_PATH=\$(prepend_path "\${RENDERKIT_OIDN_ROOT}/lib/cmake/OpenImageDenoise" "\${CMAKE_PREFIX_PATH:-}") ; export CMAKE_PREFIX_PATH
	else
	    echo "ERROR:  Could not find \$RENDERKIT_OIDN_ROOT/lib.  Please install Intel(R) Open Image Denoise."
	fi
	
	if [ -d "\${RENDERKIT_OIDN_ROOT}/bin" ] ; then
	
	    # Add component bin folder to the system PATH, using prepend_path() function.
	    PATH=\$(prepend_path "\${RENDERKIT_OIDN_ROOT}/bin" "\${PATH:-}") ; export PATH
	
	else
	    echo "ERROR:  Could not find \$RENDERKIT_OIDN_ROOT/bin.  Please install Intel(R) Open Image Denoise."
	fi
	
	
	if [ -d "\${RENDERKIT_OIDN_ROOT}/lib/pkgconfig" ] ; then
	    PKG_CONFIG_PATH=\$(prepend_path "\${RENDERKIT_OIDN_ROOT}/lib/pkgconfig" "\${PKG_CONFIG_PATH:-}") ; export PKG_CONFIG_PATH
	fi

EOM
read -d '\0' ISPC_VARS_FOOTER <<- EOM
	# ############################################################################


	# Get the absolute path to this vars.sh script
	RENDERKIT_ISPC_SCRIPT_PATH=\$(get_script_path "\${vars_script_name:-}")
	RENDERKIT_ISPC_ROOT="\${RENDERKIT_ISPC_SCRIPT_PATH}"
	
	if [ -d "\${RENDERKIT_ISPC_ROOT}/bin" ] ; then
	    # Add component bin folder to the system PATH, using prepend_path() function.
	    PATH=\$(prepend_path "\${RENDERKIT_ISPC_ROOT}/bin" "\${PATH:-}") ; export PATH
	else
	    echo "ERROR:  Could not find \$RENDERKIT_ISPC_ROOT/bin.  Please install Intel(R) Implicit SPMD Program compiler."
	fi
	
	if [ -d "\${RENDERKIT_ISPC_ROOT}/lib64" ] ; then
	    # Add component bin folder to the system LD_LIBRARY_PATH, using prepend_path() function.
	    LD_LIBRARY_PATH=\$(prepend_path "\${RENDERKIT_ISPC_ROOT}/lib64" "\${LD_LIBRARY_PATH:-}") ; export LD_LIBRARY_PATH
	    CMAKE_PREFIX_PATH=\$(prepend_path "\${RENDERKIT_ISPC_ROOT}/lib64/cmake/ispcrt" "\${CMAKE_PREFIX_PATH:-}") ; export CMAKE_PREFIX_PATH
	else
	    echo "ERROR:  Could not find \$RENDERKIT_ISPC_ROOT/lib64.  Please install Intel(R) Implicit SPMD Program compiler."
	fi

EOM
read -d '\0' OSPRAY_VARS_FOOTER <<- EOM
	# ############################################################################


	# Get the absolute path to this vars.sh script
	RENDERKIT_OSPRAY_SCRIPT_PATH=\$(get_script_path "\${vars_script_name:-}")
	RENDERKIT_OSPRAY_ROOT="\${RENDERKIT_OSPRAY_SCRIPT_PATH}"
	
	if [ -d "\${RENDERKIT_OSPRAY_ROOT}/lib" ] ; then
	    LD_LIBRARY_PATH=\$(prepend_path "\${RENDERKIT_OSPRAY_ROOT}/lib" "\${LD_LIBRARY_PATH:-}") ; export LD_LIBRARY_PATH
	    CMAKE_PREFIX_PATH=\$(prepend_path "\${RENDERKIT_OSPRAY_ROOT}/lib/cmake/ospray" "\${CMAKE_PREFIX_PATH:-}") ; export CMAKE_PREFIX_PATH
	else
	    echo "ERROR:  Could not find \$RENDERKIT_OSPRAY_ROOT/lib.  Please install Intel(R) OSPRay."
	fi
	
	if [ -d "\${RENDERKIT_OSPRAY_ROOT}/bin" ] ; then
	
	    # Add component bin folder to the system PATH, using prepend_path() function.
	    PATH=\$(prepend_path "\${RENDERKIT_OSPRAY_ROOT}/bin" "\${PATH:-}") ; export PATH
	
	else
	    echo "ERROR:  Could not find \$RENDERKIT_OSPRAY_ROOT/bin.  Please install Intel(R) OSPRay."
	fi
	
	if [ -d "\${RENDERKIT_OSPRAY_ROOT}/lib/pkgconfig" ] ; then
	    PKG_CONFIG_PATH=\$(prepend_path "\${RENDERKIT_OSPRAY_ROOT}/lib/pkgconfig" "\${PKG_CONFIG_PATH:-}") ; export PKG_CONFIG_PATH
	fi

EOM
read -d '\0' OSPRAY_STUDIO_VARS_FOOTER <<- EOM
	# ############################################################################



	# Get the absolute path to this vars.sh script
	RENDERKIT_OSPRAY_STUDIO_SCRIPT_PATH=\$(get_script_path "\${vars_script_name:-}")
	RENDERKIT_OSPRAY_STUDIO_ROOT="\${RENDERKIT_OSPRAY_STUDIO_SCRIPT_PATH}"
	
	if [ -d "\${RENDERKIT_OSPRAY_STUDIO_ROOT}/lib" ] ; then
	
	    LD_LIBRARY_PATH=\$(prepend_path "\${RENDERKIT_OSPRAY_STUDIO_ROOT}/lib" "\${LD_LIBRARY_PATH:-}") ; export LD_LIBRARY_PATH
	    PYTHONPATH=\$(prepend_path "\${RENDERKIT_OSPRAY_STUDIO_ROOT}/lib" "\${PYTHONPATH:-}") ; export PYTHONPATH
	else
	    echo "ERROR:  Could not find \$RENDERKIT_OSPRAY_STUDIO_ROOT/lib.  Please install Intel(R) OSPRay Studio."
	fi
	
	if [ -d "\${RENDERKIT_OSPRAY_STUDIO_ROOT}/bin" ] ; then
	
	    # Add component bin folder to the system PATH, using prepend_path() function.
	    PATH=\$(prepend_path "\${RENDERKIT_OSPRAY_STUDIO_ROOT}/bin" "\${PATH:-}") ; export PATH
	
	else
	    echo "ERROR:  Could not find \$RENDERKIT_OSPRAY_STUDIO_ROOT/bin.  Please install Intel(R) OSPRay Studio."
	fi

EOM

read -d '\0' RKCOMMON_VARS_FOOTER <<- EOM
	# ############################################################################
	# Get the absolute path to this vars.sh script
	RENDERKIT_RKCOMMON_SCRIPT_PATH=\$(get_script_path "\${vars_script_name:-}")
	RENDERKIT_RKCOMMON_ROOT=\$(dirname -- "\${RENDERKIT_RKCOMMON_SCRIPT_PATH}")
	
	if [ -d "\${RENDERKIT_RKCOMMON_ROOT}/lib" ] ; then
	    LD_LIBRARY_PATH=\$(prepend_path "\${RENDERKIT_RKCOMMON_ROOT}/lib" "\${LD_LIBRARY_PATH:-}") ; export LD_LIBRARY_PATH
	    CMAKE_PREFIX_PATH=\$(prepend_path "\${RENDERKIT_RKCOMMON_ROOT}/lib/cmake/rkcommon" "\${CMAKE_PREFIX_PATH:-}") ; export CMAKE_PREFIX_PATH
	fi
	
	
	if [ -d "\${RENDERKIT_RKCOMMON_ROOT}/lib/pkgconfig" ] ; then
	    PKG_CONFIG_PATH=\$(prepend_path "\${RENDERKIT_RKCOMMON_ROOT}/lib/pkgconfig" "\${PKG_CONFIG_PATH:-}") ; export PKG_CONFIG_PATH
	fi
	
EOM

read -d '\0' TBB_VARS_FOOTER <<- EOM
	# ############################################################################
	TBBROOT=$(get_script_path "${vars_script_name:-}")
	
	TBB_TARGET_ARCH="intel64"
	TBB_ARCH_SUFFIX=""
	
	if [ -n "${SETVARS_ARGS:-}" ]; then
	  tbb_arg_ia32="$(expr "${SETVARS_ARGS:-}" : '^.*\(ia32\)')" || true
	  if [ -n "${tbb_arg_ia32:-}" ]; then
	    TBB_TARGET_ARCH="ia32"
	  fi
	else
	  for arg do
	    case "$arg" in
	    (intel64|ia32)
	      TBB_TARGET_ARCH="${arg}"
	      ;;
	    (*) ;;
	    esac
	  done
	fi
	
	TBB_LIB_NAME="libtbb.so.12"
	
	# Parse layout
	if [ -e "$TBBROOT/lib/$TBB_TARGET_ARCH" ]; then
	  TBB_LIB_DIR="$TBB_TARGET_ARCH/gcc4.8"
	else
	  if [ "$TBB_TARGET_ARCH" = "ia32" ] ; then
	    TBB_ARCH_SUFFIX="32"
	  fi
	  TBB_LIB_DIR=""
	fi
	
	if [ -e "$TBBROOT/lib$TBB_ARCH_SUFFIX/$TBB_LIB_DIR/$TBB_LIB_NAME" ]; then
	  export TBBROOT
	
	  LIBRARY_PATH=$(prepend_path "${TBBROOT}/lib$TBB_ARCH_SUFFIX/$TBB_LIB_DIR" "${LIBRARY_PATH:-}") ; export LIBRARY_PATH
	  LD_LIBRARY_PATH=$(prepend_path "${TBBROOT}/lib$TBB_ARCH_SUFFIX/$TBB_LIB_DIR" "${LD_LIBRARY_PATH:-}") ; export LD_LIBRARY_PATH
	  CPATH=$(prepend_path "${TBBROOT}/include" "${CPATH:-}") ; export CPATH
	  CMAKE_PREFIX_PATH=$(prepend_path "${TBBROOT}" "${CMAKE_PREFIX_PATH:-}") ; export CMAKE_PREFIX_PATH
	  PKG_CONFIG_PATH=$(prepend_path "${TBBROOT}/lib$TBB_ARCH_SUFFIX/pkgconfig" "${PKG_CONFIG_PATH:-}") ; export PKG_CONFIG_PATH
	else
	  >&2 echo "ERROR: $TBB_LIB_NAME library does not exist in $TBBROOT/lib$TBB_ARCH_SUFFIX/$TBB_LIB_DIR."
	  return 255 2>/dev/null || exit 255
	fi

	# Get the absolute path to this vars.sh script
	RENDERKIT_TBB_SCRIPT_PATH=\$(get_script_path "\${vars_script_name:-}")
	RENDERKIT_TBB_ROOT="\${RENDERKIT_TBB_SCRIPT_PATH}"
	
	if [ -d "\${RENDERKIT_TBB_ROOT}/lib" ] ; then
	    LD_LIBRARY_PATH=\$(prepend_path "\${RENDERKIT_TBB_ROOT}/lib" "\${LD_LIBRARY_PATH:-}") ; export LD_LIBRARY_PATH
	    CMAKE_PREFIX_PATH=\$(prepend_path "\${RENDERKIT_TBB_ROOT}/lib/cmake/rkcommon" "\${CMAKE_PREFIX_PATH:-}") ; export CMAKE_PREFIX_PATH
	fi
	
	
	if [ -d "\${RENDERKIT_TBB_ROOT}/lib/pkgconfig" ] ; then
	    PKG_CONFIG_PATH=\$(prepend_path "\${RENDERKIT_TBB_ROOT}/lib/pkgconfig" "\${PKG_CONFIG_PATH:-}") ; export PKG_CONFIG_PATH
	fi
	
EOM
# End of script definition section


# rkcommon and onetbb section

TBB_DOWNLOAD_VERSION=2021.11.0
TBB_FILE="oneapi-tbb-${TBB_DOWNLOAD_VERSION}-lin.tgz"
TBB_URL="https://github.com/oneapi-src/oneTBB/releases/download/v2021.11.0/oneapi-tbb-${TBB_DOWNLOAD_VERSION}-lin.tgz"
if [ -d "${TARGET_DIR}/renderkit/tbb" ]; then
  rm -rf "${TARGET_DIR}/renderkit/tbb"
fi
mkdir "${TARGET_DIR}/renderkit/tbb"

DOWNLOAD=1
if [ -f "${TARGET_DIR}/renderkit/oneapi-tbb-${TBB_DOWNLOAD_VERSION}-lin.tgz" ]; then
  echo "${TBB_SHA} ${TARGET_DIR}/renderkit/oneapi-tbb-${TBB_DOWNLOAD_VERSION}-lin.tgz" | sha256sum --check > "${TARGET_DIR}/renderkit/${TBB_FILE}.chkresult" 2>&1
  if [ $? -eq 0 ]; then
    DOWNLOAD=0
    if [ "${SILENT_MODE}" -eq "0" ]; then
      echo "OK   : SHA256SUM of ${TBB_FILE}"
    fi
  else
    echo "ERROR: Bad SHA256SUM of ${TBB_FILE}... Delete all files in ${TARGET_DIR}/renderkit, check proxy/internet connection, and try again" >&2
    exit -1
  fi
fi

if [ ${DOWNLOAD} -eq 1 ]; then
  if [ "${SILENT_MODE}" -eq "0" ]; then
    echo "STATUS: Downloading ${TBB_FILE}.."
  fi


  if [ "${SILENT_MODE}" -eq "0" ]; then
    wget -O "${TARGET_DIR}/renderkit/oneapi-tbb-${TBB_DOWNLOAD_VERSION}-lin.tgz" "${TBB_URL}"
  else
    wget -O "${TARGET_DIR}/renderkit/oneapi-tbb-${TBB_DOWNLOAD_VERSION}-lin.tgz" -q "${TBB_URL}"
  fi
  
  if [ -f "${TARGET_DIR}/renderkit/oneapi-tbb-${TBB_DOWNLOAD_VERSION}-lin.tgz" ]; then
    echo "${TBB_SHA} ${TARGET_DIR}/renderkit/oneapi-tbb-${TBB_DOWNLOAD_VERSION}-lin.tgz" | sha256sum --check > "${TARGET_DIR}/renderkit/${TBB_FILE}.chkresult" 2>&1
    if [ $? -eq 0 ]; then
      if [ "${SILENT_MODE}" -eq "0" ]; then
        echo "OK   : SHA256SUM of ${TBB_FILE}"
      fi
    else
      echo "ERROR: Bad SHA256SUM of ${TBB_FILE}... Delete all files in ${TARGET_DIR}/renderkit, check proxy/internet connection, and try again" >&2
      exit -1
    fi
  else
    echo "ERROR: Could not download ${TBB_FILE}... Check proxy/internet connection" >&2
    exit -1
  fi
fi


#strip
EXTRACTSTRIP_DIR=--strip-components=1
if [ "${SILENT_MODE}" -eq "0" ]; then
  tar -xvf "${TARGET_DIR}/renderkit/oneapi-tbb-${TBB_DOWNLOAD_VERSION}-lin.tgz" -C "${TARGET_DIR}/renderkit/tbb" ${EXTRACTSTRIP_DIR} | sed 's/^/  /g'
  echo "OK   : oneapi-tbb-${TBB_DOWNLOAD_VERSION}-lin.tgz extracted"
else
  tar -xf "${TARGET_DIR}/renderkit/oneapi-tbb-${TBB_DOWNLOAD_VERSION}-lin.tgz" -C "${TARGET_DIR}/renderkit/tbb" ${EXTRACTSTRIP_DIR}
fi

RKCOMMON_DOWNLOAD_VERSION=1.13.0
RKCOMMON_FILE=v${RKCOMMON_DOWNLOAD_VERSION}.tar.gz
RKCOMMON_URL="https://github.com/ospray/rkcommon/archive/refs/tags/${RKCOMMON_FILE}"

DOWNLOAD=1
if [ -f "${TARGET_DIR}/renderkit/${RKCOMMON_FILE}" ]; then
  echo "${RKCOMMON_SRC_SHA} ${TARGET_DIR}/renderkit/${RKCOMMON_FILE}" | sha256sum --check > "${TARGET_DIR}/renderkit/${RKCOMMON_FILE}.chkresult" 2>&1
  if [ $? -eq 0 ]; then
    DOWNLOAD=0
    if [ "${SILENT_MODE}" -eq "0" ]; then
      echo "OK   : SHA256SUM of ${RKCOMMON_FILE}"
    fi
  else
    echo "ERROR: Bad SHA256SUM of ${RKCOMMON_FILE}... Delete all files in ${TARGET_DIR}/renderkit, check proxy/internet connection, and try again" >&2
    exit -1
  fi
fi


if [ -d "${TARGET_DIR}/renderkit/rkcommon-src" ]; then
  rm -rf "${TARGET_DIR}/renderkit/rkcommon-src"
fi
mkdir "${TARGET_DIR}/renderkit/rkcommon-src"

if [ ${DOWNLOAD} -eq 1 ]; then
  if [ "${SILENT_MODE}" -eq "0" ]; then
    echo "STATUS: Downloading ${RKCOMMON_FILE}..."
  fi


  if [ "${SILENT_MODE}" -eq "0" ]; then
    wget -O "${TARGET_DIR}/renderkit/${RKCOMMON_FILE}" "${RKCOMMON_URL}"
  else
    wget -O "${TARGET_DIR}/renderkit/${RKCOMMON_FILE}" -q "${RKCOMMON_URL}"
  fi
  
  if [ -f "${TARGET_DIR}/renderkit/${RKCOMMON_FILE}" ]; then
    echo "${RKCOMMON_SRC_SHA} ${TARGET_DIR}/renderkit/${RKCOMMON_FILE}" | sha256sum --check > "${TARGET_DIR}/renderkit/${RKCOMMON_FILE}.chkresult" 2>&1
    if [ $? -eq 0 ]; then
      if [ "${SILENT_MODE}" -eq "0" ]; then
        echo "OK   : SHA256SUM of ${RKCOMMON_FILE}"
      fi
    else
      echo "ERROR: Bad SHA256SUM of ${RKCOMMON_FILE}... Delete all files in ${TARGET_DIR}/renderkit and try again" >&2
      exit -1
    fi
  else
    echo "ERROR: Could not download ${RKCOMMON_FILE}... Check proxy/internet connection" >&2
  fi

fi
EXTRACTSTRIP_DIR=--strip-components=1
if [ "${SILENT_MODE}" -eq "0" ]; then
  tar -xvf "${TARGET_DIR}/renderkit/v${RKCOMMON_DOWNLOAD_VERSION}.tar.gz" -C "${TARGET_DIR}/renderkit/rkcommon-src" ${EXTRACTSTRIP_DIR} | sed 's/^/  /g'
  echo "OK   : v${RKCOMMON_DOWNLOAD_VERSION}.tar.gz extracted"
else
  tar -xf "${TARGET_DIR}/renderkit/v${RKCOMMON_DOWNLOAD_VERSION}.tar.gz" -C "${TARGET_DIR}/renderkit/rkcommon-src" ${EXTRACTSTRIP_DIR}
fi

#Build rkcommon
pushd "${TARGET_DIR}/renderkit/rkcommon-src" 2>&1 > /dev/null
rm -rf build
mkdir build
cd build
if [ "${SILENT_MODE}" -eq "0" ]; then
  echo "STATUS: Configuring rkcommon..."
fi
cmake -DTBB_ROOT="${TARGET_DIR}/renderkit/tbb" -DCMAKE_INSTALL_PREFIX="${TARGET_DIR}/renderkit/rkcommon" .. > "${TARGET_DIR}/renderkit/rkcommon_build.log" 2>&1
if [ $? -ne 0 ]; then
  echo "ERROR: Failed rkcommon configure" >&2
  cat "${TARGET_DIR}/renderkit/rkcommon_configure.log" >&2
  popd
  exit $?
fi
if [ "${SILENT_MODE}" -eq "0" ]; then
  echo "OK   : rkcommon configure"
fi
if [ "${SILENT_MODE}" -eq "0" ]; then
  echo "STATUS: Building rkcommon..."
fi
cmake --build . 2>&1 > "${TARGET_DIR}/renderkit/rkcommon_build.log"
if [ $? -ne 0 ]; then
  echo "ERROR: Failed rkcommon build" >&2
  cat "${TARGET_DIR}/renderkit/rkcommon_build.log" >&2
  popd
  exit $?
fi
if [ "${SILENT_MODE}" -eq "0" ]; then
  echo "OK   : rkcommon build"
fi
if [ "${SILENT_MODE}" -eq "0" ]; then
  echo "STATUS: Install rkcommon to ${TARGET_DIR}/renderkit/rkcommon.."
fi
cmake --install . 2>&1 > "${TARGET_DIR}/renderkit/rkcommon_install.log"
if [ $? -ne 0 ]; then
  echo "ERROR: Failed rkcommon install" >&2
  cat "${TARGET_DIR}/renderkit/rkcommon_install.log" >&2
  popd
  exit $?
fi
if [ "${SILENT_MODE}" -eq "0" ]; then
  echo "OK   : rkcommon install to ${TARGET_DIR}/renderkit/rkcommon"
fi
popd 2>&1 > /dev/null

if [ "${DELETE_TMP}" -ne "0" ]; then
  rm -rf "${TARGET_DIR}/renderkit/v${RKCOMMON_DOWNLOAD_VERSION}.tar.gz"
  if [ "${SILENT_MODE}" -eq "0" ]; then
    echo "STATUS: ${TARGET_DIR}/renderkit/v${RKCOMMON_DOWNLOAD_VERSION}.tar.gz removed"
  fi
  rm -rf "${TARGET_DIR}/renderkit/oneapi-tbb-${TBB_DOWNLOAD_VERSION}-lin.tgz"
  if [ "${SILENT_MODE}" -eq "0" ]; then
    echo "STATUS: ${TARGET_DIR}/renderkit/oneapi-tbb-${TBB_DOWNLOAD_VERSION}-lin.tgz removed"
  fi
fi

# Write the environment variable scripts to disk for each component
echo -e "${VARS_HEADER}\n${EMBREE_VARS_FOOTER}" > "${TARGET_DIR}/renderkit/embree/rk-embree-vars.sh"
echo -e "${VARS_HEADER}\n${OPENVKL_VARS_FOOTER}" > "${TARGET_DIR}/renderkit/openvkl/rk-openvkl-vars.sh"
echo -e "${VARS_HEADER}\n${OIDN_VARS_FOOTER}" > "${TARGET_DIR}/renderkit/oidn/rk-oidn-vars.sh"
echo -e "${VARS_HEADER}\n${ISPC_VARS_FOOTER}" > "${TARGET_DIR}/renderkit/ispc/rk-ispc-vars.sh"
echo -e "${VARS_HEADER}\n${OSPRAY_VARS_FOOTER}" > "${TARGET_DIR}/renderkit/ospray/rk-ospray-vars.sh"
echo -e "${VARS_HEADER}\n${OSPRAY_STUDIO_VARS_FOOTER}" > "${TARGET_DIR}/renderkit/ospray-studio/rk-ospray-studio-vars.sh"
echo -e "${VARS_HEADER}\n${RKCOMMON_VARS_FOOTER}" > "${TARGET_DIR}/renderkit/rkcommon/rk-rkcommon-vars.sh"
echo -e "${VARS_HEADER}\n${TBB_VARS_FOOTER}" > "${TARGET_DIR}/renderkit/tbb/rk-tbb-vars.sh"

# EOF

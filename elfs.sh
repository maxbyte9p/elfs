#!/bin/false

if [ -z "$PS1" ]; then
	echo -e "Please, source this script with\n$ source $0\nrather than attempting to run it in a shell"
	exit
fi

## ELFS Env Setup
ELFS_VERSION="0.1"

cat << EOF
Preparing ELFS environment. Version: ${ELFS_VERSION}
EOF

source ~/.bashrc

if [ "$(basename $(pwd))" != "elfs" ]; then
	echo "FATAL: Not in ELFS directory. Cannot setup environment!"
	return 1
fi

ELFS=${ELFS:=$(pwd)}

if [ ! -d "$ELFS/localrepo" ]; then
	echo "INFO: Making localrepo directory."
	mkdir -pv $ELFS/localrepo/{tmp,results}
fi

if [ ! -d "$ELFS/build" ]; then 
	echo "INFO: Making build directory."
	mkdir -v $ELFS/build
fi

## ELFS Wrappers
function elfs-mock() {
	STAGE=${STAGE:=1}

	case $STAGE in
		1) mock -r $ELFS/mockconfig/elfs-0.1-x86_64-bootstrap-stage1.cfg $@;;
		2) mock -r $ELFS/mockconfig/elfs-0.1-x86_64-bootstrap-stage2.cfg $@;;
		3) mock -r $ELFS/mockconfig/elfs-0.1-x86_64-bootstrap-stage3.cfg $@;;
		4) mock -r $ELFS/mockconfig/elfs-0.1-x86_64-bootstrap-stage4.cfg $@;;
		*) echo 'Set $STAGE to 1, 2, 3, or 4';;
	esac
}

function elfs-repo() {
	echo "Updating repos..."
	createrepo $ELFS/localrepo/tmp
	createrepo $ELFS/localrepo/results
}

function elfs-bsrpm() {
	pkg=$1
	rpmbuild -bs --define "_topdir $ELFS/build/$pkg" --define "dist .el9" $ELFS/build/$pkg/SPECS/$pkg.spec
}

function elfs-getsrc {
	# Skip's "universal" lookaside grabber
	#
	# Run this in a Fedora/Rocky/CentOS/CentOS Stream source directory, and it will retrieve the lookaside sources (tarballs) into the current directory
	#
	# Modified by Maxine for use in ELFS
	# You can find the original here: https://git.rockylinux.org/skip/getsrc

	IFS='
	'


	# List of lookaside locations and their patterns
	# This can be easily edited to add more distro locations, or change their order for less 404 misses:
	LOOKASIDES='https://rocky-linux-sources-staging.a1.rockylinux.org/%HASH%
	https://sources.build.resf.org/%HASH%
	https://git.centos.org/sources/%PKG%/%BRANCH%/%HASH%
	https://sources.stream.centos.org/sources/rpms/%PKG%/%FILENAME%/%SHATYPE%/%HASH%/%FILENAME%
	https://src.fedoraproject.org/repo/pkgs/%PKG%/%FILENAME%/%SHATYPE%/%HASH%/%FILENAME%
	'



	###
	# Function that actually downloads a lookaside source
	# Takes HASH / FILENAME / BRANCH / PKG / SHATYPE as arguments $1 / $2 / $3 / $4 / $5
	function download {
	  
	  foundFile=0

	  for site in $(echo "${LOOKASIDES}"); do
	    url="$site"

	    # Substitute each of our macros (%PKG%, %HASH%, etc.):
	    url=$(echo "${url}" | sed "s|%HASH%|${1}|g")
	    url=$(echo "${url}" | sed "s|%FILENAME%|${2}|g")
	    url=$(echo "${url}" | sed "s|%BRANCH%|${3}|g")
	    url=$(echo "${url}" | sed "s|%PKG%|${4}|g")
	    url=$(echo "${url}" | sed "s|%SHATYPE%|${5}|g")
	    

	    # Use curl to get just the header info of the remote file
	    retCode=$(curl -o /dev/null --silent -Iw '%{http_code}' "${url}")
	    
	    # Download the file only if we get a 3-character http return code (200, 301, 302, 404, etc.) 
	    # AND the code must begin with 2 or 3, to indicate 200 FOUND, or some kind of 3XX redirect
	    if [[ $(echo "${retCode}" | wc -c) -eq 4  && ( $(echo "${retCode}" | cut -c1-1) == "2" || $(echo "${retCode}" | cut -c1-1) == "3" ) ]]; then
	       curl --silent --create-dirs -o "${2}" "${url}"
	       echo "Downloaded: ${url}  ----->  ${2}"
	       foundFile=1
	       break
	    fi
	  done

	  if [[ "${foundFile}" == "0" ]]; then
	    echo "ERROR: Unable to find lookaside file with the following HASH / FILENAME / BRANCH / PKG / SHATYPE :"
	    echo "$1  /  $2  /  $3  /  $4  /  $5"
	    return 1
	  fi

	}




	###
	# discover our list of lookaside sources.  They are either in a "sources" file (new), or the older ".packagename.metadata" format (old)
	SOURCES=$(cat .*.metadata sources 2> /dev/null) 

	if [[ $(echo "$SOURCES" | wc -c) -lt 10 ]]; then
	  echo "ERROR: Cannot find .*.metadata or sources file listing sources.  Are you in the right directory?"
	  return 1
	fi


	# Current git branch.  We don't error out if this fails, as we may not necessarily need this info
	BRANCH=$(git branch --show-current 2> /dev/null)



	# Source package name should match the specfile - we'll use that in lieu of parsing "Name:" out of it
	# There could def. be a better way to do this....
	PKG=$(find . -iname *.spec | head -1 | xargs -n 1 basename | sed 's/\.spec//')

	if [[ $(echo "$PKG" | wc -c) -lt 2 ]]; then
	  echo "ERROR: Having trouble finding the name of the package based on the name of the .spec file."
	  return 1
	fi



	# Loop through each line of our looksaide, and download the file:
	for line in $(echo "$SOURCES"); do
	  
	  # First, we need to discover whether this is a new or old style hash.  New style has 4 fields "SHATYPE (NAME) = HASH", old style has 2: "HASH NAME"
	  if [[ $(echo "$line" | awk '{print NF}') -eq 4 ]]; then
	    HASH=$(echo "$line" | awk '{print $4}')
	    FILENAME=$(echo "$line" | awk '{print $2}' | tr -d ')' | tr -d '(')
	  
	  # Old style hash: "HASH FILENAME"
	  elif [[ $(echo "$line" | awk '{print NF}') -eq 2 ]]; then
	    HASH=$(echo "$line" | awk '{print $1}')
	    FILENAME=$(echo "$line" | awk '{print $2}')
	  
	  # Skip a line if it's blank or just an empty one
	  elif [[ $(echo "$line" | wc -c) -lt 3 ]]; then
	    continue

	  else
	    echo "ERROR: This lookaside line does not appear to have 2 or 4 space-separated fields.  I don't know how to parse this line:"
	    echo "${line}"
	    return 1
	  fi
	    
	  
	  SHATYPE=""
	  # We have a hash and a filename, now we need to find the hash type (based on string length):
	  case $(echo "$HASH" | wc -c) in 
	    "33")
	      SHATYPE="md5"
	      ;;
	    "41")
	      SHATYPE="sha1"
	      ;;
	    "65")
	      SHATYPE="sha256"
	      ;;
	    "97")
	      SHATYPE="sha384"
	      ;;
	    "129")
	      SHATYPE="sha512"
	      ;;
	  esac
	    

	  # Finally, we have all our information call the download function with the relevant variables:
	  download "${HASH}"  "${FILENAME}"  "${BRANCH}"  "${PKG}"  "${SHATYPE}"


	done
}

function elfs-download() {
	pkg="$1"
	GIT="https://git.rockylinux.org/staging/rpms"

	git clone -b r9 https://git.rockylinux.org/staging/rpms/$pkg $ELFS/build/$pkg

	pushd $ELFS/build/$pkg
		elfs-getsrc
	popd
}

function elfs-priv() {
WARNINGRED="$(tput bold setaf 124)"
COLRESET="$(tput sgr0)"

	cat << EOF
${WARNINGRED}WARNING${COLRESET}: You are about to become the root user.
Running commands as the root user while not
paying attention may result in IRREVERSIBLE
DAMAGE to your system! By proceeding your are
accepting the risks that come with being the 
root user.

Do you wish to proceed? [y/n]
EOF
	while true; do
		read yn
		case $yn in 
			[Yy]* ) break;;
			[Nn]* ) return;;
			*) echo "I don't blame you I would be scared too! I believe in you though!"; return;;
		esac
	done

	sudo su -c "env -i TERM=$TERM ELFS=$ELFS bash --rcfile $ELFS/elfs.sh"
}

## ELFS Helper Functions
function elfs-help() {
	cat << 'EOF'
Wrappers:
	elfs-mock
		Wraps around mock telling it to use the ELFS mock
		config. Set $STAGE environment variable to specify
		a stage config to use.
	elfs-repo
		Wraps around createrepo for updating the local
		ELFS dnf repositories.
	elfs-bsrpm
		Wraps around rpmbuild to create source RPMS.
	elfs-getsrc
		Wraps around Skip Grube's getsrc script. The
		original script was modified to work for ELFS.
		Essentially downloads source archives from 
		lookaside locations. Typically invoked by
		elfs-download.
	elfs-download
		Clones git repository for source package from
		https://git.rockylinux.org/staging/rpms.
	elfs-priv
		Elevates the user to the root user. A warning
		will be displayed where the user is prompted
		asking if they want to accept the risks and
		proceed.

Helpers:
	elfs-help
		Displays help information about the ELFS
		environment script.
EOF
}
	


## ELFS Prompt
BASEPS1="[\u@\h \W]\$ "
ROOTPS1="[\u \W]# "

# Colors
ELA_SHADE1_F="\[$(tput setaf 41)\]"
#ELA_SHADE2_F="\[$(tput setaf 42)\]"
#ELA_SHADE3_F="\[$(tput setaf 43)\]"
ELA_SHADE2_F="\[$(tput setaf 43)\]"
#ELA_SHADE4_F="\[$(tput setaf 44)\]"
ELA_SHADE3_F="\[$(tput setaf 44)\]"
#ELA_SHADE5_F="\[$(tput setaf 45)\]"
ELA_SHADE4_F="\[$(tput setaf 45)\]"
ROOTRED="\[$(tput bold setaf 124)\]"
RESET="\[$(tput sgr0)\]"

# Functions
exitstatus() {
	CODE=$?
	case $CODE in
		0) echo "$CODE :)";;
		130) echo "$CODE X|";;
		*) echo "$CODE :(";;
	esac
}

# Design
FANCY_ELFS="${ELA_SHADE1_F}E${ELA_SHADE2_F}L${ELA_SHADE3_F}F${ELA_SHADE4_F}S${RESET}"

elfs-prompt() {
	## Enable this if you want to see exit codes :)
	#exitstatus 
	if [ $UID == 0 ]; then 
		PS1="$FANCY_ELFS ${ROOTRED}$ROOTPS1${RESET}"
		return
	fi
	PS1="$FANCY_ELFS $BASEPS1${RESET}"
}

PROMPT_COMMAND="elfs-prompt"


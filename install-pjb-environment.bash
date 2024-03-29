#!/bin/bash
# -*- mode:shell-script;coding:utf-8 -*-
#*****************************************************************************
#FILE:               install-pjb-environment
#LANGUAGE:           sh
#SYSTEM:             POSIX
#USER-INTERFACE:     NONE
#DESCRIPTION
#
#    This script fetches and installs my environment.
#
#AUTHORS
#    <PJB> Pascal J. Bourguignon <pjb@informatimago.com>
#MODIFICATIONS
#    2016-12-04 <PJB> Added this header.
#BUGS
#    - Add installation of quicklisp
#LEGAL
#    AGPL3
#
#    Copyright Pascal J. Bourguignon 2016 - 2021
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#*****************************************************************************


# - AppStore:
#     - install Xcode
#     - install Omnigrafle        from purchased applications
#     - install Closure CL        from purchased applications
#     - install Libre Office      from purchased applications
#     - install Garage Band       from purchased applications
#     - install Theta S Remote    from purchased applications
#
# - install https://emacsformacosx.com
# - install java from oracle.
# - install https://www.macports.org
#
# - install https://developer.android.com/studio/index.html

self="$(cd "$(dirname "${BASH_SOURCE[0]}")"||exit 1;pwd -P)/$(basename "${BASH_SOURCE[0]}" .bash)"
PREFIX=/usr/local
headless=0

repositories_behind_proxy=(
    https://github.com/informatimago/rc
    https://github.com/informatimago/bin
    https://github.com/informatimago/lisp
    https://github.com/informatimago/emacs
)
repositories_thru_ssh=(
    # pjb@git.informatimago.com:/srv/git/public/rc
    # pjb@git.informatimago.com:/srv/git/public/bin
    # pjb@git.informatimago.com:/srv/git/public/lisp
    # pjb@git.informatimago.com:/srv/git/public/emacs

    git@github.com:informatimago/rc.git
    git@github.com:informatimago/bin.git
    git@github.com:informatimago/lisp.git
    git@github.com:informatimago/emacs.git
    git@github.com:informatimago/commands.git
)

apt_package_not_on_debian_11=(
    gnucobol
)

apt_packages=(
    gnutls-bin gnutls-doc libgnutls28-dev libgnutls30 # ubuntu 18.04
    mailutils # for emacs
    libavcall1 # for clisp

    # The default-jdk on ubuntu is openjdk which is missing components for abcl.
    # We need to install Oracle's jdk.
    # default-jdk default-jdk-doc default-jdk-headless

    net-tools etherwake wakeonlan
    mmv psmisc  tree  ghostscript


    sbcl clisp ecl gcl cmucl-source chezscheme mit-scheme fpc
    cpp gcc g++ gfortran gnat  gobjc gobjc++ cross-gcc-dev
    clang clang-tools llvm
    openjdk-17-jdk
    coq ocaml swi-prolog
    make cmake ant dwarves mandoc
    autoconf automake
    pcc tcc

    strace xtrace dnstracer

    git mercurial subversion cvs
    w3m
    rst2pdf pandoc texlive

    umbrello
    unrar-free
    ncftp wget curl rsync     sitecopy

    csound

    x11-apps   x11-xserver-utils   x11-xfs-utils
    xauth xcb xcompmgr
    # xdm
    xdotool xfig xinit xmlto
    xmms2 xpdf xplot xscreensaver xskat  xterm

    postgresql postgresql-client postgresql-doc
    postgresql-server-dev-all

    fortune-mod

    rlwrap cdecl libreadline-dev
    libffcall1-dev
    libgif-dev giflib-tools
    libncurses5-dev
    libtinfo-dev
    libsigsegv-dev
    libdb5.3-dev
    libgdbm-dev
    libglade2-dev

    libffcall1-dev libgif-dev giflib-tools libncurses5-dev libtinfo-dev
    libreadline6-dev libsigsegv-dev
    libdb5.3-dev libgdbm-dev libglade2-dev

    postgresql postgresql-client postgresql-doc
    postgresql-server-dev-all

    xsel

    pulseaudio alsamixer
    dnsutils locate
)


headless_debian_packages=( "${apt_packages[@]}"
		               )
headless_ubuntu_packages=( "${apt_packages[@]}"
		               )

local_debian_packages=( "${apt_packages[@]}"
		                mplayer
		              )
local_ubuntu_packages=( "${apt_packages[@]}"
		                mplayer
		              )


ports=(
    xorg-server
    xorg-libXt+flat_namespace
    MPlayer abcMIDI abcm2ps ant-contrib
    apache-ant bash ccl clisp cmake coreutils docbook-xml-5.0 cvs
    docbook-xsl ecl enscript fluidsynth fop gawk gcl gdb giflib
    gnupg gnutar gradle graphviz gsed libconfig-hr libevent libiconv
    lisp-hyperspec lynx mercurial mmv multimarkdown
    ncftp ninja optipng pandoc pngcheck pngcrush pngpp port_cutleaves
    portmidi pstree py-pdfrw py27-pip py27-sphinx py33-docutils
    py33-pip ragel rlwrap rst2pdf sbcl sitecopy texlive+full tiemu3
    umbrello unrar w3m wget x11perf xauth xcalc xcb
    xclipboard xclock xcompmgr xconsole xcursorgen xditview xdm
    xdotool xdpyinfo xedit xev xeyes xfd xfig xfontsel xforms xfs
    xfsinfo xgamma xgc xhost xinit xkeyboard-config xkill xload xlogo
    xlsatoms xlsclients xlsfonts xmag xman xmessage xmh xmlto xmms2
    xmodmap xmore xorg-scripts xpdf xpdf-cyrillic xplot xpr xprop
    xrandr xrefresh xscope xscreensaver xsetmode xsetpointer xsetroot
    xskat xsm xstdcmap xwd xwininfo xwud xsel
    py27-readline
    mysql57 mysql57-server mysql_select
    gcc5 gcc6 gcc_select
    tree boehmgc ghostscript
    fpc fpc-doc fortune xterm
    ffcall  libsigsegv readline libiconv
)


ports_osx_10_11=( vineserver )


# files to clone in ~/emacs
emacs_fileurls=(
    http://mumble.net/~campbell/emacs/paredit.el
)


# git repository to clone in ~/emacs
emacs_gitrepos=(
    # https://code.google.com/p/android-emacs-toolkit/
    https://github.com/remvee/android-mode.git
    https://github.com/emacs-java/auto-java-complete.git
    https://github.com/defunkt/coffee-mode.git
    https://github.com/szermatt/emacs-bash-completion.git
    https://github.com/larsbrinkhoff/emacs-cl.git
    https://github.com/jacobono/emacs-gradle-mode.git
    https://github.com/VincentToups/emacs-utils.git
    https://github.com/tlh/emms-info-id3v2.el.git
    https://github.com/zenspider/enhanced-ruby-mode.git
    https://github.com/death/naggum.git
    https://github.com/magnars/s.el.git
    https://github.com/hayamiz/twittering-mode.git
    https://github.com/capitaomorte/yasnippet.git
    https://github.com/jrblevin/markdown-mode.git
)


function printe(){
    printf '%-8s: %s\n' ERROR   "$*" >&2
}


function printw(){
    printf '%-8s: %s\n' WARNING "$*" >&2
}


function printi(){
    printf '%-8s: %s\n' INFO    "$*" >&2
}


if type -p ccl >/dev/null 2>&1 ; then
    function lisp(){
        ccl --no-init "$@"
    }
elif type -p clisp >/dev/null 2>&1 ; then
	# shellcheck disable=SC2120
    function lisp(){
        clisp -q -ansi -norc "$@"
    }
else
    printe "Missing a lisp implementation."
    function lisp(){
        printe "Missing a lisp implementation."
    }
fi


function download(){
    local url="${1?Missing URL as first argument of ${FUNCNAME[0]}}"
    printi 'Downloading ' "${url}"
    curl -O "${url}"
}


function unarchive(){
    local archive="$1"
    local dir="$2"
    case "${archive}" in
    (*.tar.xz|*.txz)
        rm -rf  "${dir}"
        printi 'Extracting ' "${archive}"
        tar Jxf "${archive}"
        ;;
    (*.tar.bz2)
        rm -rf  "${dir}"
        printi 'Extracting ' "${archive}"
        tar jxf "${archive}"
        ;;
    (*.tar.gz|*.tgz)
        rm -rf  "${dir}"
        printi 'Extracting ' "${archive}"
        tar zxf "${archive}"
        ;;
    (*.zip)
        rm -rf  "${dir}"
        printi 'Extracting ' "${archive}"
        unzip "${archive}"
        ;;
    (*)
        printe "Unknown archive type: ${archive}"
        exit 1
        ;;
    esac
}


function svn-checkout-or-warn(){
    local svnurl="${1?Missing SVN repository URL as first argument to ${FUNCNAME[0]}}"
    local dir="${2:-$(basename "${svnurl}" .svn)}"
    if [ -e "$dir" ] ; then
        printw 'There is already an item named ' "${dir}" ','
        printw '         skipping svn checkout ' "${svnurl}"
    else
        printi 'Checking out ' "${svnurl}"
        svn checkout "${svnurl}" "${dir}"
    fi
}


function git-clone-or-warn(){
    local giturl="${1?Missing GIT repository URL as first argument to ${FUNCNAME[0]}}"
    local dir="${2:-$(basename "${giturl}" .git)}"
    if [ -e "$dir" ] ; then
        printw 'There is already an item named ' "${dir}" ','
        printw '         skipping git clone '  "${giturl}"
    else
        printi 'Checking out ' "${giturl}"
        git clone "${giturl}" "${dir}"
    fi
}


function old(){
    local path="${1?Missing path as first argument of ${FUNCNAME[0]}}"
    if [ -e "${path}.old" ] ; then
        local i=0
        while  [ -e "${path}.${i}.old" ] ; do
            ((i++))
        done
        echo "${path}.${i}.old"
    else
        echo "${path}.old"
    fi
}


function link(){
    local src="${1?Missing source as first argument of ${FUNCNAME[0]}}"
    local dst="${2?Missing destination as second argument of ${FUNCNAME[0]}}"
    if [ -L "${dst}" ] ; then
        rm "${dst}"
    elif [[ -e "${dst}" ]]; then
        mv "${dst}" "$(old "${dst}")"
    fi
    ln -sf "${src}" "${dst}"
}


function compile(){
    local name="$1" ; shift
    local logbase="$1" ; shift
    printi "Configuring ${name}"
    if ./configure --prefix="${PREFIX}" "$@"        > "${logbase}".configure.log      2>&1
	then
        printi "Making ${name}"     ; make          > "${logbase}".make.log           2>&1
	    printi "Installing ${name}" ; make install  > "${logbase}".make-install.log   2>&1
    else
        printe "Compiling ${name} failed; check the logs."
    fi
}


function SGR () {
    # SELECT GRAPHIC RENDITION
	local semicolon=''
	local res=''
	for arg in "$@" ; do
		res="${res}${semicolon}${arg}"
		semicolon=';'
	done
    echo -n "[${res}m"
}


function normal(){
    SGR 0
}


#-----------------------------------------------------------------------
# Pjb Environments ~/bin ~/rc ~/src/public/lisp ~/src/public/emacs
#-----------------------------------------------------------------------

function install_pjb_environment(){
    printi "Installing PJB Environment"
    cd "$HOME"
    git config --global user.name "Pascal J. Bourguignon"
    git config --global user.email pjb@informatimago.com
    mkdir -p src/public
    cd "$HOME/src/public"
    if git config --global http.proxy >/dev/null 2>&1 ; then
	    printi "Choosing repository URLs via http proxy."
	    repositories=("${repositories_behind_proxy[@]}")
    else
	    printi "Choosing repository URLs thru ssh."
	    repositories=("${repositories_thru_ssh[@]}")
    fi
    for repo in "${repositories[@]}" ; do
        git-clone-or-warn "${repo}"
    done
    cd "$HOME"
    link src/public/bin bin
    link src/public/rc  rc
    cd "$HOME/rc"
    make symlinks
    cd "$HOME"
	# shellcheck disable=SC1090
	source "$HOME"/.bashrc || true
    printi 'Evaluate:'
	# shellcheck disable=SC2016
    printi 'cd $HOME ; source .bashrc'
}


#-----------------------------------------------------------------------
# "/usr/local" stuff
#-----------------------------------------------------------------------

function prepare_usr_local(){
    sudo mkdir -p "${PREFIX}"/{bin,sbin,src,share/emacs/site-lisp,etc,lib,libexec,include,info,man}
    sudo tee "${PREFIX}"/share/emacs/site-lisp/subdirs.el >/dev/null <<EOF
;; -*- no-byte-compile: t -*-
(if (fboundp (quote normal-top-level-add-subdirs-to-load-path))
   (normal-top-level-add-subdirs-to-load-path))
EOF
    sudo chown "$USER" "${PREFIX}"/* "${PREFIX}"
}


function install_emacs_from_sources(){
    if [ ! -x "${PREFIX}"/bin/emacs ] ; then
        cd "${PREFIX}"/src
        local url='ftp://ftp.gnu.org/gnu/emacs/emacs-25.1.tar.gz' # not on ubuntu 18.04
        local url='ftp://ftp.gnu.org/gnu/emacs/emacs-25.3.tar.gz'
        local url='ftp://ftp.gnu.org/gnu/emacs/emacs-26.1.tar.gz'
        local url='ftp://ftp.gnu.org/gnu/emacs/emacs-27.2.tar.gz'
        local tarball;tarball="$(basename "${url}")"
        local dir    ;dir="$(basename "${tarball}" .tar.gz)"
	    if [[ ! -e "${tarball}" ]] ; then
	        download "${url}"
            download "${url}.sig"
        fi
        unarchive "${tarball}" "${dir}"
        cd "${dir}"
        # CFLAGS=-L/usr/lib/x86_64-linux-gnu \
        # LDFLAGS=-L/usr/lib/x86_64-linux-gnu \
        #
        compile "${dir}" "$(pwd)" --with-x --without-ns --with-gif=no --with-x-toolkit=no --with-gnutls=yes --without-pop --with-mailutils
    fi
}


function install_ccl_from_sources(){
    local version
    local sys
    local pro
    local dir
    local ker
    local exe
	# shellcheck disable=SC2019,SC2018
    sys="$(uname|tr 'A-Z' 'a-z')"
    pro="$(uname -m)"
    case "$sys" in
    (linux)     exe=l ;;
    (darwin)    exe=d ;;
    (solaris)   exe=s ;;
    (freebsd)   exe=f ;;
    (win32)     exe=w ;;
    esac
    case "$pro" in
	(x86_64) pro=x86 ; ker=x8664 ; bit=64 ;;
	(x86)    pro=x86 ; ker=x8632 ; bit=32 ;;
	(arm)    pro=arm ; ker=arm   ; bit=64 ;;
    esac
    cd "${PREFIX}/src"
    dir=ccl-dev
    if [ ! -d "$dir" ]  ; then
        git clone https://github.com/Clozure/ccl.git "${dir}"
    fi
    if [ ! -r "${sys}${pro}.tar.gz" ] ; then
        curl -L -O "https://github.com/Clozure/ccl/releases/download/v1.12/${sys}${pro}.tar.gz"
    fi
    cd "${PREFIX}/src/${dir}"
    tar xf "../${sys}${pro}.tar.gz"
    cd "${PREFIX}/src/${dir}/lisp-kernel/${sys}${ker}"
    make clean
    make
    cd "${PREFIX}/src/${dir}"
    for f in  [dlwsf]{arm,x86}cl{32,64}{,.image} ; do
        cp "$f" "original-$f" || true
    done
    echo # Using "${exe}${pro}cl${bit}"
    { echo '(ccl:rebuild-ccl :clean t)' ; echo '(ccl:quit)' ; } | ./"${exe}${pro}cl${bit}"  -n
    /bin/ls -lt | head -n 4
    # version="$(svn ls http://svn.clozure.com/publicsvn/openmcl/release|sort -t. -k 1,1n -k 2,2n -k 3,3n -k 4,4n|tail -1)"
    # dir="ccl-${version%/}"
    # cd "${PREFIX}"/src
    # if [ ! -e "${dir}" ] ; then
    #     svn-checkout-or-warn "http://svn.clozure.com/publicsvn/openmcl/release/${version}${sys}${pro}/ccl" "${dir}"
    # fi
    cd "${PREFIX}/src"
    link "${dir}" ccl
    cd "${PREFIX}/bin"
    link ../src/ccl/scripts/ccl   ccl32
    link ../src/ccl/scripts/ccl64 ccl64
    link ccl64 ccl
}



# shellcheck disable=SC2191
function install_clisp_from_sources(){
    cd "${PREFIX}"/src/
    local do_ffi=true
    local hyperspec='http://www.lispworks.com/documentation/HyperSpec/'
    # local url='http://hg.code.sf.net/p/clisp/clisp'
    # local url='http://gitlab.com/gnu-clisp/clisp.git'
    local url='git@gitlab.com:gnu-clisp/clisp.git'
    local dir='clisp'
    local logbase;logbase="$(pwd)/${dir}"
    if [ ! -e "${dir}" ] ; then
        # hg clone "${url}" "${dir}"
	    git clone "${url}" "${dir}"
    fi
    cd "${dir}"
    make distclean >/dev/null 2>&1 || true
    rm -rf build
    local configuration=(
        --prefix="${PREFIX}"

        --with-threads=POSIX_THREADS
        --with-dynamic-modules
        --with-unicode
        --with-readline

        --with-module=berkeley-db
        --with-module=clx/new-clx
        --with-module=gdbm
        --with-module=pcre
        --with-module=queens
        --with-module=rawsock

        --hyperspec="${hyperspec}"
    )
    local configuration_darwin=(
        --with-libsigsegv-prefix=/opt/local/lib
        --with-libpth-prefix=/opt/local/lib
        --with-libiconv-prefix=/opt/local/lib
        --with-libintl-prefix=/opt/local/lib
        --with-libffcall-prefix=/opt/local/lib
        --with-libtermcap-prefix=/opt/local/lib
        --with-libreadline-prefix=/opt/local/lib
    )
    local ffi_modules=(
        --with-module=bindings/glibc
        --with-module=dbus
        --with-module=gtk2
        --with-module=postgresql
        --with-module=zlib
    )
    local linux_ffi=(
        --with-ffcall
    )
    local darwin_ffi=(
        --with-ffcall
        --with-ffcall-prefix=/opt/local
    )
    if [[ "$(uname)" = Darwin ]] ; then
        configuration+=( "${configuration_darwin[@]}" )
        if $do_ffi false ; then
            configuration+=( "${darwin_ffi[@]}" "${ffi_modules[@]}"
	                         --with-libsigsegv-prefix=/opt/local/lib
	                         --with-libpth-prefix=/opt/local/lib
	                         --with-libiconv-prefix=/opt/local/lib
	                         --with-libintl-prefix=/opt/local/lib
	                         --with-libffcall-prefix=/opt/local/lib
	                         --with-libtermcap-prefix=/opt/local/lib
	                         --with-libreadline-prefix=/opt/local/lib
                           )
        fi
    else
        if $do_ffi false ; then
            configuration+=( "${linux_ffi[@]}" "${ffi_modules[@]}" )
        fi
    fi
    (
        export EDITOR=emacsclient
        export ORGANIZATION=informatimago
        if [[ "$(uname)" = Darwin ]] ; then
            export CPPFLAGS=-I/opt/local/include
            export LDFLAGS=-L/opt/local/lib
            export LIBS='/opt/local/lib/libcallback.a /opt/local/lib/libavcall.a'
        fi
        printi "Configuring ${dir}"
		# shellcheck disable=SC2015
        ./configure "${configuration[@]}" build                      > "${logbase}".configure.log      2>&1   \
            && ( printi "Making ${dir}"     ; make -C build          > "${logbase}".make.log           2>&1 ) \
            && ( cp build/libgnu.a  build/bindings/glibc/ ) \
            && ( printi "Installing ${dir}" ; make -C build install  > "${logbase}".make-install.log   2>&1 ) \
            ||   printe "Compiling ${dir} failed; check the logs."
    )
}


function java_home(){
    case "$(uname)" in
	(Darwin) echo /usr/libexec/java_home             ;;
	(*)      echo /usr/lib/jvm/java-17-openjdk-amd64 ;;
    esac
}


function install_abcl_from_sources(){
    # Assume ccl is available.
    cd "${PREFIX}"/src/
    local url='https://abcl.org/releases/1.8.0/abcl-src-1.8.0.tar.gz'
    local tarball;tarball="$(basename "${url}")"
    local dir;dir="$(basename "${tarball}" .tar.gz)"
    local jdkhome;jdkhome="$(java_home)"
    local logbase;logbase="$(pwd)/${dir}"
    export JAVA_HOME="${jdkhome}"
    if [[ ! -e  "${tarball}" ]] ; then
        download "${url}"
    fi
    unarchive "${tarball}" "${dir}"
    cd "${dir}"
    case "$(uname)" in
    (Darwin)
        sed -e 's^"/usr/"^"'"${jdkhome}/"'"^' \
            <customizations.lisp.in >customizations.lisp
        ;;
    (*)
        sed -e 's^"/home/peter/sun/jdk1.5.0_16/"^"'"${jdkhome}/"'"^' \
            -e 's/fastjar/jar/' \
            <customizations.lisp.in >customizations.lisp
        ;;
    esac
    sed -e "s/\((progn $3 (\(.*\)))\)/(handler-case \1 (error (err) (princ err *error-output*) (terpri *error-output*) (finish-output *error-output*) (\2 1)))/g" \
        < ./build-from-lisp.bash > ./build-from-lisp
    chmod 755 ./build-from-lisp
    printi 'Building abcl from lisp with ccl'
    ./build-from-lisp ccl  > "${logbase}".build-from-lisp.log      2>&1 \
        && ( printi 'Installing abcl' ; install -m 755 abcl "${PREFIX}"/bin/  > "${logbase}".make-install.log   2>&1 ) \
        ||   printe 'Compiling abcl failed; check the logs.'
}


function install_ecl_from_sources(){
    cd "${PREFIX}"/src/
    local url='https://gitlab.com/embeddable-common-lisp/ecl.git'
    local dir='ecl'
    git-clone-or-warn "${url}"
    cd "${dir}"
    compile "${dir}" "$(pwd)"
}


function install_emacs_w3m_from_sources(){
    cd "${PREFIX}"/src
    local url=':pserver:anonymous@cvs.namazu.org:2401/storage/cvsroot'
    local dir='emacs-w3m'
    if [[  -d "${dir}" ]] ; then
        printw 'There is already an item named ' "${dir}" ','
        printw '         skipping cvs checkout ' "${svnurl}"
    else
        printi 'Checking out ' "${svnurl}"
        printf '/1 %s A\n' "${svnurl}" >> ~/.cvspass
        sort -u -o ~/.cvspass ~/.cvspass
        cvs -d "${url}" co "${dir}"
    fi
    cd "${dir}"
    autoconf
    compile "${dir}" "$(pwd)"
}

function install_usr_local_stuff(){
    prepare_usr_local
    for component in emacs ccl clisp abcl ecl  # emacs_w3m
    do
        "install_${component}_from_sources"
    done
}


#-----------------------------------------------------------------------
# quicklisp
#-----------------------------------------------------------------------

function install_quicklisp(){
    local url="https://beta.quicklisp.org/quicklisp.lisp"
	local file
    file="$(basename "${url}")"
    if [ ! -r "$HOME/quicklisp/dists/quicklisp/distinfo.txt" ] ; then
        download "${url}"
        download "${url}".asc
        gpg --verify "${file}".asc "${file}" || true
        printi 'Installing quicklisp'
		# shellcheck disable=SC2119
        lisp <<EOF
(load "quicklisp.lisp")
(quicklisp-quickstart:install)
(ql:quickload "quicklisp-slime-helper")
(ccl::quit)
EOF
        mkdir -p quicklisp/local-systems/com
        ln -s ../../../src/public/lisp  quicklisp/local-systems/com/informatimago
    fi
}


function install_home_emacs(){
    printi 'Installing ~/emacs'
	mkdir -p "$HOME/emacs"
    cd "$HOME/emacs" || exit 1

    cat > subdirs.el <<EOF
;; -*- no-byte-compile: t -*-
(if (fboundp (quote normal-top-level-add-subdirs-to-load-path))
   (normal-top-level-add-subdirs-to-load-path))
EOF

    for url in "${emacs_gitrepos[@]}" ; do
        git-clone-or-warn "${url}"
    done

    for url in "${emacs_fileurls[@]}" ; do
        download "${url}"
    done

    # cd "$HOME"
    # if [ -x /Applications/Emacs.app/Contents/MacOS/Emacs ] ; then
    #     emacs=/Applications/Emacs.app/Contents/MacOS/Emacs
    # else
    #     emacs=emacs
    # fi
    # "$emacs"  --batch --eval "(dolist (package '(${elpackages[@]})) (package-install package))"

}


#-----------------------------------------------------------------------
# Darwin: EmacsForMacOSX
#-----------------------------------------------------------------------

function install_emacsformacosx(){
    local url='https://emacsformacosx.com/download/emacs-builds/Emacs-25.1-1-universal.dmg'
    local dir='/Applications/Emacs.app'
    if [ -d "${dir}" ] ; then
        printw 'There is already an item named ' "${dir}" ','
        printw '         skipping downloading emacsformacosx '  "${url}"
    else
        local dmg;dmg="$(basename "${url}")"
        local mnt;mnt="$(mktemp -d /tmp/mnt.XXXXXX)" || ( printe cannot make mount point ; return 1 )
        (
            cd /tmp || exit 1
            download "${url}"
            printi 'Installing emacsformacosx'
            dev="$(hdiutil attach "${dmg}" -mountpoint "${mnt}" |grep dev|tail -1|awk '{print $1}')"
            cp -av "${mnt}"/Emacs.app "${dir}"
            hdiutil detach "${dev}"
            rmdir "${mnt}"
        )
    fi
}


#-----------------------------------------------------------------------
# Debian: apt
#-----------------------------------------------------------------------

function install_apt_packages(){
    # for package in "${debian_packages[@]}" ; do
    #   sudo apt-get install "${package}"
    # done
    # --install-suggested
    sudo apt-get install --assume-yes --fix-broken "$@"
}


#-----------------------------------------------------------------------
# Darwin: MacPorts
#-----------------------------------------------------------------------

function install_macports(){
    local item=/opt/local/bin/port
    if [ -x "${item}" ] ; then
        printw 'There is already an item named ' "${item}" ','
        printw '         skipping installing MacPorts.'
    else
 	    local ignore1
	    local ignore2
	    local version
	    local url
		# shellcheck disable=SC2162,SC2034
	    read ignore1 ignore2 version <<<"$(distribution)"
	    case "${version}" in
	    (16.*)  url='https://distfiles.macports.org/MacPorts/MacPorts-2.3.4-10.12-Sierra.pkg' ;;
	    (15.*)  url='https://distfiles.macports.org/MacPorts/MacPorts-2.3.4-10.11-ElCapitan.pkg' ;;
	    (14.*)  url='https://distfiles.macports.org/MacPorts/MacPorts-2.3.4-10.10-Yosemite.pkg' ;;
	    (13.*)  url='https://distfiles.macports.org/MacPorts/MacPorts-2.3.4-10.9-Mavericks.pkg' ;;
	    (*) printe 'Unexpected OSX version:' "${version}"
		    return 1
		    ;;
	    esac
	    cd /tmp
		local packageName
	    packageName="$(basename "${url}")"
	    download "${url}"
	    printi 'Installing' "${packageName}"
	    sudo installer -pkg "${packageName}" -target /
    fi
}


function install_ports(){
    # run as sudo.
    export "PATH=/opt/local/bin:$PATH"
    local port
    local variant

    port selfupdate                                ; normal
    port upgrade outdated || true                  ; normal

    for port in  "${ports[@]}" ; do
        if [[ "${port}" =~ (.*)([-+])(.*) ]] ; then
            port="${BASH_REMATCH[1]}"
            variant="${BASH_REMATCH[2]}${BASH_REMATCH[3]}"
        else
            variant=''
        fi
        port install "${port}" ${variant}
        normal
    done

    port uninstall inactive      # remove the inactive ports.
    port clean --all uninstalled # remove the non-installed distfiles

    port select --set cython    cython27
    port select --set gcc       mp-gcc6
    port select --set llvm      mp-llvm-3.8
    port select --set mysql     mysql57
    port select --set nosetests nosetests27
    port select --set pip       pip33
    port select --set python    python33
    port select --set python2   python27
    port select --set python3   python33
    port select --set sphinx    py27-sphinx

    normal

    launchctl load -w /Library/LaunchDaemons/org.freedesktop.dbus-system.plist
}


function post_install_ports(){
    launchctl load -w /Library/LaunchDaemons/org.freedesktop.dbus-system.plist
    launchctl load -w /Library/LaunchAgents/org.freedesktop.dbus-session.plist
    launchctl load -w /Library/LaunchAgents/org.macports.kdecache.plist
}


#-----------------------------------------------------------------------
# Install All
#-----------------------------------------------------------------------

function install_packages(){
    printi "Starting installation on $(uname)"
    case "$(uname)" in
    (Linux)
    	if [ -r /etc/os-release ] ; then
    		if grep -q -s -e '^ID=debian' /etc/os-release ; then
    		    # Debian
                if [ $headless -eq 0 ] ; then
    		        install_apt_packages "${local_debian_packages[@]}"
                else
    		        install_apt_packages "${headless_debian_packages[@]}"
                fi
    		elif grep -q -s -e '^ID=ubuntu' /etc/os-release ; then
    		    # Ubuntu
                if [ $headless -eq 0 ] ; then
    		        install_apt_packages "${local_ubuntu_packages[@]}"
                else
    		        install_apt_packages "${headless_ubuntu_packages[@]}"
                fi
    		fi
    	fi
    	;;
    (Darwin)
        install_emacsformacosx
        install_macports
        export "PATH=/opt/local/bin:$PATH"
        sudo "${self}" --install-ports
        post_install_ports
        ;;
    esac
}

function install_all(){
    install_packages
    install_pjb_environment
	# shellcheck disable=SC1090
    source "$HOME/.bashrc"
    install_usr_local_stuff
    install_home_emacs
    install_quicklisp
    printi 'Installation completed.'
}


function prerequisites(){
    printf 'List of prerequisite components:\n'
    printf ' - %s\n' 'Oracle JDK'
    printf 'Have you installated those components? '
    read -r rep
    case "$rep" in
    (yes|y|Y|Yes|YES|oui|o|OUI|Oui|O|ja|JA|j|J) true ;;
    (*)
        printf 'Please install them first, and try again.\n'
        exit 1
        ;;
    esac
}


function help(){
	local functions=(
        install_pjb_environment
        install_emacs_from_sources
        install_ccl_from_sources
        install_clisp_from_sources
        install_abcl_from_sources
        install_ecl_from_sources
        install_emacs_w3m_from_sources
        install_usr_local_stuff
        install_quicklisp
        install_home_emacs
        install_emacsformacosx
        install_apt_packages
        install_macports
        install_ports
        post_install_ports
        install_packages
        install_all
    )
	printf '%s\n' "${functions[@]}"
}

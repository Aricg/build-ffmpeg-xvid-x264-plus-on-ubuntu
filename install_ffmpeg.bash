#!/bin/bash
#This script assumes vanilla ubnutu 12.04 or 10.04 no extra repositories.

check_if_root () {
if [[ $EUID -ne 0 ]]; then
echo "This script must be run as root"
   exit 1
fi
}

get_prerequisitpackages () {
#apt-get update
apt-get install -f git-core build-essential checkinstall libopenjpeg-dev libfaac-dev \
libfaad-dev libmp3lame-dev libopencore-amrnb-dev libopencore-amrwb-dev libsdl1.2-dev \
libtheora-dev libvdpau-dev libvorbis-dev libxfixes-dev zlib1g-dev libdirac-dev yasm  \
subversion
}


check_for_conflicting_packages () {
if [[ -z $(which ffmpeg || true) ]]
        then
echo "Installing x264"
                        install_x264

        else
echo "conflicting install exists, aborting"
                        exit 1
fi

if [[ -z $(which ffmpeg || true) ]]
        then
echo "Installing xvid"
                       install_xvid

        else
echo "conflicting install exists, aborting"
                        exit 1
fi

if [[ -z $(which ffmpeg || true) ]]
        then
echo "Installing SDL"
                        install_SDL
        else
echo "conflicting install exists, aborting"
                        exit 1
fi



if [[ -z $(which ffmpeg || true) ]]
        then
echo "Installing gpac "
                        install_gpac
        else
echo "conflicting install exists, aborting"
                        exit 1
fi


if [[ -z $(which ffmpeg || true) ]]
        then
echo "Installing ffmpeg"
                       install_ffmpeg

        else
echo "conflicting install exists, aborting"
                        exit 1
fi


}

install_x264 () {
#x264 is a free software library for encoding video streams into the H.264/MPEG-4 AVC format. GPL

#get x264
cd ~/

#check that we got it
if [ ! -d "x264" ];
    then
echo "Cloning x264 repo"
                git clone git://git.videolan.org/x264

                        if [ ! -d "x264" ];
                                then
echo "Clone Failed, not retrying"
                                                exit 1
                        fi
fi

cd x264

is_264x_installed="$(dpkg -l | grep x264 | grep "$(./version.sh| head -n1 | awk '{print $3}')")"

if [[ -z "$is_264x_installed" ]];
        then
git pull
make distclean
                ./configure --enable-static --disable-asm --enable-shared
                make
                sudo checkinstall --pkgname=x264 --pkgversion="3:"$(./version.sh| head -n1 | awk '{print $3}')"-from-script" --backup=no --deldoc=yes --fstrans=no --default

        else echo "264x already installed"
fi


}


install_xvid () {
# XVID'S WEBSITE http://www.xvid.org/
cd ~/
if [ ! -d "xvidcore" ];
    then
echo "Downloading and extracting xvid"
                wget http://downloads.xvid.org/downloads/xvidcore-1.3.2.tar.gz
                tar xvf ./xvidcore-1.3.2.tar.gz

                        if [ ! -d "xvidcore" ];
                                then
echo "Clone Failed, not retrying"
                                                exit 1
                        fi
fi

if [ -f "xvidcore-1.3.2.tar.gz" ];
        then
rm xvidcore-1.3.2.tar.gz
fi

is_xvid_installed="$(dpkg -l | grep xvid-dev-1.3.2 )"
if [[ -z "$is_xvid_installed" ]];
        then
cd xvidcore/build/generic/
                make distclean
                ./configure
                make
                sudo checkinstall --pkgname=xvid-dev-1.3.2 --pkgversion="1.3.2-from-script" --backup=no --deldoc=yes --fstrans=no --default
        else echo "xvid already installed"
fi
}

install_SDL () {
cd ~/

if [ ! -d "SDL-1.2.15" ];
        then
echo "Downloading and extracting SDL 1.2.15"
                wget http://www.libsdl.org/release/SDL-1.2.15.tar.gz
                tar -xvf SDL-1.2.15.tar.gz
        fi


is_SDL_installed="$(dpkg -l | grep sdl | grep 1.2.15)"
if [[ -z "$is_SDL_installed" ]];
        then

cd SDL-1.2.15/
./configure --enable-shared
make
checkinstall --pkgname=sdl --pkgversion="1.2.15" --backup=no --deldoc=yes --fstrans=no --default
        else echo "SDL already installed"

fi
}


install_gpac () {
cd ~/

if [ ! -d "gpac" ];
    then
echo "Downloading and extracting gpac"
                svn co https://gpac.svn.sourceforge.net/svnroot/gpac/trunk/gpac gpac

cd gpac
        ./configure --enable-shared
        make all
        checkinstall --pkgname=gpac --pkgversion="0.5.1" --default
fi
}



install_ffmpeg () {
# INSTALL FFMPEG (1.0 has been released need to update this)
cd ~/

if [ ! -d "ffmpeg" ];
    then
echo "Downloading and extracting ffmpeg"
                git clone --depth 1 git://git.videolan.org/ffmpeg
                git checkout -b git origin/release/1.1
                git pull  origin release/1.1
                        if [ ! -d "ffmpeg" ];
                                then
echo "Clone Failed, not retrying"
                                                exit 1
                        fi
fi


is_ffmpeg_installed="$(dpkg -l | grep ffmpeg-1.1-from-git-source )"
if [[ -z "$is_ffmpeg_installed" ]];
        then
cd ffmpeg
                make distclean
                ./configure --enable-gpl --enable-version3 --enable-libmp3lame --enable-libopencore-amrnb --enable-libopencore-amrwb \
                 --enable-libtheora --enable-libvorbis --enable-libx264 --enable-libxvid --enable-nonfree --enable-libfaac --enable-postproc \
                 --enable-x11grab --enable-pthreads --enable-libopenjpeg --enable-zlib --enable-bzlib --enable-filter=movie --enable-avfilter \
                 --enable-pic --enable-shared
                make
                checkinstall --pkgname=ffmpeg-1.1-from-git-source --pkgversion="1.1-from-git-source" --backup=no --deldoc=yes --fstrans=no --default
fi

}

show_decoding_options () {
ffmpeg -formats
}

check_if_root
get_prerequisitpackages
check_for_conflicting_packages
show_decoding_options

#!/bin/bash
#This script assumes vanilla ubnutu 12.04 or 10.04 no extra repositories.
script_dir=$(cd "$(dirname "$0")" && pwd) #This is actually badmojo -> http://mywiki.wooledge.org/BashFAQ/028 (will fix)

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
libtheora-dev libvdpau-dev libvorbis-dev libxfixes-dev zlib1g-dev libdirac-dev subversion 
}

#uninstall these pacakges from you machine if they already exist
check_for_conflicting_packages () {

for package in mediainfo yasm x264 xvid SDL MP4Box ffmpeg
	do


if [[ -z $(which "$package" || true) ]]
	then
		       install_"$package"
	else
		echo "conflicting package "$package" exists, skipping"
fi
	done

}


install_mediainfo () {
apt-get install python-software-properties
add-apt-repository ppa:shiki/mediainfo
apt-get update
apt-get install -f mediainfo
}


#needed to compile lib264 for extra CPU capabilities
install_yasm () {

cd "$script_dir"

#get yasm
if [ ! -d "yasm-1.2.0" ];
	 then
echo "Downloading yasm repo"
		wget http://www.tortall.net/projects/yasm/releases/yasm-1.2.0.tar.gz
		tar -xvf yasm-1.2.0.tar.gz

	if [ ! -d "yasm-1.2.0" ];
	then
echo "Download Failed, not retrying"
	exit 1
	fi
fi

is_yasm_installed="$(dpkg -l | grep yasm | grep 1.2.0)"
if [[ -z "$is_yasm_installed" ]];

	 then

cd yasm-1.2.0/
./configure
make
checkinstall --pkgname=yasm --pkgversion="1.2.0-from-script" --default

	else echo "yasm already installed"
fi

}

install_x264 () {
#x264 is a free software library for encoding video streams into the H.264/MPEG-4 AVC format. GPL

cd "$script_dir"

#get x264
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


is_264x_installed="$(dpkg -l | grep x264 | grep "$(./version.sh| head -n1 | awk '{print $3}')")"

if [[ -z "$is_264x_installed" ]];
	then
		cd x264	
		git pull
		make distclean
	./configure --enable-static --enable-shared
	make
	sudo checkinstall --pkgname=x264 --pkgversion="3:"$(./version.sh| head -n1 | awk '{print $3}')"-from-script" --backup=no --deldoc=yes --fstrans=no --default

	else 
		echo "264x already installed"
fi


}

install_xvid () {
# XVID'S WEBSITE http://www.xvid.org/

cd "$script_dir"

#get xvid
if [ ! -d "xvidcore" ];
	 then
		echo "Downloading and extracting xvid"
	wget http://downloads.xvid.org/downloads/xvidcore-1.3.2.tar.gz
	tar xvf ./xvidcore-1.3.2.tar.gz

	if [ ! -d "xvidcore" ];
	then
echo "Download Failed, not retrying"
	exit 1
	fi
fi

is_xvid_installed="$(dpkg -l | grep xvid-dev-1.3.2 )"
if [[ -z "$is_xvid_installed" ]];
	then
		cd xvidcore/build/generic/
	make distclean
	./configure
	make
	sudo checkinstall --pkgname=xvid-dev-1.3.2 --pkgversion="1.3.2-from-script" --backup=no --deldoc=yes --fstrans=no --default

	else 
		echo "xvid already installed"
fi
}

install_SDL () {
cd "$script_dir"

#get SDL
if [ ! -d "SDL-1.2.15" ];
	then
		echo "Downloading and extracting SDL 1.2.15"
	wget http://www.libsdl.org/release/SDL-1.2.15.tar.gz
	tar -xvf SDL-1.2.15.tar.gz
fi
	if [ ! -d "SDL-1.2.15" ];
	then
echo "Download of SDL-1.2.15 Failed, not retrying"
	exit 1
	fi

is_SDL_installed="$(dpkg -l | grep sdl | grep 1.2.15)"
if [[ -z "$is_SDL_installed" ]];
	then
		cd SDL-1.2.15/
		./configure --enable-shared
		make
		checkinstall --pkgname=sdl --pkgversion="1.2.15" --backup=no --deldoc=yes --fstrans=no --default

	else 
		echo "SDL already installed"
fi
}


install_MP4Box () {
cd "$script_dir"

#get MP4box
if [ ! -d "MP4Box" ];
	then
		echo "Cloning MP4Box Repo"
			svn co https://gpac.svn.sourceforge.net/svnroot/gpac/trunk/gpac MP4Box
fi

	if [ ! -d "MP4Box" ];
	then
echo "Cloning MP4box Failed, not retrying"
	exit 1
	fi
is_MP4box_installed="$(dpkg -l | grep MP4box | grep 0.5.1)"
if [[ -z "$is_MP4box_installed" ]];
	then
		cd MP4Box
		./configure --enable-shared
		make all
		checkinstall --pkgname=MP4Box --pkgversion="0.5.1" --default

	else 
	echo "MP4box already installed"

fi
}

install_ffmpeg () {
package_name="ffmpeg-1.1-from-git"
cd "$script_dir"

#get ffmpeg
if [ ! -d "ffmpeg" ];
	then
		echo "Downloading and extracting ffmpeg"
	git clone --depth 1 git://git.videolan.org/ffmpeg ffmpeg
	
fi
	if [ ! -d "ffmpeg" ];
	then
echo "Clone Failed, not retrying"
	exit 1
	fi
is_ffmpeg_installed="$(dpkg -l | grep $package_name)"
if [[ -z "$is_ffmpeg_installed" ]];
	then
	cd ffmpeg
	git checkout -b git origin/release/1.1
	git pull  origin release/1.1
	make distclean
	./configure --enable-gpl --enable-version3 --enable-libmp3lame --enable-libopencore-amrnb --enable-libopencore-amrwb \
	--enable-libtheora --enable-libvorbis --enable-libx264 --enable-libxvid --enable-nonfree --enable-libfaac --enable-postproc \
	--enable-x11grab --enable-pthreads --enable-libopenjpeg --enable-zlib --enable-bzlib --enable-filter=movie --enable-avfilter \
	--enable-pic --enable-shared
	make
	checkinstall --pkgname="$package_name" --pkgversion="1.1-from-git-source" --backup=no --deldoc=yes --fstrans=no --default
	else
	echo "ffmpeg already installed"
fi

}

show_decoding_options () {
ffmpeg -formats
}

check_if_root
get_prerequisitpackages
check_for_conflicting_packages
show_decoding_options

#TODO
#apt-get install libjpeg-progs imagemagick php5-curl php5-mysql
#yamdi () {
#wget  http://downloads.sourceforge.net/project/yamdi/yamdi/1.9/yamdi-1.9.tar.gz
#gcc yamdi.c -o yamdi -O2 -Wall
#cp yamdi /usr/local/bin
#}

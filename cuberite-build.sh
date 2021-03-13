#!/bin/bash
# Obviously you'd wanna call this script every X days ( ex; via cron: 0 0 */3 * * /home/gpay/cuberite-build.sh ).
# Manually define Cuberite source, cmake, server folder location and additionally server ip & password for MCRcon.
build_dir="/home/gpay/crs" # The build directory of Cuberite (Usually the folder where you git clone'd it.)
server_dir="/home/gpay/Server" # This is where you server actually resides.
server_ip="0.0.0.0"
spasswd="weedweed420" # Amazing rcon password i know.
cmakebin="/home/gpay/cmake-3.20.0-rc4-linux-aarch64/bin/cmake"
# Change directory to defined source location.
cd $build_dir

upb () {

# Get the commit message to be broadcasted.
commit_msg=$(git show-branch --no-name)

# Shut down the server safely for updates & kill the screen session its running on.
	mcrcon -H $server_ip -p $spasswd "say §4 [Warning] §7 Server updating in 10 seconds!"
	mcrcon -H $server_ip -p $spasswd "say §3 $commit_msg"
	sleep 10 # Let users brace themselfs for a bit.
	mcrcon -H $server_ip -p $spasswd "save-all"
	mcrcon -H $server_ip -p $spasswd "stop"
  	sync # No, I don't trust my SD card.
  	sleep 10  # Let it brace itself for a bit.
	screen -X -S "mcserver" quit # Let's stop the screen already !
	git pull # If local and repo version don't match >> pull from repo.

# Start the build
	mkdir Release # This is here to be more for sanity..
	cd Release
	rm CMakeCache.txt # This might be unnecessary but rather safe than sorry.
	$cmakebin -DCMAKE_BUILD_TYPE=RELEASE .. # Using the latest cmake for aarch64 (at least for me) yields much faster builds.
	make -j`nproc` # Lets build it.
	chmod +x $build_dir/Release/Server/Cuberite # Make the server executeable.
	cp $build_dir/Release/Server/Cuberite $server_dir # Copy the executeable to the server dir.
	screen -wipe # Let's clear any leftover dead screens for sanity.
	screen -dmS mcserver bash $server_dir/start.sh # Restart the server.
	exit
}

dpb () {
	echo "No new commits!"
	mcrcon -H 0.0.0.0 -p weedweed420 "say §7 [Info] §1No new commits." # Let's infor the players that new commits were checked for and there we no new commits-
	exit
}

# Manual build option for this buildscript.
if getopts "b:" arg; then
	echo "Manual build triggered."
	upb
fi

# Check if we have updates (aka commits) in git.
[ $(git rev-parse HEAD) = $(git ls-remote $(git rev-parse --abbrev-ref @{u} | \
sed 's/\// /g') | cut -f1) ] && dpb || upb

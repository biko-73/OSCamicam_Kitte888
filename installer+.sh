#!/bin/sh

# IP of the box for the wget commands 
BOXIP="http://localhost"
TMP=/tmp
DATE="$(date +%a.%d.%b.%Y-%H:%M)"
MESSAGES="message*"
LOGDIR=/tmp
LOGFILE=$LOGDIR/kitte888_postinst.log
EXTRAINSTALL_ANSWER_FILE=$LOGDIR/extrainstall_answer.txt
##########

# General logging.
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>$LOGFILE 2>&1

# so logging with echo output

echo "***********************************************************"
echo "*                  Kitte888    postinstall                *"
echo "***********************************************************"
echo ""
echo ""

################  just change the cam name  ######################

CAMNAME='oscamicam'

##################################################################
##########    checking your device and bin file        ###########
TMPDIR='/tmp/kitte888/install'
# where the binaries are located
ARMBIN='/tmp/kitte888/install/binary/arm/oscamarm'
MIPSBIN='/tmp/kitte888/install/binary/mipsel/oscammipsel'
# ist the camname
BINPATH='/tmp/kitte888/install/'
STARTDIR='/tmp/kitte888/install/startscript'
# camname binary

#### checking your device path
CHECK='/tmp/kitte888/install/check/cpu.txt'
############  only from his orders into the TMPDIR ###############
uname -m > $CHECK

echo "***********************************************************"
cpu="none"

if grep -qs -i 'armv7l' cat $CHECK ; then
    echo ':Your Device IS ARM processor ...'

	sleep 2
    if [ ! -f $ARMBIN ] ; then
        echo "**************************"
        echo "**** Bin file Missing ****"
        echo "**************************"
		sleep 2
        exit 1
    else
		sleep 2
        cp -f $ARMBIN $TMPDIR/$CAMNAME
		# is then in TMPDIR to be copied at startsscript selection
		cpu="arm"
    fi 

elif grep -qs -i 'mips' cat $CHECK ; then
    echo ':Your Device IS MIPS processor ...'
	sleep 2
    if [ ! -f $MIPSBIN ] ; then
        echo "**************************"
        echo "**** Bin file Missing ****"
        echo "**************************"
		sleep 2	
        exit 1
    else
		sleep 2
        cp -f $MIPSBIN $TMPDIR/$CAMNAME
		cpu="mipsel"
		 
    fi

else
    echo 'Sorry, your Device does not have the proper Emu'
	sleep 10
    rm -r $TMPDIR > /dev/null 2>&1
    rm -r $CHECK > /dev/null 2>&1
    exit 1
fi
echo "***********************************************************"
echo ""
echo ""
echo "***********************************************************"

#################  paths images for startscript  #################
OPENATV='/etc/init.d/softcam.'
PURE2='/usr/lib/enigma2/python/Plugins/Extensions/pManager'
OPENVIX='/usr/lib/enigma2/python/Plugins/SystemPlugins/ViX'
CONFIGPFAD='/etc/tuxbox/config'
VTI='/usr/lib/enigma2/python/Plugins/SystemPlugins/VTIPanel'
VTICAM='_cam.sh'
VTIPFAD=$CAMNAME$VTICAM
OPENHDF='/usr/lib/enigma2/python/Plugins/Extensions/HDF-Toolbox'
NEWNIGMA2='/usr/lib/enigma2/python/Plugins/newnigma2'
imagefound=0
imagename="no"
OSCAMCONFIGFILES='/tmp/kitte888/config/*'
OSCAMCONFIGFILES1='/tmp/kitte888/config1/*'

mkdir $CONFIGPFAD >/dev/null 2>&1
###########  start scripte copy stop oscam binary or  ############
pkill -9 oscamicam

#########################  Open ATV OK   #########################
if grep -qs -i "openATV" /etc/image-version; then
    echo "openATV image"
## check oscamicam available, keep old config files with update ##
	CONFIGPATHATV=$CONFIGPFAD/$CAMNAME
	######## -f for files exist and -d for folders ###############
	if ! [ -d $CONFIGPATHATV ];
	then
	wget -O -q "$BOXIP/web/message?text=    neuanlage      &type=2&timeout=5"
	sleep 5
	mkdir $CONFIGPFAD/$CAMNAME >/dev/null 2>&1
	sleep 2
	cp -rf $OSCAMCONFIGFILES $CONFIGPFAD/$CAMNAME >/dev/null 2>&1
	else
	wget -O -q "$BOXIP/web/message?text=    update      &type=2&timeout=5"
	sleep 5
	fi
	#############  set startscripte copy and rights ##############
    cp -rf $STARTDIR/openatv/softcam    $OPENATV$CAMNAME > /dev/null 2>&1
	sleep 1
	chmod 755 $OPENATV$CAMNAME
    ############# set binary copy and rights #####################
	cp -rf $BINPATH$CAMNAME /usr/bin > /dev/null 2>&1
	sleep 1
	chmod 755 /usr/bin/$CAMNAME
	imagefound=1
	imagename="OpenAtv"
	echo $imagefound

########################  Team Blue OK   #########################
elif grep -qs -i "teamBlue" /etc/image-version; then
    echo "Team Blue image found"
	CONFIGPATHATV=$CONFIGPFAD/$CAMNAME
	######## -f for files exist and -d for folders ###############
	if ! [ -d $CONFIGPATHATV ];
	then
	wget -O -q "$BOXIP/web/message?text=    neuanlage      &type=2&timeout=5"
	sleep 5
	mkdir $CONFIGPFAD/$CAMNAME >/dev/null 2>&1
	sleep 2
	cp -rf $OSCAMCONFIGFILES $CONFIGPFAD/$CAMNAME >/dev/null 2>&1
	else
	wget -O -q "$BOXIP/web/message?text=    update      &type=2&timeout=5"
	sleep 5
	fi

	echo "Team Blue init.d found deleted"
    rm /etc/init.d/softcam
    echo "Team Blue image update"

	update-rc.d softcam remove
 
    cp -rf $STARTDIR/teamblue/softcam    $OPENATV$CAMNAME > /dev/null 2>&1
	sleep 5
	echo "Team Blue image copy file"
	ln -s /etc/init.d/softcam.oscamicam /etc/init.d/softcam

    update-rc.d softcam defaults 90
	echo "Team Blue image copy file after softcam"
	sleep 5
	chmod 755 $OPENATV$CAMNAME
	echo "Team Blue image right softcam.oscamicam"
#########################  binary copy ###########################
	cp -rf $BINPATH$CAMNAME /usr/bin > /dev/null 2>&1
	sleep 1
	chmod 755 /usr/bin/$CAMNAME

	sleep 5
	echo "Team Blue image right bin file"
	/etc/init.d/softcam start
	imagefound=1
	imagename="TeamBlue"

##########################  pure2  OK  ###########################
elif [ -r $PURE2 ]; then
    echo "PURE2 image"
	CONFIGPATHATV=$CONFIGPFAD/$CAMNAME
	######## -f for files exist and -d for folders ###############
	if ! [ -d $CONFIGPATHATV ];
	then
	wget -O -q "$BOXIP/web/message?text=    neuanlage      &type=2&timeout=5"
	sleep 5
	mkdir $CONFIGPFAD/$CAMNAME >/dev/null 2>&1
	sleep 2
	cp -rf $OSCAMCONFIGFILES $CONFIGPFAD/$CAMNAME >/dev/null 2>&1
	else
	wget -O -q "$BOXIP/web/message?text=    update      &type=2&timeout=5"
	sleep 5
	fi

    if [ ! -r /usr/script/cam ]; then
        mkdir -p /usr/script/cam > /dev/null 2>&1
    fi
    cp -rf $STARTDIR/pure2/start.sh /usr/script/cam/$CAMNAME.sh > /dev/null 2>&1
    sleep 1
    chmod 755 /usr/script/cam/$CAMNAME.sh

	if [ ! -r /usr/bin/cam ]; then
        mkdir -p /usr/bin/cam > /dev/null 2>&1
    fi

    cp -rf $BINPATH$CAMNAME /usr/bin/cam > /dev/null 2>&1
    sleep 1
    chmod 755 /usr/bin/cam/$CAMNAME
	imagefound=1
	imagename="Pure2"

##################  open vix has them in config  #################
elif [ -r $OPENVIX ]; then
    echo "OpenVIX image"
    
	CONFIGPATHVIX=$CONFIGPFAD/oscam.kitte888
	######## -f for files exist and -d for folders ###############
	if ! [ -f $CONFIGPATHVIX ];
	then
	wget -O -q "$BOXIP/web/message?text=    neuanlage      &type=2&timeout=5"
	sleep 5
	cp -rf $OSCAMCONFIGFILES1 $CONFIGPFAD >/dev/null 2>&1
	
	else
	wget -O -q "$BOXIP/web/message?text=    update      &type=2&timeout=5"
	sleep 5
	fi

    if [ ! -r /usr/softcams ]; then
        mkdir -p /usr/softcams > /dev/null 2>&1
    fi
    cp -rf $STARTDIR/openvix/* / > /dev/null 2>&1

    cp -rf $BINPATH$CAMNAME /usr/softcams > /dev/null 2>&1
    sleep 1
    chmod 755 /usr/softcams/$CAMNAME

	imagefound=1
	imagename="OpenVix"

#############################  vti  ##############################
elif [ -r $VTI ]; then
    echo "VTI image"
	mkdir $CONFIGPFAD >/dev/null 2>&1
	ln -s /lib/libcrypto.so.1.0.0 /lib/libcrypto.so.0.9.8
	ln -s /usr/lib/libssl.so.1.0.0 /usr/lib/libssl.so.0.9.8

	CONFIGPATHATV=$CONFIGPFAD/$CAMNAME
	######## -f for files exist and -d for folders ###############
	if ! [ -d $CONFIGPATHATV ];
	then
	wget -O -q "$BOXIP/web/message?text=    neuanlage      &type=2&timeout=5"
	sleep 5
	mkdir $CONFIGPFAD/$CAMNAME >/dev/null 2>&1
	sleep 2
	cp -rf $OSCAMCONFIGFILES $CONFIGPFAD/$CAMNAME >/dev/null 2>&1
	else
	wget -O -q "$BOXIP/web/message?text=    update      &type=2&timeout=5"
	sleep 5
	fi
	
    cp -rf $STARTDIR/vti/start.sh  /usr/script/$VTIPFAD > /dev/null 2>&1
    sleep 1
    chmod 755 /usr/script/$VTIPFAD

    cp -rf $BINPATH$CAMNAME /usr/bin > /dev/null 2>&1
    sleep 1
    chmod 755 /usr/bin/$CAMNAME
	imagefound=1
	imagename="VTI"

##########################  openhdf OK  ##########################
elif [ -r $OPENHDF ]; then
    echo "OpenHDF image"

	CONFIGPATHATV=$CONFIGPFAD/$CAMNAME
	######## -f for files exist and -d for folders ###############
	if ! [ -d $CONFIGPATHATV ];
	then
	wget -O -q "$BOXIP/web/message?text=    neuanlage      &type=2&timeout=5"
	sleep 5
	mkdir $CONFIGPFAD/$CAMNAME >/dev/null 2>&1
	sleep 2
	cp -rf $OSCAMCONFIGFILES $CONFIGPFAD/$CAMNAME >/dev/null 2>&1
	else
	wget -O -q "$BOXIP/web/message?text=    update      &type=2&timeout=5"
	sleep 5
	fi

    cp -rf $STARTDIR/HDF/softcam $OPENATV$CAMNAME > /dev/null 2>&1
    sleep 1
    chmod 755 $OPENATV$CAMNAME

    cp -rf $BINPATH$CAMNAME /usr/bin > /dev/null 2>&1
    sleep 1
    chmod 755 /usr/bin/$CAMNAME
	imagefound=1
	imagename="OpenHdf"

##############################  NN2  #############################
elif [ -r $NEWNIGMA2 ]; then
    echo "newnigma2 image"

	CONFIGPATHATV=$CONFIGPFAD/$CAMNAME
	######## -f for files exist and -d for folders ###############
	if ! [ -d $CONFIGPATHATV ];
	then
	wget -O -q "$BOXIP/web/message?text=    neuanlage      &type=2&timeout=5"
	sleep 5
	mkdir $CONFIGPFAD/$CAMNAME >/dev/null 2>&1
	sleep 2
	cp -rf $OSCAMCONFIGFILES $CONFIGPFAD/$CAMNAME >/dev/null 2>&1
	else
	wget -O -q "$BOXIP/web/message?text=    update      &type=2&timeout=5"
	sleep 5
	fi
	
    cp -rf $STARTDIR/newnigma2/oscam.emu usr/script/$CAMNAME.emu > /dev/null 2>&1
    sleep 1
    chmod 755 usr/script/$CAMNAME.emu

    cp -rf $BINPATH$CAMNAME /usr/bin > /dev/null 2>&1
    sleep 1
    chmod 755 /usr/bin/cam/$CAMNAME
	imagefound=1
	imagename="NN2"

##########################  open pli OK ##########################
elif grep -qs -i "openpli" /etc/issue; then
    echo "OpenPLI image"

	CONFIGPATHATV=$CONFIGPFAD/$CAMNAME
	######## -f for files exist and -d for folders ###############
	if ! [ -d $CONFIGPATHATV ];
	then
	wget -O -q "$BOXIP/web/message?text=    neuanlage      &type=2&timeout=5"
	sleep 5
	mkdir $CONFIGPFAD/$CAMNAME >/dev/null 2>&1
	sleep 2
	cp -rf $OSCAMCONFIGFILES $CONFIGPFAD/$CAMNAME >/dev/null 2>&1
	else
	wget -O -q "$BOXIP/web/message?text=    update      &type=2&timeout=5"
	sleep 5
	fi

    cp -rf $STARTDIR/openpli/softcam $OPENATV$CAMNAME > /dev/null 2>&1
    sleep 1
    chmod 755 $OPENATV$CAMNAME
	
    cp -rf $BINPATH$CAMNAME /usr/bin > /dev/null 2>&1
    sleep 1
    chmod 755 /usr/bin/$CAMNAME
	imagefound=1
	imagename="OpenPli"

#########################  sat dream gr  #########################
elif [ -r /usr/lib/enigma2/python/Plugins/Satdreamgr ]; then
    echo "SatdreamGr image"
	ln -s /usr/lib/libcrypto.so.1.1 /usr/lib/libcrypto.so.0.9.8
	ln -s /usr/lib/libssl.so.1.1 /usr/lib/libssl.so.0.9.8


	CONFIGPATHATV=$CONFIGPFAD/$CAMNAME
	######## -f for files exist and -d for folders ###############
	if ! [ -d $CONFIGPATHATV ];
	then
	wget -O -q "$BOXIP/web/message?text=    neuanlage      &type=2&timeout=5"
	sleep 5
	mkdir $CONFIGPFAD/$CAMNAME >/dev/null 2>&1
	sleep 2
	cp -rf $OSCAMCONFIGFILES $CONFIGPFAD/$CAMNAME >/dev/null 2>&1

	else
	wget -O -q "$BOXIP/web/message?text=    update      &type=2&timeout=5"
	sleep 5
	fi

	cp -rf $STARTDIR/openpli/softcam $OPENATV$CAMNAME > /dev/null 2>&1
    sleep 1
    chmod 755 $OPENATV$CAMNAME
	
    cp -rf $BINPATH$CAMNAME /usr/bin > /dev/null 2>&1
    sleep 1
    chmod 755 /usr/bin/$CAMNAME
	imagefound=1
	imagename="SatDreamGR"


#####################  openblackhole      ########################
elif [ -f /usr/lib/enigma2/python/Screens/BpBlue.pyc ]; then
    echo "OpenBlackhole image"

	CONFIGPATHATV=$CONFIGPFAD/$CAMNAME
	######## -f for files exist and -d for folders ###############
	if ! [ -d $CONFIGPATHATV ];
	then
	wget -O -q "$BOXIP/web/message?text=    neuanlage      &type=2&timeout=5"
	sleep 5
	mkdir $CONFIGPFAD/$CAMNAME >/dev/null 2>&1
	sleep 2
	cp -rf $OSCAMCONFIGFILES $CONFIGPFAD/$CAMNAME >/dev/null 2>&1
	else
	wget -O -q "$BOXIP/web/message?text=    update      &type=2&timeout=5"
	sleep 5
	fi
###########          copy start script here       ################
###########    check whether directory exists     ################

	if [ ! -r /usr/camscript ]; then
        mkdir -p /usr/camscript > /dev/null 2>&1
    fi

    cp -rf $STARTDIR/blackhole/Ncam_oscamicam.sh /usr/camscript > /dev/null 2>&1
    sleep 1
    chmod 755 /usr/camscript/Ncam_oscamicam.sh
#######       here oscam binary      ############	
    cp -rf $BINPATH$CAMNAME /usr/bin > /dev/null 2>&1
    sleep 1
    chmod 755 /usr/bin/$CAMNAME
	imagefound=1
	imagename="OpenBlackhole"

#########################    blackhole   #########################
elif [ -r /usr/lib/enigma2/python/Blackhole ]; then
    echo "Blackhole image"

	CONFIGPATHATV=$CONFIGPFAD/$CAMNAME
	######## -f for files exist and -d for folders ###############
	if ! [ -d $CONFIGPATHATV ];
	then
	wget -O -q "$BOXIP/web/message?text=    neuanlage      &type=2&timeout=5"
	sleep 5
	mkdir $CONFIGPFAD/$CAMNAME >/dev/null 2>&1
	sleep 2
	cp -rf $OSCAMCONFIGFILES $CONFIGPFAD/$CAMNAME >/dev/null 2>&1
	else
	wget -O -q "$BOXIP/web/message?text=    update      &type=2&timeout=5"
	sleep 5
	fi
###########          copy start script here       ################
###########    check whether directory exists     ################
	if [ ! -r /usr/camscript ]; then
        mkdir -p /usr/camscript > /dev/null 2>&1
    fi

    cp -rf $STARTDIR/blackhole/Ncam_oscamicam.sh /usr/camscript > /dev/null 2>&1
    sleep 1
    chmod 755 /usr/camscript/Ncam_oscamicam.sh
###############      here oscam binary           #################	
    cp -rf $BINPATH$CAMNAME /usr/bin > /dev/null 2>&1
    sleep 1
    chmod 755 /usr/bin/$CAMNAME
	imagefound=1
	imagename="Blackhole"

#########################  openspa   OK  #########################
elif [ -r /usr/lib/enigma2/python/Plugins/Extensions/OpenSPAPlug ]; then
    echo "OpenSpa image"

	CONFIGPATHATV=$CONFIGPFAD/$CAMNAME
	######## -f for files exist and -d for folders ###############
	if ! [ -d $CONFIGPATHATV ];
	then
	wget -O -q "$BOXIP/web/message?text=    neuanlage      &type=2&timeout=5"
	sleep 2
	mkdir $CONFIGPFAD/$CAMNAME >/dev/null 2>&1
	sleep 2
	cp -rf $OSCAMCONFIGFILES $CONFIGPFAD/$CAMNAME >/dev/null 2>&1
	else
	wget -O -q "$BOXIP/web/message?text=    update      &type=2&timeout=5"
	sleep 5
	fi	
###########          copy start script here       ################
###########    check whether directory exists     ################
	if [ ! -r /usr/bin/cam ]; then
        mkdir -p /usr/script > /dev/null 2>&1
    fi

    cp -rf $STARTDIR/openspa/oscamicam.sh /usr/script > /dev/null 2>&1
    sleep 1
    chmod 755 /usr/script/oscamicam.sh
#################     here oscam binary         ###################	
    cp -rf $BINPATH$CAMNAME /usr/bin > /dev/null 2>&1
    sleep 1
    chmod 755 /usr/bin/$CAMNAME
	imagefound=1
	imagename="OpenSpa"

#########################    Egami      ##########################
elif [ -r /usr/lib/enigma2/python/EGAMI ]; then
    echo "Egami image"

	CONFIGPATHEGAMI=$CONFIGPFAD/oscam.kitte888
	######## -f for files exist and -d for folders ###############
	if ! [ -f $CONFIGPATHEGAMI ];
	then
	wget -O -q "$BOXIP/web/message?text=    neuanlage      &type=2&timeout=5"
	sleep 5
	cp -rf $OSCAMCONFIGFILES1 $CONFIGPFAD >/dev/null 2>&1
	else
	wget -O -q "$BOXIP/web/message?text=    update      &type=2&timeout=5"
	sleep 5
	fi
###########          copy start script here       ################
###########    check whether directory exists     ################
	if [ ! -r /usr/emu_scripts ]; then
        mkdir -p /usr/emu_scripts > /dev/null 2>&1
    fi

    cp -rf $STARTDIR/egami/egamistart.sh /usr/emu_scripts/EGcam_$CAMNAME.sh > /dev/null 2>&1
    sleep 1
    chmod 755 /usr/emu_scripts/$CAMNAME.sh
#################     here oscam binary     #####################	
    cp -rf $BINPATH$CAMNAME /usr/bin > /dev/null 2>&1
    sleep 1
    chmod 755 /usr/bin/$CAMNAME
	imagefound=1
	imagename="Egami"

#################  NFR has them in usr/keys   ###################
elif grep -qs -i "OpenNFR" /etc/image-version; then
    echo "OpenNFR image"

    CONFIGPATHNFR=usr/keys/oscam.kitte888
	######## -f for files exist and -d for folders ###############
	if ! [ -f $CONFIGPATHNFR ];
	then
	wget -O -q "$BOXIP/web/message?text=    neuanlage      &type=2&timeout=5"
	sleep 5
	cp -rf $OSCAMCONFIGFILES1 $CONFIGPFADNFR >/dev/null 2>&1
	
	else
	wget -O -q "$BOXIP/web/message?text=    update      &type=2&timeout=5"
	sleep 5
	fi

    if [ ! -r /usr/emu ]; then
        mkdir -p /usr/emu > /dev/null 2>&1
    fi
    cp -rf $BINPATH$CAMNAME /usr/emu > /dev/null 2>&1
    sleep 1
    chmod 755 /usr/emu/$CAMNAME
		
	imagefound=1
	imagename="Nfr"
fi
##########################   output   ############################
Imagecheck=0
Image=$imagefound

echo $Imagecheck "imagefound"  $Image

if [ $Image -gt $Imagecheck ] 
	
then
echo " image found "
	
else
echo " image not found "
imagename="Doesn't work in this image yet, sorry"
wget -O -q  "$BOXIP/web/message?text=$imagename&type=2&timeout=4"
sleep 4

fi

echo "cpu" $cpu "imagename" $imagename

echo "***********************************************************"
echo "*          The Oscam Webif has the port   8888            *" 
echo "*                                                         *"
echo "***********************************************************"
echo ""
echo "***********************************************************"
echo "*                    REBOOT THE BOX                       *"
echo "*            Plugin successfully installed                *"
echo "***********************************************************"

if [ $Image -gt $Imagecheck ]
then
echo " image found texte "
wget -O -q  "$BOXIP/web/message?text=Cpu+ist+eine+$cpu+-+OK?&type=2&timeout=4"
sleep 4
wget -O -q  "$BOXIP/web/message?text=$imagename&type=2&timeout=4"
sleep 4

wget -O -q  "$BOXIP/web/message?text=Das+Oscam+Webif+hat+den+Port+-+8888+OK?&type=2&timeout=4"
sleep 4
	
else
echo " image not found finished "

fi

#######################  delete everything #######################
wget -O -q  "$BOXIP/web/message?text= loeschen im tmp ?&type=2&timeout=4"
sleep 4
rm -rf /tmp/kitte888 >/dev/null 2>&1
sleep 3

echo
echo "*******************************************"
echo "*             Uninstall Finished          *"
echo "*                                         *"
echo "*         Need To Restart Enigma2         *"
echo "*                                         *"
echo "*                                         *"
echo "*******************************************"
echo

sleep 3

#### Restart Image GUI ####
killall -9 enigma2

# Reboot receiver:
#reboot

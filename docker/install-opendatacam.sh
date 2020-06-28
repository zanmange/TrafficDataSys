#!/bin/bash

# exit when any command fails
set -e

# Each OpenDataCam release should set the correct version here and tag appropriatly on github
VERSION=v3.0.1
# PLATFORM in ["nano","xavier","tx2","nvidiadocker"]
PLATFORM=undefined
VIDEO_INPUT=undefined
INDEX=undefined

PLATFORM_OPTIONS=("nano" "xavier" "desktop")
DEFAUT_VIDEO_INPUT_OPTIONS=("file" "file" "file")
DEFAUT_NEURAL_NETWORK_OPTIONS=("yolov4-tiny" "yolov4" "yolov4")

# PATH TO DARKNET in docker container
PATH_DARKNET=/var/local/darknet

echo "Installing OpenDataCam docker image"
command -v docker-compose >/dev/null 2>&1 || { echo >&2 "OpenDataCam requires docker-compose, please install and retry"; }

display_usage() {
  echo
  echo "Usage: $0"
  echo -n " -p, --platform   Specify platform "
  for i in "${PLATFORM_OPTIONS[@]}" 
  do
    echo -n "$i "
  done
  echo
  echo " -h, --help       Display usage instructions"
  echo
}

raise_error() {
  local error_message="$@"
  echo "${error_message}" 1>&2;
}

function index(){
  local elem=$1
  
  for i in "${!PLATFORM_OPTIONS[@]}" 
  do
    #"${foo[$i]}"
    #echo ${PLATFORM_OPTIONS[$i]} " | " ${i} " | " "${elem}"
    if [ ${PLATFORM_OPTIONS[$i]} == "${elem}" ]; then
      echo ${i}
    fi
  done
}

argument="$1"

if [[ -z $argument ]] ; then
  raise_error "Expected argument to be present"
  display_usage
  exit
fi

case $argument in
  -h|--help)
    display_usage
    ;;
  -p|--platform)

    INDEX=$( index $2)

    if [ "$INDEX" == "" ]
      then
        raise_error "Platform choise not correct"
        display_usage
        exit
    fi

    
    echo index : $INDEX
    
    # Stop any current docker container from running
    echo "Stop any running OpenDataCam docker container..."
    set +e
    sudo docker stop opendatacams
    set -e

    # Platform is specified 
    PLATFORM=$2
    
    echo "Installing OpenDataCam $VERSION for platform: $2 ..."

    # Get the docker compose file
    wget -N https://raw.githubusercontent.com/opendatacam/opendatacam/$VERSION/docker/run/$PLATFORM/docker-compose.yml

    # Get the config file
    echo "Download config file ..."
    wget -N https://raw.githubusercontent.com/opendatacam/opendatacam/$VERSION/config.json

    # Replace VIDEO_INPUT and NEURAL_NETWORK with default config for this platform
    VIDEO_INPUT=${DEFAUT_VIDEO_INPUT_OPTIONS[$INDEX]}
    NEURAL_NETWORK=${DEFAUT_NEURAL_NETWORK_OPTIONS[$INDEX]}

    echo "Replace config file with platform default params ... (you can change those later)"
    echo "NEURAL_NETWORK : $NEURAL_NETWORK"
    echo "VIDEO_INPUT : $VIDEO_INPUT"

    # Replace in config.json with default params for the current platform
    sed -i'.bak' -e "s/TO_REPLACE_VIDEO_INPUT/$VIDEO_INPUT/g" config.json
    sed -i'.bak' -e "s/TO_REPLACE_NEURAL_NETWORK/$NEURAL_NETWORK/g" config.json

    sed -i'.bak' -e "s|TO_REPLACE_PATH_TO_DARKNET|$PATH_DARKNET|g" config.json

    echo "Download, install and run opendatacam docker container"
    sudo docker-compose up -d

    # Message that docker container has been started and opendatacam will be available shorty on <IP>
    echo "OpenDataCam docker container installed successfully, it might take up to 1-2 min to start the node app and the webserver"
    
    # Cancel stop bash script on error (get IP will fail is no wifi dongle / ethernet connexion)
    set +e
    # TODO better way to get the ip to run
    wifiIP=$(ifconfig wlan0 | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')
    ethernetIP=$(ifconfig eth0 | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.2')
    
    if [ -n "$wifiIP" ]; then
      echo "WIFI device IP"
      echo "OpenDataCam is available at: http://$wifiIP:8080"
    fi

    if [ -n "$ethernetIP" ]; then
      echo "Ethernet device IP"
      echo "OpenDataCam is available at: http://$ethernetIP:8080"
    fi

    echo "OpenDataCam will start automaticaly on boot when you restart you jetson"
    echo "If you want to stop it, please refer to the doc: https://github.com/opendatacam/opendatacam"

    ;;
  *)
    raise_error "Unknown argument: ${argument}"
    display_usage
    ;;
esac


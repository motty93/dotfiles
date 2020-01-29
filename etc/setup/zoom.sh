#!/bin/bash

#zoom install
wget http://zoom.us/client/latest/zoom_amd64.deb
sudo gdebi ./zoom_amd64.deb
rm ./zoom_amd64.deb

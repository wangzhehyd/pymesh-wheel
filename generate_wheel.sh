#!/bin/bash

#===========================================================
# File Name: generate_wheel.sh
# Author: wangzhe
# E-mail: wangzhehyd@163.com
# Date: 2023-05-27 13:32:53
# Last Modified: 2023-05-27 14:14:26
# Version: 1.0
# Description: 
# Copyright: Hou group
#===========================================================

podman build -t pymesh:0.3 .
mkdir -p dist
podman run --rm -v ./dist:/mnt pymesh:0.3 bash -c "cp /root/PyMesh/dist/*.whl /mnt; cp /root/PyMesh/python/requirements.txt /mnt; cp /root/PyMesh/wheelhouse/*.whl /mnt"

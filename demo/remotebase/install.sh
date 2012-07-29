#!/bin/bash 
id=$(grep REMOTE_BASE_ID ../demo.h | awk '{print $3;}')
make z1 reinstall,$id bsl,/dev/ttyUSB$1

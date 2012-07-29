#!/bin/bash 
id=$(grep REMOTE_BASE_ID ../demo.h | awk '{print $3;}')
echo $id

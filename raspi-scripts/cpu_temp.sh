#!/usr/bin/bash

# Script to return CPU temp

cpu=$(</sys/class/thermal/thermal_zone0/temp)

echo "Current CPU tempterature is $((cpu/1000)) C."

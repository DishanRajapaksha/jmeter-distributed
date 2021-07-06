#!/bin/bash

if test -z "$@" 
then
    echo "JMeter args are empty."
    tail -f /dev/null
else
    echo "JMeter args are not empty."
    echo "JMeter args = $@"
    jmeter $@
fi
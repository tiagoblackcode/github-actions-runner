#!/usr/bin/env bash

# Inspired by https://github.com/actions-runner-controller/actions-runner-controller/issues/848#issuecomment-929394653
# Inspired by https://github.com/actions/runner/issues/775#issuecomment-927826684

if [[ $1 = "network" ]] && [[ $2 = "create" ]] ; then
    shift; shift #pop 2 first parameters

    MTU=$(docker network inspect bridge --format '{{index .Options "com.docker.network.driver.mtu"}}' 2>/dev/null); 
    if [[ ! -z "$MTU" ]]; then 
        /usr/local/bin/docker.bin network create --opt com.docker.network.driver.mtu=$MTU "${@}"  
    else
        /usr/local/bin/docker.bin network create "${@}"
    fi
else
    #just call docker as normal if not network create
    /usr/local/bin/docker.bin "${@}"
fi
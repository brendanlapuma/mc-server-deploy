#!/usr/bin/env bash
java -Xmx"${MC_RAM:-2G}" -jar fabric-server-launch.jar nogui "$@"
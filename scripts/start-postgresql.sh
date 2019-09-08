#!/usr/bin/env bash

if [ ! -d /run/postgresql ]
then
    echo "/run/postgresql doesn't exist, creating"
    sudo mkdir /run/postgresql
    sudo chgrp wheel /run/postgresql
    sudo chmod 775 /run/postgresql
fi

pg_ctl -D .test -l logs/postgresql.log start

#!/usr/bin/env bash

pg_ctl init -D .test
pg_ctl -D .test -l pg.logfile start
createdb -O dd fake-crm

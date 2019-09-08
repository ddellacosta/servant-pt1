#!/usr/bin/env bash

pg_ctl init -D .test
pg_ctl -D .test -l logs/postgresql.log start
createdb -O dd musicians

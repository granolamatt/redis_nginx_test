#!/usr/bin/env bash

MYDIR=${PWD}

openresty -c ${MYDIR}/nginx_ws.conf -p ${MYDIR}/

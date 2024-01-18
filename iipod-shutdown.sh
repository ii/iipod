#!/usr/bin/env sh
set -x

kubectl delete all -l $SPACENAME

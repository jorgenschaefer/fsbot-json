#!/bin/bash

cd "$(dirname "$0")"

emacs -batch -l getfsbotjson.el

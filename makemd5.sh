#!/bin/sh
find * \( -name '*.COM' -o -name '*.EXE' \) -exec md5sum {} \; > binmd5.sum

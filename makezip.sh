#!/bin/sh
if [ ${#} -ne 1 ]; then
  >&2 echo "please specify output zip file name" 
  exit 1
fi
rm "${1}"
find * \( -name '*.COM' -o -name '*.EXE' -o -name '*.com' -o -name '*.exe' \) -exec 7z a "${1}" {} \;

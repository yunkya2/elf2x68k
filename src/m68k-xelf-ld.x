#!/bin/bash

set -e -o pipefail

outfile="a.out"
xbaseopt=""
xstripopt=""
elfbase="0"

objs=""
param=("$@")
j=0
for ((i=0; i<${#param[@]}; i++)); do
  case ${param[$i]} in
    -o )
      i=$((i+1));
      outfile=${param[$i]}
      ;;
    -Ttext=*)
      elfbase=${param[$i]#-Ttext=}
      xbaseopt="-b ${elfbase}"
      ;;
    -s | -S | --strip* )
      xstripopt="-s"
      ;;
    * )
      newparam[j]="${param[$i]}"
      j=$((j+1))
      ;;
  esac
done

#for ((i=0; i<${#newparam[@]}; i++)); do
#	echo $i ${newparam[$i]}
#done

#set -x

m68k-xelf-ld.bfd -Ttext=${elfbase} -o "${outfile}.elf" -q ${newparam[@]}
elf2x68k.py -o "${outfile}" ${xbaseopt} ${xstripopt} "${outfile}.elf"

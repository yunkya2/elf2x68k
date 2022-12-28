#!/bin/bash

set -e -o pipefail

outfile="a.out"
xbaseopt=""
xstripopt=""
elfbase="0x6800"

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

elfbase1=`printf "0x%x" $((elfbase))`
elfbase2=`printf "0x%x" $((elfbase+0x1000))`

#set -x

m68k-elf-ld.bfd -Ttext=${elfbase1} -o "${outfile}.elf" ${newparam[@]}
m68k-elf-ld.bfd -Ttext=${elfbase2} -o "${outfile}.elf.2" ${newparam[@]}
elf2x68k.py -o "${outfile}" ${xbaseopt} ${xstripopt} "${outfile}.elf" "${outfile}.elf.2"

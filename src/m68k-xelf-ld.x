#!/bin/bash

set -e -o pipefail

outfile="a.out"
xbaseopt=""
xstripopt=""
elfbase="0"

objs=""
param=("$@")
j=0
newparam=()
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

case ${outfile} in
  *.out | *.OUT | *.elf | *.ELF )   # -o ABC.out : ABC.out   -> ABC.x
    xoutfile="${outfile%.*}.x"
    ;;
  *.* )                             # -o ABC.x   : ABC.x.elf -> ABC.x
    xoutfile="${outfile}"
    outfile="${xoutfile}.elf"
    ;;
  * )                               # -o ABC     : ABC       -> ABC.x    
    xoutfile="${outfile}".x
    ;;
esac

#for ((i=0; i<${#newparam[@]}; i++)); do
#	echo $i ${newparam[$i]}
#done

#set -x

m68k-xelf-ld.bfd -Ttext=${elfbase} -o "${outfile}" -q ${newparam[@]}
elf2x68k.py -o "${xoutfile}" ${xbaseopt} ${xstripopt} "${outfile}"

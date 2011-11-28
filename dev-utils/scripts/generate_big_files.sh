#!/bin/bash
# Generate big J2K files with kdu_compress with rotation of tiles following the parity
# kdu_compress is downloaded from http://www.kakadusoftware.com/index.php section download
# with respect to the conditions of the licence 
# $1 : input file
# $2 : output file
# $3 : output image size
# $4 : input image size 
# $5 : number of tiles in x and y file
# Example: 
# ./generate_big_files lena2048color.tiff lena_massive_rotate_2.j2k 81920 2048 40 => output file is bigger than 2^32
# ./generate_big_files lena512color.tiff lena_massive_rotate.j2k 35840 512 70 =>  => output file is bigger than 2^31

# You should export the path to your kakadu in the library path
# export LD_LIBRARY_PATH="/home/mickael/dev/src/OpenJPEG/kakadu_bin/"

i_parity = 0 # 0 => i is even and 1 => i is odd
j_parity = 0 # 0 => j is even and 1 => j is odd

for ((i=0 ; $5-$i ; i++)) do
  let "i_parity = i % 2"
 
  for ((j=0 ; $5-$j ; j++)) do
    let "j_parity = j % 2"

    if [ "$j_parity" = "1" ] && [ "$i_parity" = "0" ]   
    then
      ./kdu_compress -i $1 -o $2 Sdims="{$3,$3}" Stiles="{$4,$4}" -frag $i,$j,1,1 -quiet -rotate 180 Creversible=yes Clayers=9 Clevels=6 
    elif [ "$j_parity" = "0" ] && [ "$i_parity" = "1" ]  
    then
      ./kdu_compress -i $1 -o $2 Sdims="{$3,$3}" Stiles="{$4,$4}" -frag $i,$j,1,1 -quiet -rotate 180 Creversible=yes Clayers=9 Clevels=6 
    else
      ./kdu_compress -i $1 -o $2 Sdims="{$3,$3}" Stiles="{$4,$4}" -frag $i,$j,1,1 -quiet Creversible=yes Clayers=9 Clevels=6 
    fi

  done
  echo $i
done

echo "Big file $2 is generated"


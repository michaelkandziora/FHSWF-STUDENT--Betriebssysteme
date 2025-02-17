#!/bin/bash - 
#===============================================================================
#
#          FILE: cd_mount.sh
# 
#         USAGE: ./cd_mount.sh <UNMOUNT DESTINATION DIR>
# 
#   DESCRIPTION: Bindet ein Image aus.
#
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Michael Kandziora, kandziora.michael@fh-swf.de
#  ORGANIZATION: FH Südwestfalen, Iserlohn, Germany
#       CREATED: 09.01.2020 16:04
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error


#-------------------------------------------------------------------------------
# Variablen / Konstanten
#-------------------------------------------------------------------------------

file_type="image"
file_name=""
image_dir=$HOME"/CDs/"
mount_dir=$image_dir"mount/"


#-------------------------------------------------------------------------------
# Aufruf Parameter abarbeiten
#-------------------------------------------------------------------------------
if [ ${#} -gt 0 ]
then
  echo "Nutzung: $0 <MOUNTPOINT DIR> <IMAGE DIR> <IMAGE TYPE>"
  
  # Ein Parameter: <MOUNTPOINT DIR>
  if [ ${#} -eq 1 ]
  then
    if [ ! -d $1 ]
    then
      echo $1 "wird als Image Typ interpretiert."
      file_type=$1
    else
      mount_dir=$1
    fi
  fi
  
  # Zwei Parameter: <MOUNTPOINT DIR> <IMAGE DIR>
  if [ ${#} -eq 2 ]
  then
    if [ ! -d $1 ]
    then
      echo $1 "wird als Image Typ interpretiert."
      file_type=$1
    else
      mount_dir=$1
    fi
    
    if [ ! -d $2 ]
    then
      echo $2 "wird als Image Typ interpretiert."
      file_type=$2
    else
      image_dir=$2
    fi
  fi
  
  # Drei Parameter: <MOUNTPOINT DIR> <IMAGE DIR> <IMAGE TYPE>
  if [ ${#} -eq 3 ]
  then
    if [ ! -d $1 ]
    then
      echo "Uebergebener Parameter ist kein Verzeichnis"
      exit 2
    else
      mount_dir=$1
    fi
    
    if [ ! -d $2 ]
    then
      echo "Uebergebener Parameter ist kein Verzeichnis"
      exit 2
    else
      image_dir=$2
    fi
  
    file_type=$3
  fi
fi

#-------------------------------------------------------------------------------
# Images ermitteln
#-------------------------------------------------------------------------------
liste=$(find $image_dir -type f -name "[^.]*.$file_type")
if [ -z "$liste" ]
then
  echo -e "\n Keine Images vom Typ " $file_type " gefunden.\n"
  exit 3
fi

#-------------------------------------------------------------------------------
# Gefundene Images aushaengen 
#-------------------------------------------------------------------------------
zaehler=0


  for image in $liste 
  do 
    if [ ! -f "$image" ] || [ ! -r "$image" ]
    then
      echo -e "\n"$image" ist kein Image oder nicht lesbar.\n"
      exit 4
    fi
    
    echo "Gefundenes Image: " $image
    file_name=$(echo $image | sed -e 's:[^.]*/::g' | sed -e "s:\.$file_type::g")

    
    if [ -d "$mount_dir" ]
    then
      echo "Mount Ordner gefunden: $mount_dir"
    else
      echo -e "Mount Ordner "$mount_dir" nicht gefunden."
      exit 5
    fi

    if [ ! -d "$mount_dir$file_name" ]
    then
      echo "Mountpoint "$mount_dir$file_name" existiert nicht"
    else
      if grep --quiet "^fuseiso $mount_dir$file_name fuse" /proc/mounts
      then
	  fusermount -u "$mount_dir$file_name"
	  if [ $? -eq 0 ]
	  then
	    rmdir $mount_dir$file_name
	    if [ $? -eq 0 ]
	    then
	      echo "Mountpoint "$mount_dir$file_name" erfolgreich geloescht."
	    fi
	
	    ((zaehler++))
	  else
	    echo "Image \"$file_name.$file_type\" konnte nicht ausgehangen werden."
	  fi
      fi
    fi
  done


#-------------------------------------------------------------------------------
# Kontrollausgabe
#-------------------------------------------------------------------------------
echo -e "\n${zaehler} Images wurden ausgehaengt.\n"


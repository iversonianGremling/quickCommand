#!/usr/bin/env bash
usage() {
  printf '%s\n'     \
    "Usage: ${0##*/} [-ihrlcmsexd] [-a command] [-f file] [-b size]"    \
   "       ${0##*/} [-e file]"    \
   ''    \
   'Options:'    \
   '  -a command  Adds a new command to the bottom of the stack'    \
   '  -b size     Changes the size of the stack'    \
   '  -c name     Creates a simple script with all the stored commands'    \
   '  -d          Lists the directories used by qc'      \
   '  -e file     Loads commands from a file that can be used as a script'    \
   '  -h          Displays this help message'    \
   '  -i          Initializes the script (required before using other commands)'    \
   '  -l          Lists all stored commands'    \
   '  -m          Modifies a command in a specific slot'    \
   '  -r          Removes a specific command frcm the list'    \
   '  -s          Switches two commands'    \
   '  -u          Outputs the current stack size'    \
   '  -x          Lists available command lists'    
}


#TODO:Make a flag for changing the arguments of the commands

set -o errexit
# set -o nounset
# set -o xtrace #To debug

DEBUG=1
qc_dir=$HOME/.cache/qc
command_file="${qc_dir}"/qc_commands 
stack_file="${qc_dir}"/qc_max_stacksize
script_dir="${qc_dir}"/scripts/

if [[ -z "${stack_file}" ]]; then
  if [[ -z "${max_stacksize}" ]]; then 
    max_stacksize=$(<"${stack_file}")
  else 
    echo "var is set to ${max_stacksize}" 
  fi
fi

debug() {
    if (( DEBUG )); then
        printf '%s\n' "$*" >&2
    fi
}

isAssigned() {
  used_slots=$(sed 's/|/ /' "${command_file}" | awk '{print $1, $8}')
  if [[ "${used_slots}" == *"$1"* ]]; then
    echo "That slot is already used by another command"
    return 1
  else
    return 0
  fi
}

addCommand() {

  number_of_lines=$(wc -l "${command_file}" | cut -c 1)
  if isAssigned "$1" ; then
    max_stacksize=$(<"${stack_file}")
    if [ "${max_stacksize}" -lt $((number_of_lines + 1)) ]; then
      echo "Deleting first command from stack"
      tail -n $((max_stacksize - 1)) "${command_file}" | sponge "${command_file}"
      awk '{ print substr($0, index($0,$2)) }' "${command_file}" | sponge "${command_file}"
      awk '{print NR  " " $s}'  "${command_file}" | sponge "${command_file}"
      printf "%s %s\n" "${number_of_lines}" "${1}" >> "${command_file}"
      cat "${command_file}"
    else
      printf "%s %s\n" "$((number_of_lines + 1))" "${1}" >> "${command_file}"
    cat "${command_file}"
    fi
  fi
}

while getopts "ia:f:hrlcmsb:exdu" option; do 
  case "${option}" in 
    i)#Initializes the script (required before using other commands)    
      if [[ -z "${qc_dir}" ]]; then
      mkdir "${qc_dir}"
      echo "qc directory has been created succesfully"
    fi
    touch "${command_file}"
    sudo chmod 755 "${command_file}"
    echo "qc_commands has been created succesfully"
    touch "${stack_file}"
    sudo chmod 755 "${stack_file}"
    echo 5 > "${stack_file}"
    echo "qc_max_stacksize has been created succesfully"
    if [ ! -d "${script_dir}" ]; then
      mkdir "${script_dir}"
    fi
    echo "script directory has been created succesfully"
    touch "${script_dir}"/zzzzz
    echo "dummy file has been created succesfully"
    exit
    ;;
    a)# Adds a new command to the bottom of the stack
      command="${@:2}"
    addCommand "${command[@]}"
    exit
      ;;
    c)# Make an script based on commands
      scriptname="${qc_dir}"/scripts/${2?Error: no filename given, please see usage or provide a default file from configuration}

      touch "$scriptname"
      sed 's/^[0-9]\(.*\)/\1/' "${command_file}"| sed 's/^[ \t]\(*\)/\1/' "${command_file}" >> "$scriptname"
      echo "The script $scriptname has been saved in ${script_dir}"
      echo "These are its contents: "

      cat "$scriptname"
      exit
      ;;

    #Help
    h)#Displays this help message
      usage >&2
      exit
      ;;   
    #Remove commands
    r) #Removes a specific command frcm the list
      if (( "$#" == 2 )); then
        sed -i "/^$2/d" "${command_file}"
        sed "s/^[0-9]* //" "${command_file}" | awk '{print NR " " $0}' | sponge "${command_file}"
        cat "${command_file}"
        exit
      elif (( "$#" == 1 )); then
        command_delete_flag=y
         read -r -p "Are you sure that you want to delete all the commands? [Y/n] " command_delete_flag
         if [[ "${command_delete_flag}" != "n" ]]; then
         printf "">"${command_file}" 
         echo "All commands have been removed"
         fi
      # else 
        # read -pr "Select the command to erase: $(echo '') "$(sed 's/^\([A-Za-z0-9]\) /\1) /' "${command_file}" )"; echo 'Option: ')" option;
        # sed -i "/^$option/d" "${command_file}"
        # sed -i '/^$/d' "${command_file}"
        # sed "s/^[0-9]* //" "${command_file}" | awk '{print NR " " $0}' | sponge "${command_file}"
      fi
    ;;
    l)#Lists all stored commands
      cat "${command_file}"
      exit
    ;;
    b)#  -b size     Changes the size of the stack
    if [[ -n "$2" ]]; then
      number_of_lines=$(wc -l <"${command_file}")
      if (( "${number_of_lines}" > "$2" )); then
      echo "$2" > "${stack_file}"
      tail -n "$2" "${command_file}" | sponge "${command_file}"
      cat "${command_file}"
      sed "s/^[0-9] \(.*\)/ \1/" "${command_file}" | awk '{print NR  $s}' | sponge "${command_file}"
      cat "${command_file}"
      echo The size has been changed to "$2" , the first commands have been erased
      cat "${command_file}"
    else
      echo "$2" > "${stack_file}"
      echo Stack size changed to: "$2"
      fi
    else
      echo Error, no argumets given
    fi
    exit
    ;;
    m) #Modifies a command in a specific slot
      if (($# == 3)); then
        sed -i --expression "s:^$2.*:$2 $3:" "${command_file}"
        cat "${command_file}"
        exit
      fi
      if (( $# == 1 )); then
        echo "These are the current slots"
        cat "${command_file}"
        read -pr "Which slot would you like to edit? " slot
      fi
      if (( $# == 2 )); then
        slot="$2"
        echo "slot = $slot"
      fi
        read -pr "Introduce the new command: " command
        sed -i --expression "s:^$slot.*:$slot $command:" "${command_file}"
        cat "${command_file}"
        exit
      ;;
    s) #Switches two commands
      if (( "$#" == 1 )); then
      cat "${command_file}"
      read -r -p "Please select the two commands that you want to switch: " command1 command2
      elif (($# == 3 )); then
        command1="$2"
        command2=$3
      else
        usage >&2
        exit 1
      fi
      first_command=$(grep "^$command1" "${command_file}" | sed "s/^[0-9]/$command2/")
      second_command=$(grep "^$command2" "${command_file}" | sed "s/^[0-9]/$command1/")
      sed -i "s/^${command1}.*/${second_command}/" "${command_file}"
      sed -i "s/^${command2}.*/${first_command}/" "${command_file}"
      echo "Commands $command1 and $command2 have been swaped"
      cat "${command_file}"
      exit
      ;;
    e) #Loads commands from a file that can be used as a script
      if (( $(ls -1 "${script_dir}"| wc -l) == 1 )); then
        echo "There are no scripts/lists of commands!"
        exit 1
      else 
        if (( "$#" == 2 )); then
          file_to_load="${script_dir}""$2"
          echo "The file to load is: ${file_to_load}"
          number_of_lines_new_file=$(wc -l <"${file_to_load}")
          number_of_lines_original_file=$(wc -l <"${command_file}")
          if (( number_of_lines_new_file != number_of_lines_original_file )); then
            echo "${number_of_lines_new_file}" > "${stack_file}"
            echo The size has been changed to "${number_of_lines_new_file}"
          fi
          cat "${file_to_load}" > "${command_file}"
          echo "The new command file is as follows: "
          cat "${command_file}"
          xdotool key Return
          exit
        else
          usage >&2
          xdotool key Return
          exit
        fi
      fi
      ;;
      x)# Lists available command lists
        ls "${script_dir}"
        exit
        ;;
      d)# Lists the directories used by qc
        echo "Quick command directory: ${qc_dir}
Command file: ${command_file}
File with the size of the stack: ${stack_file}
Script directory: ${script_dir}" | column --table --separator ":"
        exit
        ;;
      u)# Outputs the current stacksize
        echo "The current stacksize is: $(<"${stack_file}")"
        exit
        ;;
      ?)
        usage >&2
        exit 1
        ;;
    esac 
  done
  shift "$((OPTIND -1))"
  
  if [[ -n "$1" ]]; then
    echo "Welcome to qc, we'll do some stuff before get going"
    if [[ -n "${qc_dir}" ]]; then
      mkdir "${qc_dir}"
      echo "qc directory has been created succesfully"
    else
      echo "qc directory already exists"
    fi
    touch "${command_file}"
    sudo chmod 755 "${command_file}"
    echo "qc_commands has been created succesfully"
    touch "${stack_file}"
    sudo chmod 755 "${stack_file}"
    echo 5 > "${stack_file}"
    echo "qc_max_stacksize has been created succesfully"
    if [ ! -d "${script_dir}" ]; then
      mkdir "${script_dir}"
    fi
    echo "script directory has been created succesfully"
    touch "${script_dir}"/zzzzz
    echo "dummy file has been created succesfully"
    exit
  fi
  if (( "$#" == 1 )); then
    slot="${1}"
    re='^[0-9]$'
    if [[ "${slot}" == "$re" ]] ; then
    execute_command=$(grep ^"$1" "${command_file}" | cut --complement -c 1,2)
    "${execute_command}"
    fi
  fi 
      
  exit

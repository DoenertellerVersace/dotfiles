### color codes
RED='\033[0;31m'
BRED='\033[1;31m'
NOCOLOR='\033[0m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BBLUE='\033[1;36m'

### alias
alias config='nano ~/.bashrc'
alias src='source ~/.bashrc 2> /dev/null'
alias ip='ifconfig | grep "inet 192.*netmask" | sed -e "s/.*inet \(.*\) netmask.*/\1/"'
alias unip='ifconfig | grep "inet 141*" | sed -e "s/.*inet \(.*\) netmask.*/\1/"'
alias rm='rm -i'
alias ij='idea .'
alias son='/Applications/Spotify.app/Contents/MacOS/Spotify & export SPOTIFY_PID=$!'
alias soff='kill $SPOTIFY_PID'
alias la='ls -a'
alias lla='ls -al'
alias back='cd $OLDPWD'
alias up='cd ..'
alias of='oh'
alias op='cd ~/dev-root/ && printf "${BBLUE}\nProjekte in ${YELLOW}~/dev-root/:${NOCOLOR}\n" && oh'
alias home='cd ~'
alias clone='git clone'
alias stat='git status'
alias add='git add'
alias commit='git commit -m'
alias mst='mvn clean install -DskipTests'
alias mci='mvn clean install'
alias gb='gradle build'
alias gt='gradle test'
alias gr='gradle run'
alias psp="ps -A | grep .App"
alias listdir="/Users/jakob/dev-root/dev-subroot/bash/listdir"
alias transpos="awk 'true { for (i=1; i<=NF; i++) { a[NR,i]=\$i } } NF>p { p=NF } END { for(j=1; j<=p; j++) { 
str=a[1,j]; for(i=2; i<=NR; i++) { str=str\" \"a[i,j]; }; print str } }'"

### set env variables
export BASH_SILENCE_DEPRECATION_WARNING=1
IFS=$'\n'

### set prompt to show git branch
parse_git_branch() {
  git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}
export PS1="\u@\h \[\e[32m\]\w \[\e[91m\]\$(parse_git_branch)\[\e[00m\]\n$ "

### real kill program script
nuke() {
	counter=0
	if [[ $# -ne 0 ]]; then
		for process in $( ps -A | grep -i $1 | grep .App | grep -wv grep ); do 
			pid=$( echo $process | awk '{print $1}' )
			name=$( echo $process | awk '{print $4$5$6$7}' )
			kill $pid &> /dev/null && counter=$((counter + 1))
		done
		printf "$counter processes were murdered to stop $1 for good\n"
	else
		printf 'gotta tell me who to nuke man...\n'
	fi
}

### open location dir script
od() {
  if [[ $# -ne 0 ]]; then
    if [[ $1 =~ $numbers ]]; then
      oh $1
    else
      cd $1 2>/dev/null
      if [ ${PWD%/} = ${1%/} ]; then
        printf "${BBLUE}\nVerzeichnisse in ${YELLOW}$PWD:${NOCOLOR}\n"
        oh
      else
        printf "\n${RED}Verzeichnis ${YELLOW}$1 ${RED}konnte nicht geoeffnet werden${NOCOLOR}\n\n"
      fi
    fi
  else
    oh
  fi
}

### open this dir script
oh() {
  list=""
  go_dir=0
  cd_go=""
  start_dir="$PWD"
  numbers='^[0-9]+$'
  counter=0

  ### check if a valid argument was passed
  if [[ $# -ne 0 ]]; then
    if [[ $1 =~ $numbers ]]; then
      go_dir=$1
    fi
  fi

  ### get subdirectories list and check if it has any
  list=$(ls -d ./*/ 2>/dev/null)
  if [[ $list = "" ]]; then
    printf "\n${RED}Keine Unterordner in diesem Verzeichnis${NOCOLOR}\n\n"
  else

    ### check if there is only 1 folder and if so set cd_go
    for item in $list; do
      counter=$(($counter + 1))
      current="$item"
    done
    if [ $counter -eq 1 ]; then
      cd_go="$current"
    fi

    ### loop through subdirectories, if go_dir is not set yet, and show with corresponding numbers
    counter=0
    if [[ $go_dir -eq 0 ]] && [[ $cd_go = "" ]]; then
      for item in $list; do
        counter=$(($counter + 1))
        show_it=${item:2}
        show_item=${show_it%/}

        if [[ $counter -lt 10 ]]; then
          printf "\n${NOCOLOR}...  ${BBLUE}$counter ${YELLOW}$show_item ${NOCOLOR}"
        else
          if [[ $counter -lt 100 ]]; then
            printf "\n${NOCOLOR}... ${BBLUE}$counter ${YELLOW}$show_item ${NOCOLOR}"
          else
            printf "\n${NOCOLOR}...${BBLUE}$counter ${YELLOW}$show_item ${NOCOLOR}"
          fi
        fi
      done

      printf "\n\n"
      read -p "Welche Ordner-Nummer? -> " go_dir
    fi

    ### second loop for finding the directory corresponding to chosen number
    counter=0
    for item in $list; do
      counter=$(($counter + 1))
      if [[ $counter -eq $go_dir ]]; then
        show_it=${item:2}
        show_item=${show_it%/}
        cd_go="$item"
      fi
    done

    ### check if directory to go to was set
    if [[ $cd_go = "" ]]; then
      if [[ $go_dir = "" ]]; then
        printf "\n${RED}Ordner-Nummer muss angegeben werden${NOCOLOR}\n\n"
      else
        printf "\n${RED}Ordner mit Nummer ${BBLUE}$go_dir ${RED}existiert nicht${NOCOLOR}\n\n"
      fi
    else
      cd "$cd_go" 2>/dev/null

      ### check if cd worked and if not, ask if sudo should be used
      if [[ $PWD = $start_dir ]]; then
        printf "\nRechte reichen nicht aus f??r Verzeichnis ${YELLOW}$show_item:${NOCOLOR}\n"
        read -p "Als root fortsetzen? [(y)es, (n)o] : " root_choice
        if [[ $root_choice = "yes" ]] || [[ $root_choice = "y" ]]; then
          printf "\n${GREEN}Wechsle als ${BRED}root@$(hostname -s) ${GREEN}nach --> ${YELLOW}$start_dir/$show_item${NOCOLOR}\n\n"
          sudo bash -c "cd $cd_go && bash"
        fi
      fi

      ### check success
      if ! [[ $PWD = $start_dir ]]; then
        show_it=${cd_go:2}
        show_item=${show_it%/}
        printf "\n${GREEN}Wechsle nach --> ${YELLOW}$show_item${NOCOLOR}\n\n"
      fi
    fi
  fi
}

run-server() {
	cd ~/server-root/ && python3 -m http.server 8080 &
}



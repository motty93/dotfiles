# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples
# We use preexec and precmd hook functions for Bash
# If you have anything that's using the Debug Trap or PROMPT_COMMAND
# change it to use preexec or precmd
# See also https://github.com/rcaloras/bash-preexec

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='%{debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='%{debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'


# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.
if [ -f "$HOME/.bash_aliases" ]; then
    . "$HOME/.bash_aliases"
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# If this is an xterm set more declarative titles
# "dir: last_cmd" and "actual_cmd" during execution
# If you want to exclude a cmd from being printed see line 156
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\$(print_title)\a\]$PS1"
    __el_LAST_EXECUTED_COMMAND=""
    print_title ()
    {
        __el_FIRSTPART=""
        __el_SECONDPART=""
        if [ "$PWD" == "$HOME" ]; then
            __el_FIRSTPART=$(gettext --domain="pantheon-files" "Home")
        else
            if [ "$PWD" == "/" ]; then
                __el_FIRSTPART="/"
            else
                __el_FIRSTPART="${PWD##*/}"
            fi
        fi
        if [[ "$__el_LAST_EXECUTED_COMMAND" == "" ]]; then
            echo "$__el_FIRSTPART"
            return
        fi
        #trim the command to the first segment and strip sudo
        if [[ "$__el_LAST_EXECUTED_COMMAND" == sudo* ]]; then
            __el_SECONDPART="${__el_LAST_EXECUTED_COMMAND:5}"
            __el_SECONDPART="${__el_SECONDPART%% *}"
        else
            __el_SECONDPART="${__el_LAST_EXECUTED_COMMAND%% *}"
        fi
        printf "%s: %s" "$__el_FIRSTPART" "$__el_SECONDPART"
    }
    put_title()
    {
        __el_LAST_EXECUTED_COMMAND="${BASH_COMMAND}"
        printf "\033]0;%s\007" "$1"
    }

    # Show the currently running command in the terminal title:
    # http://www.davidpashley.com/articles/xterm-titles-with-bash.html
    update_tab_command()
    {
        # catch blacklisted commands and nested escapes
        case "$BASH_COMMAND" in
            *\033]0*|update_*|echo*|printf*|clear*|cd*)
            __el_LAST_EXECUTED_COMMAND=""
                ;;
            *)
            put_title "${BASH_COMMAND}"
            ;;
        esac
    }
    preexec_functions+=(update_tab_command)
    ;;
*)
    ;;
esac

# function command_not_found_handle() {
#   figlet -c "command not found"
# 
#   return $?
# }

function sshs {
  t=$(cat ~/.ssh/config | grep 'Host ' | cut -f2 -d' ' | fzf --preview "cat ~/.ssh/config | sed -ne '/^Host {}$/,/^\s*$/p'")
  if [ -n "$t" ]; then
    ssh "$t"
  fi
}

#export
PATH="$HOME/bin:$HOME/.local/bin:$PATH"
# PATH="/usr/local/bin/rubocop-daemon-wrapper:$PATH"
export home="$HOME"
export PULSE_LATENCY_MSEC=30
export SDKMAN_DIR="$HOME/.sdkman"
export FLYCTL_INSTALL="/home/motty/.fly"
export PATH="$PATH:/usr/bin/go"
export PATH="$HOME/tools:$HOME/tools/bin:$PATH"
export PATH="$FLYCTL_INSTALL/bin:$PATH"
export PS1='\[\e[1;36m\]\w\[\e[m\] \n% '
export GTAGSLABEL="pygments"
export CLOUDSDK_PYTHON="$HOME/.asdf/shims/python"
export LD_LIBRARY_PATH="/usr/local/lib"
export snippets="$HOME/.cache/dein/repos/github.com/honza/vim-snippets/UltiSnips"
export HISTSIZE=200000
export ASDF_DATA_DIR="$HOME/.asdf"
export ASDF_GOLANG_MOD_VERSION_ENABLED=true
export DOCKER_BUILDKIT=0
export COMPOSE_DOCKER_CLI_BUILD=0
alias home="$home"
export GO111MODULE=on
export GOPATH="$HOME/go"
export GOBIN="$GOPATH/bin"
export PATH=$GOBIN:$PATH
export DENO_INSTALL="$HOME/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"
export RUST_WITHOUT=rust-docs
# export GOOGLE_IMPERSONATE_SERVICE_ACCOUNT="terraform@amazon-ban-staging.iam.gserviceaccount.com"
export GOOGLE_IMPERSONATE_SERVICE_ACCOUNT="terraform@ad-automation-tool.iam.gserviceaccount.com"
export GOOGLE_APPLICATION_CREDENTIALS="$HOME/.config/gcloud/application_default_credentials.json"
export NODE_OPTIONS=--openssl-legacy-provider
# mount google drive
# google-drive-ocamlfuse $HOME/GoogleDrive 2> /dev/null


[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# The next line updates PATH for the Google Cloud SDK.
if [ -f "$HOME/google-cloud-sdk/path.bash.inc" ]; then source "$HOME/google-cloud-sdk/path.bash.inc"; fi

# The next line enables shell command completion for gcloud.
if [ -f "$HOME/google-cloud-sdk/completion.bash.inc" ]; then source "$HOME/google-cloud-sdk/completion.bash.inc"; fi

if [ -f "$HOME/.asdf/asdf.sh" ]; then source "$HOME/.asdf/asdf.sh"; fi
if [ -f "$HOME/.asdf/completions/asdf.bash" ]; then source "$HOME/.asdf/completions/asdf.bash"; fi

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
export KERL_CONFIGURE_OPTIONS="--disable-debug --without-javac"

# complete -C aws_completer aws
my_prompt

# wsl2 script
if [[ "$(uname -r)" == *microsoft* ]]; then
  # docker start
  sudo /etc/init.d/docker start

  # xserver display
  export DISPLAY="$(ip route show scope global | grep -o '[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*'):0.0"

  # if [[ ! -v INSIDE_GENIE ]]; then
  #   read -t 3 -p "yn? * Preparing to enter genie bottle (in 3s); abort? " yn
  #   echo
  #
  #   if [[ \$yn != "y" ]]; then
  #     echo "Starting genie:"
  #     exec /usr/bin/genie -s
  #   fi
  # fi
fi

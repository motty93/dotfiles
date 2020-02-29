shopt -s expand_aliases

if [ -f "$HOME/.bash_function" ]; then
  . $HOME/.bash_function
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias cd="cdls"

# keyboard command
alias disablekey="disable_keyboard"
alias enablekey="enable_keyboard"

# some git command
alias push="g push"
alias pull="g pull"
alias gb="git branch"
alias gc="gcheckout"
alias gs="git status"
alias gd="git diff"
alias gl="git log"
alias gsa="git stash apply stash@{0}"
alias gcm="gcheckout_master"
alias gcd="switch_dev"
alias gmd="git merge dev"
alias mybranch="my_git_branch"

# some tools
alias pbcopy='xsel --clipboard --input'
alias mozc='/usr/lib/mozc/mozc_tool --mode=config_dialog'
alias slack='/usr/bin/slack'
alias my-chown="sudo chown -R $USER:$USER *"
alias chrome-kill="ps aux | grep [c]hrome | awk '{ print $2 }' | sudo xargs kill -9"

# rails bundle exec
alias bedev='RAILS_ENV=development bundle exec'
alias betest='RAILS_ENV=test bundle exec'

# some docker command
alias fig='docker-compose'
alias lzd='lazydocker'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias dpsd="docker rm -f $(docker ps -q -a)"
alias faw="web_container_attach"
alias dr='docker-compose run web bundle exec rails'

alias vi="vim"
alias t='tmux'

shopt -s expand_aliases

if [ -f "$HOME/.bash_function" ]; then
  . $HOME/.bash_function
fi

# peco
alias fc='find_cd'
alias fv='find_vim'
alias pk='peco-pkill'
alias his='peco-history'
alias hiss='peco-sort-history'
alias gbc='peco-git-branch'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias lp='ll | peco'
alias cd="cdls"
alias cdd="cd ../"
alias cddd="cd ../../"
alias ukiyo="cd ~/github.com/ukiyocreate"
alias sub="cd ~/github.com/subcontracting"
alias ango="cd ~/github.com/subcontracting/ango-ya"
alias blog="cd ~/github.com/home-blog"

# keyboard command aliases
alias disablekey="disable_keyboard"
alias enablekey="enable_keyboard"
alias dkey="xinput disable 17"

# some git command aliases
alias push="g push"
alias pull="g pull"
alias gb="current_branch"
alias gc="gcheckout"
alias gs="git status"
alias gd="git diff"
alias gl="git log"
alias gsa="git stash apply stash@{0}"
alias gcm="switch_master"
alias gcd="switch_dev"
alias gmd="git merge dev"
alias mybranch="my_git_branch"
alias ti="tig"

# some tools
alias pbcopy='xsel --clipboard --input'
alias mozc='/usr/lib/mozc/mozc_tool --mode=config_dialog'
alias slack='/usr/bin/slack'
alias my-chown="sudo chown -R $USER:$USER *"
alias chrome-kill="ps aux | grep [c]hrome | awk '{ print $2 }' | sudo xargs kill -9"

# rails bundle exec
alias be='bundle exec'
alias bedev='RAILS_ENV=development bundle exec'
alias betest='RAILS_ENV=test bundle exec'

# some docker command
alias fig='docker-compose'
alias lzd='lazydocker'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias dpsd="docker rm -f $(docker ps -q -a)"
alias drmi='docker images | grep none | xargs docker rmi -f `awk "{ print $3 }"`'
alias faw="web_container_attach"
alias dr='docker-compose run --rm web bundle exec rails'
alias drspec='docker-compose run --rm -e RAILS_ENV=test web bundle exec rspec'
alias solidus-up='docker run --rm -it -p 3000:3000 solidusio/solidus-demo:latest'

alias vi="vim ."
alias t='tmux'
alias remix='docker run -p 8080:80 remixproject/remix-ide:latest'

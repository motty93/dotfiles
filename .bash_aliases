shopt -s expand_aliases

if [ -f "$HOME/.bash_function" ]; then
  . $HOME/.bash_function
fi

# tools
alias pcd='find_cd'
alias pvi='find_vim'
alias pc='peco-file-cat'
alias pkill='peco-pkill'
alias pgb='peco-git-branch'
alias his='peco-history'
alias hiss='peco-sort-history'
alias cdr='peco-cd'
alias fd='fdfind'

# keymapping
alias anne='xkbcomp -I$HOME/.xkb $HOME/.xkb/keymap/anne_pro2_keymap $DISPLAY 2> /dev/null'
alias xvx='xkbcomp -I$HOME/.xkb $HOME/.xkb/keymap/xvx_m61 $DISPLAY 2> /dev/null'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias lp='ll | peco'
# alias cd="cdls"
alias cdd="cd ../"
alias cddd="cd ../../"
alias ukiyo="cd ~/github.com/ukiyocreate"
alias roots="cd ~/github.com/androots"
alias sub="cd ~/github.com/subcontracting"
alias ango="cd ~/github.com/subcontracting/ango-ya"
alias blog="cd ~/github.com/home-blog"
alias ani="cd ~/github.com/subcontracting/anique"
alias cavin="cd ~/github.com/subcontracting/cavin"
alias mint="cd /mnt/linux_mint/home/motty"

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
alias open="xdg-open"

# rails bundle exec
alias be='bundle exec'
alias bedev='RAILS_ENV=development bundle exec'
alias betest='RAILS_ENV=test bundle exec'

# some docker command
alias fig='docker-compose'
alias lzd='lazydocker'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias dpsd="docker ps -a -q | xargs docker rm -f"
alias drmi='docker images | grep none | xargs docker rmi -f `awk "{ print $3 }"`'
alias faw="web_container_attach"
alias dr='docker-compose run --rm web bundle exec rails'
alias drspec='docker-compose run --rm -e RAILS_ENV=test web bundle exec rspec'
alias dvr='specific_docker_volume_rm'

alias vi="vim ."
alias mvim="vim -u NONE -N --noplugin -c 'set swapfile nobackup nowritebackup noswapfile noundofile' -c 'syntax off'"
alias t="tmux"
alias tn="tmux new -s"
alias ta="tmux-attached"
alias ts="tmux-session"
alias tl="tmux list-sessions"
alias tkill="tmux-kill-session-all"
# alias remix='docker run -p 8080:80 remixproject/remix-ide:latest'
alias rain='era'
alias tree='tree -a -I "\.DS_Store|\.git|node_modules|vendor\/bundle" -N'

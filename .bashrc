#-------------------------#
# Aliases
#-------------------------#

alias ~="cs ~"
alias ..="cs .."
alias ...="cd ..;cs .."
alias ....="cd ..;cd ..;cs .."
alias .....="cd ..;cd ..;cd ..;cs .."
alias ls="ls -GF"
alias lsa="ls -AGF"
alias lsl="ls -AGFplh"
alias lst="ls -AGFplht"
alias c="pbcopy"
alias v="pbpaste"
alias pri="gpg -d ~/Google\ Drive/Finance/Accounts/private.json.asc | less"
alias so="source ~/.bashrc"
alias ch='open -a Google\ Chrome'
alias flushdns='dscacheutil -flushcache;sudo killall -HUP mDNSResponder'
alias grep="grep --color=always"
alias tra="trash" # requires brew install trash
alias traa="trash ./*"
alias pkg="cp -n ~/projects/new-package.json package.json && echo 'package.json created' || (echo 'package.json already exists' && false)"
alias sublimebackup="~/Library/Application\ Support/Sublime\ Text\ 3/backup.sh"

# editing aliases
alias rc="subl ~/.bashrc"
alias pro="subl ~/.bash_profile"
alias key="subl ~/Google\ Drive/Settings/Karabiner/private.xml"

# project directory
p() {
	DIR=~/projects/$@
	pushd "$DIR"
	pwd
	ls
}

md() {
	mkdir -p "$@"
	cd "$@"
}

cs() {
	cd "$@"
	pwd
	ls
}

rl() {
	which "$@" | xargs readlink
}

# display [w]here a sym[l]inked executable is pointing
wl() {
	which "$@" | xargs ls -lG
}

# add, commit, and push ~/.bashrc to dotfiles repo
dotcommit() {
	pushd ~/projects/dotfiles
	git add -A
	git commit -m "backup `date +%F-%T`"
	git push
	popd
	so
}

# diff the dotfiles repo
dotdiff() {
	pushd ~/projects/dotfiles
	git diff
	popd
}

# grep man page for a specific term
mang() {
	man "$1" | grep -n -C 2 "$2"
}

# echo the last command entered
prev() {
	history ${1:-2} | head -n 1 | sed 's/^ *[[:digit:]]* *//'
}

# Command-line usage: trim "abc   "
# Command-line usage: trim `echo "abc   "`
# Bash script usage:  $(trim "abc   ")
trim() {
    # Determine if 'extglob' is currently on.
    local extglobWasOff=1
    shopt extglob >/dev/null && extglobWasOff=0
    (( extglobWasOff )) && shopt -s extglob # Turn 'extglob' on, if currently turned off.
    # Trim leading and trailing whitespace
    local var=$1
    var=${var##+([[:space:]])}
    var=${var%%+([[:space:]])}
    (( extglobWasOff )) && shopt -u extglob # If 'extglob' was off before, turn it back off.
    echo -n "$var"  # Output trimmed string.
}

notify() {
  /usr/bin/osascript -e "display notification \"$*\" with title \"Notification\""
}

# encrypt and remove original
gpge() {
  gpg -e -r raine "$@" && rm "$@"
}

# empty the temp directory and cd there
temp() {
  rm -rf ~/test/temp &&
  mkdir ~/test/temp &&
  cd ~/test/temp
}

#-------------------------#
# git
#-------------------------#

alias git=hub
alias push="git push"
alias pusht="git push && git push --tags"
alias pushh="git push && git push heroku master && heroku info -s | grep web_url | cut -d= -f2 | xargs -I{} curl {} -w '%{http_code}' -so /dev/null"
alias pushu="git push -u origin master"
alias pull="git pull"
alias ga="git add -A"
alias gb="git branch -v"
alias gc="git checkout"
alias gd="git diff"
alias gds="git diff --staged"
alias gi="git init"
alias gl="git log"
alias gm="git commit -m"
alias gr="git remote -v"
alias gs="git status"
alias gt="git tag"
alias br="git for-each-ref --sort=-committerdate refs/heads/ --format='%(committerdate) %(authorname) %(refname:short)'"

# print working branch
alias pwb="git rev-parse --abbrev-ref HEAD"

# amend with optional new message
amend() {
	if [ $# -eq 0 ]
	then
		git commit --amend --no-edit
	else
		git commit --amend -m "$@"
	fi
}

# add all and amend with same message
aamend() {
  git add -A
  amend
}

# add and commit
gam() {
	git add -A
	git commit -m "$@"
}

# checkout prev (older) commit
gp() {
	git checkout HEAD~
}

# checkout next (newer) commit
gn() {
	BRANCH=`git show-ref | grep $(git show-ref -s -- HEAD) | sed 's|.*/\(.*\)|\1|' | grep -v HEAD | sort | uniq`
	HASH=`git rev-parse $BRANCH`
	PREV=`git rev-list --topo-order HEAD..$HASH | tail -1`
	git checkout $PREV
}

# same as 'git browse' with the hub cli
gho() {
	MATCH=$1
	: ${MATCH:="github"}
	git remote -v | grep --color=none $MATCH | head -n1 | awk '{print $2;}' | xargs open -a Google\ Chrome
}

# git commit and tag
gcat() {
	printf -v v "v%s" $(cat package.json | jsonpath version)
	git commit -m "$v"
	git tag "$v"
}

# git clone and cd
gcl() {
  git clone $1 && cd $(basename $1)
}

# git create with the description set from your package.json
# requires jq be installed
gcreate() {
  DESC=`cat package.json | jq -r .description`
  git create -d "$DESC"
  git push -u origin master
}

# git create, bump to first major version, and publish to npm
createandpub() {
  gcreate
  npub major
}

# git create, bump to first major version, publish to npm, and trigger travis build
createandpubt() {
  gcreate
  pushu
  npub major
  yes | travis enable
  git commit --amend --no-edit && git push -f # trigger travis build
}

# force push
force() {
  git push --force
}

# add, amend, and force push
aforce() {
  git add -A
  amend
  git push --force
}

#-------------------------#
# npm
#-------------------------#

alias ni="npm install"
alias nig="npm install -g"
alias nu="npm update"
alias nv="npm view"
alias nis="npm install --save"
alias nisd="npm install --save-dev"
alias nun="npm uninstall"
alias nus="npm uninstall --save"
alias nusd="npm uninstall --save-dev"
alias nls="npm ls --depth=0"
alias npmo="npm outdated --depth=0"
alias nr="npm run"
alias nt="npm test"
alias nre="npm repo"

alias yi="yarn install"
alias ya="yarn add"
alias yr="yarn remove"
alias yl="yarn link"

# browse the home page of an npm module
npmb() {
  npm view "$@" homepage | xargs open
}

# npm view short
nvs() {
  npm view "$@" name description repository.url version
}

# print the dist-tags for an npm module
dt() {
  npm view "$@" dist-tags
}

# bump the version, push, and publish
npub() {

  if [ $# -eq 0 ]
  then
    echo "You must specify major|minor|patch"
    return 1
  else
    npm version "$@" &&
    git push &&
    git push --tags &&
    npm publish
  fi

}

#-------------------------#
# Miscellaneous
#-------------------------#

# added by travis gem
[ -f /Users/raine/.travis/travis.sh ] && source /Users/raine/.travis/travis.sh

alias node='env NODE_REPL_HISTORY_FILE=$HOME/.node_history node'

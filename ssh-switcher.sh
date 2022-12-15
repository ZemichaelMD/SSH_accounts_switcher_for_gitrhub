
function ssh-which() {
  if [ $# -ge 1 ]; then
    echo "[usage] ssh-which"
    return 1
  fi
  if [ ! -f ~/.ssh/.active ]; then
    echo "No active key yet"
  else
    echo "Active key: \"$(cat ~/.ssh/.active)\""
    ssh -T git@github.com
  fi
}

function ssh-list() {
  if [ $# -ge 1 ]; then
    echo "[usage] ssh-list"
    return 1
  fi
  current=$(pwd)
  echo "Existing profiles:"
  cd ~/.ssh
  find * -type d
  cd $current
}

function ssh-create() {
  if [ $# -ge 1 ]; then
    echo "[usage] ssh-create"
    return 1
  fi
  printf "Enter a name for this ssh git profile: "; read profile
  printf "Enter your name: "; read name
  printf "Enter your git username: "; read username
  printf "Enter your git user mail: "; read email
  printf "Enter your git private access token (Optional): "; read token

  echo "Generating new key for \"$profile\""
  rm -rf ~/.ssh/$profile &> /dev/null
  mkdir -p ~/.ssh/$profile &> /dev/null
  ssh-keygen -q -b 4096 -t rsa -f ~/.ssh/$profile/id_rsa -C "$email" -N ''
  printf "[user]\nemail = $email\nname = $username\n\n[github]\nuser = $username\ntoken = $token" > ~/.ssh/$profile/.gitconfig
  printf "Files created:\n$(ls -p -a ~/.ssh/$profile | grep -v / | grep -v '^[\.]*/$')\n"
  ssh-which
}

# function ssh-stash() {
#   if [ $# -ge 1 ]; then
#     profile=$1
#     echo $profile > ~/.ssh/.active
#   fi

#   if [ ! -f ~/.ssh/.active ]; then
#     echo "No active key to stash"
#     return 1
#   fi

#   active=$(cat ~/.ssh/.active)
#   mkdir -p ~/.ssh/$active &> /dev/null
#   cp -f ~/.ssh/id_rsa* ~/.ssh/$active/ &> /dev/null
#   cp -f ~/.ssh/known_hosts ~/.ssh/$active/ &> /dev/null
#   cp -f ~/.gitconfig ~/.ssh/$active/ &> /dev/null

#   echo "SSH key stashed to \"$active\""
# }

function ssh-switch() {
  if [ $# -ge 1 ]; then
    echo "[usage] ssh-switch"
    return 1
  fi
  current=$(pwd)
  cd ~/.ssh
  PS3="Please select profile to switch to: "
  profileNames=$(for f in */; do echo "${f%/*}"; done | sort -u )
  select lng in $profileNames
  do
    case $lng in
      $lng)
        if [ -z "$lng" ]
        then
          echo "Invalid! Please select again..."
        else
          if [ ! -f ~/.ssh/$lng/id_rsa ]; then
            echo "No profile \"$lng\" exists"
            return 2
          else
            # ssh-stash
            cp -f ~/.ssh/$lng/.gitconfig ~/.gitconfig
            cp -f ~/.ssh/$lng/id_rsa* ~/.ssh
            cp -f ~/.ssh/$lng/known_hosts ~/.ssh/known_hosts
            echo $lng > ~/.ssh/.active
            ssh-which
            break
          fi
        fi
    esac
  done
  cd $current
}

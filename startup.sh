#!/bin/sh

# OSX Start v1.2.0
# (c)2017 Robert Hafner <tedivm@tedivm.com>
# MIT License (see LICENSE file)
# https://github.com/tedivm/osx_start

user='Robert Hafner'
email='tedivm@tedivm.com'

# Apps to install with Caskroom.
# Installed to /opt/homebrew-cask/Caskroom/ and linked to /Applications.
apps=(
  appcleaner
  arduino
  caffeine
  cheatsheet
  cyberduck
  disk-inventory-x
  docker
  docker-toolbox
  dropbox
  firefox
  github
  hermes
  istumbler
  java
  libreoffice
  sequel-pro
  skype
  slack
  spotify
  the-unarchiver
  textmate
  transmission
  vagrant
  vagrant-manager
  virtualbox
  visual-studio-code
  xquartz
)

# Plugins to install with cask
plugins=(
  qlcolorcode
  qlstephen
  qlmarkdown
  qlprettypatch
  qlprettypatch
  quicklook-csv
  quicklook-json
  suspicious-package
  webpquicklook
)


# Build tools- install these first so other tools are built with them.
build=(
  autoconf
  automake
  bash
  coreutils
  findutils
  gcc
  grep
  imagemagick
  zlib
)


# Standard applications to install with Brew (not using casks).
binaries=(
  ack
  boost
  cmake
  curl
  ffmpeg
  git
  golang
  graphicsmagick
  homebrew/php/composer
  hub
  jq
  mtr
  nano
  nmap
  libyaml
  lunar
  node
  pandoc
  pcre
  pngcrush
  pyenv
  python
  pyqt
  rename
  shellcheck
  trash
  tree
  watch
  webkit2png
  wget
  zeromq
  zopfli
)


# Fonts to install with Homebrew Fonts
fonts=(
  font-clear-sans
  font-inconsolata
  font-m-plus
  font-roboto
  font-microsoft-office
)

# Applications available via gem installer
gems=(
  puppet-lint
  jekyll
)


# Applications available via pip installer
pips=(
  awscli
  jinja2
  nose
  pep8
  pyparsing
  python-dateutil
  pygments
  pyzmq
  tornado
  virtualenv
  ipython
)


# Applications available via npm installer
npms_global=(
  coffeescript
  create-app-react-express
  express-generator
  generator-express-no-stress
  git-labelmaker
  grunt-cli
  gulp
  http-server
  jsonsmash
  mklicense
  nativescript
  serve
  serverless
  sloc
  standard
  yarn
  yo
)


# These packages have to be installed after pip.
brew_science=(
  numpy
  scipy
  matplotlib
)


# Enable syntax highlighting for nano
echo 'include /usr/local/share/nano/*.nanorc' > .nanorc

# Initial sudo now so we can walk away from the script.
sudo -v


# Trigger OSX CLI Install package if needed, otherwise do nothing.
echo "Checking for Xcode Command Line Tools"
gcc --version > /dev/null

#

# Check for PIP and install it if it's not available.
if test ! $(which pip); then
  echo "Installing pip..."
  sudo easy_install pip
fi


# Refresh sudo
sudo -v


# Check for Homebrew, install if we don't have it
if test ! $(which brew); then
  echo "Installing homebrew..."
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi


# Refresh sudo
sudo -v

# Add the base stuff
echo "Installing base build packages..."
brew install ${build[@]}

# Refresh sudo
sudo -v

# Update homebrew recipes
echo "Upgrading homebrew and installed packages..."
brew update
brew upgrade

# Refresh sudo
sudo -v

# Add override and backup paths to override system binaries and add new applications, respectively.
export PATH=$(brew --prefix coreutils)/libexec/gnubin:$PATH:/usr/local/opt
buildPathAddition="export PATH=\$(brew --prefix coreutils)/libexec/gnubin:/usr/local/sbin:$PATH:/usr/local/opt"
if grep -q "$buildPathAddition" ~/.profile
then
    echo "Build path already saved..."
else
    echo "Saving build path to ~/.zshrc..."
    echo  $buildPathAddition >> ~/.zshrc
    
    # The system zlib is currently broken
    echo "export LDFLAGS=\"-L/usr/local/opt/zlib/lib\""  >> ~/.zshrc
    echo "export CPPFLAGS=\"-I/usr/local/opt/zlib/include\""  >> ~/.zshrc
    echo "export PKG_CONFIG_PATH=\"/usr/local/opt/zlib/lib/pkgconfig\""  >> ~/.zshrc
fi

# The system zlib is currently broken
export LDFLAGS="-L/usr/local/opt/zlib/lib"
export CPPFLAGS="-I/usr/local/opt/zlib/include"
export PKG_CONFIG_PATH="/usr/local/opt/zlib/lib/pkgconfig"

# Add base packages
echo "Installing binaries..."
for i in "${binaries[@]}"
do
  echo "Installing $i..."
  brew install "$i"
  # Refresh sudo
  sudo -v
done

brew tap homebrew/cask


# Refresh sudo
sudo -v

echo "Installing apps..."
for i in "${apps[@]}"
do
  echo "Installing $i..."
  brew cask install "$i"
  # Refresh sudo
  sudo -v
done


# Install plugins.
echo "installing plugins..."
for i in "${plugins[@]}"
do
  echo "Installing $i..."
  brew cask install "$i"
  # Refresh sudo
  sudo -v
done

# Refresh sudo
sudo -v

# Install fonts
echo "Installing fonts..."
brew tap homebrew/cask-fonts
brew tap colindean/fonts-nonfree
for i in "${fonts[@]}"
do
  echo "Installing $i..."
  brew cask install "$i"
done

# Refresh sudo
sudo -v

# Install gems
echo "Installing ruby gems..."
sudo gem install "${gems[@]}"


# Install npm packages
echo "Installing npm globals..."
for i in "${npms_global[@]}"
do
  echo "Installing $i..."
  sudo npm install -g "$i"
done


# Install pips
echo "Installing python pips..."
sudo python3 -m pip install "${pips[@]}" --upgrade --ignore-installed six

# Refresh sudo
sudo -v

# Add the base stuff
echo "Installing python science packages..."
brew install "${brew_science[@]}"


# Update composer
echo "Self update composer..."
composer selfupdate


echo "Configuring git..."
currentuser=$(whoami)
sudo chown -R ${currentuser}:staff .config
git config --global user.name "$user"
git config --global user.email "$email"
git config --global credential.helper osxkeychain
if [ ! -f ~/.gitignore ]; then
  touch ~/.gitignore
  echo '.DS_Store' >> ~/.gitignore
  echo '._*' >> ~/.gitignore
  echo 'Thumbs.db' >> ~/.gitignore
  echo '.Spotlight-V100' >> ~/.gitignore
  echo '.ruby-version' >> ~/.gitignore
  echo '.gitcredentials' >> ~/.gitignore
  echo 'github_app.private-key.pem' >> ~/.gitignore
  echo '.vscode*' >> ~/.gitignore
fi


# Right now cleanup
echo "Cleaning up..."
brew cleanup

echo "All done!"

#!/bin/sh

# OSX Start v1.1.0
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
  asepsis
  atom
  caffeine
  cheatsheet
  cyberduck
  disk-inventory-x
  docker-toolbox
  dropbox
  firefox
  github
  hermes
  istumbler
  java
  libreoffice
  mou
  omnigraffle
  omnioutliner
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
  xquartz
)

# Plugins to install with cask
plugins=(
  betterzipql
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
  homebrew/dupes/grep
  imagemagick
)


# CLI applications to install with Brew.
binaries=(
  ack
  android-sdk
  boost
  cmake
  curl
  ffmpeg
  git
  graphicsmagick
  homebrew/php/composer
  hub
  jq
  mtr
  nano
  nmap
  libyaml
  node
  pandoc
  pcre
  pngcrush
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
  express-generator
  generator-express-no-stress
  git-labelmaker
  grunt-cli
  gulp
  jsonsmash
  mklicense
  nativescript
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


# Atom plugins with apm
atom=(
  atom-autocomplete-php
  atom-beautify
  atom-jinja2
  atom-terminal
  autocomplete-php
  autocomplete-python
  autocomplete-ruby
  badges
  color-picker
  dash-ui
  docker
  es6-javascript
  file-type-icons
  impure-syntax
  language-docker
  language-groovy
  language-pgsql
  language-protobuf
  language-puppet
  language-restructuredtext
  language-markdown
  linter
  linter-docker
  linter-js-standard
  linter-js-yaml
  linter-jshint
  linter-php
  linter-protocol-buffer
  linter-puppet-lint
  linter-python
  linter-shellcheck
  markdown-toc
  markdown-lists
  merge-conflicts
  php-analyser
  php-cs-fixer
  pigments
  rst-preview
  rst-preview-pandoc
  tabs-to-spaces
  travis-ci-status
  tidy-markdown
  wordcount
)

# Enable syntax highlighting for nano
echo 'include /usr/local/share/nano/*.nanorc' > .nanorc

# Initial sudo now so we can walk away from the script.
sudo -v


# Trigger OSX CLI Install package if needed, otherwise do nothing.
echo "Checking for Xcode Command Line Tools"
gcc --version > /dev/null


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
    echo "Saving build path to ~/.profile..."
    echo  $buildPathAddition >> ~/.profile
    echo "export ANDROID_HOME=/usr/local/opt/android-sdk" >> ~/.profile
fi


# Add base packages
echo "Installing binaries..."
for i in "${binaries[@]}"
do
  echo "Installing $i..."
  brew install "$i"
  # Refresh sudo
  sudo -v
done

brew tap caskroom/cask


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
brew tap caskroom/fonts
brew tap colindean/fonts-nonfree
for i in "${fonts[@]}"
do
  echo "Installing $i..."
  brew cask install "$i"
done

# Refresh sudo
sudo -v

# Install atom packages
echo "Installing atom packages..."
for i in "${atom[@]}"
do
  echo "Installing $i..."
  apm install "$i"
  # Refresh sudo
  sudo -v
done


# Refresh sudo
sudo -v

# Install gems
echo "Installing ruby gems..."
sudo gem install "${gems[@]}"


# Install gems
echo "Installing npm globals..."
for i in "${npms_global[@]}"
do
  echo "Installing $i..."
  sudo npm install -g "$i"
done


# Install pips
echo "Installing python pips..."
sudo pip install "${pips[@]}" --upgrade --ignore-installed six

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
  echo '.Trashes' >> ~/.gitignore
fi


# Apply settings
echo "Disabling iTunes autostart on media keys..."
launchctl unload -w /System/Library/LaunchAgents/com.apple.rcd.plist


# Right now cleanup
echo "Cleaning up..."
brew cleanup

echo "All done!"

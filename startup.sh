#!/bin/sh

# OSX Start v1.0.0
# (c)2014 Robert Hafner <tedivm@tedivm.com>
# MIT License (see LICENSE file)
# https://github.com/tedivm/osx_start


# Apps to install with Caskroom.
# Installed to /opt/homebrew-cask/Caskroom/ and linked to /Applications.
apps=(
  arduino
  atom
  caffeine
  crashplan
  cyberduck
  disk-inventory-x
  dropbox
  firefox
  flash
  github
  hermes
  lastpass-universal
  libreoffice
  mou
  omnigraffle
  omnioutliner
  phpstorm
  qlmarkdown
  qlprettypatch
  qlstephen
  quicklook-json
  sequel-pro
  skype
  slack
  spotify
  the-unarchiver
  textmate
  transmission
  vagrant
  virtualbox
)


# Build tools- install these first so other tools are built with them.
build=(
  autoconf
  automake
  bash
  coreutils
  findutils
  homebrew/dupes/grep
)


# CLI applications to install with Brew.
binaries=(
  ack
  android-sdk
  cmake
  curl
  ffmpeg
  git
  graphicsmagick
  hhvm
  hub
  nmap
  node
  pcre
  python
  rename
  sshfs
  trash
  tree
  webkit2png
  wget
  zopfli
)


# Fonts to install with Homebrew Fonts
fonts=(
  font-clear-sans
  font-inconsolata
  font-m-plus
  font-roboto
)

# Atom plugins with apm
atom=(
  atom-beautify
  atom-terminal
  language-puppet
  language-markdown
  linter
  linter-js-yaml
  linter-puppet-lint
  markdown-toc
  markdown-preview
  markdown-lists
  merge-conflicts
  tabs-to-spaces
  wordcount
  autocomplete-python
  atom-autocomplete-php
  autocomplete-ruby
  travis-ci-status
)

# Trigger OSX CLI Install package if needed, otherwise do nothing.
echo "Checking for Xcode Command Line Tools"
gcc --version > /dev/null


# Check for Homebrew, install if we don't have it
if test ! $(which brew); then
  echo "Installing homebrew..."
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi


# Add the base stuff
echo "Installing base build packages..."
brew tap homebrew/dupes
brew install ${build[@]}


# Update homebrew recipes
echo "Upgrading homebrew and installed packages..."
brew update
brew upgrade


# Add override and backup paths to override system binaries and add new applications, respectively.
export PATH=$(brew --prefix coreutils)/libexec/gnubin:$PATH:/usr/local/opt
buildPathAddition="export PATH=\$(brew --prefix coreutils)/libexec/gnubin:$PATH:/usr/local/opt"
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
brew install ${binaries[@]}
brew install caskroom/cask/brew-cask


# Install apps to /Applications
# Default is: /Users/$user/Applications
echo "installing apps..."
brew cask install --appdir="/Applications" ${apps[@]}


# Install fonts
echo "Installing fonts..."
brew tap caskroom/fonts
brew cask install ${fonts[@]}


# Install atom packages
echo "Installing atom packages..."
apm install ${atom[@]}


# Right now cleanup
echo "Cleaning up..."
brew cleanup

echo "All done!"

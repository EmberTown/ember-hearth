#!/bin/sh
if [ ! -f ~/.bash_profile ]; then
cp ~/.bashrc ~/.bash_profile
fi

if ! grep "PATH=\$HOME/local/bin:\$PATH" ~/.bashrc ; then
echo 'export PATH=$HOME/local/bin:$PATH' >> ~/.bashrc
fi

if ! grep "PATH=\$HOME/local/bin:\$PATH" ~/.bash_profile ; then
echo 'export PATH=$HOME/local/bin:$PATH' >> ~/.bash_profile
fi
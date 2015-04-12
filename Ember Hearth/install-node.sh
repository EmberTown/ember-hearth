# via https://gist.github.com/isaacs/579814
if ! grep "PATH=\$HOME/local/bin:\$PATH" ~/.bashrc ; then
 echo 'export PATH=$HOME/local/bin:$PATH' >> ~/.bashrc
fi
if ! grep "PATH=\$HOME/local/bin:\$PATH" ~/.bash_profile ; then
    echo 'export PATH=$HOME/local/bin:$PATH' >> ~/.bash_profile
fi
. ~/.bashrc
. ~/.bash_profile
mkdir ~/local
mkdir ~/node-latest-install
cd ~/node-latest-install
curl http://nodejs.org/dist/node-latest.tar.gz | tar xz --strip-components=1
./configure --prefix=$HOME/local
make install

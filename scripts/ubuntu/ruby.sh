# Install ruby 2.1.3

apt-get -y install libyaml-0-2

wget https://www.dropbox.com/s/hwdt4q6l82uxdsc/ruby-2.1.3_amd64.deb
dpkg -i ruby-2.1.3_amd64.deb
sudo apt-get install -f

rm ruby-2.1.3_amd64.deb

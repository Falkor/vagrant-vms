# Install ruby 2.1.3

apt-get -y install libyaml-0-2

wget http://ec2-54-77-95-196.eu-west-1.compute.amazonaws.com/repo/ubuntu14.04/packages/ruby-2.1.3_amd64.deb
dpkg -i ruby-2.1.3_amd64.deb
sudo apt-get install -f

rm ruby-2.1.3_amd64.deb

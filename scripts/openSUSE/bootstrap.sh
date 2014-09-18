# Falkor Bootstrap to install missing packages etc... 

## First remove the old version of ruby (cause librarian-puppet need 1.9.3 or higher and centos6.5 has 1.8.7)
#yum remove -y ruby ruby-devel
#
## Second install ruby 2.1.2 from the source
#yum -y groupinstall "Development Tools"
#yum -y install openssl-devel
#yum -y install wget
#wget http://cache.ruby-lang.org/pub/ruby/2.1/ruby-2.1.2.tar.gz
#tar xvfvz ruby-2.1.2.tar.gz
#cd ruby-2.1.2
#./configure
#make
#make install
#
## Third create symlink to have it in the path
#ln -s /usr/local/bin/* /usr/bin/
#
## Forth update Rubygems and Bundler
#gem update --system
#gem install bundler
#
## Fifth update allready installed gems if any
#gem update -f




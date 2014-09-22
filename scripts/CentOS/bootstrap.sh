# Falkor Bootstrap to install missing packages etc... 

yum install -y wget
#wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
#wget http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
#rpm -Uvh remi-release-6*.rpm epel-release-6*.rpm
#yum install -y libyaml
#rpm -ivh https://www.dropbox.com/s/18z5vvkpnambr1m/ruby-2.1.2-2.el6.x86_64.rpm?dl=0

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
#
#yum install -y ruby-devel




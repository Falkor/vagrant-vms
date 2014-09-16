# Falkor Bootstrap to install missing packages etc... 

# Install Ruby
yum install ruby

# Needed dependencies
yum install gcc g++ make automake autoconf curl-devel openssl-devel zlib-devel httpd-devel apr-devel apr-util-devel sqlite-devel
yum install ruby-rdoc ruby-devel

# Install Ruby Gems
yum install rubygems

# Install librarian-puppet
gem install librarian-puppet





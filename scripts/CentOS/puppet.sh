# Install Puppet

VERSION=$(sed 's/[^0-9]//g' /etc/centos-release)
VERSION=${VERSION:0:1}

yum install -y epel-release

if [ "$VERSION" -eq "6" ]
then
    # Ajout du repository personnel contenant le package ruby
    echo "[personal-repo-www]" >> /etc/yum.repos.d/personal-repos-www.repo
    echo "gpgcheck=0" >> /etc/yum.repos.d/personal-repos-www.repo
    echo "name=Red Hat Linux $releasever - $basearch" >> /etc/yum.repos.d/personal-repos-www.repo
    echo "baseurl=http://ec2-54-77-188-112.eu-west-1.compute.amazonaws.com/repo/el6/" >> /etc/yum.repos.d/personal-repos-www.repo

    yum clean all
    yum install -y ruby-2.1.2-2.el6.x86_64
elif [ "$VERSION" -eq "7" ]
then
    # Ajout du repository personnel contenant le package ruby
    echo "[personal-repo-www]" >> /etc/yum.repos.d/personal-repos-www.repo
    echo "gpgcheck=0" >> /etc/yum.repos.d/personal-repos-www.repo
    echo "name=Red Hat Linux $releasever - $basearch" >> /etc/yum.repos.d/personal-repos-www.repo
    echo "baseurl=http://ec2-54-77-188-112.eu-west-1.compute.amazonaws.com/repo/el7/" >> /etc/yum.repos.d/personal-repos-www.repo

    yum clean all
    yum install -y ruby-2.1.3-2.el7.centos.x86_64
fi

gem install puppet facter ruby-shadow


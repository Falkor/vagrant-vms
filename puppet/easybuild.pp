class easybuild {
	
	exec { 'install-eb':
		user => 'swuser',
		command => 'cd && wget https://raw.github.com/hpcugent/easybuild-framework/develop/easybuild/scripts/bootstrap_eb.py && python bootstrap_eb.py /opt/apps/EasyBuild && rm bootstrap_eb.py',
		unless => 'test -d /opt/apps/EasyBuild',
		require => [ Package [ 'GitPython' ],
			File [ '/opt/apps' ],
			User [ 'swuser' ],
			]
	}

	package { 'GitPython':
                ensure => latest,
        }

	File { '/opt/apps':
		ensure => directory,
		mode => '0777',
	}

	User { 'swuser':
		ensure => 'present',
	}

	#configure eb env
	file { '/etc/profile.d/easybuild.sh':
		ensure => file,
		owner => 'swuser',
		source => "/tmp/eb_config/easybuild.sh",
		require => exec [ 'Git' ],
	}

	exec { 'Git':
		# Commande temporaire : pas sur qu'on garde l'avantage de Git : la commande telecharge tout ou juste ce qui differe ? A verifier
		# Pour le moment dans tmp, a changer pour conserver le repo git
		command => 'cd /tmp/eb_config && git fetch origin --all && git reset --hard origin/master',
		require => exec [ 'GitInit' ],
	}

	exec { 'GitIni':
		command => 'cd /tmp/eb_config && git clone https://github.com/sylmarien/easybuild.git .',
		unless => 'test -d /tmp/eb_config/.git',
		require => File [ '/tmp/eb_config' ],
	}

	File { '/tmp/eb_config':
		ensure => directory,
		mode => '0777',
	}
}

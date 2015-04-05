default['sickrage'] = {
	'repo' => 'https://github.com/SiCKRAGETV/SickRage',
	'prerequisites' => {
		'linux' => [
			'git-core',
			'python',
			'python-cheetah',
			'unrar-free'
		]
	},
	'init' => {
		'ubuntu' => 'init.ubuntu'
	},
	'config' => {
		'path' => '/opt/SickRage',
		'branch' => 'master',
		# Service account
		'user' => 'servicesickrage',
		# Service account
		'password' => 'pass',
		'datadir' => '/var/SickRage/',
		'options' => '--config=/var/SickRage/config.ini',
		'providers_replace' =>{
			'piratebay' => {
				'search' => 'pirateproxy\.net',
				'replace' => 'pirateproxy.ws'
			}
		}
	}
}
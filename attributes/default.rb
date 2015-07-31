default['castor']['version'] = '0.4.3'
default['castor']['user'] = 'castor'
default['castor']['group'] = 'castor'
default['castor']['base_dir'] = '/opt/castor'

default['ls_logstash_forwarder']['logs']['/var/log/castor/*.log'] = { 'type' => 'rds', 'log_format' => 'json' }

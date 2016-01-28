default['castor']['version'] = '1.0.3'
default['castor']['user'] = 'castor'
default['castor']['group'] = 'castor'
default['castor']['base_dir'] = '/opt/castor'
default['castor']['iam_profile_name'] = 'aws-rds-readonly-download-logs-role'
default['castor']['logrotate_postrotate'] = '/etc/init.d/logstash-forwarder restart'
default['castor']['aws']['region'] = 'us-east-1'
default['castor']['logs_to_process'] = %w(general slowquery)

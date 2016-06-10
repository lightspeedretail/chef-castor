#
# Cookbook Name:: castor
# Recipe:: crons
#
# Copyright (C) 2015 Lightspeed POS Inc.
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

link '/etc/cron.hourly/logrotate' do
  to '/etc/cron.daily/logrotate'
end

if node['castor']['rds_instances'].empty?
  chef_gem 'aws-sdk' do
  end.run_action(:install)

  ruby_block 'create cron jobs' do # ~FC014
    block do
      require 'aws-sdk'
      require 'json'

      rds = Aws::RDS::Client.new(:region => node['castor']['aws']['region'])

      # Delete the cron file first, to be sure we don't have old
      # RDS instances in there.
      File.delete('/var/spool/cron/castor') if File.exist?('/var/spool/cron/castor')

      results = []
      marker = nil
      finished = false
      sleep_duration = 10
      until finished
        begin
          data = rds.describe_db_instances(:marker => marker)
          results.concat(data.db_instances)
          marker = data.marker
          finished = marker.nil?
        rescue Aws::RDS::Errors::Throttling
          sleep(sleep_duration)
          sleep_duration += 5
          retry
        end
      end

      instances = []
      results.each { |d| instances << d['db_instance_identifier'] }

      instances.each do |i|
        node['castor']['logs_to_process'].each do |e|
          cron = Chef::Resource::Cron.new("castor_#{i}_#{e}", run_context)
          cron.command("nice -n 0 castor -i #{i} -t #{e} -r #{node['castor']['aws']['region']} >> /var/log/castor/#{i}.#{e}.log")
          cron.user(node['castor']['user'])
          cron.minute(node['castor']['cron_minute'])
          cron.mailto(node['castor']['mailto'])
          cron.run_action :create
        end
      end
    end
  end
else
  # Make cron jobs based on the defined attributes
  node['castor']['rds_instances'].each do |instance_config|
    instance_config['logs'].each do |log|
      cron "castor_#{instance_config['name']}_#{log}" do
        command "nice -n 0 castor -i #{instance_config['name']} -t #{log} -r #{node['castor']['aws']['region']} >> /var/log/castor/#{instance_config['name']}.#{log}.log"
        user node['castor']['user']
        minute node['castor']['cron_minute']
        mailto node['castor']['mailto']
        action instance_config['action']
      end
    end
  end
end

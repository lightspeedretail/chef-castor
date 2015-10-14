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

ruby_block 'create cron jobs' do
  block do
    require 'json'

    # Delete the cron file first, to be sure we don't have old
    # RDS instances in there.
    File.delete('/var/spool/cron/castor')
    data = JSON.parse(`sudo su castor -c 'aws rds describe-db-instances'`) # ~FC048
    instances = []
    data['DBInstances'].each { |d| instances << d['DBInstanceIdentifier'] }

    instances.each do |i|
      %w(general slowquery).each do |e|
        cmd = Chef::Config[:solo] ? "castor -n #{i} -t #{e} -d /var/lib/castor >> /var/log/castor/#{e}.log" : "castor -n #{i} -t #{e} -a -p #{node['castor']['iam_profile_name']} -d /var/lib/castor >> /var/log/castor/#{e}.log"
        cron = Chef::Resource::Cron.new("castor_#{i}_#{e}", run_context)
        cron.command(cmd)
        cron.user(node['castor']['user'])
        cron.minute('5-55/5')
        cron.run_action :create
      end
    end
  end
end

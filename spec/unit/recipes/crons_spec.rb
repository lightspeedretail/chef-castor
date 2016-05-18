require_relative '../../spec_helper'
require 'aws-sdk'

describe 'castor::crons' do
  context 'default run' do
    before do
      # Mock AWS api calls
      db_instances_response = double
      expect(db_instances_response).to receive(:db_instances).and_return([{ 'db_instance_identifier' => 'db1' }, { 'db_instance_identifier' => 'db2' }])
      expect(db_instances_response).to receive(:marker).and_return(nil)
      allow_any_instance_of(Aws::RDS::Client).to receive(:describe_db_instances).and_return(db_instances_response)

      # Cron resource creation using doubles
      cron_db1_slowquery = cron_db1_general = cron_db2_slowquery = cron_db2_general = double
      expect(Chef::Resource::Cron).to receive(:new).with('castor_db1_slowquery', instance_of(Chef::RunContext)).and_return(cron_db1_slowquery)
      expect(Chef::Resource::Cron).to receive(:new).with('castor_db1_general', anything).and_return(cron_db1_general)
      expect(Chef::Resource::Cron).to receive(:new).with('castor_db2_slowquery', instance_of(Chef::RunContext)).and_return(cron_db2_slowquery)
      expect(Chef::Resource::Cron).to receive(:new).with('castor_db2_general', instance_of(Chef::RunContext)).and_return(cron_db2_general)

      # Verify cron doubles get called correctly
      [cron_db1_slowquery, cron_db1_general, cron_db2_slowquery, cron_db2_general].all? do |c|
        expect(c).to receive(:user).with('castor')
        expect(c).to receive(:minute).with('5-55/5')
        expect(c).to receive(:mailto).with('/dev/null')
        expect(c).to receive(:run_action).with(:create)
      end

      # Verify cron doubles get called with correct command
      expect(cron_db1_general).to receive(:command).with('nice -n 0 castor -r us-east-1 -n db1 -t general -d /var/lib/castor >> /var/log/castor/general.log')
      expect(cron_db1_slowquery).to receive(:command).with('nice -n 0 castor -r us-east-1 -n db1 -t slowquery -d /var/lib/castor >> /var/log/castor/slowquery.log')
      expect(cron_db2_general).to receive(:command).with('nice -n 0 castor -r us-east-1 -n db2 -t general -d /var/lib/castor >> /var/log/castor/general.log')
      expect(cron_db2_slowquery).to receive(:command).with('nice -n 0 castor -r us-east-1 -n db2 -t slowquery -d /var/lib/castor >> /var/log/castor/slowquery.log')
    end

    let(:chef_run) do
      ChefSpec::SoloRunner.converge(described_recipe)
    end

    it 'runs' do
      # Verify the simple chef resources
      expect(chef_run).to run_execute('create AWS credentials').with(command: "su castor -c 'castor -a -p aws-rds-readonly-download-logs-role'")
      expect(chef_run).to create_link('/etc/cron.hourly/logrotate')
      expect(chef_run).to run_ruby_block('create cron jobs')

      # Make sure the ruby block runs
      chef_run.ruby_block('create cron jobs').old_run_action(:run)
    end
  end
end

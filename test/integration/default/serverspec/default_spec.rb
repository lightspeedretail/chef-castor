require 'spec_helper'

describe 'Installation' do
  describe user('castor') do
    it { should exist }
    it { should belong_to_group 'castor' }
    it { should have_home_directory '/opt/castor' }
    it { should have_login_shell '/bin/bash' }
  end

  describe group('castor') do
    it { should exist }
  end

  describe file('/opt/castor') do
    it { should be_directory }
    it { should be_mode 755 }
    it { should be_owned_by 'castor' }
    it { should be_grouped_into 'castor' }
  end

  %w(git ruby).each do |p|
    describe package(p) do
      it { should be_installed }
    end
  end

  %w(deep_merge mixlib-shellout aws-sdk).each do |g|
    describe package(g) do
      it { should be_installed.by('gem') }
    end
  end

  describe command('castor -h') do
    its(:exit_status) { should eq 0 }
  end
end

describe 'AWS credentials' do
  describe file('/opt/castor/.aws') do
    it { should be_directory }
    it { should be_mode 700 }
    it { should be_owned_by 'castor' }
    it { should be_grouped_into 'castor' }
  end

  describe file('/opt/castor/.aws/credentials') do
    it { should be_file }
    it { should be_mode 600 }
    it { should be_owned_by 'castor' }
    it { should be_grouped_into 'castor' }
    it { should contain /[default]/ }
    it { should contain /aws_access_key_id/ }
    it { should contain /aws_secret_access_key/ }
  end

  describe file('/opt/castor/.aws/config') do
    it { should be_file }
    it { should be_mode 600 }
    it { should be_owned_by 'castor' }
    it { should be_grouped_into 'castor' }
    it { should contain /[default]/ }
    it { should contain /region=us-east-1/ }
    it { should contain /output=json/ }
  end
end

describe 'Directories' do
  %w(/var/log/castor /var/lib/castor).each do |dir|
    describe file(dir) do
      it { should be_directory }
      it { should be_mode 755 }
      it { should be_owned_by 'castor' }
      it { should be_grouped_into 'castor' }
    end
  end
end

describe 'Crons' do
  describe 'hourly logrotate' do
    describe file('/etc/cron.hourly/logrotate') do
      it { should be_symlink }
    end
  end

  # Will exit 1 if the crontab's empty
  describe command('crontab -l -u castor') do
    its(:exit_status) { should eq 0 }
  end
end

describe 'Logrotate' do
  describe file('/etc/logrotate.d/castor') do
    it { should be_file }
    it { should be_mode 440 }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    it { should contain /\/var\/log\/castor\/general.log/ }
    it { should contain /\/var\/log\/castor\/error.log/ }
    it { should contain /\/var\/log\/castor\/slowquery.log/ }
    it { should contain /hourly/ }
    it { should contain /create 644 castor castor/ }
    it { should contain /rotate 1/ }
    it { should contain /missingok/ }
    it { should contain /notifempty/ }
    it { should contain /delaycompress/ }
  end
end

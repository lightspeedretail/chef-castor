require_relative '../../spec_helper'

describe 'castor::install' do
  context 'default run' do
    let(:chef_run) do
      ChefSpec::SoloRunner.converge(described_recipe)
    end

    it 'installs the need packages' do
      expect(chef_run).to install_package('git')
      expect(chef_run).to install_package('ruby')
      expect(chef_run).to install_gem_package('aws-sdk')
      expect(chef_run).to install_gem_package('deep_merge')
      expect(chef_run).to install_gem_package('mixlib-shellout')
    end
    it 'creates the needed links' do
      expect(chef_run).to create_link('/usr/bin/castor')
      expect(chef_run).to create_link('/opt/castor/current')
    end
  end
end

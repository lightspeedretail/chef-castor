require_relative '../../spec_helper'

describe 'castor::default' do
  context 'default run' do
    let(:chef_run) do
      ChefSpec::SoloRunner.converge(described_recipe)
    end

    it 'runs' do
      expect(chef_run).to create_directory('/var/log/castor')
      expect(chef_run).to create_directory('/var/lib/castor')
    end
  end
end

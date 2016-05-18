require_relative '../../spec_helper'

describe 'castor::user' do
  context 'default run' do
    let(:chef_run) do
      ChefSpec::SoloRunner.converge(described_recipe)
    end

    it 'creates the needed user' do
      expect(chef_run).to create_user('castor')
    end
    it 'creates the install dir' do
      expect(chef_run).to create_directory('/opt/castor').with(owner: 'castor', group: 'castor')
    end
  end
end

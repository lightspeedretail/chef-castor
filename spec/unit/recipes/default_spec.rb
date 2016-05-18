require_relative '../../spec_helper'

describe 'chef-castor::default' do
  context 'default run' do
    it 'runs' do
      expect(true).to eq(true)
    end
  end
end

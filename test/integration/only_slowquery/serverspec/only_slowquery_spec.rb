require 'spec_helper'

context 'Should not have general logs CRONs' do
  describe command('crontab -l -u castor | grep general') do
    its(:exit_status) { should eq 1 }
  end
end

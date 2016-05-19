module Castor
  module Helper
    def self.create_cron_command(region, type, instance, iam_role)
      solo = "nice -n 0 castor -r #{region} -n #{instance} -t #{type} -d /var/lib/castor >> /var/log/castor/#{type}.log"
      normal = "nice -n 0 castor -r #{region} -n #{instance} -t #{type} -a -p #{iam_role} -d /var/lib/castor >> /var/log/castor/#{type}.log"
      Chef::Config[:solo] ? solo : normal
    end
  end
end

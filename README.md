[![Build Status](https://magnum.travis-ci.com/lightspeedretail/chef-castor.svg?token=AnrKCXhosPuRPGA1NFHX&branch=master)](https://magnum.travis-ci.com/lightspeedretail/chef-castor)

This cookbook installs and configures [castor](https://github.com/lightspeedretail/castor). It also creates the required CRON jobs to run castor every 5 minutes.

## Supported OS

This cookbook is tested on:

+ Centos 7
+ Ubuntu 14.04

NOTE: It should work pretty much on each variation of the Debian and RHEL families.

## Usage

Apply ```castor::default``` to a node's run_list.

## Usage - Test kitchen

Copy the ```.kitchen.yml``` example file into ```.kitchen.local.yml``` and modify it to your needs.

## License and Authors

Author:: Jean-Francois Theroux (<jean-francois.theroux@lightspeedpos.com>)

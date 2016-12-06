#
# Cookbook Name:: castor
# Recipe:: install
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

package 'git'
git "#{node['castor']['base_dir']}/#{node['castor']['version']}" do
  repository 'https://github.com/lightspeedretail/castor.git'
  revision node['castor']['version']
  user node['castor']['user']
end

link "#{node['castor']['base_dir']}/current" do
  to "#{node['castor']['base_dir']}/#{node['castor']['version']}"
end

link '/usr/bin/castor' do
  to "#{node['castor']['base_dir']}/current/bin/castor"
end

package 'ruby'
%w(deep_merge mixlib-cli).each { |pkg| gem_package pkg }

gem_package 'aws-sdk' do
  action :upgrade
  version "#{node['castor']['aws-sdk-version']}"
end
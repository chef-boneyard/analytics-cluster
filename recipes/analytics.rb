#
# Cookbook Name:: chef-server-cluster
# Recipes:: analytics
#
# Copyright (C) 2014, Chef Software, Inc. <legal@getchef.com>
#

directory '/etc/opscode' do
  recursive true
end

directory '/etc/opscode-analytics' do
  recursive true
end

file '/etc/opscode-analytics/opscode-analytics.rb' do
  content "topology 'standalone'\nanalytics_fqdn '#{node['analytics-cluster']['analytics']['fqdn']}'"
  notifies :reconfigure, 'chef_server_ingredient[opscode-analytics]'
end

chef_server_ingredient 'opscode-analytics' do
  notifies :reconfigure, 'chef_server_ingredient[opscode-analytics]'
end

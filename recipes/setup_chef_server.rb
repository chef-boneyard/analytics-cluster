#
# Cookbook Name:: analytics-cluster
# Recipe:: setup_chef_server
#
# Author:: Salim Afiune (<afiune@chef.io>)
#
# Copyright 2015, Chef Software, Inc.
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'analytics-cluster::_aws_settings'

# It's ugly but this must happen in the compile phase so we can switch out
# the Chef Server we are talking to for the remainder of the CCR.

# Provision the Chef Server with an empty runlist so we can extract
# it's primary ipaddress to use as the hostname in the initial
# `/etc/opscode/chef-server.rb` file
machine chef_server_hostname do
  add_machine_options bootstrap_options: { instance_type: node['analytics-cluster']['chef-server']['flavor'] } if node['analytics-cluster']['chef-server']['flavor']
  # Transfer any trusted certs from the current CCR
  Dir.glob("#{Chef::Config[:trusted_certs_dir]}/*.{crt,pem}").each do |cert_path|
    file cert_path, cert_path
  end
  action :converge
end

# Now that we've extracted the Chef Server's ipaddress we can fully
# converge and complete the install.
machine chef_server_hostname do
  recipe "chef-server-12"
  attributes lazy { chef_server_attributes }
  converge true
  action :converge
end

directory Chef::Config[:trusted_certs_dir] do
  action :create
end

machine_file 'chef-server-cert' do
  path lazy { "/var/opt/opscode/nginx/ca/#{chef_server_ip}.crt" }
  machine chef_server_hostname
  local_path lazy { "#{Chef::Config[:trusted_certs_dir]}/#{chef_server_ip}.crt" }
  action :download
end

directory cluster_data_dir do
  recursive true
  action :create
end

# Fetch our client and validator pems from the provisioned Chef Server
machine_file "/tmp/validator.pem" do
  machine chef_server_hostname
  local_path "#{cluster_data_dir}/validator.pem"
  action :download
end

machine_file "/tmp/chefadmin.pem" do
  machine chef_server_hostname
  mode "0644"                                     # This is not working.
  local_path "#{cluster_data_dir}/chefadmin.pem"
  action :download
end

# Workaround: Ensure that the `chefadmin.pem` has the right permissions.
# PR: https://github.com/chef/chef-provisioning/issues/174
file "#{cluster_data_dir}/chefadmin.pem" do
  mode '0644'
end

# generate a knife config file that points at the new Chef Server
file File.join(cluster_data_dir, 'knife.rb') do
  content lazy {
    <<-EOH
node_name         'chefadmin'
chef_server_url   '#{chef_server_url}'
client_key        '#{cluster_data_dir}/chefadmin.pem'
cookbook_path     '#{Chef::Config[:cookbook_path]}'
trusted_certs_dir '#{Chef::Config[:trusted_certs_dir]}'
    EOH
  }
end

execute "upload all cookbooks" do
  command "knife cookbook upload --all --cookbook-path #{Chef::Config[:cookbook_path]}"
  environment(
    'KNIFE_HOME' => cluster_data_dir
  )
end

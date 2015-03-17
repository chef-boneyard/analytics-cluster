#
# Cookbook Name:: chef-server-12
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

directory "/etc/opscode" do
  recursive true
end

chef_server_ingredient 'chef-server-core' do
  notifies :reconfigure, 'chef_server_ingredient[chef-server-core]'
end

template "/etc/opscode/chef-server.rb" do
  owner "root"
  mode "0644"
  notifies :run, "execute[reconfigure chef]", :immediately
end

execute "reconfigure chef" do
  command "chef-server-ctl reconfigure"
  action :nothing
end

# Install Enabled Plugins
node['chef-server-12']['plugin'].each do |feature, enabled|
  install_plugin(feature) if enabled
end

execute "Create #{node['chef-server-12']['analytics']['user']} User" do
  command "chef-server-ctl user-create #{node['chef-server-12']['analytics']['user']} \
            #{node['chef-server-12']['analytics']['name']} \
            #{node['chef-server-12']['analytics']['last_name']} \
            #{node['chef-server-12']['analytics']['email']} \
            #{node['chef-server-12']['analytics']['password']} \
            > #{node['chef-server-12']['analytics']['chefadmin_pem']}"
  not_if "chef-server-ctl user-list | grep -w #{node['chef-server-12']['analytics']['user']}"
  not_if { ::File.exist?(node['chef-server-12']['analytics']['chefadmin_pem']) }
  notifies :run, "ruby_block[upload analytics key]" if node['chef-server-12']['store_keys_databag']
end

execute "Create #{node['chef-server-12']['analytics']['organization']} Organization" do
  command "chef-server-ctl org-create #{node['chef-server-12']['analytics']['organization']} \
            #{node['chef-server-12']['analytics']['org_longname']} -a #{node['chef-server-12']['analytics']['user']} \
            > #{node['chef-server-12']['analytics']['validator_pem']}"
  not_if "chef-server-ctl org-list | grep -w #{node['chef-server-12']['analytics']['organization']}"
end

ruby_block "upload analytics key" do
  block do
    Chef::Config.new
    Chef::Config.chef_server_url  = (node['chef-server-12']['analytics']['ssl'] ? "https" : "http") + "://#{node['chef-server-12']['api_fqdn']}/organizations/#{node['chef-server-12']['analytics']['organization']}"
    Chef::Config.client_key       = node['chef-server-12']['analytics']['chefadmin_pem']
    Chef::Config.node_name        = node['chef-server-12']['analytics']['user']

    begin
      bag = Chef::DataBag.new
      bag.name(node['chef-server-12']['analytics']['db'])
      bag.create
    rescue Exception => e
      puts "DataBag #{node['chef-server-12']['analytics']['db']} already exists."
    end

    begin
      # Assuming there is already a `encrypted_data_bag_secret` configured on `solo.rb` file
      data = Chef::EncryptedDataBagItem.encrypt_data_bag_item(
        { "content" => File.read(node['chef-server-12']['analytics']['chefadmin_pem']) },
        Chef::Config.encrypted_data_bag_secret)
      analytics_item = Chef::DataBagItem.from_hash({ "id" => node['chef-server-12']['analytics']['item'] }.merge(data))
      analytics_item.data_bag(node['chef-server-12']['analytics']['db'])
      analytics_item.save
    rescue Exception => e
      puts "Something went wrong with the data bag creation.\nERROR: #{e.message}"
    end
  end
  action :nothing
end

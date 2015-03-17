#
# Cookbook Name:: chef-server-12
# Attributes:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

# Chef Server Version
default['chef-server-12']['version']       = 'latest'

# Plugins / Feautures
#
# To Install plugins into the Chef-Server simply enable them setting the value `true`
# If there is more plugins you just need to add them as follow:
# => default['chef-server-12']['plugin']['PLUGIN_NAME'] = true
default['chef-server-12']['plugin']['opscode-manage']            = true
default['chef-server-12']['plugin']['opscode-reporting']         = true
default['chef-server-12']['plugin']['opscode-replication']       = false
default['chef-server-12']['plugin']['opscode-push-jobs-server']  = true

# Chef Server Parameters
default['chef-server-12']['api_fqdn'] = node['ipaddress']
default['chef-server-12']['topology'] = "standalone"

# Analytics Server Parameters
# default['chef-server-12']['analytics'] = nil


# This process includes:
# => Create an organization
# => Create the chefadmin user
# => Save keys into the server and/or a databag. (['chef-server-12']['store_keys_databag'])
#
# TODO: Figure out how to make chefadmin user an admin (tricky)
default['chef-server-12']['store_keys_databag']        = true
default['chef-server-12']['analytics']['ssl']           = true
default['chef-server-12']['analytics']['organization']  = "chefadmin"
default['chef-server-12']['analytics']['org_longname']  = "\"Chef Starter Org\""
default['chef-server-12']['analytics']['user']          = "chefadmin"
default['chef-server-12']['analytics']['name']          = "Chef"
default['chef-server-12']['analytics']['last_name']     = "admin"
default['chef-server-12']['analytics']['email']         = "chefadmin@getchef.com"
default['chef-server-12']['analytics']['password']      = "chefadmin"
default['chef-server-12']['analytics']['validator_pem'] = "/tmp/validator.pem"
default['chef-server-12']['analytics']['chefadmin_pem'] = "/tmp/chefadmin.pem"
default['chef-server-12']['analytics']['db']            = "chefadmin"
default['chef-server-12']['analytics']['item']          = "chefadmin_pem"

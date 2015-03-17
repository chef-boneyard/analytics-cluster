require 'spec_helper'

describe "chef-server-12::default WITHOUT analytics setup" do
  let(:chef_run) do
    runner = ChefSpec::Runner.new(
      platform: 'redhat',
      version: '6.3',
      log_level: :error
    )
    runner.node.set['chef-server-12']['analytics_setup'] = false
    Chef::Config.force_logger true
    runner.converge('recipe[chef-server-12::default]')
  end

  it 'install chef-server package' do
    expect(chef_run).to install_package('chef-server')
  end

  it 'creates chef-server.rb file' do
    expect(chef_run).to create_template('/etc/opscode/chef-server.rb')
  end

  it 'creates /etc/opscode directory' do
    expect(chef_run).to create_directory('/etc/opscode')
  end
end

describe "chef-server-12::default WITH analytics setup" do
  before do
    stub_command("chef-server-ctl org-list | grep -w chefadmin ").and_return(false)
    stub_command("chef-server-ctl user-list | grep -w chefadmin").and_return(false)
  end

  let(:chef_run) do
    runner = ChefSpec::Runner.new(
      platform: 'redhat',
      version: '6.3',
      log_level: :error
    )
    runner.node.set['chef-server-12']['analytics_setup'] = true
    Chef::Config.force_logger true
    runner.converge('recipe[chef-server-12::default]')
  end

  it 'create chefadmin organization' do
    expect(chef_run).to run_execute("Create #{chef_run.node['chef-server-12']['analytics']['organization']} Organization")
  end

  it 'create chefadmin user' do
    expect(chef_run).to run_execute("Create #{chef_run.node['chef-server-12']['analytics']['user']} User")
  end

  it 'install chef-server package' do
    expect(chef_run).to install_package('chef-server')
  end

  it 'creates chef-server.rb file' do
    expect(chef_run).to create_template('/etc/opscode/chef-server.rb')
  end

  it 'creates /etc/opscode directory' do
    expect(chef_run).to create_directory('/etc/opscode')
  end
end

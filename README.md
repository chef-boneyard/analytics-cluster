analytics-cluster cookbook
=========================

This cookbook setup a full Chef Server and Analytics Server environment.

That includes:

*  1 -  Chef Server 12
*  1 -  Analytics Server [Optional]

Additionally you could Activate an Analytics Server. [Optional]

REQUIREMENTS
------------

### AWS Config
You MUST configure your `~/.aws/config` file like this:
```
$ vi ~/.aws/config
[default]
region = us-west-2
aws_access_key_id = YOUR_ACCESS_KEY_ID
aws_secret_access_key = YOUR_SECRET_KEY
```
You also need to create a `security_group` with the following ports open

| Port           | Protocol    | Description                                 |
| -------------- |------------ | ------------------------------------------- |
| 10000 - 10003  | TCP | Push Jobs
| 443            | TCP | HTTP Secure
| 22             | TCP | SSH
| 80             | TCP | HTTP
| 5672           | TCP | Analytics MQ
| 10012 - 10013  | TCP | Analytics Messages/Notifier

ATTRIBUTES
------------

### AWS

| Attribute                                           | Description                                 |
| --------------------------------------------------- | ------------------------------------------- |
| `['analytics-cluster']['aws']['key_name']`           | Key Pair to configure.                      |
| `['analytics-cluster']['aws']['ssh_username']`       | SSH username to use to connect to machines. |
| `['analytics-cluster']['aws']['image_id']`           | AWS AMI.                                    |
| `['analytics-cluster']['aws']['flavor']`             | Size/flavor of your machine.                |
| `['analytics-cluster']['aws']['security_group_ids']` | Security Group on AWS.                      |

### Chef Server Settings

| Attribute                                              | Description                       |
| ------------------------------------------------------ | --------------------------------- |
| `['analytics-cluster']['chef-server']['hostname']`      | Hostname of your Chef Server.     |
| `['analytics-cluster']['chef-server']['organization']`  | The organization name we will create for the Analytics Environment. |
| `['analytics-cluster']['chef-server']['flavor']`        | AWS Flavor of the Chef Server.   |

### Analytics Settings (Not required)

| Attribute                                              | Description                       |
| ------------------------------------------------------ | --------------------------------- |
| `['analytics-cluster']['analytics']['hostname']`      | Hostname of your Analytics Server.     |
| `['analytics-cluster']['analytics']['fqdn']`          | The Analytics FQDN to use for the `/etc/opscode-analytics/opscode-analytics.rb`. |
| `['analytics-cluster']['analytics']['flavor']`        | AWS Flavor of the Analytics Server.   |


Supported Platforms
-------------------

Chef Server packages are available for the following platforms:

* EL (CentOS, RHEL) 6 64-bit
* Ubuntu 12.04, 14.04 64-bit

So please don't use another AMI type.


PROVISION
=========

#### Install your deps

```
$ bundle install
```

#### Assemble your cookbooks

```
$ bundle exec berks vendor cookbooks
```

#### Create a basic environment

```
$ cat environments/test.json
{
  "name": "test",
  "description": "",
  "json_class": "Chef::Environment",
  "chef_type": "environment",
  "override_attributes": {
    "analytics-cluster": {
      "id": "my_uniq_id",
      "aws": {
        "key_name": "analytics-test",
        "ssh_username": "ubuntu",
        "image_id": "ami-3d50120d",
        "subnet_id": "subnet-19ac017c",
        "security_group_ids": "sg-cbacf8ae",
        "use_private_ip_for_ssh": true
      }
      "chef-server": {
        "flavor": "c3.xlarge",
        "organization": "my_organization"
      },
      "analytics": {
        "flavor": "c3.xlarge"
      }
    }
  }
}
```

#### Run chef-client on the local system (provisioning node)

```
$ bundle exec chef-client -z -o analytics-cluster::setup -E test
```

Activate Analytics Server
========
In order to activate Analytics you MUST provision the entire `analytics-cluster::setup` first. After you are done completely you can execute a second `chef-zero` like:
```
$ bundle exec chef-client -z -o analytics-cluster::setup_analytics -E test
```

That will provision and activate Analytics on your entire cluster.

UPGRADE
========
In order to upgrade the existing infrastructure and cookbook dependencies you need to run the following steps:

#### Update your cookbook dependencies
```
$ bundle exec berks update
```
#### Assemble your cookbooks again

```
$ bundle exec berks vendor cookbooks
```

LICENSE AND AUTHORS
===================
- Author: Scott Ford (<fords@chef.io>)

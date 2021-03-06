# == Class: logstash
#             logstash::config
#             logstash::elasticsearch
#             logstash::kibana
#             logstash::lumberjack
#             logstash::package
#             logstash::params
#             logstash::redis
#             logstash::service
#
# This module will install and manage logstash with lumberjack, redis, elasticsearch
#
# === Parameters
#
# [*role*]
#   role of the logstash daemon
#     indexer: will install logstash server, redis server, elasticsearch server
#     shipper: will install logstash agent
#     lumberjack: will install lumberjack which will serve as logstash agent
#
# [*indexer*]
#   fqdn or ip of the logstash indexer, required for agnets to report to
#
# [*lj_logs*]
#   a list of log files path for the lumberjack to monitor
#   ex: ['/var/log/syslog', '/var/log/hadoop-hdfs/hadoop-namenode*'] (or) [ '/var/log/*.log' ]
#
# [*lj_fields*]
#   a custom field name, if provided will be used as a tag from that host
#
# === Variables
#
# Nothing.
#
# === Requires
#
# Java
#
# === Sample Usage
#
# See README.md

class logstash(
  $role,
  $indexer = undef
  ) inherits logstash::params {

  if ! ($role in [ 'indexer', 'shipper' ]) {
    fail("\"${role}\" is not a valid ensure parameter value")
  }

  if $role == 'indexer' {
    notice('installing role logstash indexer (server)')
    #requires java module
    class { 'java': } ->
    class { 'logstash::redis': } ->
    class { 'logstash::elasticsearch': } ->
    class { 'logstash::kibana': } ->
    class { 'logstash::package': } ->
    class { 'logstash::config':
      role => $role,
      indexer => $indexer
    } ~>
    class { 'logstash::service': }
  }
  elsif $role == 'shipper' {
    notice('installing role logstash shipper (agent)')
    #shipper requires a indexer(hostname|ip) to send events to
    if $indexer == undef {
      fail("\"${role}\" requires hostname|ip of indexer")
    }
    #requires java module
    class { 'java': } ->
    class { 'logstash::package': } ->
    class { 'logstash::config':
      role => $role,
      indexer => $indexer
    } ~>
    class { 'logstash::service': }
  }
}
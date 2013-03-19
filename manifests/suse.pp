class apache::suse inherits apache::base {

  include apache::params

  # BEGIN inheritance from apache::base
  Exec['apache-graceful'] {
    command => '/usr/sbin/apache2ctl graceful',
    onlyif  => '/usr/sbin/apache2ctl configtest',
    
  }

  Package['apache'] {
    require => [
      File['/usr/local/sbin/a2ensite'],
      File['/usr/local/sbin/a2dissite'],
      ],
  }

  # the following variables are used in template logrotate-httpd.erb
  $logrotate_paths = "${apache::params::root}/*/logs/*.log ${apache::params::log}/*log"
  $httpd_pid_file = '/var/run/httpd2.pid'
  $httpd_reload_cmd = '/sbin/service apache2 reload > /dev/null 2> /dev/null || true'
  $awstats_condition = '-x /etc/cron.hourly/awstats'
  $awstats_command = '/etc/cron.hourly/awstats || true'
  File['logrotate configuration'] {
    path    => '/etc/logrotate.d/apache2',
    content => template('apache/logrotate-httpd.erb'),
  }

  File['default status module configuration'] {
    path   => "${apache::params::conf}/conf.d/status.conf",
    source => "puppet:///modules/${module_name}/etc/httpd/conf/status.conf",
  }

  File['default virtualhost'] {
    seltype => 'httpd_config_t',
  }
  # END inheritance from apache::base

  # FIXME: suse does not have disabled vhosts
  file {[
    '/usr/local/sbin/a2ensite',
    '/usr/local/sbin/a2dissite',
  ]:
    ensure => present,
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
    source => "puppet:///modules/${module_name}/usr/local/sbin/a2X.suse",
  }

  $httpd_mpm = $apache_mpm_type ? {
    ''         => '', # default MPM
    'pre-fork' => 'prefork',
    'prefork'  => 'prefork',
    default    => "",
  }

  augeas { "select httpd mpm ${httpd_mpm}":
    changes => "set /files/etc/sysconfig/apache2/APACHE_MPM '${httpd_mpm}'",
    require => Package['apache'],
    notify  => Service['apache'],
  }

  file { [
      "${apache::params::conf}/sites-available",
      "${apache::params::conf}/sites-enabled",
      "${apache::params::conf}/mods-enabled"
    ]:
    ensure  => directory,
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    seltype => 'httpd_config_t',
    require => Package['apache'],
  }
  #
  #file { "${apache::params::conf}/conf/httpd.conf":
  #  ensure  => present,
  #  content => template('apache/httpd.conf.erb'),
  #  seltype => 'httpd_config_t',
  #  notify  => Service['apache'],
  #  require => Package['apache'],
  #}

  # the following command was used to generate the content of the directory:
  # egrep '(^|#)LoadModule' /etc/httpd/conf/httpd.conf | sed -r 's|#?(.+ (.+)_module .+)|echo "\1" > mods-available/redhat5/\2.load|' | sh
  # ssl.load was then changed to a template (see apache-ssl-redhat.pp)
  #file { "${apache::params::conf}/mods-available":
  #  ensure  => directory,
  #  source  => $::lsbmajdistrelease ? {
  #    5 => "puppet:///modules/${module_name}/etc/httpd/mods-available/redhat5/",
  #    6 => "puppet:///modules/${module_name}/etc/httpd/mods-available/redhat6/",
  #  },
  #  recurse => true,
  #  mode    => '0755',
  #  owner   => 'root',
  #  group   => 'root',
  #  seltype => 'httpd_config_t',
  #  require => Package['apache'],
  #}

  # this module is statically compiled on debian and must be enabled here
  apache::module {'log_config':
    ensure => present,
    notify => Exec['apache-graceful'],
  }

 
}


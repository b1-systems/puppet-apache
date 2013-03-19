class apache::params {

  $pkg = $::operatingsystem ? {
    /RedHat|CentOS/ => 'httpd',
    /Debian|Ubuntu/ => 'apache2',
    /SLES|OpenSuSE/ => 'apache2',
  }

  $root = $apache_root ? {
    "" => $::operatingsystem ? {
      /RedHat|CentOS/ => '/var/www/vhosts',
      /Debian|Ubuntu/ => '/var/www',
      /SLES|OpenSuSE/ => '/srv/www/htdocs',
    },
    default => $apache_root
  }

  $user = $::operatingsystem ? {
    /RedHat|CentOS/ => 'apache',
    /Debian|Ubuntu/ => 'www-data',
    /SLES|OpenSuSE/ => 'wwwrun',
  }

  $group = $::operatingsystem ? {
    /RedHat|CentOS/ => 'apache',
    /Debian|Ubuntu/ => 'www-data',
    /SLES|OpenSuSE/ => 'www',
  }

  $conf = $::operatingsystem ? {
    /RedHat|CentOS/ => '/etc/httpd',
    /Debian|Ubuntu/ => '/etc/apache2',
    /SLES|OpenSuSE/ => '/etc/apache2',
  }

  $log = $::operatingsystem ? {
    /RedHat|CentOS/ => '/var/log/httpd',
    /Debian|Ubuntu/ => '/var/log/apache2',
    /SLES|OpenSuSE/ => '/var/log/apache2',
  }

  $access_log = $::operatingsystem ? {
    /RedHat|CentOS/ => "${log}/access_log",
    /Debian|Ubuntu/ => "${log}/access.log",
    /SLES|OpenSuSE/ => "${log}/access.log",
  }

  $a2ensite = $::operatingsystem ? {
    /RedHat|CentOS/ => '/usr/local/sbin/a2ensite',
    /Debian|Ubuntu/ => '/usr/sbin/a2ensite',
    /SLES|OpenSuSE/ => '/bin/true',
  }

  $htpasswd = $::operatingsystem ? {
    /SLES|OpenSuSE/ => 'htpasswd2',
    default         => 'htpasswd'
  }

  $error_log = $::operatingsystem ? {
    /RedHat|CentOS/ => "${log}/error_log",
    /Debian|Ubuntu/ => "${log}/error.log",
    /SLES|OpenSuSE/ => '/bin/true',
  }

}

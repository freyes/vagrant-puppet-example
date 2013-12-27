Exec {
  path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
}

define add_user ( $name, $uid, $password, $shell, $groups, $sshkeytype, $sshkey) {

 $homedir = $kernel ? {
  'SunOS' => '/export/home',
  default => '/home'
 }

 $username = $title
 user { $username:
  comment => "$name",
  home => "$homedir/$username",
  shell => "$shell",
  uid => $uid,
  gid => $uid,
  managehome => 'true',
  password => "$password",
  groups => $groups
 }

 group { $username:
  gid => "$uid"
 }

 ssh_authorized_key{ $username:
  user => "$username",
  ensure => present,
  type => "$sshkeytype",
  key => "$sshkey",
  name => "$username"
 }
}

node 'basenode' {
  class { 'apt':
    always_apt_update => true,
    disable_keys => undef,
    purge_sources_list => false,
    purge_sources_list_d => false,
    update_timeout       => undef
  }
  include apt::backports

  include '::ntp'
  include cron
  cron::job{
    'aptupdate':
      minute      => '40',
      hour        => '*',
      date        => '*',
      month       => '*',
      weekday     => '*',
      user        => 'root',
      command     => 'apt-get update',
      environment => [ 'MAILTO=root', 'PATH="/usr/bin:/bin:/usr/sbin:/sbin"' ];
  }
}

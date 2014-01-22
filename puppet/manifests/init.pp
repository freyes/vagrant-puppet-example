import "classes/common.pp"
import "site.pp"

node "db01" inherits "basenode" {

  service { "networking":
    ensure => "running",
    enable => "true",
  }

  network_config { 'eth0':
    ensure => 'present',
    family => 'inet',
    method => 'dhcp',
    onboot => 'true',
    hotplug => 'true'
  }

  network_config { 'eth0:1':
    ensure => 'present',
    family => 'inet',
    method => 'static',
    ipaddress => $db_ip,
    netmask => '255.255.255.0',
    onboot => 'true',
    notify => Exec["restart networking"],
  }

  exec { "restart networking":
    command => "bash -c 'ifdown eth0:1 ; ifup eth0:1'",
    logoutput => on_failure,
    refreshonly => true
  }

  include "force_apt_update"

  class { 'postgresql::server':
    ip_mask_deny_postgres_user => '0.0.0.0/32',
    ip_mask_allow_all_users    => '0.0.0.0/0',
    listen_addresses           => '*',
  }

  postgresql::server::db { 'mydatabasename':
    user     => 'mydatabaseuser',
    password => postgresql_password('mydatabaseuser', 'mypassword'),
  }

  class { '::mysql::server':
    root_password    => 'strongpassword',
    override_options => { 'mysqld' => { 'max_connections' => '1024' } }
  }
  mysql::db { "db_name":
    user     => "db_username",
    password => "db_password",
    host     => '%',
    grant    => ['USAGE', 'ALL'],
  }

  file { "my_bind_all":
    path => "/etc/mysql/conf.d/my_bind_all.cnf",
    owner => "root",
    group => "root",
    mode => "0644",
    require => Package["mysql-server"],
    notify => Service["mysql"],
    content => "[mysqld]\nbind_address = 0.0.0.0",
  }
}

node "web01" inherits "basenode" {
  service { "networking":
    ensure => "running",
    enable => "true",
  }

  network_config { 'eth0':
    ensure => 'present',
    family => 'inet',
    method => 'dhcp',
    onboot => 'true',
    hotplug => 'true'
  }

  network_config { 'eth0:1':
    ensure => 'present',
    family => 'inet',
    method => 'static',
    ipaddress => $web_ip,
    netmask => '255.255.255.0',
    onboot => 'true',
    notify => Exec["restart networking"],
  }

  exec { "restart networking":
    command => "bash -c 'ifdown eth0:1 ; ifup eth0:1'",
    logoutput => on_failure,
    refreshonly => true
  }

  include "force_apt_update"

  package { ["git", "python-psycopg2", "libpq-dev", "libmysqlclient-dev"]:
    ensure => latest
  }

  add_user { hello:
    name => "hello",
    uid => "777",
    password => '',
    shell => "/bin/bash",
    groups => ['hello', 'www-data'],
    sshkeytype => "ssh-rsa",
    sshkey => "asdf"
  }

  file { "/home/hello/src":
    ensure => "directory",
    owner => "hello",
    group => "hello",
    require => [ User["hello"] ]
  }

  file { "/home/hello/venv":
    ensure => "directory",
    owner => "hello",
    group => "hello",
    require => [ User["hello"] ]
  }

  vcsrepo { "/home/hello/src/hello":
    ensure => latest,
    user => "hello",
    group => "hello",
    owner => "hello",
    provider => "git",
    source => "https://github.com/freyes/flask-hello-world.git",
    force => true,
    notify => Exec['migrate db'],
    require =>[ Package["git"], Package["libpq-dev"], User["hello"],
                File["/home/hello/src"]]
  }

  class { "webapp::python":
    owner => "hello",
    group => "hello",
    src_root => "/home/hello/src",
    venv_root => "/home/hello/venv",
  }

  #$db_uri = inline_template("postgresql+psycopg2://mydatabaseuser:mypassword@<%= @db_ip %>/mydatabasename")
  $db_uri = inline_template("mysql+mysqldb://db_username:db_password@<%= @db_ip %>/db_name")

  webapp::python::instance { "hello":
    domain => "mytest",
    wsgi_module => "hello.application:app",
    requirements => true,
    environment => {"DB_URI" => $db_uri},
    notify => Exec['migrate db'],
  }

  exec { 'migrate db':
    command     => 'bash -c "if [ -e /home/hello/venv/hello/bin/activate ]; then cd /home/hello/src/hello && source /home/hello/venv/hello/bin/activate && PYTHONPATH=. alembic upgrade head; fi"',
    environment => inline_template('DB_URI=<%= @db_uri %>'),
    logoutput   => true, #on_failure,
    refreshonly => true
  }
}

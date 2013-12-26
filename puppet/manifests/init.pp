import "site.pp"

node "db01" inherits "basenode" {
  class { 'postgresql::server': }

  postgresql::server::db { 'mydatabasename':
    user     => 'mydatabaseuser',
    password => postgresql_password('mydatabaseuser', 'mypassword'),
  }
}

node "web01" inherits "basenode" {
  package { "git":
    ensure => latest
  }

  add_user { hello:
    name => "hello",
    uid => "777",
    password => '',
    shell => "/bin/bash",
    groups => ['hello'],
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
    require =>[ Package["git"], User["hello"],
                File["/home/hello/src"]]
  }

  file { "/home/hello/venv/hello/requirements.checksum":
    ensure => present,
    owner => "hello",
    group => "hello",
    require => [ User["hello"] ]
  }

  class { "webapp::python":
    owner => "hello",
    group => "hello",
    src_root => "/home/hello/src",
    venv_root => "/home/hello/venv",
  }

  webapp::python::instance { "hello":
    domain => "test",
    wsgi_module => "application",
    requirements => true,
    environment => {}
  }
}

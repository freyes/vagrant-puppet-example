import "site.pp"

node "db01" {
  class { 'postgresql::server': }

  postgresql::server::db { 'mydatabasename':
    user     => 'mydatabaseuser',
    password => postgresql_password('mydatabaseuser', 'mypassword'),
  }
}

node "web01" {
  class { 'python':
    version    => 'system',
    dev        => true,
    virtualenv => true,
    gunicorn   => true,
  }
  # python::virtualenv { '/home/hello/venv':
  #   ensure       => present,
  #   version      => 'system',
  #   requirements => '/home/hello/flask-hello-world.git/requirements.txt',
  #   proxy        => 'http://proxy.domain.com:3128',
  #   systempkgs   => true,
  #   distribute   => false,
  #   owner        => 'hello',
  #   group        => 'hello',
  #   cwd          => '/home/hello',
  #   timeout      => 0,
  # }
}

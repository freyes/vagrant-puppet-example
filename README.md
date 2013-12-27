# Vagrant and Puppet

## Overview

This project is an example of how to deploy a [WSGI](http://en.wikipedia.org/wiki/Web_Server_Gateway_Interface)
based application with [Puppet](http://puppetlabs.com/) using [Vagrant](http://vagrantup.com)
to create the virtual machines.

## Details

The containers are configured to use Ubuntu Precise. This setup uses the following VMs:

* web, this is the Web Front End, it runs the [gunicorn](http://gunicorn.org/) inside a
[virtualenv](http://www.virtualenv.org)
* db, database server running [Postgresql 9.1](http://www.postgresql.org)

## Dependencies

These dependencies are required to run this example (create the VMs), the rest
of dependencies are automatically installed inside the VMs

* [vagrant](http://vagrantup.com)
* [librarian-puppet](http://librarian-puppet.com/)

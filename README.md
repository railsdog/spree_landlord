Landlord - Multi-tenant Spree extension
==============

[![Build Status](https://travis-ci.org/railsdog/spree_landlord.png)](https://travis-ci.org/railsdog/spree_landlord)

## What is Landlord?

Landlord is a Spree extension that enables hosting multiple store fronts from a single Rails app.

## Getting Started

These instructions assume that you already have Spree installed in your Rails app.

Add spree_landlord to your gemfile.

```
gem 'spree_landlord', github: 'railsdog/spree_landlord'
```

Run bundler.

```
$ bundle install
```

Install migrations.

```
$ bundle exec rake spree_landlord:install:migrations
```

Run migrations. This will create the first tenant, also known as the master tenant. It also moves your data into the tenant as well.

```
$ bundle exec rake db:migrate
```

Create a tenant. This will ask you for a `shortname`, and a `domain`. The `shortname` is used when accessing the tenant by subdomain such as `tenant-name.example.com`. The `domain` is used to access the tenant with just a domain name, such as `tenan.dev`. You'll also be asked if you want to populate the tenant with some sample products.

```
$ bundle exec rake spree_landlord:tenant:create
```

Note that it is CRITICAL that you use the latest version of deface in your application's Gemfile.  The decorators used in this extension won't work w/ the version of deface that ships in recent versions of spree
## Contributors

* [John Dilts](https://github.com/jbrien)
* [M. Scott Ford](https://github.com/mscottford)
* [Jeff Squires](https://github.com/jsqu99)
* [Hector V.](https://github.com/hectorvs)
* [Javid Jamae](https://github.com/javidjamae)



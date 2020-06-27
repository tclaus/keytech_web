# README

This is keytech Plm-Web.
Plm Web a web-UI for accessing the keytech api. keytech is one of the major german plm/dms software developer.

This repository is not maintained or supported by keytech in any way.

Production Site can be visited under: [plmweb.de](https://plmweb.de).

To learn about Ruby and rails visit: [ruby-lang.org](https://www.ruby-lang.org/de/).

Full source code on GitHub: [keytech_web](https://github.com/tclaus/keytech_web)

What can you do?
------------------
With keytech PLM-Web you can create, edit and search nearly all aspects of keytech data
provided by the keytech web-api. ideal for devs, Dev-Ops or Admins.
Just install locally or on a server and have access to all keytech data without
any installation of a client.
Any user can create a local account and login to a keytech database just easy as
login to any other web-service.

Local installation
------------------
If you still have not develop in Ruby on Rails - install Ruby and Rails first:
On macOS the best way is to use  [RVM](https://rvm.io):
Install RVM with default Ruby and Rails in one Command:

$: curl -sSL https://get.rvm.io | bash -s stable --rails

You may experience errors on install ('binary not found'). In this case open a new
Terminal so make the newly installed RVM active and install ruby with:
$: rvm install

Install Postgres Database
Use Postgres App from Postgres Server: [postgresapp.com](https://postgresapp.com)
Init Database and start Server

Install redis caching Service
You need Redis to send deferred emails
Use Homebrew to install:
$: brew install redis

Start the service:
$: brew services start redis

Start the JobQueue:
$: QUEUE=* rake resque:work

Export the redis local environment:
$: export REDISTOGO_URL=localhost:6379

### The .env file
All environments may be inserted to the .env file.

For the environment you can create a .env file in the main directory and copy the
line: 'export REDISTOGO_URL=localhost:6379' into it.

For more information check the .env_demo file and rename it to .env

Database Setup
--------------
You need to create local test and development databases:

$:rails db:setup

Install GEM Files
-----------------
$: bundle install

You may have problems with the 'pg' gem. in this case try manually this:
$: gem install 'pg' -- --with_pg_config=/Applications/Postgres.app/Contents/Versions/latest/bin/pg_config


Install jobs / scheduler
------------------------
On OSX install redis-server
Its needed for Jobs as well as for caching

$: brew install redis

You might want to start redis before running local

Start development environment
-----------------------------
You now have Ruby, Rails Gemfiles, and redis server.
Databases are created.
Just seed development Database with initial data:

$: rails db:seed

To get a full list of tasks available in Rails and what db tasks you have simply ask rails:

$: rails --tasks

Start the server
------------------
1. start the redis-server
2. start a batch job queue
3. start rails server

$: redis-server
$: QUEUE=* rake environment resque:work

Start locally
--------------
$: rails s

    => Booting Puma

    => Rails 5.2.4 application starting in development

    => Run `rails server -h` for more startup options

    Puma starting in single mode...

    * Version 3.12.2 (ruby 2.5.1-p57), codename: Love Song

    * Min threads: 5, max threads: 5

    * Environment: development

    * Listening on tcp://0.0.0.0:3000

    Use Ctrl-C to stop

Open your browser at: http://localhost:3000

Write tests and running
$: rails test

Start / Update in Productive-Configuration
------------------------------------------
Upload to heroku

1. $: Heroku login
2. Setup Database on heroku

    $: heroku run rake db:schema:load -a <app name>
    $: heroku run rake db:seed -a <app name>

Migrate Database:
On every update don't forget a

Development:
  $: heroku run rake db:migrate -a <app name>

to set database to latest state.

In Procfile there is a line 'release: bundle exec rake db:migrate' that should do the DB:Migration task automatically on deployment.

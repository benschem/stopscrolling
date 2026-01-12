# frozen_string_literal: true

# This configuration file will be evaluated by Puma. The top-level methods that
# are invoked here are part of Puma's configuration DSL. For more information
# about methods provided by the DSL, see https://puma.io/puma/Puma/DSL.html.
#
# Puma starts a configurable number of processes (workers) and each process
# serves each request in a thread from an internal thread pool.
#
# You can control the number of workers using ENV["WEB_CONCURRENCY"]. You
# should only set this value when you want to run 2 or more workers. The
# default is already 1.
#
# The ideal number of threads per worker depends both on how much time the
# application spends waiting for IO operations and on how much you wish to
# prioritize throughput over latency.
#
# As a rule of thumb, increasing the number of threads will increase how much
# traffic a given process can handle (throughput), but due to CRuby's
# Global VM Lock (GVL) it has diminishing returns and will degrade the
# response time (latency) of the application.
#
# The default is set to 3 threads as it's deemed a decent compromise between
# throughput and latency for the average Rails application.
#
# Any libraries that use a connection pool or another resource pool should
# be configured to provide at least as many connections as the number of
# threads. This includes Active Record's `pool` parameter in `database.yml`.
threads_count = ENV.fetch('RAILS_MAX_THREADS', 2)
threads threads_count, threads_count

# Worker count - start with 1 for SQLite, can increase if needed
workers 1
worker_timeout 3600 if ENV.fetch('RAILS_ENV', 'development') == 'development'

on_worker_boot do
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end

# Specifies the `port` that Puma will listen on to receive requests; default is 3000.
# port ENV.fetch('PORT', 3000)

# Use Unix socket instead of port
# TO DO: Don't hardcode this
if ENV.fetch('RAILS_ENV', 'production').downcase == 'production'
  bind 'unix:///var/www/stopscrolling-production/shared/tmp/sockets/puma.sock'
elsif ENV.fetch('RAILS_ENV', 'staging').downcase == 'staging'
  bind 'unix:///var/www/stopscrolling-staging/shared/tmp/sockets/puma.sock'
else
  port ENV.fetch('PORT', 3000)
end

# Allow puma to be restarted by `bin/rails restart` command.
plugin :tmp_restart

# Run the Solid Queue supervisor inside of Puma for single-server deployments
plugin :solid_queue

if ENV.fetch('RAILS_ENV', 'production').downcase == 'production'
  # Specify the PID file. Defaults to tmp/pids/server.pid in development.
  # In other environments, only set the PID file if requested.
  # pidfile ENV['PIDFILE'] if ENV['PIDFILE']
  # TO DO: Don't hardcode these
  pidfile '/var/www/stopscrolling-production/shared/tmp/pids/puma.pid'
  state_path '/var/www/stopscrolling-production/shared/tmp/pids/puma.state'

  # Logging
  # TO DO: Don't hardcode these
  stdout_redirect '/var/www/stopscrolling-production/shared/log/puma.stdout.log',
                  '/var/www/stopscrolling-production/shared/log/puma.stderr.log', true
end

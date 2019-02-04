# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron
set :chronic_options, hours24: true

# clone the environment
ENV.each { |k, v| env(k, v) }

set :output, '/host_tmp/cron_log.log'

# Generate the GEXF file
every :day, at: '1:00' do
  rake 'nda:commoners_objects_graph'
end

# Trigger the data analysis
every :day, at: '2:00' do
  rake 'commonshare:analyse_data'
end

# Import user data from analysis results
every :day, at: '3:00' do
  rake 'commonshare:import_commoner_data'
end

# Update the dashboard
every :monday, at: '4:00' do
  rake 'dashboard:populate_yml'
  rake 'dashboard:update_social_graph'
end

# Monthly basic income distribution
every 1.month, at: 'January 5th 1:00am' do
  rake 'wallets:distribute_basic_income'
end

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

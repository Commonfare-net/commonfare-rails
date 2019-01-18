# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron
set :chronic_options, hours24: true

# clone the environment
ENV.each { |k, v| env(k, v) }

set :output, '/host_tmp/cron_log.log'

# Generate the GEXF file
every :monday, at: '1:00' do
  rake 'nda:commoners_objects_graph'
end

# Trigger the data analysis
# every :monday, at: '2:00' do
#   rake 'commonshare:analyse_data'
# end

# Import data from analysis results
# every :monday, at: '3:00' do
#   rake 'commonshare:import_data'
# end

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

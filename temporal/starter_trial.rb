require 'bundler/setup'
require 'securerandom'
require 'temporalio/client'
require_relative './activities/trial_activities'
require_relative './shared'
require_relative './workflows/trial_workflow'

client = Temporalio::Client.connect('localhost:7233', 'default')

user_email = ARGV[0] || 'dev@example.com'
interval = (ARGV[1] || 10).to_i

Demo::TrialStore.set_upgraded(user_email, false)

details = Demo::TrialDetails.new(user_email, interval)
handle = client.start_workflow(
  Demo::TrialWorkflow,
  details,
  id: "trial-#{SecureRandom.uuid}",
  task_queue: Demo::TASK_QUEUE_NAME
)

puts "Started trial workflow #{handle.id} for #{user_email} (reminder every #{interval}s)"
puts 'Watch it loop, then convert the trial with:'
puts "  bundle exec ruby -e \"require './temporal/activities/trial_activities'; Demo::TrialStore.set_upgraded('#{user_email}', true)\""
puts 'Or simply: bundle exec ruby temporal/starter_trial.rb to restart fresh.'

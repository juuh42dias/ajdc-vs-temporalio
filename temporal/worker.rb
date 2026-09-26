require 'bundler/setup'
require 'temporalio/client'
require 'temporalio/worker'
require_relative './activities/bank_activities'
require_relative './activities/trial_activities'
require_relative './shared'
require_relative './workflows/bank_transfer_workflow'
require_relative './workflows/trial_workflow'

client = Temporalio::Client.connect('localhost:7233', 'default')

worker = Temporalio::Worker.new(
  client:,
  task_queue: Demo::TASK_QUEUE_NAME,
  workflows: [Demo::BankTransferWorkflow, Demo::TrialWorkflow],
  activities: [
    Demo::BankActivities::Withdraw,
    Demo::BankActivities::Deposit,
    Demo::BankActivities::Refund,
    Demo::TrialActivities::HasUpgraded,
    Demo::TrialActivities::SendReminderEmail
  ]
)

puts 'Starting Worker (press Ctrl+C to exit)'
worker.run(shutdown_signals: ['SIGINT'])

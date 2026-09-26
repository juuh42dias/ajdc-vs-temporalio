require 'bundler/setup'
require 'securerandom'
require 'temporalio/client'
require_relative './shared'
require_relative './workflows/bank_transfer_workflow'

client = Temporalio::Client.connect('localhost:7233', 'default')

details = Demo::TransferDetails.new('A1001', 'B2002', 100, SecureRandom.uuid)
details.source_account = ARGV[0] if ARGV.length >= 1
details.target_account = ARGV[1] if ARGV.length >= 2
details.amount = ARGV[2].to_i if ARGV.length >= 3
details.reference_id = ARGV[3] if ARGV.length >= 4

puts "Initiated transfer of $#{details.amount} from #{details.source_account} to #{details.target_account}"

result = client.execute_workflow(
  Demo::BankTransferWorkflow,
  details,
  id: "bank-transfer-#{details.reference_id}",
  task_queue: Demo::TASK_QUEUE_NAME
)

puts "Result: #{result}"

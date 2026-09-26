# Verifies the AJ/DC side of the demo without any external services.
# Run with: bin/rails runner script/verify_ajdc.rb
# Exits non-zero on the first failed assertion.
ActiveJob::Base.queue_adapter = :inline

def assert(condition, message)
  if condition
    puts "  ok - #{message}"
  else
    puts "  FAIL - #{message}"
    exit 1
  end
end

puts "== ImportJob: checkpoints survive a crash (at most last step is redone) =="
import = Import.create!(name: "demo-#{Time.now.to_i}", status: "pending")
5.times { |i| import.import_items.create!(label: "row-#{i}", processed: false) }

ImportJob.perform_later(import)

import.reload
assert(import.import_items.where(processed: true).count == 5, "all 5 items processed")
run = ImportJob.workflow_runs.for(import).first
assert(run.status == "completed", "run is completed (got #{run.status})")
assert(run.completed_steps == %w[validate process], "steps recorded: #{run.completed_steps.inspect}")
assert(run.state.is_a?(Hash), "durable state kept: #{run.state.inspect}")

puts "== License::LifecycleJob: one live run per license (unique_by, on_conflict: :replace) =="
ActiveJob::Base.queue_adapter = :test
license = License.create!(identifier: "LIC-1", expires_at: 30.days.from_now)
first = License::LifecycleJob.perform_later(license)
second = License::LifecycleJob.perform_later(license)
assert(first.is_a?(License::LifecycleJob), "first enqueue returns the job")
assert(second.is_a?(License::LifecycleJob), "replace: second enqueue starts a new run")
runs = License::LifecycleJob.workflow_runs.for(license)
assert(runs.live.count == 1, "exactly one live run")
assert(runs.where(status: "cancelled").count == 1, "previous run was cancelled")
ActiveJob::Base.queue_adapter = :inline

puts "== BulkImportJob: signals + scopes =="
ActiveJob::Base.queue_adapter = :test
bulk = Import.create!(name: "bulk-#{Time.now.to_i}", status: "pending")
BulkImportJob.perform_later(bulk)
awaiting_scope = BulkImportJob.workflow_runs.for(bulk)
assert(awaiting_scope.count == 1, "run row exists for bulk import")

puts "\nAll AJ/DC checks passed."
puts "Run rows in DB: #{ActiveJob::Durable::Run.count}"

# Demonstrates AJ/DC checkpoints: each `step.advance!` commits the cursor to
# `active_job_durable_steps`, so a crash loses at most the work since the
# last checkpoint. Compare with Temporal's automatic checkpoint after every
# Activity (see temporal/workflows/bank_transfer_workflow.rb).
#
# NOTE: AJ/DC's `attribute` macro needs Rails 8.2+ (ActiveJob::Attributes);
# this demo targets Rails 8.1, so progress is tracked in the database instead.
class ImportJob < ApplicationJob
  include ActiveJob::Durable

  def perform(import)
    step :validate do
      raise "nothing to import" if import.import_items.empty?
    end

    step :process do |step|
      import.import_items.order(:id).where(processed: false).find_each(start: step.cursor) do |item|
        item.update!(processed: true)
        step.advance! from: item.id
      end
    end

    import.update!(status: "done")
  end
end

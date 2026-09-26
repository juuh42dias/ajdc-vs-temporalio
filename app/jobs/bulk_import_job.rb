# Demonstrates AJ/DC signals (`await` / `wake_up`): the human-in-the-loop
# counterpart of Temporal Signals. Run it, then approve from another terminal:
#
#   bin/rails runner 'Import.find_each { |i| BulkImportJob.workflow_runs.for(i).live.sole.wake_up(:confirmation, true) }'
#
# A signal sent *before* the `await` line is stored and replayed, so order
# doesn't matter. With `wait:` the handler is called with `nil` on timeout.
#
# NOTE: `attribute` needs Rails 8.2+, so the flag lives on the Import record.
class BulkImportJob < ApplicationJob
  include ActiveJob::Durable

  def perform(import)
    @import = import

    await :confirmation, wait: 10.minutes
    unless import.reload.confirmed
      import.update!(status: "destroyed")
      import.import_items.delete_all
      return
    end

    step :apply do
      import.import_items.update_all(processed: true)
      import.update!(status: "applied")
    end
  end

  private
    def confirmation(signal)
      @import.update!(confirmed: signal.presence)
    end
end

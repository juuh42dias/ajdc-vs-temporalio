# Demonstrates AJ/DC timers (`wait_until` / `wait`) and run uniqueness
# (`unique_by ... on_conflict: :replace`). The Temporal counterpart is
# temporal/workflows/trial_workflow.rb, which uses `Workflow.sleep` instead
# of leaving the queue.
#
# Waiting runs need a clock. With Solid Queue, schedule the waker:
#
#   # config/recurring.yml
#   durable_wake:
#     class: ActiveJob::Durable::WakeJob
#     schedule: every minute
class License::LifecycleJob < ApplicationJob
  include ActiveJob::Durable

  unique_by :license, on_conflict: :replace

  def perform(license)
    step :remind, wait_until: license.expires_at - 2.weeks do
      Rails.logger.info("Reminder: license #{license.identifier} expires at #{license.expires_at}")
    end

    step :expire, wait_until: license.expires_at do
      Rails.logger.info("License #{license.identifier} expired")
    end

    step :revoke, wait: 2.weeks do
      license.update!(revoked_at: Time.current)
    end
  end
end

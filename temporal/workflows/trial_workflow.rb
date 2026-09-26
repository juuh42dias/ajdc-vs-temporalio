# frozen_string_literal: true

require_relative '../activities/trial_activities'
require_relative '../shared'
require 'temporalio/workflow'

module Demo
  # The timer counterpart of License::LifecycleJob (app/jobs/license/lifecycle_job.rb).
  # `Workflow.sleep` is a durable timer: it survives worker and server restarts.
  # Pass a short interval for the demo (production would be 30 * 24 * 60 * 60).
  class TrialWorkflow < Temporalio::Workflow::Definition
    def execute(details)
      until Temporalio::Workflow.execute_activity(
        TrialActivities::HasUpgraded,
        details,
        start_to_close_timeout: 10
      )
        Temporalio::Workflow.execute_activity(
          TrialActivities::SendReminderEmail,
          details,
          start_to_close_timeout: 10
        )
        Temporalio::Workflow.sleep(details.interval_seconds, summary: 'wait before next reminder')
      end

      "Trial converted for #{details.user_email}"
    end
  end
end

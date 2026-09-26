# frozen_string_literal: true

# Struct (de)serialization for workflow/activity payloads. Needs json 2.x
# (see Gemfile pin): json 3.x removed JSON.create_id used by json/add/struct.
require 'json/add/struct'

# Shared types for the Temporal side of the demo.
# Mirrors the AJ/DC jobs in app/jobs: same business flows, platform runtime.
module Demo
  TASK_QUEUE_NAME = 'ajdc-vs-temporal-demo'

  class InsufficientFundsError < StandardError; end

  class InvalidAccountError < StandardError; end

  TransferDetails = Struct.new(:source_account, :target_account, :amount, :reference_id) do
    def to_s
      "TransferDetails { #{source_account}, #{target_account}, #{amount}, #{reference_id} }"
    end
  end

  TrialDetails = Struct.new(:user_email, :interval_seconds) do
    def to_s
      "TrialDetails { #{user_email}, every #{interval_seconds}s }"
    end
  end
end

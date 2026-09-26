# frozen_string_literal: true

require_relative '../shared'
require 'temporalio/activity'

module Demo
  module BankActivities
    class Withdraw < Temporalio::Activity::Definition
      def execute(details)
        puts("Doing a withdrawal from #{details.source_account} for #{details.amount}")
        raise InsufficientFundsError, 'Transfer amount too large' if details.amount > 1000

        "OKW-#{details.amount}-#{details.source_account}"
      end
    end

    class Deposit < Temporalio::Activity::Definition
      def execute(details)
        puts("Doing a deposit into #{details.target_account} for #{details.amount}")
        raise InvalidAccountError, 'Invalid account number' if details.target_account == 'B5555'

        "OKD-#{details.amount}-#{details.target_account}"
      end
    end

    class Refund < Temporalio::Activity::Definition
      def execute(details)
        puts("Refunding #{details.amount} back to account #{details.source_account}")

        "OKR-#{details.amount}-#{details.source_account}"
      end
    end
  end
end

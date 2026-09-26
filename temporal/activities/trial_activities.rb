# frozen_string_literal: true

require_relative '../shared'
require 'fileutils'
require 'temporalio/activity'

module Demo
  # File-backed stand-in for "has the user upgraded?" — keeps the demo
  # runnable with no database. The starter seeds `false`; flip it to `true`
  # (see temporal/starter_trial.rb) to let the workflow finish.
  module TrialStore
    def self.dir
      File.expand_path('../tmp', __dir__).tap { |d| FileUtils.mkdir_p(d) }
    end

    def self.path_for(user_email)
      File.join(dir, "#{user_email.gsub(/[^a-z0-9]+/i, '_')}.txt")
    end

    def self.upgraded?(user_email)
      File.read(path_for(user_email)).strip == 'true'
    rescue Errno::ENOENT
      false
    end

    def self.set_upgraded(user_email, value)
      File.write(path_for(user_email), value ? 'true' : 'false')
    end
  end

  module TrialActivities
    class HasUpgraded < Temporalio::Activity::Definition
      def execute(details)
        upgraded = TrialStore.upgraded?(details.user_email)
        puts("Checking upgrade for #{details.user_email}: #{upgraded}")
        upgraded
      end
    end

    class SendReminderEmail < Temporalio::Activity::Definition
      def execute(details)
        puts("Sending reminder email to #{details.user_email}")
        File.open(File.join(TrialStore.dir, 'reminders.log'), 'a') do |f|
          f.puts("#{Time.now.utc.iso8601} reminder to #{details.user_email}")
        end
        "reminder-sent-#{details.user_email}"
      end
    end
  end
end

# frozen_string_literal: true

require 'delayed_job'

Delayed::Worker.queue_attributes = {
  contest_creating: { priority: 2 },
  contest_processing: { priority: 1 }
}

begin
  inspect_contests_handler = '--- !ruby/object:Delayed::PerformableMethod
object: !ruby/class \'ContestsServices::InspectContests\'
method_name: :call
args: []
'
  rolling_coins_handler = '--- !ruby/object:Delayed::PerformableMethod
object: !ruby/class \'RollingServices::GrantCoins\'
method_name: :call
args: []
'
  Delayed::Job.where(handler: inspect_contests_handler).destroy_all
  Delayed::Job.where(handler: rolling_coins_handler).destroy_all

  unless Rails.env.test?
    ContestsServices::InspectContests.delay(queue: 'contest_creating').call
    RollingServices::GrantCoins.delay(queue: 'rolling_coins',
                                      run_at: Time.current.beginning_of_day + 1.day + 3.hour).call
  end
rescue ActiveRecord::StatementInvalid => e
  puts 'Can`t queue a job', e.inspect
end

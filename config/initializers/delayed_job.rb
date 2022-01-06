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
  Delayed::Job.where(handler: inspect_contests_handler).destroy_all
  ContestsServices::InspectContests.delay(queue: 'contest_creating').call unless Rails.env.test?
rescue ActiveRecord::StatementInvalid => e
  puts 'Can`t queue a job', e.inspect
end

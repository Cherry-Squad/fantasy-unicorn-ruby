# frozen_string_literal: true

require 'delayed_job'

Delayed::Worker.queue_attributes = {
  contest_creating: { priority: 2 },
  contest_processing: { priority: 1 }
}

ContestsServices::InspectContests.call unless Rails.env.test?

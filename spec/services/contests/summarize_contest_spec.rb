# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ContestsServices::SummarizeContest do
  Delayed::Worker.delay_jobs = false
end

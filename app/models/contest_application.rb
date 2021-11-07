# frozen_string_literal: true

# This class represents a ContestApplication record.
# The ContestApplication holds an application on a contest
# with possibly results of the contest for the given user.
#
# User < ContestApplication: many-to-one
# Contest < ContestApplication: many-to-one
class ContestApplication < ApplicationRecord
  belongs_to :contest
  belongs_to :user

  validates :final_position, numericality: { greater_than: 0 }, if: -> { !final_position.nil? }
  validate :data_after_contest_end
  validate :no_data_before_contest_end

  def final?
    !final_position.nil?
  end

  private

  def data_after_contest_end
    return unless contest.status == Contest.statuses[:finished]

    errors.add(:final_position, 'must be presented') if final_position.nil?
    errors.add(:coins_delta, 'must be presented') if coins_delta.nil?
    errors.add(:fantasy_points_delta, 'must be presented') if fantasy_points_delta.nil?
  end

  def no_data_before_contest_end
    return if contest.status == Contest.statuses[:finished]

    errors.add(:final_position, 'must not be presented') unless final_position.nil?
    errors.add(:coins_delta, 'must not be presented') unless coins_delta.nil?
    errors.add(:fantasy_points_delta, 'must not be presented') unless fantasy_points_delta.nil?
  end
end

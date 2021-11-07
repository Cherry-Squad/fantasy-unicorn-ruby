# frozen_string_literal: true

# This class represents a Contest record (do not confuse with Tournament)
# The Contest holds settings of a stock-based contest
#
# Stock >< Contest: many-to-many (preconfigured set)
# ContestApplication > Contest: one-to-many
class Contest < ApplicationRecord
  enum direction_strategy: {
    free: 'free',
    fixed: 'fixed',
    single_per_user: 'single_per_user'
  }
  enum status: {
    created: 'created',
    reg_ended: 'reg_ended',
    finished: 'finished'
  }

  has_and_belongs_to_many :stocks, join_table: 'contest_preconfigured_stocks'
  has_many :contest_applications, dependent: :delete_all

  after_initialize :set_defaults

  validates_presence_of :reg_ending_at, :summarizing_at
  validate :reg_ending_before_summarizing
  validate :fixed_direction_presence
  validate :fixed_direction_on_fixed_strategy
  validate :finished_change
  validate :contest_applications
  validate :finish_positions
  validates :coins_entry_fee, numericality: { greater_than_or_equal_to: 0 }
  validates :max_fantasy_points_threshold, numericality: { greater_than_or_equal_to: 0 }
  validates :direction_strategy, inclusion: { in: Contest.direction_strategies.keys }, presence: true
  validates :status, inclusion: { in: Contest.statuses.keys }, presence: true

  private

  def reg_ending_before_summarizing
    return unless reg_ending_at.present? && summarizing_at.present?

    errors.add(:reg_ending_at, "can't be after summarizing") if summarizing_at < reg_ending_at
  end

  def fixed_direction_presence
    return if direction_strategy == Contest.direction_strategies[:fixed]
    return if fixed_direction_up.nil?

    errors.add(:fixed_direction_up, "can't be with direction strategy == #{direction_strategy}")
  end

  # noinspection RubyInstanceMethodNamingConvention
  def fixed_direction_on_fixed_strategy
    return unless direction_strategy == Contest.direction_strategies[:fixed]

    errors.add(:fixed_direction_up, 'have to be present with direction strategy == fixed') if fixed_direction_up.nil?
  end

  def finished_change
    errors.add(:status, "can't change") if status_was == Contest.statuses[:finished] && status_changed? && persisted?
  end

  def finish_positions
    return unless status == Contest.statuses[:finished] && status_changed? && persisted?
    return if contest_applications.map(&:final?).all?

    errors.add(:contest_applications, 'have some unfinished applications')
  end

  def set_defaults
    self.status ||= Contest.statuses[:created]
    self.coins_entry_fee ||= 0
    self.use_briefcase_only ||= true
    self.direction_strategy ||= Contest.direction_strategies[:free]
    self.use_disabled_multipliers ||= false
    self.use_inverted_stock_prices ||= false
  end
end

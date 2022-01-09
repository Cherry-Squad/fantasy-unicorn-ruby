# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ContestsServices::CreditPoints do
  Delayed::Worker.delay_jobs = false

  let!(:contest) { create :contest, status: :reg_ended, max_fantasy_points_threshold: 600 }
  let!(:user) { create :user }
  let!(:contest_application) { create :contest_application, user_id: user.id, contest_id: contest.id }
  let!(:stock1) { create :stock }
  let!(:stock2) { create :stock }
  let!(:contest_application_stock1) do
    create :contest_application_stock,
           contest_application_id: contest_application.id,
           stock_id: stock1.id,
           reg_price: 155.0,
           final_price: 160.0,
           direction_up: true
  end
  let!(:contest_application_stock2) do
    create :contest_application_stock,
           contest_application_id: contest_application.id,
           stock_id: stock2.id,
           reg_price: 148.0,
           final_price: 139.9,
           direction_up: false
  end

  context 'one participant' do
    it 'and he is won' do
      ContestsServices::CreditPoints.call contest.id

      expect(ContestApplication.find(contest_application.id).final_position).to eq(1)
    end

    it 'and contest status has been correctly changed' do
      expect(Contest.find(contest.id).status).to eq('reg_ended')

      ContestsServices::CreditPoints.call contest.id

      expect(Contest.find(contest.id).status).to eq('finished')
    end
  end

  context 'many participants' do
    let!(:user2) { create :user }
    let!(:contest_application2) { create :contest_application, user_id: user2.id, contest_id: contest.id }
    let!(:contest_application_stock3) do
      create :contest_application_stock,
             contest_application_id: contest_application2.id,
             stock_id: stock1.id,
             reg_price: 155.0,
             final_price: 160.0,
             direction_up: true
    end
    let!(:contest_application_stock4) do
      create :contest_application_stock,
             contest_application_id: contest_application2.id,
             stock_id: stock2.id,
             reg_price: 148.0,
             final_price: 139.9,
             direction_up: true
    end
    let(:base_coins_delta) { Rails.configuration.divisions[:div2][:base_coins_delta] }
    let(:base_fp_delta) { Rails.configuration.divisions[:div2][:base_fp_delta] }

    it 'and first participant won' do
      ContestsServices::CreditPoints.call contest.id

      expect(ContestApplication.find(contest_application.id).final_position).to eq(1)
      expect(ContestApplication.find(contest_application2.id).final_position).to eq(2)
    end

    it 'correctly calculate deltas' do
      ContestsServices::CreditPoints.call contest.id

      participants_amount = ContestApplication.where(contest_id: contest.id).size.to_i

      expect(ContestApplication.find(contest_application.id).coins_delta)
        .to eq((base_coins_delta * (1.5 -
          Float(ContestApplication.find(contest_application.id).final_position - 1) / participants_amount)).to_i)

      expect(ContestApplication.find(contest_application.id).fantasy_points_delta)
        .to eq((base_fp_delta * (1.5 -
          Float(ContestApplication.find(contest_application.id).final_position - 1) / participants_amount)).to_i)

      expect(ContestApplication.find(contest_application2.id).coins_delta)
        .to eq((base_coins_delta * (1.5 -
          Float(ContestApplication.find(contest_application2.id).final_position - 1) / participants_amount)).to_i)

      expect(ContestApplication.find(contest_application2.id).fantasy_points_delta)
        .to eq((base_fp_delta * (1.5 -
          Float(ContestApplication.find(contest_application2.id).final_position - 1) / participants_amount)).to_i)
    end

    it 'coins and fp correcly changed' do
      user1_coins = user.coins
      user1_fp = user.fantasy_points
      user2_coins = user2.coins
      user2_fp = user.fantasy_points

      ContestsServices::CreditPoints.call contest.id

      participants_amount = ContestApplication.where(contest_id: contest.id).size.to_i

      expect(User.find(user.id).coins).to eq(user1_coins + (base_coins_delta * (1.5 -
        Float(ContestApplication.find(contest_application.id).final_position - 1) / participants_amount)).to_i)

      expect(User.find(user.id).fantasy_points).to eq(user1_fp + (base_fp_delta * (1.5 -
        Float(ContestApplication.find(contest_application.id).final_position - 1) / participants_amount)).to_i)

      expect(User.find(user2.id).coins).to eq(user2_coins + (base_coins_delta * (1.5 -
        Float(ContestApplication.find(contest_application2.id).final_position - 1) / participants_amount)).to_i)

      expect(User.find(user2.id).fantasy_points).to eq(user2_fp + (base_fp_delta * (1.5 -
        Float(ContestApplication.find(contest_application2.id).final_position - 1) / participants_amount)).to_i)
    end

    context 'with third participant' do
      let!(:user3) { create :user }
      let!(:contest_application3) { create :contest_application, user_id: user3.id, contest_id: contest.id }
      let!(:contest_application_stock5) do
        create :contest_application_stock,
               contest_application_id: contest_application3.id,
               stock_id: stock1.id,
               reg_price: 155.0,
               final_price: 160.0,
               direction_up: false
      end
      let!(:contest_application_stock6) do
        create :contest_application_stock,
               contest_application_id: contest_application3.id,
               stock_id: stock2.id,
               reg_price: 148.0,
               final_price: 139.9,
               direction_up: true
      end

      it 'and first participant won' do
        ContestsServices::CreditPoints.call contest.id

        expect(ContestApplication.find(contest_application.id).final_position).to eq(1)
        expect(ContestApplication.find(contest_application2.id).final_position).to eq(2)
        expect(ContestApplication.find(contest_application3.id).final_position).to eq(3)
      end
    end
  end
end

require 'rails_helper'

RSpec.describe MarkCartAsAbandonedJob, type: :job do
  describe '#perform' do
    let!(:recent_cart) do
      Cart.create(
        total_price: 0,
        last_interaction_at: 1.hour.ago,
        abandoned: false
      )
    end

    let!(:old_cart) do
      Cart.create(
        total_price: 50.0,
        last_interaction_at: 4.hours.ago,
        abandoned: false
      )
    end

    let!(:very_old_cart) do
      Cart.create(
        total_price: 25.0,
        last_interaction_at: 1.day.ago,
        abandoned: false
      )
    end

    let!(:already_abandoned_cart) do
      Cart.create(
        total_price: 10.0,
        last_interaction_at: 6.hours.ago,
        abandoned: true
      )
    end

    context 'when performing the job' do
      it 'marks carts without interaction as abandoned' do
        expect { described_class.new.perform }.to change { Cart.where(abandoned: true).count }.from(1).to(3)
      end

      it 'does not mark recent carts as abandoned' do
        described_class.new.perform

        expect(recent_cart.reload.abandoned).to be false
      end

      it 'marks old carts as abandoned' do
        described_class.new.perform

        expect(old_cart.reload.abandoned).to be true
        expect(very_old_cart.reload.abandoned).to be true
      end

      it 'does not change already abandoned carts' do
        expect { described_class.new.perform }.not_to(change { already_abandoned_cart.reload.updated_at })
      end
    end
  end
end

require 'rails_helper'

describe Event do
  describe '.all_dates' do
    let!(:event1) { Event.create!(starts_at: '2020-09-15') }
    let!(:event2) { Event.create!(starts_at: '2020-09-01') }

    subject { Event.all_dates }

    it 'returns the formatted date of each event' do
      expect(subject).to eq(['2020-09-01', '2020-09-15'])
    end
  end

  describe '.toggle!' do
    let(:date) { '2020-09-10' }
    subject { Event.toggle!(date) }

    context 'an event with date exists' do
      let!(:event) { Event.create!(starts_at: date) }

      it 'returns the deleted the event' do
        expect(subject.persisted?).to eq(false)
        expect(Event.count).to eq(0)
      end
    end

    context 'an event with date does not exist' do
      it 'creates an event' do
        expect(subject.persisted?).to eq(true)
        expect(Event.count).to eq(1)
      end
    end
  end
end

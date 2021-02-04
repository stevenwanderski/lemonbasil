require 'spec_helper'

describe Event do
  describe '.all_dates' do
    let!(:event1) { Event.create!(starts_at: '2020-09-15') }
    let!(:event2) { Event.create!(starts_at: '2020-09-01') }

    subject { Event.all_dates }

    it 'returns the formatted date of each event' do
      expect(subject).to eq(['2020-09-01', '2020-09-15'])
    end
  end
end

require 'rails_helper'

describe Page do
  describe '#friendly_slug' do
    let(:slug) { 'meal-prep' }
    let(:page) { Page.new(slug: slug) }

    subject { page.friendly_slug }

    it 'returns the slug without hyphens' do
      expect(subject).to eq('meal prep')
    end
  end
end

require 'spec_helper'

describe ClientMenu do
  describe '#set_slug' do
    it 'sets a unique slug on create' do
      client_menu = create(:client_menu)

      expect(client_menu.slug.length).to eq(6)
    end
  end
end

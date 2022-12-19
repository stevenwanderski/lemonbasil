require 'spec_helper'

describe ClientMenu do
  describe '#set_slug' do
    it 'sets a unique slug on create' do
      client_menu = create(:client_menu)

      expect(client_menu.slug.length).to eq(6)
    end
  end

  describe '#duplicate!' do
    it 'creates a copy of the client menu' do
      client_menu = create(:client_menu, job_date: '2021-01-01')
      category1 = create(:client_menu_category, client_menu: client_menu)
      item1 = create(:client_menu_item, client_menu_category: category1)
      staple_category1 = create(:staple_category, client_menu: client_menu)
      staple1 = create(:staple, staple_category: staple_category1)

      menu = client_menu.duplicate!(job_date: '2021-02-01')

      expect(client_menu.client_menu_categories.count).to eq(1)
      expect(client_menu.client_menu_items.count).to eq(1)

      expect(menu.job_date.strftime("%m/%d/%Y")).to eq('02/01/2021')
      expect(menu.client_menu_categories.count).to eq(1)
      expect(menu.client_menu_items.count).to eq(1)
      expect(menu.staple_categories.count).to eq(1)
      expect(menu.staples.count).to eq(1)
    end
  end
end

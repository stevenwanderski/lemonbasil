require 'spec_helper'

describe ClientMenuSubmission do
  describe '#running_total' do
    it 'returns the total cost of all selected items' do
      menu = create(:client_menu)
      item1 = create(:client_menu_item, cost: 7)
      item2 = create(:client_menu_item, cost: 8)
      item3 = create(:client_menu_item, cost: 9)

      submission = ClientMenuSubmission.new(
        client_menu: menu,
        client_menu_item_ids: [item1.id, item2.id]
      )

      expect(submission.running_total).to eq(15)
    end
  end

  describe '#running_quantity' do
    it 'returns the number of selected items' do
      menu = create(:client_menu)
      item1 = create(:client_menu_item, cost: 7)
      item2 = create(:client_menu_item, cost: 8)
      item3 = create(:client_menu_item, cost: 9)

      submission = ClientMenuSubmission.new(
        client_menu: menu,
        client_menu_item_ids: [item1.id, item2.id]
      )

      expect(submission.running_quantity).to eq(2)
    end
  end
end
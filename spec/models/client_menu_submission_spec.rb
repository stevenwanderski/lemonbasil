require 'spec_helper'

describe ClientMenuSubmission do
  let(:user) { create(:user) }
  let(:menu) { create(:client_menu, user: user) }
  let(:category) { create(:client_menu_category, client_menu: menu) }

  describe '#set_total' do
    context 'total value does not exist' do
      it 'sets the total from the running total on before save' do
        item1 = create(:client_menu_item, client_menu_category: category, cost: 7)
        item2 = create(:client_menu_item, client_menu_category: category, cost: 8)

        submission = ClientMenuSubmission.create!(
          client_menu: menu,
          client_menu_item_ids: [item1.id, item2.id]
        )

        expect(submission.total).to eq(15)
      end
    end

    context 'total value exists' do
      it 'keeps the total value' do
        item1 = create(:client_menu_item, client_menu_category: category, cost: 7)
        item2 = create(:client_menu_item, client_menu_category: category, cost: 8)

        submission = ClientMenuSubmission.create!(
          client_menu: menu,
          client_menu_item_ids: [item1.id, item2.id],
          total: 99
        )

        expect(submission.total).to eq(99)
      end
    end
  end

  describe '#running_total' do
    it 'returns the total cost of all selected items' do
      item1 = create(:client_menu_item, client_menu_category: category, cost: 7)
      item2 = create(:client_menu_item, client_menu_category: category, cost: 8)
      item3 = create(:client_menu_item, client_menu_category: category, cost: 9)

      submission = ClientMenuSubmission.new(
        client_menu: menu,
        client_menu_item_ids: [item1.id, item2.id]
      )

      expect(submission.running_total).to eq(15)
    end
  end

  describe '#running_quantity' do
    it 'returns the number of selected items' do
      item1 = create(:client_menu_item, client_menu_category: category, cost: 7)
      item2 = create(:client_menu_item, client_menu_category: category, cost: 8)
      item3 = create(:client_menu_item, client_menu_category: category, cost: 9)

      submission = ClientMenuSubmission.new(
        client_menu: menu,
        client_menu_item_ids: [item1.id, item2.id]
      )

      expect(submission.running_quantity).to eq(2)
    end
  end
end
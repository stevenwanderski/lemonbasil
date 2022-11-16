require 'spec_helper'

describe ClientMenuSubmissionsController do
  let!(:menu) { create(:client_menu) }
  let!(:category) { create(:client_menu_category, client_menu: menu) }
  let!(:item1) { create(:client_menu_item, client_menu_category: category, cost: 7) }
  let!(:item2) { create(:client_menu_item, client_menu_category: category, cost: 8) }

  let(:params) do
    {
      client_menu_id: menu.id,
      client_menu_submission: {
        client_menu_item_ids: [
          item1.id,
          item2.id
        ]
      }
    }
  end

  describe '#create' do
    subject { post :create, params: params }

    it 'creates a client menu submission and client menu selections' do
      subject

      submission = menu.newest_submission
      selections = submission.client_menu_selections

      expect(submission.total).to eq(15)
      expect(selections.map(&:client_menu_item_id)).to eq(
        [item1.id, item2.id]
      )
    end

    it 'sends a mailer to the client' do
      expect { subject }.to change(ActionMailer::Base.deliveries, :count).by(1)
    end
  end
end

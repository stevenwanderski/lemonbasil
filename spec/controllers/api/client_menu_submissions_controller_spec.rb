require 'spec_helper'

describe Api::ClientMenuSubmissionsController do
  let!(:menu) { create(:client_menu) }
  let!(:category) { create(:client_menu_category, client_menu: menu) }
  let!(:item1) { create(:client_menu_item, client_menu_category: category) }
  let!(:item2) { create(:client_menu_item, client_menu_category: category) }
  let!(:item3) { create(:client_menu_item, client_menu_category: category) }

  let(:params) do
    {
      client_menu_id: menu.id,
      client_menu_item_ids: [
        item1.id,
        item2.id
      ],
      total: 32
    }
  end

  def encode_token(token)
    ActionController::HttpAuthentication::Token.encode_credentials(token)
  end

  before do
    headers = {
      'Authorization' => encode_token('secret-token'),
      'Content-Type' => 'application/json;charset=UTF-8'
    }
    request.headers.merge! headers
  end

  describe '#create' do
    subject { post :create, params: params }

    it 'creates a client menu submission and client menu selections' do
      subject

      submission = menu.newest_submission
      selections = submission.client_menu_selections

      expect(submission.total).to eq(32)
      expect(selections.map(&:client_menu_item_id)).to eq(
        [item1.id, item2.id]
      )
    end

    it 'sends a mailer to the client' do
      expect { subject }.to change(
        ActionMailer::Base.deliveries, :count
      ).by(1)
    end
  end
end

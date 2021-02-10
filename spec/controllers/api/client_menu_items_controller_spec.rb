require 'spec_helper'

describe Api::ClientMenuItemsController do
  def encode_token(token)
    ActionController::HttpAuthentication::Token.encode_credentials(token)
  end

  describe '#update_weights' do
    before do
      headers = {
        'Authorization' => encode_token('secret-token'),
        'Content-Type' => 'application/json;charset=UTF-8'
      }
      request.headers.merge! headers
    end

    it 'saves all weights' do
      client_menu = create(:client_menu)
      category = create(:client_menu_category, client_menu: client_menu)
      menu_item1 = create(:client_menu_item, weight: 0, client_menu_category: category)
      menu_item2 = create(:client_menu_item, weight: 1, client_menu_category: category)
      menu_item3 = create(:client_menu_item, weight: 2, client_menu_category: category)

      params = {
        weights: [
          [menu_item1.id, 1],
          [menu_item2.id, 2],
          [menu_item3.id, 0]
        ]
      }

      post :update_weights, params: params

      expect(menu_item1.reload.weight).to eq(1)
      expect(menu_item2.reload.weight).to eq(2)
      expect(menu_item3.reload.weight).to eq(0)
    end
  end
end

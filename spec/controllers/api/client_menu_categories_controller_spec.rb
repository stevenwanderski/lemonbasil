require 'spec_helper'

describe Api::ClientMenuCategoriesController do
  def encode_token(token)
    ActionController::HttpAuthentication::Token.encode_credentials(token)
  end

  describe '#update_weights' do
    before do
      headers = {
        'Authorization' => encode_token(ENV['API_TOKEN']),
        'Content-Type' => 'application/json;charset=UTF-8'
      }
      request.headers.merge! headers
    end

    it 'saves all weights' do
      client_menu = create(:client_menu)
      category1 = create(:client_menu_category, weight: 0, client_menu: client_menu)
      category2 = create(:client_menu_category, weight: 1, client_menu: client_menu)
      category3 = create(:client_menu_category, weight: 2, client_menu: client_menu)

      params = {
        client_menu_id: client_menu.id,
        weights: [
          [category1.id, 1],
          [category2.id, 2],
          [category3.id, 0]
        ]
      }

      post :update_weights, params: params

      expect(category1.reload.weight).to eq(1)
      expect(category2.reload.weight).to eq(2)
      expect(category3.reload.weight).to eq(0)
    end
  end
end

require 'spec_helper'

describe Admin::ClientMenusController do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    user = create(:user)
    sign_in(user)
  end

  describe '#show' do
    let!(:client_menu) { create(:client_menu) }

    subject { get :show, params: { id: client_menu.id } }

    context 'menu categories exist' do
      let!(:category) { create(:client_menu_category, client_menu: client_menu) }

      it 'redirects to menu items' do
        expect(subject).to redirect_to(admin_client_menu_menu_items_path(client_menu_id: client_menu.id))
      end
    end

    context 'menu categories do not exist' do
      it 'redirects to categories' do
        expect(subject).to redirect_to(admin_client_menu_categories_path(client_menu_id: client_menu.id))
      end
    end
  end
end

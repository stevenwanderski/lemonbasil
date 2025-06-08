require 'spec_helper'

describe Admin::UsersController do
  let!(:user) { create(:user, role: 'admin') }

  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in(user)
  end

  describe '#index' do
    subject { get :index }

    it 'renders the route' do
      expect(subject.code).to eq("200")
    end

    context 'user is not admin role' do
      let!(:user) { create(:user, role: 'staff') }

      it 'redirects to clients' do
        expect(subject).to redirect_to(admin_clients_path)
      end
    end
  end

  describe '#switch_user' do
    let!(:user2) { create(:user, role: 'staff', email: 'some@guy.com') }

    subject { get :switch_user, params: { id: user2.id } }

    it 'logs in the new user' do
      subject
      expect(flash[:notice]).to eq('Logged in as some@guy.com')
    end

    context 'user is not admin role' do
      let!(:user) { create(:user, role: 'staff') }

      it 'redirects to clients' do
        expect(subject).to redirect_to(admin_clients_path)
      end
    end
  end
end

require 'spec_helper'

RSpec.describe "Admin::ClientMenus", type: :request do
  let(:user) { create(:user, email: 'user1@test.com') }

  before do
    login_as(user, scope: :user)
  end

  describe "GET /admin/client_menus/monthly" do
    it "returns 200" do
      get monthly_admin_client_menus_path
      expect(response).to have_http_status(200)
    end

    it "lists distinct month/year combinations ordered descending" do
      create(:client_menu, user: user, job_date: Date.new(2026, 1, 10))
      create(:client_menu, user: user, job_date: Date.new(2026, 4, 15))
      create(:client_menu, user: user, job_date: Date.new(2025, 11, 5))

      get monthly_admin_client_menus_path

      expect(response.body).to match(/April 2026.*January 2026.*November 2025/m)
    end

    it "excludes menus with nil job_date" do
      create(:client_menu, user: user, job_date: nil)
      create(:client_menu, user: user, job_date: Date.new(2026, 3, 1))

      get monthly_admin_client_menus_path

      expect(response.body).to include("March 2026")
      expect(response.body).not_to include("No menus with dates.")
    end

    it "only includes the current user's menus" do
      other_user = create(:user, email: 'other@test.com')
      create(:client_menu, user: other_user, job_date: Date.new(2026, 6, 1))
      create(:client_menu, user: user, job_date: Date.new(2026, 2, 1))

      get monthly_admin_client_menus_path

      expect(response.body).to include("February 2026")
      expect(response.body).not_to include("June 2026")
    end
  end

  describe "GET /admin/client_menus/monthly/:year/:month" do
    it "returns 200" do
      get monthly_show_admin_client_menus_path(2026, 4)
      expect(response).to have_http_status(200)
    end

    it "only returns menus within the specified month" do
      menu_in_month = create(:client_menu, user: user, job_date: Date.new(2026, 4, 15))

      get monthly_show_admin_client_menus_path(2026, 4)

      expect(response.body).to include(menu_in_month.client.full_name)
    end

    it "excludes menus from other months" do
      other_menu = create(:client_menu, user: user, job_date: Date.new(2026, 5, 10))

      get monthly_show_admin_client_menus_path(2026, 4)

      expect(response.body).not_to include(other_menu.client.full_name)
      expect(response.body).to include("No menus for this month.")
    end

    it "only includes the current user's menus" do
      other_user = create(:user, email: 'other2@test.com')
      other_client = create(:client, user: other_user, first_name: 'Other', last_name: 'Person')
      other_menu = create(:client_menu, user: other_user, client: other_client, job_date: Date.new(2026, 4, 20))
      my_menu = create(:client_menu, user: user, job_date: Date.new(2026, 4, 10))

      get monthly_show_admin_client_menus_path(2026, 4)

      expect(response.body).to include(my_menu.client.full_name)
      expect(response.body).not_to include(other_menu.client.full_name)
    end
  end
end

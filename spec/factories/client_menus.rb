FactoryBot.define do
  factory :client_menu do
    client { create(:client, user: user)}
    user
    due_at { Time.now }
    job_date { 2.days.from_now }
  end
end

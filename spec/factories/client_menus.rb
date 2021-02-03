FactoryBot.define do
  factory :client_menu do
    client
    due_at { Time.now }
  end
end

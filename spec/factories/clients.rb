FactoryBot.define do
  factory :client do
    user
    first_name { 'Frank' }
    last_name { 'Zappa' }
    email { 'frank@zappa.com' }
  end
end

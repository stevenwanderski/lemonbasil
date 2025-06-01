FactoryBot.define do
  factory :meal do
    user
    name { 'seafood pasta' }
    instructions { 'cook it' }
  end
end

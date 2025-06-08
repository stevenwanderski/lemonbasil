FactoryBot.define do
  factory :user do
    email { 'admin@admin.com' }
    password { 'testtest' }
    password_confirmation { 'testtest' }
    role { 'admin' }
  end
end

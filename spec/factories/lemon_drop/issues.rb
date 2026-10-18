FactoryBot.define do
  factory :lemon_drop_issue, class: 'LemonDrop::Issue' do
    title { 'oct 19–23' }
    sequence(:starts_on) { |n| Date.new(2026, 10, 19) + (n * 7).days }
    ends_on { starts_on + 4.days }

    trait :published do
      status { 'published' }
      published_at { Time.current }
    end
  end
end

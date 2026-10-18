FactoryBot.define do
  factory :lemon_drop_section, class: 'LemonDrop::Section' do
    association :issue, factory: :lemon_drop_issue
    association :sectionable, factory: :lemon_drop_title_page_section
    sequence(:position)
  end
end

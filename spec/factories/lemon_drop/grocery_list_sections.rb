FactoryBot.define do
  factory :lemon_drop_grocery_list_section, class: 'LemonDrop::GroceryListSection' do
    heading { 'your grocery list' }
  end

  factory :lemon_drop_grocery_group, class: 'LemonDrop::GroceryGroup' do
    grocery_list_section { association(:lemon_drop_section, sectionable: build(:lemon_drop_grocery_list_section)).sectionable }
    name { 'Produce' }
    sequence(:position)

    after(:build) do |group|
      group.grocery_items << build(:lemon_drop_grocery_item, grocery_group: group) if group.grocery_items.empty?
    end
  end

  factory :lemon_drop_grocery_item, class: 'LemonDrop::GroceryItem' do
    association :grocery_group, factory: :lemon_drop_grocery_group
    text { '1 large delicata squash' }
    sequence(:position)
  end
end

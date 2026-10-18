FactoryBot.define do
  factory :lemon_drop_allergen_swap_section, class: 'LemonDrop::AllergenSwapSection' do
    heading { 'allergen swaps' }
  end

  factory :lemon_drop_swap_group, class: 'LemonDrop::SwapGroup' do
    allergen_swap_section { association(:lemon_drop_section, sectionable: build(:lemon_drop_allergen_swap_section)).sectionable }
    name { 'Dairy-free swaps' }
    sequence(:position)

    after(:build) do |group|
      group.swaps << build(:lemon_drop_swap, swap_group: group) if group.swaps.empty?
    end
  end

  factory :lemon_drop_swap, class: 'LemonDrop::Swap' do
    association :swap_group, factory: :lemon_drop_swap_group
    from_text { 'parm' }
    to_text { 'nutritional yeast' }
    sequence(:position)
  end

  factory :lemon_drop_swap_recipe, class: 'LemonDrop::SwapRecipe' do
    allergen_swap_section { association(:lemon_drop_section, sectionable: build(:lemon_drop_allergen_swap_section)).sectionable }
    title { 'Cashew cream' }
    yield_label { 'Makes ~1 cup' }
    ingredients { "1 c raw cashews\n½ c water" }
    steps { "Soak cashews in hot water for 30 mins. Drain well.\nBlend until silky smooth, about 2 mins." }
    sequence(:position)
  end
end

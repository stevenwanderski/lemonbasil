FactoryBot.define do
  factory :lemon_drop_recipe, class: 'LemonDrop::Recipe' do
    recipes_section { association(:lemon_drop_section, sectionable: build(:lemon_drop_recipes_section)).sectionable }
    title { 'chickpea stew' }
    category { 'soup' }
    sequence(:position)

    after(:build) do |recipe|
      if recipe.ingredient_groups.empty?
        recipe.ingredient_groups << build(:lemon_drop_ingredient_group, recipe: recipe)
      end
      recipe.steps << build(:lemon_drop_step, recipe: recipe) if recipe.steps.empty?
    end
  end

  factory :lemon_drop_ingredient_group, class: 'LemonDrop::IngredientGroup' do
    association :recipe, factory: :lemon_drop_recipe
    name { 'Produce' }
    sequence(:position)

    after(:build) do |group|
      group.ingredients << build(:lemon_drop_ingredient, ingredient_group: group) if group.ingredients.empty?
    end
  end

  factory :lemon_drop_ingredient, class: 'LemonDrop::Ingredient' do
    association :ingredient_group, factory: :lemon_drop_ingredient_group
    text { '4 garlic cloves, thinly sliced' }
    sequence(:position)
  end

  factory :lemon_drop_step, class: 'LemonDrop::Step' do
    association :recipe, factory: :lemon_drop_recipe
    body { 'Heat a generous pour of olive oil.' }
    sequence(:position)
  end
end

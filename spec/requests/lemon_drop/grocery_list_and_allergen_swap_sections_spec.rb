require 'spec_helper'

RSpec.describe 'LemonDrop Grocery List and Allergen Swap Sections', type: :request do
  let(:issue) { create(:lemon_drop_issue, :published) }

  def add_section(sectionable, **section_attributes)
    create(:lemon_drop_section, issue: issue, sectionable: sectionable, **section_attributes)
  end

  def page
    get lemon_drop_issue_path(issue.slug)
    response.body
  end

  describe 'Grocery List' do
    it 'renders its heading, icon and groups of items in order' do
      grocery_list = build(:lemon_drop_grocery_list_section, icon: uploaded_image('bowl.png'))
      grocery_list.grocery_groups = [
        build(:lemon_drop_grocery_group, grocery_list_section: grocery_list, name: 'Pantry', position: 2,
          grocery_items: [build(:lemon_drop_grocery_item, text: 'arborio rice')]),
        build(:lemon_drop_grocery_group, grocery_list_section: grocery_list, name: 'Produce', position: 1,
          grocery_items: [
            build(:lemon_drop_grocery_item, text: 'fresh sage', position: 2),
            build(:lemon_drop_grocery_item, text: '1 large delicata squash', position: 1)
          ])
      ]
      add_section(grocery_list)

      expect(page).to match(%r{<div class="grocery-head">\s*<img[^>]+bowl\.png[^>]*>\s*<h2>your grocery list</h2>})
      expect(response.body).to match(
        %r{<div class="grocery-grid">\s*<div class="grocery-col">\s*<h3>Produce</h3>\s*<ul>\s*<li>1 large delicata squash</li>\s*<li>fresh sage</li>\s*</ul>\s*</div>\s*<div class="grocery-col">\s*<h3>Pantry</h3>}
      )
    end

    it 'leaves out the icon when there is none' do
      add_section(build(:lemon_drop_grocery_list_section))

      expect(page).to include('<h2>your grocery list</h2>')
      expect(response.body).not_to match(%r{<div class="grocery-head">\s*<img})
    end
  end

  describe 'Allergen Swap' do
    it 'renders its heading, icon and groups of swaps in order as from → to' do
      allergen_swap = build(:lemon_drop_allergen_swap_section, icon: uploaded_image('stacked-bowls.png'))
      allergen_swap.swap_groups = [
        build(:lemon_drop_swap_group, allergen_swap_section: allergen_swap, name: 'Dairy-free swaps', position: 2,
          swaps: [build(:lemon_drop_swap, from_text: 'parm', to_text: 'nutritional yeast')]),
        build(:lemon_drop_swap_group, allergen_swap_section: allergen_swap, name: 'Gluten-free swaps', position: 1,
          swaps: [
            build(:lemon_drop_swap, from_text: 'gnocchi', to_text: 'potato starch gnocchi', position: 2),
            build(:lemon_drop_swap, from_text: 'pappardelle', to_text: 'gf pasta', position: 1)
          ])
      ]
      add_section(allergen_swap)

      expect(page).to match(%r{<div class="swaps-head">\s*<h2>allergen swaps</h2>\s*<img[^>]+stacked-bowls\.png})
      expect(response.body).to match(
        %r{<div class="swap-box">\s*<h3>Gluten-free swaps</h3>\s*<ul>\s*<li><b>pappardelle</b> → gf pasta</li>\s*<li><b>gnocchi</b> → potato starch gnocchi</li>\s*</ul>\s*<h3>Dairy-free swaps</h3>\s*<ul>\s*<li><b>parm</b> → nutritional yeast</li>}
      )
    end

    it 'renders Swap recipes in order, one ingredient and one step per line' do
      allergen_swap = build(:lemon_drop_allergen_swap_section)
      allergen_swap.swap_recipes = [
        build(:lemon_drop_swap_recipe, allergen_swap_section: allergen_swap, position: 2,
          title: 'Cashew cream', yield_label: 'Makes ~1 cup',
          ingredients: "1 c raw cashews\r\n½ c water\r\n\r\n", steps: "Soak cashews.\nBlend until silky.",
          use_for: 'Creamy pasta sauces, drizzling over bowls'),
        build(:lemon_drop_swap_recipe, allergen_swap_section: allergen_swap, position: 1,
          title: 'Cashew ricotta', yield_label: 'Makes ~1½ cups', use_for: nil)
      ]
      add_section(allergen_swap)

      expect(page).to match(%r{<div class="swaps-grid">\s*<div class="mini">\s*<h3>Cashew ricotta</h3>.*<div class="mini">\s*<h3>Cashew cream</h3>}m)
      expect(response.body).to match(
        %r{<h3>Cashew cream</h3>\s*<p class="makes">Makes ~1 cup</p>\s*<h4>What you need:</h4>\s*<ul>\s*<li>1 c raw cashews</li>\s*<li>½ c water</li>\s*</ul>\s*<h4>What you do:</h4>\s*<p>Soak cashews.</p>\s*<p>Blend until silky.</p>\s*<p class="use"><b>Use for:</b> Creamy pasta sauces, drizzling over bowls</p>\s*</div>}
      )
      expect(response.body.scan('class="use"').size).to eq(1)
    end

    it 'leaves out an empty swap box and the parts of a Swap recipe without a value' do
      allergen_swap = build(:lemon_drop_allergen_swap_section)
      allergen_swap.swap_recipes = [
        build(:lemon_drop_swap_recipe, allergen_swap_section: allergen_swap,
          yield_label: nil, ingredients: '', steps: nil, use_for: nil)
      ]
      add_section(allergen_swap)

      expect(page).to match(%r{<div class="mini">\s*<h3>Cashew cream</h3>\s*</div>})
      expect(response.body).not_to include('class="swap-box"', 'What you need:', 'What you do:', 'class="makes"')
    end

    it 'renders its disclaimer' do
      add_section(build(:lemon_drop_allergen_swap_section, disclaimer: 'check every label, every time.'))

      expect(page).to match(%r{</div>\s*<p class="disclaimer">check every label, every time.</p>})
    end

    it 'defaults the disclaimer to the standard allergen disclaimer' do
      add_section(LemonDrop::AllergenSwapSection.new(heading: 'allergen swaps'))

      expect(page).to include('<p class="disclaimer">these swaps are suggestions, not medical advice.')
    end

    it 'still renders the standard disclaimer when it has been cleared' do
      add_section(build(:lemon_drop_allergen_swap_section, disclaimer: ' '))

      expect(page).to include('<p class="disclaimer">these swaps are suggestions, not medical advice.')
    end
  end

  it 'renders several Grocery Lists and Allergen Swap Sections with unique anchors and a disclaimer on each' do
    add_section(build(:lemon_drop_grocery_list_section, heading: 'grocery one'), position: 1, theme: 'sage')
    add_section(build(:lemon_drop_allergen_swap_section, heading: 'swaps one'), position: 2, theme: 'sage')
    add_section(build(:lemon_drop_grocery_list_section, heading: 'grocery two'), position: 3)
    add_section(build(:lemon_drop_allergen_swap_section, heading: 'swaps two'), position: 4)

    expect(page).to match(/grocery one.*swaps one.*grocery two.*swaps two/m)
    expect(response.body).to include(
      '<div id="grocery-list" class="theme-sage">', '<div id="allergen-swap" class="theme-sage">',
      '<div id="grocery-list-2" class="theme-cream">', '<div id="allergen-swap-2" class="theme-cream">'
    )
    expect(response.body.scan('<p class="disclaimer">').size).to eq(2)
  end
end

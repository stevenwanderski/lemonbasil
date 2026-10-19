require 'spec_helper'

RSpec.describe LemonDrop::Issue do
  describe '#recipes' do
    let(:issue) { create(:lemon_drop_issue) }

    def add_recipes_section(position:, visible: true)
      create(:lemon_drop_section, issue: issue, position: position, visible: visible,
        sectionable: build(:lemon_drop_recipes_section)).sectionable
    end

    it 'returns every Recipe in page order: Section position, then Recipe position' do
      third = add_recipes_section(position: 3)
      first = add_recipes_section(position: 1)
      hidden = add_recipes_section(position: 2, visible: false)
      create(:lemon_drop_section, issue: issue, position: 0, sectionable: build(:lemon_drop_title_page_section))
      create(:lemon_drop_recipe, recipes_section: third, title: 'ragu', position: 1)
      create(:lemon_drop_recipe, recipes_section: first, title: 'gnocchi', position: 2)
      create(:lemon_drop_recipe, recipes_section: hidden, title: 'egg bake', position: 1)
      create(:lemon_drop_recipe, recipes_section: first, title: 'stew', position: 1)
      create(:lemon_drop_recipe, title: 'another issue’s soup')

      expect(issue.recipes.map(&:title)).to eq(['stew', 'gnocchi', 'egg bake', 'ragu'])
    end
  end
end

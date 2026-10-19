require 'spec_helper'

RSpec.describe 'Admin::LemonDrop::Sections', type: :request do
  let(:admin) { create(:user, email: 'admin@test.com', role: 'admin') }
  let(:issue) { create(:lemon_drop_issue) }

  def add_section(sectionable, **section_attributes)
    create(:lemon_drop_section, issue: issue, sectionable: sectionable, **section_attributes)
  end

  # A reference image as a form posts it.
  def image_upload(name)
    Rack::Test::UploadedFile.new(Rails.root.join('lemon-drop/images', name), Marcel::MimeType.for(name: name))
  end

  describe 'as a signed-in non-Admin' do
    let!(:section) { add_section(build(:lemon_drop_title_page_section), position: 1) }

    before { login_as(create(:user, email: 'staff@test.com', role: 'staff'), scope: :user) }

    {
      'add a Section' => -> { post admin_lemon_drop_issue_sections_path(issue), params: { section_type: 'IntroSection' } },
      'edit a Section' => -> { get edit_admin_lemon_drop_issue_section_path(issue, section) },
      'update a Section' => -> { patch admin_lemon_drop_issue_section_path(issue, section), params: { lemon_drop_section: { visible: '0' } } },
      'duplicate a Section' => -> { post duplicate_admin_lemon_drop_issue_section_path(issue, section) },
      'delete a Section' => -> { delete admin_lemon_drop_issue_section_path(issue, section) },
      'reorder Sections' => -> { patch reorder_admin_lemon_drop_issue_sections_path(issue), params: { section_ids: [section.id] } }
    }.each do |action, request|
      it "is sent to the clients page instead of being able to #{action}" do
        instance_exec(&request)

        expect(response).to redirect_to(admin_clients_path)
        expect(issue.sections.reload.map { |s| [s.id, s.visible] }).to eq([[section.id, true]])
      end
    end
  end

  describe 'as an Admin' do
    before { login_as(admin, scope: :user) }

    describe 'the Section list' do
      it 'shows every Section in page order with its type, heading and visibility, linking to its form' do
        hero = add_section(build(:lemon_drop_hero_section), position: 2, visible: false)
        title_page = add_section(build(:lemon_drop_title_page_section), position: 1)
        toc = add_section(build(:lemon_drop_table_of_contents_section), position: 3)

        get edit_admin_lemon_drop_issue_path(issue)

        rows = response.body.scan(%r{<li class="section-list__row( is-hidden)?" data-id="(\d+)">.*?<a href="([^"]+)">\s*<strong>([^<]+)</strong>\s*<span>([^<]*)</span>}m)
        expect(rows).to eq([
          [nil, title_page.id.to_s, edit_admin_lemon_drop_issue_section_path(issue, title_page), 'Title Page', 'the lemon drop'],
          [' is-hidden', hero.id.to_s, edit_admin_lemon_drop_issue_section_path(issue, hero), 'Hero', 'let’s cook'],
          [nil, toc.id.to_s, edit_admin_lemon_drop_issue_section_path(issue, toc), 'Table of Contents', 'this week’s drop']
        ])
      end
    end

    describe 'the Issue settings link' do
      it 'leads back to the Issue settings from a Section, and is selected on them' do
        section = add_section(build(:lemon_drop_title_page_section), position: 1)
        settings_link = %r{<a class="issue-settings-link( is-selected)?" href="#{edit_admin_lemon_drop_issue_path(issue)}">Issue settings</a>}

        get edit_admin_lemon_drop_issue_section_path(issue, section)
        expect(response.body[settings_link, 1]).to be_nil
        expect(response.body).to match(settings_link)

        get edit_admin_lemon_drop_issue_path(issue)
        expect(response.body[settings_link, 1]).to eq(' is-selected')
      end
    end

    describe 'hiding and showing a Section' do
      it 'hides a Section from its row, keeping it on the Issue, and shows it again' do
        section = add_section(build(:lemon_drop_title_page_section), position: 1)

        get edit_admin_lemon_drop_issue_path(issue)
        expect(response.body).to match(%r{<form class="button_to" method="post" action="#{admin_lemon_drop_issue_section_path(issue, section)}">.*?<button[^>]*type="submit">Hide</button>}m)

        patch admin_lemon_drop_issue_section_path(issue, section), params: { lemon_drop_section: { visible: '0' } },
          headers: { 'HTTP_REFERER' => edit_admin_lemon_drop_issue_path(issue) }

        expect(response).to redirect_to(edit_admin_lemon_drop_issue_path(issue))
        expect(section.reload.visible).to be(false)
        follow_redirect!
        expect(response.body).to match(%r{<button[^>]*type="submit">Show</button>})

        patch admin_lemon_drop_issue_section_path(issue, section), params: { lemon_drop_section: { visible: '1' } }

        expect(section.reload.visible).to be(true)
      end
    end

    describe 'the shared fields' do
      it 'are on every Section form and save' do
        LemonDrop::Section::TYPES.each.with_index(1) do |type, position|
          section = issue.insert_section(type.constantize.new, position: position)

          get edit_admin_lemon_drop_issue_section_path(issue, section)

          expect(response.body).to include('name="lemon_drop_section[theme]"', 'name="lemon_drop_section[anchor]"',
            'name="lemon_drop_section[show_in_toc]"', 'name="lemon_drop_section[toc_label]"')
        end

        section = issue.sections.first
        patch admin_lemon_drop_issue_section_path(issue, section), params: { lemon_drop_section: {
          theme: 'sage', anchor: 'cover', show_in_toc: '1', toc_label: 'the cover'
        } }

        expect(response).to redirect_to(edit_admin_lemon_drop_issue_section_path(issue, section))
        expect(section.reload).to have_attributes(theme: 'sage', anchor: 'cover', show_in_toc: true, toc_label: 'the cover')
      end

      it 'show an anchor already used on the page as an error' do
        add_section(build(:lemon_drop_grocery_list_section), position: 1, anchor: 'grocery')
        hero = add_section(build(:lemon_drop_hero_section), position: 2)

        patch admin_lemon_drop_issue_section_path(issue, hero), params: { lemon_drop_section: { anchor: 'grocery', toc_label: 'x' } }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include('Anchor has already been taken')
        expect(hero.reload).to have_attributes(anchor: 'hero', toc_label: nil)
      end
    end

    describe 'the Title Page form' do
      let(:section) { add_section(build(:lemon_drop_title_page_section), position: 1) }

      it 'saves the heading, tagline, date label and cover image' do
        get edit_admin_lemon_drop_issue_section_path(issue, section)
        expect(response.body).to include('enctype="multipart/form-data"', 'name="lemon_drop_section[sectionable_attributes][cover_image]"')

        patch admin_lemon_drop_issue_section_path(issue, section), params: { lemon_drop_section: { sectionable_attributes: {
          heading: 'the lemon drop!', tagline: 'meal plan', date_label: 'late oct', cover_image: image_upload('gnocchi.jpg')
        } } }

        expect(response).to redirect_to(edit_admin_lemon_drop_issue_section_path(issue, section))
        expect(section.sectionable.reload).to have_attributes(heading: 'the lemon drop!', tagline: 'meal plan', date_label: 'late oct')
        expect(section.sectionable.cover_image.filename.to_s).to eq('gnocchi.jpg')
        expect(LemonDrop::TitlePageSection.count).to eq(1)

        get edit_admin_lemon_drop_issue_section_path(issue, section)
        expect(response.body).to match(%r{<img[^>]+gnocchi\.jpg})
      end

      it 'shows the image rule errors and keeps the current image' do
        section.sectionable.update!(cover_image: uploaded_image('gnocchi.jpg'))
        fake = Rack::Test::UploadedFile.new(StringIO.new('just some text'), 'image/jpeg', original_filename: 'photo.jpg')

        patch admin_lemon_drop_issue_section_path(issue, section), params: { lemon_drop_section: { sectionable_attributes: {
          heading: 'renamed', cover_image: fake
        } } }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to match(%r{<ul class="form-errors">\s*<li>Cover image [^<]+</li>})
        expect(section.sectionable.reload).to have_attributes(heading: 'the lemon drop')
        expect(section.sectionable.cover_image.filename.to_s).to eq('gnocchi.jpg')
      end
    end

    describe 'the Hero form' do
      it 'saves the heading lines, both images and the focus, text and height presets' do
        section = add_section(build(:lemon_drop_hero_section), position: 1)

        get edit_admin_lemon_drop_issue_section_path(issue, section)
        expect(response.body).to include('<textarea', 'name="lemon_drop_section[sectionable_attributes][heading]"')
        expect(response.body.scan(%r{<option[^>]*value="(\w+)">([^<]+)</option>})).to include(
          %w[top Top], %w[center Center], %w[bottom Bottom], %w[light Light], %w[dark Dark], %w[medium Medium], %w[tall Tall]
        )

        patch admin_lemon_drop_issue_section_path(issue, section), params: { lemon_drop_section: { sectionable_attributes: {
          heading: "let’s\neat", background_image: image_upload('crispy-chickpeas.jpg'), overlay_image: image_upload('fork-knife.png'),
          background_focus: 'bottom', text_color: 'dark', min_height: 'medium'
        } } }

        hero = section.sectionable.reload
        expect(hero).to have_attributes(heading_lines: %w[let’s eat], background_focus: 'bottom', text_color: 'dark', min_height: 'medium')
        expect([hero.background_image.filename.to_s, hero.overlay_image.filename.to_s]).to eq(%w[crispy-chickpeas.jpg fork-knife.png])
      end
    end

    describe 'the Table of Contents form' do
      it 'saves the heading and says where its entries come from' do
        section = add_section(build(:lemon_drop_table_of_contents_section), position: 1)

        get edit_admin_lemon_drop_issue_section_path(issue, section)
        expect(response.body).to include('Entries come from the Sections marked “Show in the Table of Contents”')

        patch admin_lemon_drop_issue_section_path(issue, section), params: { lemon_drop_section: { sectionable_attributes: { heading: 'inside' } } }

        expect(section.sectionable.reload.heading).to eq('inside')
      end
    end

    describe 'the Intro form' do
      it 'saves the heading, sign-off, icon and the body, keeping only the editor’s formatting' do
        section = add_section(build(:lemon_drop_intro_section), position: 1)

        get edit_admin_lemon_drop_issue_section_path(issue, section)
        expect(response.body).to include('data-controller="rich-text"', 'name="lemon_drop_section[sectionable_attributes][body_html]"',
          'name="lemon_drop_section[sectionable_attributes][icon]"')

        patch admin_lemon_drop_issue_section_path(issue, section), params: { lemon_drop_section: { sectionable_attributes: {
          heading: 'hi there', signoff: 'xo beth', icon: image_upload('mortar.png'),
          body_html: '<h1>big</h1><p style="color: red">it’s <strong>soup</strong> <em>season</em>, <a href="https://x.co" onclick="steal()">read</a></p>' \
                     '<ul><li>one</li></ul><script>alert(1)</script><img src="x.png"><a href="javascript:alert(1)">bad</a>'
        } } }

        expect(response).to redirect_to(edit_admin_lemon_drop_issue_section_path(issue, section))
        intro = section.sectionable.reload
        expect(intro).to have_attributes(heading: 'hi there', signoff: 'xo beth')
        expect(intro.body_html).to eq(
          'big<p>it’s <strong>soup</strong> <em>season</em>, <a href="https://x.co">read</a></p><ul><li>one</li></ul><a>bad</a>'
        )
        expect(intro.icon.filename.to_s).to eq('mortar.png')
      end
    end

    describe 'the Outro form' do
      let(:section) { add_section(build(:lemon_drop_outro_section), position: 1) }

      def outro_params(**fields)
        { lemon_drop_section: { sectionable_attributes: fields } }
      end

      def kept(*images)
        images.map(&:signed_id)
      end

      it 'saves the heading, body and CTA, and adds and removes images in one save' do
        section.sectionable.update!(images: [uploaded_image('party-1.jpg'), uploaded_image('party-2.jpg')])
        party_1, party_2 = section.sectionable.images.to_a

        get edit_admin_lemon_drop_issue_section_path(issue, section)
        expect(response.body).to include('data-controller="rich-text"', 'multiple="multiple"')
        keep_boxes = Nokogiri::HTML(response.body).css('input[type=checkbox][name="lemon_drop_section[sectionable_attributes][images][]"]')
        expect(keep_boxes.map { |box| [box['value'], box['checked']] }).to eq(kept(party_1, party_2).map { |id| [id, 'checked'] })

        patch admin_lemon_drop_issue_section_path(issue, section), params: outro_params(
          heading: "let’s\nparty", body_html: '<p>book <b>now</b></p><h2>x</h2>', cta_label: 'email us', cta_url: 'mailto:hello@lemonandbasil.co',
          images: ['', *kept(party_2), image_upload('party-3.jpg')]
        )

        expect(response).to redirect_to(edit_admin_lemon_drop_issue_section_path(issue, section))
        outro = section.sectionable.reload
        expect(outro).to have_attributes(heading: "let’s\nparty", body_html: '<p>book <b>now</b></p>x',
          cta_label: 'email us', cta_url: 'mailto:hello@lemonandbasil.co')
        expect(outro.images.map { |image| image.filename.to_s }).to eq(%w[party-2.jpg party-3.jpg])
      end

      it 'refuses a seventh image and keeps the six already there' do
        section.sectionable.update!(images: Array.new(6) { uploaded_image('party-1.jpg') })

        patch admin_lemon_drop_issue_section_path(issue, section), params: outro_params(
          images: ['', *kept(*section.sectionable.images), image_upload('party-3.jpg')]
        )

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to match(%r{<ul class="form-errors">\s*<li>Images [^<]+</li>})
        expect(section.sectionable.reload.images.map { |image| image.filename.to_s }).to eq(['party-1.jpg'] * 6)
      end

      it 'refuses a CTA link that isn’t https or mailto' do
        patch admin_lemon_drop_issue_section_path(issue, section), params: outro_params(cta_label: 'go', cta_url: 'javascript:alert(1)')

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include('Button link must start with https:// or mailto:')
        expect(section.sectionable.reload.cta_url).to be_nil
      end
    end

    describe 'the Grocery List form' do
      let(:section) { add_section(build(:lemon_drop_grocery_list_section), position: 1) }
      let(:grocery_list) { section.sectionable }

      def groups_params(groups, **fields)
        { lemon_drop_section: { sectionable_attributes: { **fields, grocery_groups_attributes: groups.each_with_index.to_h { |group, index| [index.to_s, group] } } } }
      end

      it 'turns each group’s lines into its items in order, skipping blank lines, and shows the same lines again' do
        get edit_admin_lemon_drop_issue_section_path(issue, section)
        expect(response.body).to include('data-controller="nested-form"', 'name="lemon_drop_section[sectionable_attributes][icon]"')

        patch admin_lemon_drop_issue_section_path(issue, section), params: groups_params(
          [{ name: 'Produce', items_text: "1 delicata squash\r\n\r\n  2 lemons  \r\n1 bunch basil\n", position: '1' },
           { name: 'Pantry', items_text: 'tahini', position: '2' }],
          heading: 'shop this', icon: image_upload('lemon-slice.png')
        )

        expect(response).to redirect_to(edit_admin_lemon_drop_issue_section_path(issue, section))
        expect(grocery_list.reload.heading).to eq('shop this')
        expect(grocery_list.icon.filename.to_s).to eq('lemon-slice.png')
        expect(grocery_list.grocery_groups.map { |group| [group.name, group.grocery_items.map(&:text)] })
          .to eq([['Produce', ['1 delicata squash', '2 lemons', '1 bunch basil']], ['Pantry', ['tahini']]])

        get edit_admin_lemon_drop_issue_section_path(issue, section)
        # Rails starts every textarea with a newline, which browsers drop.
        textareas = Nokogiri::HTML(response.body).css('ol.nested-list textarea[name$="[items_text]"]').map { |area| area.text.delete_prefix("\n") }
        expect(textareas).to eq(["1 delicata squash\n2 lemons\n1 bunch basil", 'tahini'])
      end

      it 'renames, reorders and deletes groups in one save' do
        produce = create(:lemon_drop_grocery_group, grocery_list_section: grocery_list, name: 'Produce', position: 1,
          grocery_items: [build(:lemon_drop_grocery_item, text: 'lemons')])
        pantry = create(:lemon_drop_grocery_group, grocery_list_section: grocery_list, name: 'Pantry', position: 2)
        dairy = create(:lemon_drop_grocery_group, grocery_list_section: grocery_list, name: 'Dairy', position: 3)

        patch admin_lemon_drop_issue_section_path(issue, section), params: groups_params([
          { id: produce.id, name: 'Fruit & veg', items_text: 'lemons', position: '2' },
          { id: pantry.id, name: 'Pantry', items_text: '', position: '3', _destroy: '1' },
          { id: dairy.id, name: 'Dairy/Eggs', items_text: 'eggs', position: '1' }
        ])

        expect(grocery_list.reload.grocery_groups.map(&:name)).to eq(['Dairy/Eggs', 'Fruit & veg'])
        expect(LemonDrop::GroceryGroup.exists?(pantry.id)).to be(false)
        expect(produce.reload.grocery_items.map(&:text)).to eq(['lemons'])
      end
    end

    describe 'the Allergen Swap form' do
      let(:section) { add_section(build(:lemon_drop_allergen_swap_section), position: 1) }
      let(:allergen_swap) { section.sectionable }

      def swap_params(groups: [], recipes: [], **fields)
        indexed = ->(rows) { rows.each_with_index.to_h { |row, index| [index.to_s, row] } }
        { lemon_drop_section: { sectionable_attributes: {
          **fields, swap_groups_attributes: indexed.(groups), swap_recipes_attributes: indexed.(recipes)
        } } }
      end

      it 'reads swaps written with → or ->, in order, and shows them again with →' do
        patch admin_lemon_drop_issue_section_path(issue, section), params: swap_params(
          heading: "allergen\nswaps", disclaimer: 'ask your doctor.', icon: image_upload('bowl.png'),
          groups: [{ name: 'Dairy-free', position: '1', swaps_text: "parm → nutritional yeast\r\n\r\nbutter -> olive oil\nricotta→cashew ricotta (recipe below)" }]
        )

        expect(response).to redirect_to(edit_admin_lemon_drop_issue_section_path(issue, section))
        expect(allergen_swap.reload).to have_attributes(heading: "allergen\nswaps", disclaimer: 'ask your doctor.')
        expect(allergen_swap.icon.filename.to_s).to eq('bowl.png')
        expect(allergen_swap.swap_groups.sole.swaps.map { |swap| [swap.from_text, swap.to_text, swap.position] }).to eq([
          ['parm', 'nutritional yeast', 1], ['butter', 'olive oil', 2], ['ricotta', 'cashew ricotta (recipe below)', 3]
        ])

        get edit_admin_lemon_drop_issue_section_path(issue, section)
        textarea = Nokogiri::HTML(response.body).at_css('ol.nested-list textarea[name$="[swaps_text]"]')
        expect(textarea.text.delete_prefix("\n")).to eq("parm → nutritional yeast\nbutter → olive oil\nricotta → cashew ricotta (recipe below)")
      end

      it 'refuses a swap line without an arrow, naming the line, and keeps what was typed' do
        group = create(:lemon_drop_swap_group, allergen_swap_section: allergen_swap, name: 'Dairy-free',
          swaps: [build(:lemon_drop_swap, from_text: 'parm', to_text: 'nutritional yeast')])

        patch admin_lemon_drop_issue_section_path(issue, section), params: swap_params(
          groups: [{ id: group.id, name: 'Dairy-free', position: '1', swaps_text: "butter -> olive oil\n\noat milk instead of cream" }]
        )

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include('Dairy-free, line 3 (“oat milk instead of cream”) needs an arrow: from → to')
        expect(response.body).to include("butter -&gt; olive oil\n\noat milk instead of cream</textarea>")
        expect(group.reload.swaps.map(&:from_text)).to eq(['parm'])
      end

      it 'shows a refused save as the Admin left it: groups in the dragged order, removed ones still hidden' do
        nuts = create(:lemon_drop_swap_group, allergen_swap_section: allergen_swap, name: 'Nut-free', position: 1)
        dairy = create(:lemon_drop_swap_group, allergen_swap_section: allergen_swap, name: 'Dairy-free', position: 2)
        gluten = create(:lemon_drop_swap_group, allergen_swap_section: allergen_swap, name: 'Gluten-free', position: 3)

        patch admin_lemon_drop_issue_section_path(issue, section), params: swap_params(groups: [
          { id: nuts.id, name: 'Nut-free', swaps_text: 'no arrow here', position: '3' },
          { id: dairy.id, name: 'Dairy-free', swaps_text: '', position: '1', _destroy: '1' },
          { id: gluten.id, name: 'Gluten-free', swaps_text: '', position: '2' }
        ])

        expect(response).to have_http_status(:unprocessable_entity)
        rows = Nokogiri::HTML(response.body).css('ol.nested-list')[0].css('li.nested-row')
        expect(rows.map { |row| [row.at_css('input[name$="[name]"]')['value'], row['style']] })
          .to eq([['Dairy-free', 'display: none'], ['Gluten-free', nil], ['Nut-free', nil]])

        patch admin_lemon_drop_issue_section_path(issue, section), params: swap_params(groups: [
          { id: nuts.id, name: 'Nut-free', swaps_text: '', position: '1' },
          { id: dairy.id, name: 'Dairy-free', swaps_text: '', position: '2' },
          { id: gluten.id, name: 'Gluten-free', swaps_text: '', position: '3' }
        ])

        expect(allergen_swap.reload.swap_groups.map(&:name)).to eq(%w[Nut-free Dairy-free Gluten-free])
      end

      it 'adds, edits, reorders and deletes swap recipes in one save' do
        ricotta = create(:lemon_drop_swap_recipe, allergen_swap_section: allergen_swap, title: 'Cashew ricotta', position: 1)
        cream = create(:lemon_drop_swap_recipe, allergen_swap_section: allergen_swap, title: 'Cashew cream', position: 2)

        get edit_admin_lemon_drop_issue_section_path(issue, section)
        expect(response.body).to include('name="lemon_drop_section[sectionable_attributes][swap_recipes_attributes][NEW_RECORD][use_for]"')

        patch admin_lemon_drop_issue_section_path(issue, section), params: swap_params(recipes: [
          { id: ricotta.id, title: 'Cashew ricotta', position: '2' },
          { id: cream.id, title: 'Cashew cream', position: '3', _destroy: '1' },
          { title: 'Oat cream', yield_label: 'Makes 1 cup', ingredients: "1 c oats\n2 c water", steps: "Blend.\nStrain.",
            use_for: 'the soup', position: '1' }
        ])

        expect(allergen_swap.reload.swap_recipes.map(&:title)).to eq(['Oat cream', 'Cashew ricotta'])
        expect(allergen_swap.swap_recipes.first).to have_attributes(yield_label: 'Makes 1 cup', ingredient_lines: ['1 c oats', '2 c water'],
          step_lines: ['Blend.', 'Strain.'], use_for: 'the soup')
      end
    end

    describe 'the Menu Overview form' do
      let(:section) { add_section(build(:lemon_drop_menu_overview_section, category_order: %w[soup entree]), position: 1) }

      it 'lists all seven categories to drag, in the current order, and saves the order submitted' do
        get edit_admin_lemon_drop_issue_section_path(issue, section)

        expect(response.body).to include('data-controller="sortable"', 'name="lemon_drop_section[sectionable_attributes][icon]"')
        expect(response.body.scan(%r{<li class="category-order__row">.*?<input[^>]*name="lemon_drop_section\[sectionable_attributes\]\[category_order\]\[\]" value="(\w+)"}m).flatten)
          .to eq(%w[soup entree salad snack breakfast side dessert])

        patch admin_lemon_drop_issue_section_path(issue, section), params: { lemon_drop_section: { sectionable_attributes: {
          heading: 'the menu', icon: image_upload('mortar.png'), category_order: %w[breakfast entree soup salad snack side dessert]
        } } }

        menu = section.sectionable.reload
        expect(menu).to have_attributes(heading: 'the menu', category_order: %w[breakfast entree soup salad snack side dessert])
        expect(menu.icon.filename.to_s).to eq('mortar.png')
      end

      it 'refuses a category that Recipes don’t have' do
        patch admin_lemon_drop_issue_section_path(issue, section), params: { lemon_drop_section: { sectionable_attributes: {
          category_order: %w[entree brunch]
        } } }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include('Category order can only hold the Recipe categories, once each')
        expect(section.sectionable.reload.category_order).to eq(%w[soup entree])
      end
    end

    describe 'the image rule on the other forms' do
      {
        [:lemon_drop_hero_section, :background_image] => 'Background image',
        [:lemon_drop_hero_section, :overlay_image] => 'Overlay image',
        [:lemon_drop_menu_overview_section, :icon] => 'Icon'
      }.each do |(factory, image), label|
        it "refuses a fake #{label.downcase} with its error" do
          section = add_section(build(factory), position: 1)
          fake = Rack::Test::UploadedFile.new(StringIO.new('just some text'), 'image/jpeg', original_filename: 'photo.jpg')

          patch admin_lemon_drop_issue_section_path(issue, section), params: { lemon_drop_section: { sectionable_attributes: { image => fake } } }

          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.body).to match(%r{<ul class="form-errors">\s*<li>#{label} [^<]+</li>})
          expect(section.sectionable.reload.public_send(image)).not_to be_attached
        end
      end
    end

    describe 'reordering Sections' do
      let!(:title_page) { add_section(build(:lemon_drop_title_page_section), position: 1) }
      let!(:intro) { add_section(build(:lemon_drop_intro_section), position: 2) }
      let!(:outro) { add_section(build(:lemon_drop_outro_section), position: 3) }

      it 'stores the order posted by the drag as positions, top first' do
        get edit_admin_lemon_drop_issue_path(issue)
        expect(response.body).to include(
          %(<ol class="section-list" data-controller="sortable" data-sortable-url-value="#{reorder_admin_lemon_drop_issue_sections_path(issue)}" data-sortable-param-value="section_ids[]">)
        )

        patch reorder_admin_lemon_drop_issue_sections_path(issue), params: { section_ids: [outro.id, title_page.id, intro.id] }, as: :json

        expect(response).to have_http_status(:no_content)
        expect(issue.sections.reload.map { |section| [section, section.position] }).to eq([[outro, 1], [title_page, 2], [intro, 3]])
      end

      it "refuses a list that isn't exactly the Issue's Sections" do
        other = create(:lemon_drop_section, sectionable: build(:lemon_drop_intro_section))

        patch reorder_admin_lemon_drop_issue_sections_path(issue), params: { section_ids: [outro.id, title_page.id, other.id] }, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(issue.sections.reload).to eq([title_page, intro, outro])
      end
    end

    describe 'duplicating a Section' do
      it 'puts a copy right after it, with its own copy of each image' do
        title_page = add_section(build(:lemon_drop_title_page_section, cover_image: uploaded_image('chickpea-stew.jpg')),
          position: 1, theme: 'sage', show_in_toc: true, toc_label: 'cover')
        outro = add_section(build(:lemon_drop_outro_section), position: 2)

        get edit_admin_lemon_drop_issue_section_path(issue, title_page)
        expect(response.body).to match(%r{<form class="button_to" method="post" action="#{duplicate_admin_lemon_drop_issue_section_path(issue, title_page)}">})

        post duplicate_admin_lemon_drop_issue_section_path(issue, title_page)

        copy = issue.sections.reload.second
        expect(response).to redirect_to(edit_admin_lemon_drop_issue_section_path(issue, copy))
        expect(issue.sections.map(&:id)).to eq([title_page.id, copy.id, outro.id])
        expect(copy).to have_attributes(anchor: 'title-page-2', theme: 'sage', show_in_toc: true, toc_label: 'cover', position: 2)
        expect(copy.sectionable).to have_attributes(heading: 'the lemon drop', tagline: 'your weekly meal plan')
        expect(copy.sectionable_id).not_to eq(title_page.sectionable_id)
        expect(copy.sectionable.cover_image.filename.to_s).to eq('chickpea-stew.jpg')
        expect(copy.sectionable.cover_image.blob).not_to eq(title_page.sectionable.cover_image.blob)

        delete admin_lemon_drop_issue_section_path(issue, copy)

        expect(title_page.sectionable.reload.cover_image.blob.service.exist?(title_page.sectionable.cover_image.key)).to be(true)
      end

      it 'copies everything inside, giving copied Recipes their own slugs' do
        recipes_section = build(:lemon_drop_recipes_section, heading: 'this week')
        section = add_section(recipes_section, position: 1)
        create(:lemon_drop_recipe, recipes_section: recipes_section, title: 'chickpea stew', hero_image: uploaded_image('chickpea-stew.jpg'))
        grocery_list = add_section(build(:lemon_drop_grocery_list_section), position: 2)
        create(:lemon_drop_grocery_group, grocery_list_section: grocery_list.sectionable, name: 'Pantry',
          grocery_items: [build(:lemon_drop_grocery_item, text: 'tahini')])

        post duplicate_admin_lemon_drop_issue_section_path(issue, section)
        post duplicate_admin_lemon_drop_issue_section_path(issue, grocery_list)

        sections = issue.sections.reload.to_a
        expect(sections.map(&:anchor)).to eq(%w[recipes recipes-2 grocery-list grocery-list-2])
        recipe_copy = sections.second.sectionable.recipes.sole
        expect(recipe_copy).to have_attributes(title: 'chickpea stew', slug: 'chickpea-stew-2', category: 'soup')
        expect(recipe_copy.ingredient_groups.flat_map { |group| group.ingredients.map(&:text) }).to eq(['4 garlic cloves, thinly sliced'])
        expect(recipe_copy.steps.map(&:body)).to eq(['Heat a generous pour of olive oil.'])
        expect(recipe_copy.hero_image).to be_attached
        expect(sections.fourth.sectionable.grocery_groups.map { |group| [group.name, group.grocery_items.map(&:text)] })
          .to eq([['Pantry', ['tahini']]])
        expect(LemonDrop::Recipe.count).to eq(2)
      end
    end

    describe 'deleting a Section' do
      it 'deletes the Section and closes the gap it leaves' do
        title_page = add_section(build(:lemon_drop_title_page_section), position: 1)
        hero = add_section(build(:lemon_drop_hero_section), position: 2)
        outro = add_section(build(:lemon_drop_outro_section), position: 3)

        get edit_admin_lemon_drop_issue_section_path(issue, hero)
        expect(response.body).to include('data-turbo-confirm="Delete this Hero Section?"')

        delete admin_lemon_drop_issue_section_path(issue, hero)

        expect(response).to redirect_to(edit_admin_lemon_drop_issue_path(issue))
        expect(issue.sections.reload.map { |section| [section, section.position] }).to eq([[title_page, 1], [outro, 2]])
        expect(LemonDrop::HeroSection.exists?(hero.sectionable_id)).to be(false)
      end

      it 'deletes a Recipes Section along with its Recipes, after saying how many' do
        recipes_section = build(:lemon_drop_recipes_section)
        section = add_section(recipes_section, position: 1)
        create_list(:lemon_drop_recipe, 2, recipes_section: recipes_section)

        get edit_admin_lemon_drop_issue_section_path(issue, section)
        expect(response.body).to include('data-turbo-confirm="Delete this Recipes Section and its 2 Recipes?"')

        delete admin_lemon_drop_issue_section_path(issue, section)

        expect(issue.sections.reload).to be_empty
        expect(LemonDrop::Recipe.count).to eq(0)
      end
    end

    describe 'adding a Section' do
      it 'offers every Section type and every position' do
        add_section(build(:lemon_drop_title_page_section), position: 1)

        get edit_admin_lemon_drop_issue_path(issue)

        expect(response.body.scan(%r{<option value="(\w+Section)">([^<]+)</option>})).to eq([
          %w[TitlePageSection Title\ Page], %w[IntroSection Intro], ['TableOfContentsSection', 'Table of Contents'],
          %w[HeroSection Hero], ['MenuOverviewSection', 'Menu Overview'], %w[RecipesSection Recipes],
          ['GroceryListSection', 'Grocery List'], ['AllergenSwapSection', 'Allergen Swap'], %w[OutroSection Outro]
        ])
        expect(response.body.scan(%r{<option (?:selected="selected" )?value="(\d+)">([^<]+)</option>})).to eq([
          ['1', 'At the top'], ['2', 'After Title Page: the lemon drop']
        ])
      end

      it 'inserts the new Section at the chosen position, any number of times, and opens its form' do
        title_page = add_section(build(:lemon_drop_title_page_section), position: 1)
        outro = add_section(build(:lemon_drop_outro_section), position: 2)

        post admin_lemon_drop_issue_sections_path(issue), params: { section_type: 'HeroSection', position: 2 }
        first_hero = issue.sections.reload.second
        post admin_lemon_drop_issue_sections_path(issue), params: { section_type: 'HeroSection', position: 2 }

        sections = issue.sections.reload.to_a
        expect(response).to redirect_to(edit_admin_lemon_drop_issue_section_path(issue, sections.second))
        expect(sections.map(&:sectionable_type)).to eq(%w[LemonDrop::TitlePageSection LemonDrop::HeroSection LemonDrop::HeroSection LemonDrop::OutroSection])
        expect(sections.map(&:position)).to eq([1, 2, 3, 4])
        expect(sections.values_at(0, 2, 3)).to eq([title_page, first_hero, outro])
        expect(sections.map(&:anchor)).to eq(%w[title-page hero-2 hero outro])
      end

      it 'refuses an unknown Section type' do
        post admin_lemon_drop_issue_sections_path(issue), params: { section_type: 'User', position: 1 }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(issue.sections.count).to eq(0)
      end
    end
  end
end

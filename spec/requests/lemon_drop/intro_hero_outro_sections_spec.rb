require 'spec_helper'

RSpec.describe 'LemonDrop Intro, Hero and Outro Sections', type: :request do
  let(:issue) { create(:lemon_drop_issue, :published) }

  def add_section(sectionable, **section_attributes)
    create(:lemon_drop_section, issue: issue, sectionable: sectionable, **section_attributes)
  end

  def page
    get lemon_drop_issue_path(issue.slug)
    response.body
  end

  describe 'Intro' do
    it 'renders its heading, body, sign-off and icon' do
      add_section(build(:lemon_drop_intro_section, icon: uploaded_image('lemon-slice.png')))

      expect(page).to include('hello!', '<p>it’s mid october and i’m fully in it.</p>', 'xx beth')
      expect(response.body).to match(%r{<img class="icon"[^>]+lemon-slice\.png})
    end

    it 'leaves out the icon and sign-off when there are none' do
      add_section(build(:lemon_drop_intro_section, signoff: nil))

      expect(page).not_to include('class="icon"', 'class="sig"')
    end
  end

  describe 'Hero' do
    it 'renders each heading line as a row of large text, with the overlay image after the first' do
      add_section(build(:lemon_drop_hero_section, overlay_image: uploaded_image('fork-knife.png')))

      expect(page).to match(%r{<h2>let’s</h2>\s*<img[^>]+fork-knife\.png[^>]*>\s*<h2>cook</h2>})
    end

    it 'uses the background image, focus, text color and height' do
      add_section(build(:lemon_drop_hero_section,
        background_image: uploaded_image('crispy-chickpeas.jpg'),
        background_focus: 'bottom', text_color: 'dark', min_height: 'medium'))

      expect(page).to include('class="hero hero-medium hero-text-dark"', 'background-position: center bottom;')
      expect(response.body).to match(%r{background-image: url\([^)]+crispy-chickpeas\.jpg\)})
    end

    it 'has no background style without an image' do
      add_section(build(:lemon_drop_hero_section))

      expect(page).to include('class="hero hero-tall hero-text-light"')
      expect(response.body).not_to include('background-image')
    end
  end

  describe 'Outro' do
    it 'renders its heading, body, photo grid and CTA' do
      add_section(build(:lemon_drop_outro_section,
        images: [uploaded_image('party-1.jpg'), uploaded_image('party-2.jpg'), uploaded_image('party-3.jpg')],
        cta_label: 'reach out', cta_url: 'mailto:hello@lemonandbasil.co'))

      expect(page).to include('book your holiday party!', 'reach out now to talk deets, dates &amp; pricing.')
      expect(response.body.scan(%r{<img[^>]+party-\d\.jpg}).size).to eq(3)
      expect(response.body).to include('<a class="cta" href="mailto:hello@lemonandbasil.co">reach out</a>')
    end

    it 'leaves out the photo grid and CTA when there are none' do
      add_section(build(:lemon_drop_outro_section))

      expect(page).not_to include('outro-photos', 'class="cta"')
    end
  end

  describe 'rich text' do
    let(:dirty_html) do
      '<p onclick="steal()">kept <strong>bold</strong> <em>italic</em> <a href="https://x.co" style="color:red">link</a></p>' \
        '<ul><li>item</li></ul><ol><li>step</li></ol>' \
        '<script>alert("x")</script><style>body{}</style><h1>big</h1><img src="x.png"><a href="javascript:alert(1)">bad</a>'
    end

    it 'keeps paragraphs, bold, italic, links and lists, and strips everything else' do
      add_section(build(:lemon_drop_intro_section, body_html: dirty_html))
      add_section(build(:lemon_drop_outro_section, body_html: dirty_html))

      body = page
      expect(body.scan('<p>kept <strong>bold</strong> <em>italic</em> <a href="https://x.co">link</a></p>').size).to eq(2)
      expect(body.scan('<ul><li>item</li></ul><ol><li>step</li></ol>').size).to eq(2)
      expect(body).not_to include('onclick', 'style="color:red"', '<script>alert', '<style>body', '<h1>', 'x.png', 'javascript:')
    end
  end

  it 'renders any number of these Sections in any order, with unique anchors' do
    add_section(build(:lemon_drop_outro_section, heading: 'outro one'), position: 1)
    add_section(build(:lemon_drop_hero_section, heading: 'hero one'), position: 2)
    add_section(build(:lemon_drop_intro_section, heading: 'intro one'), position: 3)
    add_section(build(:lemon_drop_hero_section, heading: 'hero two'), position: 4)
    add_section(build(:lemon_drop_outro_section, heading: 'outro two'), position: 5)

    expect(page).to match(/outro one.*hero one.*intro one.*hero two.*outro two/m)
    expect(response.body).to include('id="outro"', 'id="hero"', 'id="intro"', 'id="hero-2"', 'id="outro-2"')
  end
end

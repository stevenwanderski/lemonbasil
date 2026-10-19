require 'spec_helper'

describe LemonDrop::OutroSection do
  it 'accepts https and mailto CTA links' do
    expect(build(:lemon_drop_outro_section, cta_label: 'book', cta_url: 'https://lemonandbasil.co/parties')).to be_valid
    expect(build(:lemon_drop_outro_section, cta_label: 'reach out', cta_url: 'mailto:hello@lemonandbasil.co')).to be_valid
  end

  it 'rejects other CTA link schemes' do
    %w[http://lemonandbasil.co javascript:alert(1) /parties].each do |url|
      outro = build(:lemon_drop_outro_section, cta_label: 'book', cta_url: url)

      expect(outro).not_to be_valid
      expect(outro.errors[:cta_url]).to include('must start with https:// or mailto:')
    end
  end

  it 'needs a label when there is a CTA link' do
    expect(build(:lemon_drop_outro_section, cta_url: 'https://lemonandbasil.co')).not_to be_valid
  end

  it 'allows at most six images' do
    outro = build(:lemon_drop_outro_section, images: Array.new(7) { uploaded_image('party-1.jpg') })

    expect(outro).not_to be_valid
  end
end

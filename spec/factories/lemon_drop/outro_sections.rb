FactoryBot.define do
  factory :lemon_drop_outro_section, class: 'LemonDrop::OutroSection' do
    heading { 'book your holiday party!' }
    body_html { '<p>reach out now to talk deets, dates &amp; pricing.</p>' }
  end
end

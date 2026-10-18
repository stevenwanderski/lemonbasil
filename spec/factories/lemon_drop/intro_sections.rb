FactoryBot.define do
  factory :lemon_drop_intro_section, class: 'LemonDrop::IntroSection' do
    heading { 'hello!' }
    body_html { '<p>it’s mid october and i’m fully in it.</p>' }
    signoff { 'xx beth' }
  end
end

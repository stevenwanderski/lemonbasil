require 'spec_helper'
require 'rake'

RSpec.describe 'lemon_drop:purge_unattached_uploads' do
  include ActiveSupport::Testing::TimeHelpers

  before(:all) { Rails.application.load_tasks if Rake::Task.tasks.none? { |task| task.name == 'lemon_drop:purge_unattached_uploads' } }

  def upload(name)
    ActiveStorage::Blob.create_and_upload!(io: File.open(Rails.root.join('lemon-drop/images', name)), filename: name)
  end

  def run
    Rake::Task['lemon_drop:purge_unattached_uploads'].execute
  end

  it 'deletes a day-old upload that was never attached, along with any preview sizes made from it' do
    orphan = travel_to(2.days.ago) { upload('lemon-slice.png') }
    orphan.variant(resize_to_limit: [100, 100]).processed

    run

    expect(ActiveStorage::Blob.exists?(orphan.id)).to be(false)
    expect(ActiveStorage::Blob.service.exist?(orphan.key)).to be(false)
  end

  it 'keeps attached images and uploads less than a day old' do
    section = create(:lemon_drop_section, issue: create(:lemon_drop_issue), sectionable: build(:lemon_drop_intro_section))
    attached = travel_to(2.days.ago) { upload('lemon-slice.png') }
    section.sectionable.update!(icon: attached.signed_id)
    recent = upload('bowl.png')

    run

    expect(ActiveStorage::Blob.where(id: [attached.id, recent.id]).count).to eq(2)
  end
end

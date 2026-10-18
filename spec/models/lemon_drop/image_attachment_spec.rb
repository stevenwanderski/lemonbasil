require 'spec_helper'

# Lemon drop models declare their images like this test record: the type is
# checked from the file's contents, and pages show only variants, saved with
# metadata (including location) stripped. Originals are never linked.
class LemonDropImageTestRecord < ApplicationRecord
  self.table_name = 'lemon_drop_image_test_records'

  has_one_attached :cover_image do |attachable|
    attachable.variant :hero, resize_to_limit: [1600, 1600], saver: { strip: true }
  end
  has_many_attached :photos

  validates :cover_image, :photos,
    content_type: { in: %w[image/jpeg image/png image/webp], spoofing_protection: true },
    size: { less_than_or_equal_to: 15.megabytes }
end

describe 'Lemon drop image attachments' do
  before(:all) do
    ActiveRecord::Base.connection.create_table(:lemon_drop_image_test_records, force: true)
    LemonDropImageTestRecord.reset_column_information
  end

  after(:all) do
    ActiveRecord::Base.connection.drop_table(:lemon_drop_image_test_records)
  end

  # Keep blob analysis out of background threads while the DB is cleaned.
  around do |example|
    adapter = ActiveJob::Base.queue_adapter
    ActiveJob::Base.queue_adapter = :test
    example.run
    ActiveJob::Base.queue_adapter = adapter
  end

  def image_bytes(format, width: 40, height: 30)
    path = Rails.root.join('tmp', "lemon_drop_test_image#{format}").to_s
    MiniMagick.convert { |convert| convert.size("#{width}x#{height}").xc('gray') << path }
    File.binread(path)
  ensure
    FileUtils.rm_f(path)
  end

  def image_from(bytes)
    MiniMagick::Image.read(bytes)
  end

  # A JPEG carrying a minimal EXIF block with a GPS latitude of 41° 52' N.
  def jpeg_with_gps
    tiff = "MM\x00\x2A".b + [8].pack('N')
    tiff += [1].pack('n') + [0x8825, 4, 1, 26].pack('nnNN') + [0].pack('N')
    tiff += [2].pack('n') +
            [0x0001, 2, 2].pack('nnN') + "N\x00\x00\x00".b +
            [0x0002, 5, 3, 56].pack('nnNN') + [0].pack('N')
    tiff += [41, 1, 52, 1, 0, 1].pack('N*')
    exif = "Exif\x00\x00".b + tiff

    jpeg = image_bytes('.jpg')
    jpeg.byteslice(0, 2) + "\xFF\xE1".b + [exif.bytesize + 2].pack('n') + exif + jpeg.byteslice(2..)
  end

  def gps_fields(bytes)
    image_from(bytes).exif.keys.grep(/gps/i)
  end

  # What a form submission hands the model.
  def upload(bytes, filename, content_type = 'image/jpeg')
    file = Tempfile.new(['upload', File.extname(filename)], binmode: true)
    file.write(bytes)
    file.rewind
    ActionDispatch::Http::UploadedFile.new(tempfile: file, filename: filename, type: content_type)
  end

  describe 'accepted images' do
    { '.jpg' => 'image/jpeg', '.png' => 'image/png', '.webp' => 'image/webp' }.each do |format, content_type|
      it "stores a #{format} image" do
        record = LemonDropImageTestRecord.create!(cover_image: upload(image_bytes(format), "photo#{format}", content_type))

        expect(record.cover_image).to be_attached
      end
    end

    it 'stores several images on a many-image attachment' do
      record = LemonDropImageTestRecord.create!(photos: [upload(image_bytes('.jpg'), 'a.jpg'), upload(image_bytes('.png'), 'b.png', 'image/png')])

      expect(record.photos.count).to eq(2)
    end
  end

  describe 'variants' do
    it 'resizes the image' do
      record = LemonDropImageTestRecord.create!(cover_image: upload(image_bytes('.jpg', width: 2000, height: 1000), 'photo.jpg'))
      hero = image_from(record.cover_image.variant(:hero).processed.download)

      expect([hero.width, hero.height]).to eq([1600, 800])
    end

    it 'strips location data' do
      bytes = jpeg_with_gps
      expect(gps_fields(bytes)).not_to be_empty

      record = LemonDropImageTestRecord.create!(cover_image: upload(bytes, 'photo.jpg'))

      expect(gps_fields(record.cover_image.variant(:hero).processed.download)).to be_empty
    end
  end

  describe 'rejected files' do
    it 'rejects a non-image renamed to .jpg' do
      record = LemonDropImageTestRecord.new(cover_image: upload('just some text', 'photo.jpg'))

      expect(record).not_to be_valid
      expect(record.errors[:cover_image]).not_to be_empty
    end

    it 'rejects image types other than JPEG, PNG and WebP' do
      record = LemonDropImageTestRecord.new(cover_image: upload(image_bytes('.gif'), 'photo.gif', 'image/gif'))

      expect(record).not_to be_valid
      expect(record.errors[:cover_image]).not_to be_empty
    end

    it 'rejects files over 15 MB' do
      record = LemonDropImageTestRecord.new(cover_image: upload(image_bytes('.jpg') + ("\x00" * 15.megabytes), 'photo.jpg'))

      expect(record).not_to be_valid
      expect(record.errors[:cover_image]).not_to be_empty
    end

    it 'rejects a bad file among several images' do
      record = LemonDropImageTestRecord.new(photos: [upload(image_bytes('.jpg'), 'a.jpg'), upload('nope', 'b.png', 'image/png')])

      expect(record).not_to be_valid
      expect(record.errors[:photos]).not_to be_empty
    end
  end
end

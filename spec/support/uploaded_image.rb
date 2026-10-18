# Builds what a form submission hands the model for one of the reference
# images in lemon-drop/images. Attaching a raw IO instead fails the
# content-type spoofing check (see HAP-16).
module UploadedImage
  def uploaded_image(name)
    tempfile = Tempfile.new(name, binmode: true)
    IO.copy_stream(Rails.root.join('lemon-drop/images', name).to_s, tempfile)
    tempfile.rewind
    ActionDispatch::Http::UploadedFile.new(tempfile: tempfile, filename: name, type: Marcel::MimeType.for(name: name))
  end
end

RSpec.configure do |config|
  config.include UploadedImage
end

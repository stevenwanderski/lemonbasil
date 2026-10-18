# Images are processed with ImageMagick, not libvips

Rails 7 defaults Active Storage's variant processor to libvips, but we use ImageMagick through `mini_magick` (`config.active_storage.variant_processor = :mini_magick`). ImageMagick is what the team has always used with CarrierWave and Paperclip, it's already installed locally, and Heroku's heroku-24 stack ships it. Homebrew has no prebuilt libvips for the macOS version we develop on, so installing it meant compiling LLVM and other dependencies from source for the best part of an hour.

## Consequences

- ImageMagick loads the whole image into memory while resizing (a couple of hundred MB for a 12-megapixel photo), where libvips streams it. At a few admin uploads a week that's fine on a web dyno; if uploads become heavy, switching back is the one config line plus making sure libvips is installed.
- Variants use `saver: { strip: true }`, which ImageMagick applies as `-strip`, so readers never get EXIF location data (ADR 0005).

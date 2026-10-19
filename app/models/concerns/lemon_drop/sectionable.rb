module LemonDrop::Sectionable
  extend ActiveSupport::Concern

  included do
    has_one :section, as: :sectionable, touch: true
  end

  # Whether the public page leaves this Section out even though it's visible,
  # because it has nothing to show. Types that can come up empty override it.
  def skipped?
    false
  end
end

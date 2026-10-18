module LemonDrop::Sectionable
  extend ActiveSupport::Concern

  included do
    has_one :section, as: :sectionable, touch: true
  end
end

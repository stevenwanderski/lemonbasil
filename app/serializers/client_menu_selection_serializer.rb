class ClientMenuSelectionSerializer < ActiveModel::Serializer
  attributes :id
  has_one :client_menu_item
end

class ClientMenuItemSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :cost, :quantity
  has_one :client_menu_category
end

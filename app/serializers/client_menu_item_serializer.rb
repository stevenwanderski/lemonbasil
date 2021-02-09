class ClientMenuItemSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :cost, :quantity
end

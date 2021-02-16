class ClientMenuCategorySerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :weight
end

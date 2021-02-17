class ClientMenuSubmissionSerializer < ActiveModel::Serializer
  attributes :id, :message, :created_at
  has_many :client_menu_selections
end

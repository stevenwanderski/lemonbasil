class ClientMenuSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  attributes :id, :client_full_name, :url

  def client_full_name
    object.client.full_name
  end

  def url
    edit_admin_client_menu_path(object)
  end
end

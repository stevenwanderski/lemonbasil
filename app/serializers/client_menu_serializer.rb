class ClientMenuSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  attributes :id,
    :client_full_name,
    :due_at,
    :slug_url,
    :url

  def client_full_name
    object.client.full_name
  end

  def slug_url
    "#{ENV['APP_HOST']}/menus/#{object.slug}"
  end

  def url
    admin_client_menu_path(object)
  end
end

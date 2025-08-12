class ClientMenuMailerPreview < ActionMailer::Preview
  def client_submission
    client_menu = ClientMenu.find(3956)

    ClientMenuMailer.with(client_menu: client_menu).client_submission
  end

  def send_to_client
    client_menu = ClientMenu.find(15)

    ClientMenuMailer.with(client_menu: client_menu).send_to_client
  end
end

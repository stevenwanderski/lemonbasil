class ClientMenuMailerPreview < ActionMailer::Preview
  def client_submission
    client_menu = ClientMenu.find(15)

    ClientMenuMailer.with(client_menu: client_menu).client_submission
  end
end

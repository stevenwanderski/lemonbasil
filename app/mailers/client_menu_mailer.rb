class ClientMenuMailer < ApplicationMailer
  def client_submission
    @client_menu = params[:client_menu]
    @submission = @client_menu.newest_submission

    mail(
      from: 'Lemon&Basil <hello@lemonandbasil.co>',
      to: "#{@client_menu.client.full_name} <#{@client_menu.client.email}>",
      bcc: "Birdie <lemonandbasil.co@gmail.com>",
      subject: "Menu Submission: #{@client_menu.client.full_name} - #{@client_menu.job_date.strftime("%m/%d/%Y")}"
    )
  end
end

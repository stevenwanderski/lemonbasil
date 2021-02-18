class ClientMenuMailer < ApplicationMailer
  def client_submission
    @client_menu = params[:client_menu]

    mail(
      from: 'Lemon&Basil <hello@lemonandbasil.co>',
      to: "#{@client_menu.client.full_name} <client@client.com>",
      subject: "Menu Submission for Meal Prep: #{@client_menu.job_date.strftime("%m/%d/%Y")}"
    )
  end
end

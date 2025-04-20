class ClientMenuMailer < ApplicationMailer
  def client_submission
    @client_menu = params[:client_menu]
    @submission = @client_menu.newest_submission

    bcc = [
      'Beth Hackett <beth@lemonandbasil.co>'
    ]

    if @client_menu.is_kat?
      bcc << 'Kat Szymanski <info@lemonandbasil.co>'
    end

    mail(
      from: 'Lemon&Basil Menu Submission <hello@lemonandbasil.co>',
      to: "#{@client_menu.client.full_name} <#{@client_menu.client.email}>",
      bcc: bcc,
      subject: "Menu Submission: #{@client_menu.client.full_name} - #{@client_menu.job_date.strftime("%m/%d/%Y")}"
    )
  end

  def send_to_client
    @client_menu = params[:client_menu]

    mail(
      from: 'Lemon&Basil Menu Submission <hello@lemonandbasil.co>',
      to: "#{@client_menu.client.full_name} <#{@client_menu.client.email}>",
      subject: "New Menu: #{@client_menu.client.full_name} - #{@client_menu.job_date.strftime("%m/%d/%Y")}"
    )
  end
end

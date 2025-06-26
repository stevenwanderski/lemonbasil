class ClientMenuMailer < ApplicationMailer
  def client_submission
    @client_menu = params[:client_menu]
    @submission = @client_menu.newest_submission

    bcc = [
      'beth@lemonandbasil.co',
      @client_menu.user.email
    ]

    if @client_menu.is_kat?
      bcc << 'kat@lemonandbasil.co'
    end

    mail(
      from: 'Lemon&Basil Menu Submission <hello@lemonandbasil.co>',
      to: "#{@client_menu.client.full_name} <#{@client_menu.client.email}>",
      bcc: bcc.uniq,
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

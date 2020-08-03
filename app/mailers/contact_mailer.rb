class ContactMailer < ApplicationMailer
  def success
    @contact = params[:contact]

    mail(
      from: 'Birdie <hello@lemonandbasil.co>',
      to: 'Steven <wandoledzep@gmail.com>',
      subject: 'New contact message from lemonandbasil.co'
    )
  end
end

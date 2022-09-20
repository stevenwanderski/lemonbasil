class ContactMailer < ApplicationMailer
  def success
    @contact = params[:contact]

    mail(
      from: 'L&B New Contact <hello@lemonandbasil.co>',
      to: 'Birdie <lemonandbasil.co@gmail.com>',
      subject: 'New contact message from lemonandbasil.co'
    )
  end
end

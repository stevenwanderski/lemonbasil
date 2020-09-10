class ContactMailer < ApplicationMailer
  def success
    @contact = params[:contact]

    mail(
      from: 'Lemon&Basil <hello@lemonandbasil.co>',
      to: 'Birdie <steven.wanderski@gmail.com>',
      subject: 'New contact message from lemonandbasil.co'
    )
  end
end

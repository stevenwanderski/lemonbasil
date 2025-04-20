class ContactMailer < ApplicationMailer
  def success
    @contact = params[:contact]

    mail(
      from: 'Lemon&Basil New Contact <hello@lemonandbasil.co>',
      to: 'Beth Hackett <beth@lemonandbasil.co>',
      subject: 'New contact message from lemonandbasil.co'
    )
  end
end

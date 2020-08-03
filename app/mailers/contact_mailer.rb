class ContactMailer < ApplicationMailer
  def success
    @contact = params[:contact]

    mail(to: 'wandoledzep@gmail.com', subject: 'Well, a new contact')
  end
end

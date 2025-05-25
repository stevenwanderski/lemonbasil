class WaitlistMailer < ApplicationMailer
  def success
    @waitlist = params[:waitlist]

    mail(
      from: 'Lemon&Basil New Waitlist <hello@lemonandbasil.co>',
      to: 'Birdie <lemonandbasil.co@gmail.com>',
      subject: "Waitlist: #{@waitlist.start_date}"
    )
  end
end
class WaitlistMailerPreview < ActionMailer::Preview
  def success
    waitlist = Waitlist.last

    WaitlistMailer.with(waitlist: waitlist).success
  end
end

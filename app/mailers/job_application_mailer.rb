class JobApplicationMailer < ApplicationMailer
  def success
    @job_application = params[:job_application]

    mail(
      from: 'Lemon&Basil New Job Application <hello@lemonandbasil.co>',
      to: 'Steven <steven.wanderski@gmail.com>',
      subject: 'New Job Application'
    )
  end
end

# to: 'Birdie <lemonandbasil.co@gmail.com>'
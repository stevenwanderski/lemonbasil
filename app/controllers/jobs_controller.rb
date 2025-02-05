class JobsController < ApplicationController
  before_action :validate_email!, only: [:create]

  def new
    @job_application = JobApplication.new
  end

  def create
    @job_application = JobApplication.new(job_params)

    if @job_application.save
      Akismet.api_key = 'c53388e9bb4e'
      Akismet.app_url = 'https://lemonandbsil.co'

      is_spam = Akismet.spam?(
        request.ip,
        request.user_agent,
        text: @job_application.message
      )

      if !is_spam
        JobApplicationMailer.with(job_application: @job_application).success.deliver
      end

      redirect_to job_apply_success_path
    else
      flash.now[:error] = "Oops! That didn't work. Try again?"
      render :new
    end
  end

  def success
  end

  private

  def job_params
    params.require(:job_application).permit(:name, :email, :phone, :message, :position)
  end

  def validate_email!
    if !Contact.valid_email?(job_params[:email])
      redirect_to job_apply_success_path
    end
  end
end

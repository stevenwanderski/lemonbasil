class WaitlistController < ApplicationController
  before_action :validate_email!, only: [:create]

  def new
    @waitlist = Waitlist.new
    @page_title = 'Lemon&Basil | Waitlist'
  end

  def create
    @waitlist = Waitlist.new(waitlist_params)

    if @waitlist.save
      Akismet.api_key = 'c53388e9bb4e'
      Akismet.app_url = 'https://lemonandbsil.co'

      is_spam = Akismet.spam?(
        request.ip,
        request.user_agent,
        text: @waitlist.message
      )

      if !is_spam
        WaitlistMailer.with(waitlist: @waitlist).success.deliver
      end

      redirect_to waitlist_success_path
    else
      flash.now[:error] = "Oops! That didn't work. Try again?"
      render :new
    end
  end

  def success
    @page_title = 'Lemon&Basil | Waitlist Success'
  end

  private

  def waitlist_params
    params.require(:waitlist).permit(:name, :email, :neighborhood, :message, :start_date)
  end

  def validate_email!
    if !Contact.valid_email?(waitlist_params[:email])
      redirect_to waitlist_success_path
    end
  end
end

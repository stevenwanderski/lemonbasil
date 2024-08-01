class ContactController < ApplicationController
  before_action :validate_email!, only: [:create]

  def new
    @contact = Contact.new
  end

  def create
    @contact = Contact.new(contact_params)

    if verify_recaptcha(model: @contact) && @contact.save
      Akismet.api_key = 'c53388e9bb4e'
      Akismet.app_url = 'https://lemonandbsil.co'

      is_spam = Akismet.spam?(
        request.ip,
        request.user_agent,
        text: @contact.message
      )

      if !is_spam
        ContactMailer.with(contact: @contact).success.deliver
      end

      redirect_to contact_success_path
    else
      flash.now[:error] = "Oops! That didn't work. Try again?"
      render :new
    end
  end

  def success
  end

  private

  def contact_params
    params.require(:contact).permit(:name, :email, :message, :neighborhood)
  end

  def validate_email!
    if !Contact.valid_email?(contact_params[:email])
      redirect_to contact_success_path
    end
  end
end

class ContactController < ApplicationController
  def new
    @contact = Contact.new
  end

  def create
    @contact = Contact.new(contact_params)

    if verify_recaptcha(model: @contact) && @contact.save
      ContactMailer.with(contact: @contact).success.deliver
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
end

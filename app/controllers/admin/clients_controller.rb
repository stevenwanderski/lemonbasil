class Admin::ClientsController < AdminController
  def index
    @clients = current_user.clients.order(last_name: :asc).page(params[:page]).per(10)
  end

  def new
    @client = Client.new
  end

  def create
    @client = current_user.clients.build(client_params)

    if @client.save
      redirect_to admin_clients_path, notice: 'Client created!'
    else
      flash.now[:error] = 'Could not save'
      render :new
    end
  end

  def edit
    @client = current_user.clients.find(params[:id])
  end

  def update
    @client = current_user.clients.find(params[:id])

    if @client.update!(client_params)
      redirect_to admin_clients_path, notice: 'Client updated!'
    else
      flash.now[:error] = 'Could not save'
      render :edit
    end
  end

  def show
    @client = current_user.clients.find(params[:id])
  end

  def destroy
    @client = current_user.clients.find(params[:id])
    @client.destroy
    redirect_to admin_clients_path, notice: 'Client deleted!'
  end

  private

  def client_params
    params.require(:client).permit(:first_name, :last_name, :email)
  end
end

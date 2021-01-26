class Admin::ClientsController < AdminController
  def index
    @clients = Client.all.order(last_name: :asc)
  end

  def new
    @client = Client.new
  end

  def create
    @client = Client.new(client_params)

    if @client.save
      redirect_to admin_clients_path, notice: 'Client created!'
    else
      flash.now[:error] = 'Could not save'
      render :new
    end
  end

  def edit
    @client = Client.find(params[:id])
  end

  def update
    @client = Client.find(params[:id])

    if @client.update!(client_params)
      redirect_to admin_clients_path, notice: 'Client updated!'
    else
      flash.now[:error] = 'Could not save'
      render :edit
    end
  end

  def show
    @client = Client.find(params[:id])
  end

  def destroy
    @client = Client.find(params[:id])
    @client.destroy
    redirect_to admin_clients_path, notice: 'Client deleted!'
  end

  private

  def client_params
    params.require(:client).permit(:first_name, :last_name)
  end
end

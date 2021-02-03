class Admin::ClientMenusController < AdminController
  def index
    clients = Client.all
    @clients = ActiveModelSerializers::SerializableResource.new(clients)
    @token = ENV['API_TOKEN']
  end

  def new
    @client_menu = ClientMenu.new
  end

  def create
    @client_menu = ClientMenu.new(client_menu_params)

    if @client_menu.save
      redirect_to admin_client_menus_path, notice: 'Client Menu created!'
    else
      flash.now[:error] = 'Could not save'
      render :new
    end
  end

  def edit
    @client_menu = ClientMenu.find(params[:id])
  end

  def update
    @client_menu = ClientMenu.find(params[:id])

    if @client_menu.update!(client_menu_params)
      redirect_to admin_client_menus_path, notice: 'Client Menu updated!'
    else
      flash.now[:error] = 'Could not save'
      render :edit
    end
  end

  def show
    clients = Client.all
    @clients = ActiveModelSerializers::SerializableResource.new(clients)
    @client_menu_id = params[:id]
    @token = ENV['API_TOKEN']
  end

  def destroy
    @client_menu = ClientMenu.find(params[:id])
    @client_menu.destroy
    redirect_to admin_client_menus_path, notice: 'Client Menu deleted!'
  end

  private

  def client_menu_params
    params.require(:client_menu).permit(:client_id)
  end
end

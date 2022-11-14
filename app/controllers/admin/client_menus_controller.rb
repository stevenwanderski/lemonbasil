class Admin::ClientMenusController < AdminController
  def index
    clients = Client.all.order(:last_name)
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
    @clients = Client.all.order(last_name: :asc)
  end

  def update
    @client_menu = ClientMenu.find(params[:id])

    if @client_menu.update(client_menu_params)
      render 'update'
    else
      render 'edit', status: 422
    end
  end

  def show
    @client_menu = ClientMenu.find(params[:id])

    if @client_menu.client_menu_categories.none?
      redirect_to admin_client_menu_categories_path(params[:id])
    else
      redirect_to admin_client_menu_menu_items_path(params[:id])
    end
  end

  def categories
    @client_menu = ClientMenu.find(params[:client_menu_id])
    @client = @client_menu.client
    @categories = @client_menu.client_menu_categories.order(:weight)
    @new_client_menu = ClientMenu.new
    @clients = Client.all.order(:last_name)
  end

  def menu_items
    @clients = ActiveModelSerializers::SerializableResource.new(Client.all)
    @client_menu_id = params[:client_menu_id]
    @token = ENV['API_TOKEN']
    @active_page = 'menu_items'
  end

  def results
    @client_menu = ClientMenu.find(params[:client_menu_id])
  end

  def destroy
    @client_menu = ClientMenu.find(params[:id])
    @client_menu.destroy
    redirect_to admin_client_menus_path, notice: 'Client Menu deleted!'
  end

  def send_to_client
    client_menu = ClientMenu.find(params[:client_menu_id])

    ClientMenuMailer
      .with(client_menu: client_menu)
      .send_to_client
      .deliver_now

    redirect_to admin_client_menu_path(client_menu), notice: 'Client Menu was sent!'
  end

  def update_category_weights
    weights = params[:weights]

    weights.each_with_index do |id, weight|
      category = ClientMenuCategory.find(id)
      category.update!(weight: weight)
    end

    render json: { status: 'success' }, status: 200
  end

  private

  def client_menu_params
    params.require(:client_menu).permit!
  end
end

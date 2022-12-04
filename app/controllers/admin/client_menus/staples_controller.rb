class Admin::ClientMenus::StaplesController < AdminController
  def new
    @client_menu = ClientMenu.find(params[:client_menu_id])
    @staple = Staple.new
  end

  def create
    @client_menu = ClientMenu.find(params[:client_menu_id])
    @staple = Staple.new(staple_params)
    @staple.client_menu = @client_menu

    if @staple.save
      @staples = @client_menu.staples.order(:weight)
      render 'create'
    else
      render 'new', status: 422
    end
  end

  def edit
    @client_menu = ClientMenu.find(params[:client_menu_id])
    @staple = Staple.find(params[:id])
  end

  def update
    @client_menu = ClientMenu.find(params[:client_menu_id])
    @staple = Staple.find(params[:id])

    if @staple.update(staple_params)
      render 'update'
    else
      render 'edit', status: 422
    end
  end

  def destroy
    @client_menu = ClientMenu.find(params[:client_menu_id])
    @staple = Staple.find(params[:id])
    @staple.destroy!
    @staples = @client_menu.staples.order(:weight)
  end

  private

  def staple_params
    params.require(:staple).permit!
  end
end

class Admin::ClientMenuSelectionsController < AdminController
  def edit
    @client_menu_selection = ClientMenuSelection.find(params[:id])
    @instruction = @client_menu_selection.instruction ||
                   @client_menu_selection.build_instruction
  end

  def update
    @client_menu_selection = ClientMenuSelection.find(params[:id])
    @client_menu_selection.update!(client_menu_selection_params)
  end

  def show
    @client_menu_selection = ClientMenuSelection.find(params[:id])
  end

  private

  def client_menu_selection_params
    params.require(:client_menu_selection).permit!
  end
end

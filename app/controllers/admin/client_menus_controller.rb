class Admin::ClientMenusController < AdminController
  before_action :set_client_menu, only: [:categories, :menu_items, :results, :staples, :staple_categories]
  before_action :set_client_menu_mailer_log, only: [:categories, :menu_items, :results, :staples, :staple_categories]

  def index
    @client_menus = current_user.client_menus.all.order(created_at: :desc).page(params[:page]).per(30)
  end

  def new
    @client_menu = ClientMenu.new
    @clients = current_user.clients.all.order(:last_name)
  end

  def create
    @client_menu = current_user.client_menus.build(client_menu_params)

    if @client_menu.save
      redirect_to admin_client_menus_path, notice: 'Client Menu created!'
    else
      flash.now[:error] = 'Could not save'
      render :new
    end
  end

  def edit
    @client_menu = current_user.client_menus.find(params[:id])
    @clients = current_user.clients.all.order(last_name: :asc)
  end

  def update
    @client_menu = current_user.client_menus.find(params[:id])

    if @client_menu.update(client_menu_params)
      render 'update'
    else
      render 'edit', status: 422
    end
  end

  def show
    @client_menu = current_user.client_menus.find(params[:id])

    if @client_menu.client_menu_categories.none?
      redirect_to admin_client_menu_categories_path(params[:id])
    else
      redirect_to admin_client_menu_menu_items_path(params[:id])
    end
  end

  def categories
    @client = @client_menu.client
    @categories = @client_menu.client_menu_categories.order(:weight)
  end

  def menu_items
    @client = @client_menu.client
    @categories = @client_menu.client_menu_categories.order(:weight)
  end

  def results
    @client = @client_menu.client
  end

  def destroy
    @client_menu = current_user.client_menus.find(params[:id])
    @client_menu.destroy
    redirect_to admin_client_menus_path, notice: 'Client Menu deleted!'
  end

  def send_to_client
    client_menu = current_user.client_menus.find(params[:client_menu_id])

    ClientMenuMailer
      .with(client_menu: client_menu)
      .send_to_client
      .deliver_now

    client_menu.client_menu_mailer_logs.create!(
      sent_at: Time.now,
      email: client_menu.client.email
    )

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

  def update_menu_item_weights
    weights = params[:weights]

    weights.each_with_index do |id, weight|
      item = ClientMenuItem.find(id)
      item.update!(weight: weight)
    end

    render json: { status: 'success' }, status: 200
  end

  def update_staple_weights
    weights = params[:weights]

    weights.each_with_index do |id, weight|
      item = Staple.find(id)
      item.update!(weight: weight)
    end

    render json: { status: 'success' }, status: 200
  end

  def update_staple_category_weights
    weights = params[:weights]

    weights.each_with_index do |id, weight|
      item = StapleCategory.find(id)
      item.update!(weight: weight)
    end

    render json: { status: 'success' }, status: 200
  end

  def staples
    @client = @client_menu.client
    @staple_categories = @client_menu.staple_categories.order(:weight)
  end

  def monthly
    @months = current_user.client_menus
      .where.not(job_date: nil)
      .select("EXTRACT(YEAR FROM job_date)::integer AS year, EXTRACT(MONTH FROM job_date)::integer AS month")
      .distinct
      .order(Arel.sql("year DESC, month DESC"))
      .map { |r| [r.year, r.month] }
  end

  def monthly_show
    year = params[:year].to_i
    month = params[:month].to_i
    start_date = Date.new(year, month, 1)
    end_date = start_date.end_of_month

    @year = year
    @month = month
    @client_menus = current_user.client_menus
      .where(job_date: start_date..end_date)
      .order(job_date: :asc)
      .page(params[:page]).per(30)
  end

  def staple_categories
    @client = @client_menu.client
    @staple_categories = @client_menu.staple_categories.order(:weight)
  end

  private

  def client_menu_params
    params.require(:client_menu).permit!
  end

  def set_client_menu
    @client_menu = current_user.client_menus.find(params[:client_menu_id])
  end

  def set_client_menu_mailer_log
    @client_menu_mailer_log = @client_menu.client_menu_mailer_logs.order(sent_at: :desc).first
  end
end

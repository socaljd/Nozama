class InventoriesController < ApplicationController
  before_action :signed_in_user, only: [:index, :create, :edit, :update, :destroy]
  before_action :set_inventory, only: [:show, :edit, :update, :destroy]

  # GET /inventories
  # GET /inventories.json
  def index
    @inventories = current_user.inventories.where(:user_id => current_user.id).where('quantity_remaining > 0').group(:fnsku, :received_date).paginate(page: params[:page])
  end

  def batch_inventory
    @inventories = Inventory.where(:user_id => current_user.id, :batch_id => params[:batch_id]).group(:fnsku, :received_date).paginate(page: params[:page])
  end

  def batch_index
    @inventories = Inventory.where(:user_id => current_user.id).group(:batch_id).paginate(page: params[:page])
  end

  # GET /inventories/1
  # GET /inventories/1.json
  def show
    fnsku = @inventory.fnsku
    received = @inventory.received_date

    if params[:batch_id]
    else
      @inventory.quantity = current_user.inventories.where(:user_id => current_user.id, :fnsku => fnsku, :received_date => received).sum(:quantity)
      @inventory.quantity_remaining = current_user.inventories.where(:user_id => current_user.id, :fnsku => fnsku, :received_date => received).sum(:quantity_remaining)
    end
  end

  # GET /inventories/new
  def new
    @inventory = Inventory.new
  end

  # GET /inventories/1/edit
  def edit
  end

  def search
    @inventory = Inventory.new
  end

  def search_index
    if params[:product_name] && params[:id].nil?
      @inventories = current_user.inventories.where(:user_id => current_user.id).where('product_name LIKE ?', '%' + params[:product_name] + '%').group(:fnsku, :received_date).paginate(page: params[:page])
    elsif params[:product_name]
      @inventories = current_user.inventories.where(:user_id => current_user.id).where('quantity_remaining > 0').where('product_name LIKE ?', '%' + params[:product_name] + '%').group(:fnsku, :received_date).paginate(page: params[:page])
    elsif params[:fnsku] && params[:id].nil?
      @inventories = current_user.inventories.where(:user_id => current_user.id).where(:fnsku => params[:fnsku]).group(:fnsku, :received_date).paginate(page: params[:page])
    elsif params[:fnsku]
      @inventories = current_user.inventories.where(:user_id => current_user.id).where('quantity_remaining > 0').where(:fnsku => params[:fnsku]).group(:fnsku, :received_date).paginate(page: params[:page])
    end
  end

  # POST /inventories
  # POST /inventories.json
  def create
    if params[:name] == 'Upload File'
      fileUpload = true
    elsif params[:name] == 'Search'
      searchQuery = true
    end

    if params[:inventory] && params[:inventory][:file]
      inventory = Inventory.where(:user_id => current_user.id).last

      if inventory.nil?
        batchID = 1
      else
        batchID = inventory.batch_id + 1
      end

      lines = params[:inventory][:file].tempfile.readlines.map(&:chomp)
      validHeader = lines[0].split(/\t/)

      if validHeader[0] == 'received-date'
        lines.shift
        begin
          Inventory.transaction do
              lines.each do |line|
                parse = line.split(/\t/)
                @inventory = current_user.inventories.build(batch_id: batchID, received_date: parse[0], fnsku: parse[1], sku: parse[2], product_name: parse[3].gsub(/[^\u0000-\u007F]/, ''), quantity: parse[4], fba_shipment_id: parse[5],
                                                 fulfillment_center_id: parse[6], quantity_remaining: parse[4])
                @inventory.save!
              end
          end
        rescue ActiveRecord::StatementInvalid
          notice = 'Inventory upload was unsuccessful.'
          redirect_to new_inventory_path, :notice => notice
          return
        end
      else
        @inventory = Inventory.new
      end
    elsif params[:inventory] && (params[:inventory][:product_name] != '')
      if params[:inventory][:id].nil?
        redirect_to inventorysearchindex_path(:product_name => params[:inventory][:product_name])
      else
        redirect_to inventorysearchindex_path(:product_name => params[:inventory][:product_name], :id => params[:inventory][:id])
      end
    elsif params[:inventory] && (params[:inventory][:fnsku] != '')
      if params[:inventory][:id].nil?
        redirect_to inventorysearchindex_path(:fnsku => params[:inventory][:fnsku])
      else
        redirect_to inventorysearchindex_path(:fnsku => params[:inventory][:fnsku], :id => params[:inventory][:id])
      end
    else
      @inventory = Inventory.new
    end

    if fileUpload
      respond_to do |format|
        if @inventory.save
          format.html { redirect_to inventories_path, notice: 'Inventory was successfully uploaded.' }
          format.json { render action: 'show', status: :created, location: @inventory }
        else
          format.html { redirect_to new_inventory_path, notice: 'Inventory upload was unsuccessful.' }
          format.json { render json: @inventory.errors, status: :unprocessable_entity }
        end
      end
    elsif searchQuery
      if params[:inventory][:product_name] == '' && params[:inventory][:fnsku] == ''
        respond_to do |format|
          format.html { redirect_to inventorysearch_path, notice: 'Enter product name or FNSKU to search.' }
          format.json { render json: @inventory.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PATCH/PUT /inventories/1
  # PATCH/PUT /inventories/1.json
  def update
    respond_to do |format|
      if @inventory.update(inventory_params)
        format.html { redirect_to @inventory, notice: 'Inventory was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @inventory.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /inventories/1
  # DELETE /inventories/1.json
  def destroy
    @inventory.destroy
    respond_to do |format|
      format.html { redirect_to inventories_url, notice: 'Item was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  def batch_delete
    Inventory.delete(params[:id])
    respond_to do |format|
      format.html { redirect_to batchinventory_path(:batch_id => params[:batch_id]), notice: 'Item was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  def batch_delete_all
    Inventory.where(:batch_id => params[:batch_id], :user_id => current_user.id).delete_all
    respond_to do |format|
      format.html { redirect_to indexbatchinventory_path, notice: 'Batch was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_inventory
      @inventory = Inventory.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def inventory_params
      params.require(:inventory).permit(:user_id, :received_date, :fnsku, :sku, :product_name,:quantity, :fba_shipment_id, :fulfillment_center_id)
    end
end

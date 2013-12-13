class SalesController < ApplicationController
  before_action :signed_in_user, only: [:index, :create, :edit, :update, :destroy]
  before_action :set_sale, only: [:show, :edit, :update, :destroy]

  # GET /sales
  # GET /sales.json
  def index
    if params[:fnsku] && params[:item_id]
      @sales = current_user.sales.where(:user_id => current_user.id, :fnsku => params[:fnsku], :item_id => params[:item_id]).group(:amazon_order_id).paginate(page: params[:page])
    else
      @sales = current_user.sales.where(:user_id => current_user.id).group(:fnsku, :item_id, :amazon_order_id).paginate(page: params[:page])
    end
  end

  def statistics
    @sales = current_user.sales.where(:user_id => current_user.id)
  end

  def batch_sales
    @sales = Sale.where(:user_id => current_user.id, :batch_id => params[:batch_id]).group(:fnsku, :item_id, :amazon_order_id).paginate(page: params[:page])
  end

  def batch_index
    @sales = Sale.where(:user_id => current_user.id).group(:batch_id).paginate(page: params[:page])
  end

  # GET /sales/1
  # GET /sales/1.json
  def show
    fnsku = @sale.fnsku
    item = @sale.item_id
    sale = @sale.amazon_order_id

    if params[:batch_id]
      @sale.quantity = current_user.sales.where(:user_id => current_user.id, :fnsku => fnsku, :item_id => item, :amazon_order_id => sale, :batch_id => params[:batch_id]).sum(:quantity)
    else
      @sale.quantity = current_user.sales.where(:user_id => current_user.id, :fnsku => fnsku, :item_id => item, :amazon_order_id => sale).sum(:quantity)
    end
  end

  # GET /sales/new
  def new
    @sale = Sale.new
  end

  # GET /sales/1/edit
  def edit
  end

  def search
    @sale = Sale.new
  end

  def search_index
    if params[:amazon_order_id]
      @sales = current_user.sales.where(:user_id => current_user.id, :amazon_order_id => params[:amazon_order_id]).group(:fnsku, :item_id, :amazon_order_id).paginate(page: params[:page])
    elsif params[:fnsku]
      @sales = current_user.sales.where(:user_id => current_user.id, :fnsku => params[:fnsku]).group(:fnsku, :item_id, :amazon_order_id).paginate(page: params[:page])
    end
  end

  # POST /sales
  # POST /sales.json
  def create
    if params[:name] == 'Upload File'
      fileUpload = true
    elsif params[:name] == 'Search'
      searchQuery = true
    end

    if params[:sale] && params[:sale][:file]
      sale = Sale.where(:user_id => current_user.id).last

      if sale.nil?
        batchID = 1
      else
        batchID = sale.batch_id + 1
      end

      lines = params[:sale][:file].tempfile.readlines.map(&:chomp)
      validHeader = lines[0].split(/\t/)

      if validHeader[0] == 'shipment-date'
        lines.shift
        begin
          Sale.transaction do
            Inventory.transaction do
              lines.each do |line|
                parse = line.split(/\t/)
                quantities = parse[5].to_i
                for i in (1..quantities)
                  @inventory = Inventory.limit(1).order('received_date asc').where(:user_id => current_user.id, :fnsku => parse[2]).where('quantity_remaining > 0').first

                  if @inventory.nil?
                    daysInInventory = -1
                    itemID = -1
                  else
                    daysInInventory = (parse[0].to_datetime - @inventory.received_date).to_i
                    itemID = @inventory.id
                  end

                  @sale = current_user.sales.build(batch_id: batchID, item_id: itemID, days_in_inventory: daysInInventory, shipment_date: parse[0], sku: parse[1], fnsku: parse[2], asin: parse[3], fulfillment_center_id: parse[4], quantity: 1,
                                                   amazon_order_id: parse[6], currency: parse[7], item_price_per_unit: parse[8], shipping_price: parse[9], gift_wrap_price: parse[10],
                                                   ship_city: parse[11], ship_state: parse[12], ship_postal_code: parse[13])

                  if @inventory.nil?
                    @sale.save!
                  else
                    quantityRemaining = @inventory.quantity_remaining
                    @sale.save!
                    @inventory.update_attributes(:quantity_remaining => quantityRemaining - 1)
                  end
                end
              end
            end
          end
        rescue
          notice = 'Upload error.'
          redirect_to new_sale_path, :notice => notice
          return
        end
      else
        @sale = Sale.new
      end
    elsif params[:sale] && (params[:sale][:amazon_order_id] != '')
      redirect_to salessearchindex_path(:amazon_order_id => params[:sale][:amazon_order_id])
    elsif params[:sale] && (params[:sale][:fnsku] != '')
      redirect_to salessearchindex_path(:fnsku => params[:sale][:fnsku])
    else
      @sale = Sale.new
    end

    if fileUpload
      respond_to do |format|
        if @sale.save
          format.html { redirect_to sales_path, notice: 'Sales were successfully uploaded.' }
          format.json { render action: 'show', status: :created, location: @sale }
        else
          format.html { redirect_to new_sale_path, notice: 'Sales upload was unsuccessful.' }
          format.json { render json: @sale.errors, status: :unprocessable_entity }
        end
      end
    elsif searchQuery
      if params[:sale][:amazon_order_id] == '' && params[:sale][:fnsku] == ''
        respond_to do |format|
          format.html { redirect_to salessearch_path, notice: 'Enter Amazon Order ID or FNSKU to search.' }
          format.json { render json: @inventory.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PATCH/PUT /sales/1
  # PATCH/PUT /sales/1.json
  def update
    respond_to do |format|
      if @sale.update(sale_params)
        format.html { redirect_to @sale, notice: 'Sale was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @sale.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sales/1
  # DELETE /sales/1.json
  def destroy
    @sale.destroy
    respond_to do |format|
      format.html { redirect_to sales_url, notice: 'Sale was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  def batch_delete
    Sale.delete(params[:id])
    respond_to do |format|
      format.html { redirect_to batchsales_path(:batch_id => params[:batch_id]), notice: 'Sale was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  def batch_delete_all
    Sale.where(:batch_id => params[:batch_id], :user_id => current_user.id).delete_all
    respond_to do |format|
      format.html { redirect_to indexbatchsales_path, notice: 'Batch was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_sale
      @sale = Sale.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def sale_params
      params.require(:sale).permit(:user_id, :shipment_date, :sku, :fnsku, :asin, :fulfillment_center_id, :quantity, :amazon_order_id, :currency, :item_price_per_unit, :shipping_price,
      :gift_wrap_price, :ship_city, :ship_state, :ship_postal_code)
    end
end
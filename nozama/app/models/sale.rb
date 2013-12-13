class Sale < ActiveRecord::Base
  belongs_to :user
  validates :user_id, presence: true

  def self.total_for(date)
    where('date(shipment_date) = ?', date).sum(:item_price_per_unit)
  end

  def self.totalcount_for(date)
    where('date(shipment_date) = ?', date).count()
  end

end

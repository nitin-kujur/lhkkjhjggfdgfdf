class Product < ActiveRecord::Base
  belongs_to :shop
  has_many :product_quantities, class_name: ProductQuantity
  accepts_nested_attributes_for :product_quantities, :allow_destroy => true

  #Callback
  validate :validate_product_quantities

  def get_price(qunatity, default_price)
  	price = 0.0
  	qunatity = qunatity.to_i if qunatity.present?
  	pq = self.product_quantities.select{|s| (s.first_quantity..s.last_quantity).include?(qunatity)}
    if pq.present?
    	price = pq.first.price
    else
    	price = default_price
    end
    price
  end

  def validate_product_quantities
    self.product_quantities.each_with_index do |pq, index|
			if pq.first_quantity.blank? || pq.last_quantity.blank? || pq.first_quantity <= 0 || pq.last_quantity <= 0
				self.errors.add(:base, "Quanitity value should be greater than 0")
				break
			elsif pq.price.blank? || pq.price <= 0 
				self.errors.add(:base, "Quanitity price should be greater than 0")
				break
			else
	    	self.product_quantities.each_with_index do |pro, in_index|
	    		if index != in_index && self.errors.blank?
	    			if (pro.first_quantity..pro.last_quantity).include?(pq.first_quantity) || (pro.first_quantity..pro.last_quantity).include?(pq.last_quantity)
	    				self.errors.add(:base, "Quanitity values should not overlap")
	    				break
	    			end
	    		end
	    	end
			end
    end
  end
end

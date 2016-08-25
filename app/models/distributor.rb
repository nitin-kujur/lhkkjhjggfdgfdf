class Distributor < ActiveRecord::Base
	has_many :addresses
	accepts_nested_attributes_for :addresses
	validates :first_name, :last_name, :email, presence: true
end

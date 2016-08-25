class Address < ActiveRecord::Base
  belongs_to :distributor
  validates  :city, :zip,:country, presence: true
end

class Item < ApplicationRecord
  include Dollarable

  has_many :invoice_items, dependent: :destroy
  has_many :invoices, through: :invoice_items
  belongs_to :merchant
  validates_presence_of :name, :description, :unit_price
  validates_inclusion_of :enabled, in: [true, false]
  # after_initialize :init

  # def init
  #   enabled = false if enabled.nil?
  # end

  def price_to_dollars
    price_in_dollars(unit_price)
  end

  def self.enabled_only
    where(enabled: true)
  end

  def self.disabled_only
    where(enabled: false)
  end
end

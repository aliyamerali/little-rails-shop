class Invoice < ApplicationRecord
  enum status: [:in_progress, :completed, :cancelled]

  has_many :invoice_items, dependent: :destroy
  has_many :items, through: :invoice_items
  has_many :transactions

  def self.unshipped_items
    joins(:invoice_items)
    .where('invoice_items.status != 2')
    .select('invoices.*')
    .group('invoices.id')
    .order('invoices.created_at asc')
  end

  def self.highest_revenue_date(item_id)
    joins(:invoice_items, :transactions)
    .select(invoices: :updated_at)
    .where(invoice_items: {item_id: item_id}, transactions: {result: 1}, invoices: {status: 1})
    .order(Arel.sql('sum(invoice_items.quantity * invoice_items.unit_price) desc, invoices.updated_at desc'))
    .group(:updated_at)
    .limit(1)
    .pluck(:updated_at)
  end

  def item_sale_price
    items
    .joins(:invoice_items)
    .select('items.*, invoice_items.unit_price as sale_price, invoice_items.quantity as sale_quantity')
  end

  def total_revenue
    invoice_items
    .sum('invoice_items.unit_price * invoice_items.quantity')
  end

  def total_revenue_for_merchant(merchant_id)
    invoice_items
    .joins(:item)
    .where(items: {merchant_id: merchant_id})
    .sum('invoice_items.unit_price * invoice_items.quantity')
  end
end

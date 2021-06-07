require 'rails_helper'

RSpec.describe Invoice do
  describe 'relationships' do
    it { should have_many(:invoice_items).dependent(:destroy) }
    it { should have_many(:items).through(:invoice_items) }
    it { should have_many(:transactions) }
  end

  describe 'validations' do
    it { should validate_presence_of(:customer_id) }
    it { should validate_presence_of(:status) }
  end

  describe 'enums' do
    it { should define_enum_for(:status).with_values([:in_progress, :completed, :cancelled])}
  end

  before :each do
    @merchant_1 = Merchant.create!(name: "Ralph's Monkey Hut")
    @customer_1 = Customer.create!(first_name: 'Madi', last_name: 'Johnson')
    @customer_2 = Customer.create!(first_name: 'Emmy', last_name: 'Lost')
    @customer_3 = Customer.create!(first_name: 'Shim', last_name: 'Stalone')
    @customer_4 = Customer.create!(first_name: 'Bado', last_name: 'Reason')
    @customer_5 = Customer.create!(first_name: 'Timothy', last_name: 'Richard')
    @customer_6 = Customer.create!(first_name: 'Alex', last_name: '19th')
    @invoice_1 = @customer_1.invoices.create!(status: 1)
    @invoice_2 = @customer_2.invoices.create!(status: 1)
    @invoice_3 = @customer_3.invoices.create!(status: 1)
    @invoice_4 = @customer_4.invoices.create!(status: 1)
    @invoice_5 = @customer_5.invoices.create!(status: 1)
    @invoice_6 = @customer_6.invoices.create!(status: 1)
    @item_1 = @merchant_1.items.create!(name: 'Pogs', description: 'Stack of pogs.', unit_price: 500,)
    InvoiceItem.create!(quantity: 15, unit_price: 550, status: 0, item: @item_1, invoice: @invoice_1)
    InvoiceItem.create!(quantity: 2, unit_price: 550, status: 2, item: @item_1, invoice: @invoice_1)
    InvoiceItem.create!(quantity: 1, unit_price: 550, status: 0, item: @item_1, invoice: @invoice_2)
    InvoiceItem.create!(quantity: 1, unit_price: 550, status: 0, item: @item_1, invoice: @invoice_3)
    InvoiceItem.create!(quantity: 1, unit_price: 550, status: 0, item: @item_1, invoice: @invoice_4)
    InvoiceItem.create!(quantity: 2, unit_price: 550, status: 2, item: @item_1, invoice: @invoice_5)
    InvoiceItem.create!(quantity: 2, unit_price: 550, status: 2, item: @item_1, invoice: @invoice_6)
    InvoiceItem.create!(quantity: 1, unit_price: 550, status: 0, item: @item_1, invoice: @invoice_6)
  end

  describe 'class methods' do
    describe '#unshipped_items' do
      it 'returns a collection of invoices that have unshipped items' do
        expect(Invoice.unshipped_items.first.customer_id).to eq(@customer_1.id)
        expect(Invoice.unshipped_items.length).to eq(5)
        expect(Invoice.unshipped_items.ids.include?(@invoice_5.id)).to eq(false)
      end
    end

    describe '#highest_revenue_date' do
      before :each do
        @merchant = Merchant.create!(name: "Little Shop of Horrors")
        @customer = Customer.create!(first_name: 'Audrey', last_name: 'I')
  
        @item_1 = @merchant.items.create!(name: 'Audrey II', description: 'Large, man-eating plant', unit_price: '100000000', enabled: true)
        @item_2 = @merchant.items.create!(name: 'Bouquet of roses', description: '12 red roses', unit_price: '1900', enabled: true)
        @item_3 = @merchant.items.create!(name: 'Orchid', description: 'Purple, 3 inches', unit_price: '2700', enabled: false)
        @item_4 = @merchant.items.create!(name: 'Echevaria', description: 'Peacock varietal', unit_price: '3100', enabled: true)
        @item_5 = @merchant.items.create!(name: 'Fourth item', description: '4th best', unit_price: '26400', enabled: true)
        @item_6 = @merchant.items.create!(name: 'Fifth item', description: '5th best', unit_price: '2400', enabled: true)
        @item_7 = @merchant.items.create!(name: 'Sixth item', description: '6th best', unit_price: '50', enabled: true)
  
        @invoice_1 = @customer.invoices.create!(status: 1, updated_at: '2021-03-01') # is successful and paid
        @invoice_2 = @customer.invoices.create!(status: 0, updated_at: '2021-03-01') # is cancelled
        @invoice_3 = @customer.invoices.create!(status: 2, updated_at: '2021-03-01')# is still in progress, no good transactions
        @invoice_4 = @customer.invoices.create!(status: 1, updated_at: '2021-02-08') # is successful and paid
        @invoice_5 = @customer.invoices.create!(status: 1, updated_at: '2021-02-01') # has no successful transaction
  
        @invoice_item_1 = @item_1.invoice_items.create!(invoice_id: @invoice_1.id, quantity: 2, unit_price: 5000, status: 0)
        @invoice_item_2 = @item_2.invoice_items.create!(invoice_id: @invoice_1.id, quantity: 2, unit_price: 2500, status: 0)
        @invoice_item_3 = @item_4.invoice_items.create!(invoice_id: @invoice_1.id, quantity: 2, unit_price: 1000, status: 0)
        @invoice_item_4 = @item_1.invoice_items.create!(invoice_id: @invoice_2.id, quantity: 2, unit_price: 5000, status: 0)
        @invoice_item_5 = @item_1.invoice_items.create!(invoice_id: @invoice_3.id, quantity: 2, unit_price: 5000, status: 0)
        @invoice_item_6 = @item_5.invoice_items.create!(invoice_id: @invoice_4.id, quantity: 2, unit_price: 500, status: 0)
        @invoice_item_7 = @item_6.invoice_items.create!(invoice_id: @invoice_4.id, quantity: 2, unit_price: 200, status: 0)
        @invoice_item_8 = @item_7.invoice_items.create!(invoice_id: @invoice_4.id, quantity: 2, unit_price: 50, status: 0)
  
        @invoice_1.transactions.create!(result: 1, credit_card_number: '534', credit_card_expiration_date: 'null')
        @invoice_4.transactions.create!(result: 1, credit_card_number: '534', credit_card_expiration_date: 'null')
        @invoice_5.transactions.create!(result: 0, credit_card_number: '534', credit_card_expiration_date: 'null')
      end

      it 'returns the highest revenue date for the given item' do
        expect(Invoice.highest_revenue_date(@item_1.id)[0]).to eq '2021-03-01'
      end
    end
  end
  
  describe 'instance methods' do
    describe '.item_sale_price' do
      it 'returns all items from an invoice and the amount they sold for and number sold' do
        actual = @invoice_1.item_sale_price.first

        expect(actual.sale_price).to eq(550)
        expect(actual.sale_quantity).to eq(15)
      end
    end

    describe '.total_revenue' do
      it 'returns all items from an invoice and the amount they sold for and number sold' do
        actual = @invoice_1.total_revenue

        expect(actual).to eq(9350)
      end
    end
  end
end

require 'rails_helper'

RSpec.describe 'The merchant item show page' do
  before :each do
    @merchant = Merchant.create!(name: "Little Shop of Horrors")
    @item_1 = @merchant.items.create!(name: 'Audrey II', description: 'Large, man-eating plant', unit_price: '100000000')
  end

  it 'displays the item attributes' do
    visit "/merchants/#{@merchant.id}/items/#{@item_1.id}"

    expect(page).to have_content 'Little Shop of Horrors'
    expect(page).to have_content 'Audrey II'
    expect(page).to have_content 'Large, man-eating plant'
    expect(page).to have_content '$1,000,000.00'
  end

  it 'has a link to update an item' do
    visit "/merchants/#{@merchant.id}/items/#{@item_1.id}"
    
    click_on 'Edit item details'

    expect(current_path).to eq "/merchants/#{@merchant.id}/items/#{@item_1.id}/edit"
  end
end
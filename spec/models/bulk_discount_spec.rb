require 'rails_helper'

RSpec.describe BulkDiscount do
  describe 'relationships' do
    it { should belong_to(:merchant)}
    it { should validate_presence_of(:percentage)}
    it { should validate_presence_of(:quantity_threshold)}
  end
end

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_many(:items).dependent(:destroy) }
  end

  describe 'validations' do
    subject { build(:user) }

    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:role) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_length_of(:password).is_at_least(6) }
  end

  describe 'scopes' do
    let!(:active_user) { create(:user, active: true) }
    let!(:inactive_user) { create(:user, active: false) }
    let!(:admin) { create(:user, :admin) }

    it 'returns only active users' do
      expect(User.active).to include(active_user)
      expect(User.active).not_to include(inactive_user)
    end

    it 'returns only admins' do
      expect(User.admins).to include(admin)
      expect(User.admins).not_to include(active_user)
    end
  end

  describe '#admin?' do
    it 'returns true for admin users' do
      admin = build(:user, :admin)
      expect(admin.admin?).to be true
    end

    it 'returns false for regular users' do
      user = build(:user)
      expect(user.admin?).to be false
    end
  end
end

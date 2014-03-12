class Category < ActiveRecord::Base
  has_many :tasks
  validates :title, presence: true, uniqueness: true
end

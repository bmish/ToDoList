class Task < ActiveRecord::Base
  belongs_to :list
  belongs_to :category
  validates :title, presence: true, uniqueness: true
  validates :category_id, presence: true
  validates :priority, presence: true
end

class Task < ActiveRecord::Base
  belongs_to :category
  validates :title, presence: true
  validates :category_id, presence: true
  validates :priority, presence: true
end

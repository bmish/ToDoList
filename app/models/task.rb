class Task < ActiveRecord::Base
  validates :title, presence: true
  validates :category_id, presence: true
  validates :priority, presence: true
end

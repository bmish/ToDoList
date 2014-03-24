class Task < ActiveRecord::Base
  belongs_to :list
  belongs_to :category
  before_validation :remove_whitespace
  validates :title, presence: true
  validates :priority, presence: true
  validates_uniqueness_of :title, :case_sensitive => false

  private
    def remove_whitespace
      self.title = self.title ? self.title.strip : ""
    end
end

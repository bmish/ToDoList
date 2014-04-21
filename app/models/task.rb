class Task < ActiveRecord::Base
  enum frequency: [ :Once, :Daily, :Weekly, :Biweekly, :Monthly, :Quarterly, :Yearly ]

  belongs_to :list
  belongs_to :category
  before_validation :remove_whitespace
  validates :title, presence: true
  validates :priority, presence: true
  validates_uniqueness_of :title, scope: :list_id, :case_sensitive => false

  private
    def remove_whitespace
      self.title = self.title ? self.title.strip : ""
    end
end

class Task < ActiveRecord::Base
  enum frequency: [ :Once, :Daily, :Weekly, :Biweekly, :Monthly, :Quarterly, :Yearly ]

  belongs_to :list
  belongs_to :category
  before_validation :remove_whitespace
  validates :title, presence: true
  validates :priority, presence: true
  validates_uniqueness_of :title, scope: :list_id, :case_sensitive => false
  validate :due_date_cannot_be_after_start_date

  private
    def remove_whitespace
      self.title = self.title ? self.title.strip : ""
    end

    def due_date_cannot_be_after_start_date
      if start.present? && due.present? && start > due
        errors.add(:start, "date cannot be after the due date.")
      end
    end
end

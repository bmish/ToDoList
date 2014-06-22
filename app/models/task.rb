class Task < ActiveRecord::Base
  enum frequency: [ :Continuous, :Once, :Daily, :Weekly, :Biweekly, :Monthly, :Quarterly, :Yearly ]

  belongs_to :list
  belongs_to :category
  before_validation :remove_whitespace
  validates :title, presence: true
  validates :priority, presence: true
  validates_uniqueness_of :title, scope: :list_id, :case_sensitive => false
  validate :due_date_cannot_be_after_start_date

  def status
    if self.done
      return 'Done'
    elsif self.blocked
      return 'Blocked'
    elsif self.start && self.start > Date.today
      return 'Waiting'
    elsif self.start && self.due && Date.today > self.start && Date.today < self.due
      return 'Actionable'
    elsif self.due && Date.today > self.due
      return 'Overdue'
    elsif self.underway
      return 'Underway'
    else
      return 'Actionable'
    end
  end

  private
    def remove_whitespace
      self.title = self.title ? self.title.strip : ""
    end

    def due_date_cannot_be_after_start_date
      if self.start.present? && self.due.present? && self.start > self.due
        errors.add(:start, "date cannot be after the due date.")
      end
    end
end

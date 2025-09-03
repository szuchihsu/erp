class DesignRequest < ApplicationRecord
  belongs_to :customer
  belongs_to :sales_order, optional: true
  belongs_to :assigned_designer, class_name: "Employee", optional: true
  has_many :design_images, dependent: :destroy

  # Fix enum syntax for Rails 8
  enum :status, {
    pending: 0,
    assigned: 1,
    in_progress: 2,
    review: 3,
    revision_needed: 4,
    approved: 5,
    rejected: 6
  }

  enum :priority, {
    low: 0,
    medium: 1,
    high: 2,
    urgent: 3
  }

  validates :design_details, presence: true
  validates :status, presence: true
  validates :priority, presence: true

  # Set default values
  after_initialize :set_defaults, if: :new_record?

  scope :active, -> { where(status: [ "pending", "assigned", "in_progress", "review", "revision_needed" ]) }
  scope :overdue, -> { where("requested_date < ? AND status IN (?)", 7.days.ago, [ "pending", "assigned", "in_progress" ]) }
  scope :by_designer, ->(designer_id) { where(assigned_designer_id: designer_id) }
  scope :pending, -> { where(status: :pending) }
  scope :assigned, -> { where(status: :assigned) }
  scope :in_progress, -> { where(status: [ :assigned, :in_progress ]) }
  scope :review, -> { where(status: :review) }

  def days_pending
    return 0 unless requested_date
    (Time.current - requested_date).to_i / 1.day
  end

  def final_images
    design_images.where(is_final: true)
  end

  def can_be_approved?
    status.in?([ "review" ]) && design_images.where(is_final: true).any?
  end

  def overdue?
    requested_date && requested_date < 7.days.ago && status.in?([ "pending", "assigned", "in_progress" ])
  end

  def status_badge_class
    case status
    when "pending"
      "bg-yellow-100 text-yellow-800"
    when "assigned", "in_progress"
      "bg-blue-100 text-blue-800"
    when "review"
      "bg-purple-100 text-purple-800"
    when "revision_needed"
      "bg-orange-100 text-orange-800"
    when "approved"
      "bg-green-100 text-green-800"
    when "rejected"
      "bg-red-100 text-red-800"
    else
      "bg-gray-100 text-gray-800"
    end
  end

  def priority_badge_class
    case priority
    when "low"
      "bg-gray-100 text-gray-800"
    when "medium"
      "bg-blue-100 text-blue-800"
    when "high"
      "bg-orange-100 text-orange-800"
    when "urgent"
      "bg-red-100 text-red-800"
    else
      "bg-gray-100 text-gray-800"
    end
  end

  private

  def set_defaults
    self.status ||= :pending
    self.priority ||= :medium
    self.requested_date ||= Time.current
  end
end

class WorkOrder < ApplicationRecord
  belongs_to :production_order
  belongs_to :assigned_employee, class_name: "Employee", optional: true

  validates :work_station_name, presence: true
  validates :step_name, presence: true
  validates :sequence, presence: true, uniqueness: { scope: :production_order_id }
  validates :status, presence: true

  enum :status, {
    waiting: 0,      # Waiting for previous steps to complete
    queued: 1,       # Ready to start
    in_progress: 2,  # Currently being worked
    completed: 3,    # Finished successfully
    on_hold: 4       # Paused
  }

  scope :by_sequence, -> { order(:sequence) }
  scope :active, -> { where(status: [ :queued, :in_progress ]) }

  def display_name
    "WO##{id} - #{step_name}"
  end

  def status_color
    case status
    when "waiting" then "bg-gray-100 text-gray-800"
    when "queued" then "bg-blue-100 text-blue-800"
    when "in_progress" then "bg-yellow-100 text-yellow-800"
    when "completed" then "bg-green-100 text-green-800"
    when "on_hold" then "bg-orange-100 text-orange-800"
    else "bg-gray-100 text-gray-800"
    end
  end

  def can_start?
    queued? && previous_steps_completed?
  end

  def can_complete?
    in_progress?
  end

  def start_work!(employee = nil)
    return false unless can_start?

    update!(
      status: "in_progress",
      started_at: Time.current,
      assigned_employee: employee
    )

    # Update production order status
    production_order.update!(status: "in_production") if production_order.pending?

    true
  end

  def complete_work!(actual_minutes = nil)
    return false unless can_complete?

    minutes_worked = actual_minutes || calculate_minutes_worked

    transaction do
      update!(
        status: "completed",
        completed_at: Time.current,
        actual_minutes: minutes_worked
      )

      # Start next work order if available
      next_work_order = production_order.work_orders.waiting.by_sequence.first
      next_work_order&.update!(status: "queued")

      # Check if production order is complete
      if production_order.work_orders.all?(&:completed?)
        production_order.update!(status: "quality_check")
      end
    end

    true
  end

  def duration_in_minutes
    return 0 unless started_at && completed_at
    ((completed_at - started_at) / 1.minute).round
  end

  def efficiency_percentage
    return 0 if estimated_minutes.nil? || actual_minutes.nil? || actual_minutes == 0
    (estimated_minutes.to_f / actual_minutes * 100).round
  end

  def next_work_order
    production_order.work_orders.where("sequence > ?", sequence).by_sequence.first
  end

  def previous_work_order
    production_order.work_orders.where("sequence < ?", sequence).by_sequence.last
  end

  private

  def previous_steps_completed?
    return true if sequence == 1

    previous_orders = production_order.work_orders.where("sequence < ?", sequence)
    previous_orders.all?(&:completed?)
  end

  def calculate_minutes_worked
    return estimated_minutes if started_at.nil?
    return 0 if completed_at.nil?

    duration_in_minutes
  end
end

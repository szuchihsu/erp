class ProductionOrder < ApplicationRecord
  belongs_to :sales_order, optional: true  # Can be standalone production
  belongs_to :product
  belongs_to :bill_of_material
  has_many :work_orders, dependent: :destroy

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :priority, presence: true
  validates :status, presence: true

  enum :status, {
    pending: 0,           # Created but not started
    material_allocated: 1, # Materials reserved
    in_production: 2,     # Active manufacturing
    quality_check: 3,     # In QC process
    completed: 4,         # Finished successfully
    cancelled: 5,         # Cancelled before completion
    on_hold: 6           # Temporarily paused
  }

  enum :priority, {
    normal: 0,
    high: 1,
    urgent: 2
  }

  scope :active, -> { where(status: [ :pending, :material_allocated, :in_production, :quality_check ]) }
  scope :by_priority, -> { order(priority: :desc, due_date: :asc) }
  scope :overdue, -> { where("due_date < ?", Time.current) }

  def display_name
    "PO##{id} - #{product.name} (#{quantity} units)"
  end

  def status_color
    case status
    when "pending" then "bg-gray-100 text-gray-800"
    when "material_allocated" then "bg-blue-100 text-blue-800"
    when "in_production" then "bg-yellow-100 text-yellow-800"
    when "quality_check" then "bg-purple-100 text-purple-800"
    when "completed" then "bg-green-100 text-green-800"
    when "cancelled" then "bg-red-100 text-red-800"
    when "on_hold" then "bg-orange-100 text-orange-800"
    else "bg-gray-100 text-gray-800"
    end
  end

  def priority_color
    case priority
    when "normal" then "bg-gray-100 text-gray-800"
    when "high" then "bg-orange-100 text-orange-800"
    when "urgent" then "bg-red-100 text-red-800"
    else "bg-gray-100 text-gray-800"
    end
  end

  def completion_percentage
    return 0 if work_orders.empty?
    completed_count = work_orders.completed.count
    (completed_count.to_f / work_orders.count * 100).round
  end

  def current_work_order
    work_orders.in_progress.first || work_orders.queued.first
  end

  def overdue?
    due_date.present? && due_date < Time.current && !completed?
  end

  def estimated_completion_time
    return nil if work_orders.empty?
    work_orders.sum(:estimated_minutes)
  end

  def actual_time_spent
    work_orders.sum(:actual_minutes)
  end

  # Generate work orders based on BOM or default jewelry manufacturing steps
  def generate_work_orders!
    return if work_orders.any?

    # Default jewelry manufacturing steps
    default_steps = [
      { name: "Material Preparation", station: "Material Prep", description: "Prepare and measure all materials", estimated_minutes: 30 },
      { name: "Initial Forming", station: "Bench Work", description: "Basic shaping and assembly", estimated_minutes: 120 },
      { name: "Setting/Assembly", station: "Setting Bench", description: "Stone setting or component assembly", estimated_minutes: 90 },
      { name: "Polishing", station: "Polishing", description: "Final polishing and finishing", estimated_minutes: 60 },
      { name: "Quality Check", station: "QC Station", description: "Final quality inspection", estimated_minutes: 15 }
    ]

    default_steps.each_with_index do |step, index|
      work_orders.create!(
        work_station_name: step[:station],
        step_name: step[:name],
        step_description: step[:description],
        sequence: index + 1,
        estimated_minutes: step[:estimated_minutes],
        status: index == 0 ? "queued" : "waiting"
      )
    end
  end

  def start_production!
    return false unless pending? || material_allocated?

    transaction do
      update!(status: "in_production", started_at: Time.current)
      generate_work_orders! if work_orders.empty?
      work_orders.first&.update!(status: "queued")
    end
    true
  end

  def complete_production!
    return false unless in_production? || quality_check?

    update!(status: "completed", completed_at: Time.current)

    # Update sales order if linked
    if sales_order && sales_order.make_to_order?
      check_sales_order_completion
    end

    true
  end

  private

  def check_sales_order_completion
    # Check if all production orders for this sales order are complete
    all_complete = sales_order.production_orders.all?(&:completed?)
    if all_complete
      sales_order.update!(order_status: "completed", completed_at: Time.current)
    end
  end
end

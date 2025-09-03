class DesignImage < ApplicationRecord
  belongs_to :design_request

  # Use Active Storage for file uploads
  has_one_attached :image_file

  enum :image_type, {
    sketch: 0,
    render: 1,
    technical: 2,
    reference: 3,
    final: 4,
    revision: 5
  }

  validates :image_type, presence: true
  validates :description, presence: true

  scope :final_designs, -> { where(is_final: true) }
  scope :by_type, ->(type) { where(image_type: type) }
  scope :latest, -> { order(created_at: :desc) }

  def display_name
    "#{image_type.humanize} - #{description}"
  end
end

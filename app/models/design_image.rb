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
  validates :description, presence: true, length: { minimum: 3 }
  validates :image_file, presence: true

  # Validate image file type and size
  validate :acceptable_image

  scope :final_designs, -> { where(is_final: true) }
  scope :by_type, ->(type) { where(image_type: type) }
  scope :latest, -> { order(created_at: :desc) }

  def display_name
    "#{image_type.humanize} - #{description}"
  end

  private

  def acceptable_image
    return unless image_file.attached?

    unless image_file.blob.content_type.in?(%w[image/jpeg image/png image/gif image/webp])
      errors.add(:image_file, "must be a JPEG, PNG, GIF, or WebP image")
    end

    if image_file.blob.byte_size > 10.megabytes
      errors.add(:image_file, "must be less than 10MB")
    end
  end
end

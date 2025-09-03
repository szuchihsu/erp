class DesignImagesController < ApplicationController
  before_action :set_design_request
  before_action :set_design_image, only: [ :destroy ]

  def create
    @design_image = @design_request.design_images.build(design_image_params)

    if @design_image.save
      redirect_to @design_request, notice: "Image uploaded successfully."
    else
      redirect_to @design_request, alert: "Failed to upload image. Please try again."
    end
  end

  def destroy
    @design_image.destroy
    redirect_to @design_request, notice: "Image deleted successfully."
  end

  private

  def set_design_request
    @design_request = DesignRequest.find(params[:design_request_id])
  end

  def set_design_image
    @design_image = @design_request.design_images.find(params[:id])
  end

  def design_image_params
    params.require(:design_image).permit(:image_type, :description, :is_final, :image_file)
  end
end

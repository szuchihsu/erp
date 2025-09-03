class DesignImagesController < ApplicationController
  before_action :set_design_request
  before_action :set_design_image, only: [ :show, :destroy ]

  def create
    @design_image = @design_request.design_images.build(design_image_params)

    if @design_image.save
      redirect_to @design_request, notice: "Image uploaded successfully."
    else
      error_messages = @design_image.errors.full_messages.join(", ")
      redirect_to @design_request, alert: "Error uploading image: #{error_messages}"
    end
  end

  def show
    # Show individual image details
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @design_image }
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
    params.require(:design_image).permit(:image_file, :image_type, :description, :is_final)
  end
end

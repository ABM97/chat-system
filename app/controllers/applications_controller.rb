class ApplicationsController < ApplicationController
  before_action :set_application, only: [:show, :update]

  # GET /applications
  def index
    render json: Application.paginate(page: params[:page], per_page: params[:size]), status: status, each_serializer: ApplicationGetSerializer
  end

  # GET /applications/:token
  def show
    render json: @application, status: status, serializer: ApplicationGetSerializer
  end

  # POST /applications
  def create
    @application = Application.create!(application_params)
    render json: @application, status: status, serializer: ApplicationCreationSerializer
  end

  # PUT /applications/:token
  def update
    @application.update(application_params)
    head :no_content
  end

  private

  def application_params
    params.require(:application).permit(:name)
  end

  def set_application
    @application = Application.find(token: params[:token])
  end

end

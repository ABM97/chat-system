class ChatsController < ApplicationController
  before_action :set_application
  before_action :set_chat, only: [:show]

  # GET /applications/:application_token/chats
  def index
    render json: @application.chats.paginate(page: params[:page], per_page: params[:size]), status: status, each_serializer: ChatSerializer
  end

  # GET /applications/:application_token/chats/:number
  def show
    render json: @chat, status: status, serializer: ChatShowSerializer
  end

  # POST /applications/:application_token/chats
  def create
    number = RedisService.get_current_counter_value("application_#{@application.id}")
    RabbitmqPublisher.publish("db_tasks", { number: number, application_id: @application.id, check_sum: SecureRandom.uuid, table: :Chat })
    render json: { chat_number: number }, status: status
  end

  def chat_params
    params.require(:chat).permit
  end

  def set_chat
    @chat = Chat.find_by(number: params[:number])
  end

  def set_application
    @application = Application.find_by(token: params[:application_token])
  end

end

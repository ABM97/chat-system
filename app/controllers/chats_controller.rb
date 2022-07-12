class ChatsController < ApplicationController
  before_action :set_application
  before_action :set_chat, only: [:show, :update]

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
    @chat = @application.chats.create!({ number: rand(10...42) })
    render json: @chat, status: status, serializer: ChatSerializer
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

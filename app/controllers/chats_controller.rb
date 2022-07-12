class ChatsController < ApplicationController
  before_action :set_application
  before_action :set_chat_item, only: [:show, :update]

  # GET /applications/:application_token/chats
  def index
    render json: @application.chats.paginate(page: params[:page], per_page: params[:size]), status: status, each_serializer: ChatSerializer
  end

  # GET /applications/:application_token/chats/:number
  def show
    render json: @chat, status: status, serializer: ChatSerializer
  end

  # POST /applications/:application_token/chats
  def create
    @chat = @application.chats.create!({ number: rand(10...42) })
    render json: @chat, status: status, serializer: ChatSerializer
  end

  # PUT /applications/:application_token/chats/:number
  def update
    @chat.update(chat_params)
    head :no_content
  end

  def chat_params
    params.require(:chat).permit
  end

  def set_chat_item
    @chat = Chat.find(number: params[:number])
  end

  def set_application
    @application = Application.find_by(token: params[:application_token])
  end
end

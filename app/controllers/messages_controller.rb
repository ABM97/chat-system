class MessagesController < ApplicationController
  before_action :set_application, :set_chat
  before_action :set_message, only: [:show, :update]

  # GET /applications/:application_token/chats/:chat_number/messages
  def index
    render json: @chat.messages.paginate(page: params[:page], per_page: params[:size]), status: status, each_serializer: MessageSerializer
  end

  # GET /applications/:application_token/chats/:chat_number/messages/:number
  def show
    render json: @message, status: status, serializer: MessageSerializer
  end

  # POST /applications/:application_token/chats/:chat_number/messages
  def create
    @message = @chat.messages.create!({ number: rand(10...42), body: message_params[:body]})
    render json: @message, status: status, serializer: MessageSerializer
  end

  # PUT /applications/:application_token/chats/:chat_number/messages/:number
  def update
    @message.update(message_params)
    head :no_content
  end


  def message_params
    params.require(:message).permit(:body)
  end

  private

  def set_application
    @application = Application.find_by(token: params[:application_token])
  end

  def set_chat
    @chat = Chat.find_by(number: params[:chat_number])
  end

  def set_message
    @message = Message.find_by(number: params[:number])
  end

end

class CommentsController < ApplicationController
  before_filter :check_auth, :prepare

  PER_PAGE = 10
  
  def index
    per = (params[:per] ? (3..3*10).include?(params[:per].to_i) : false) ? params[:per].to_i : PER_PAGE
    page = (params[:page] ? (1..15).include?(params[:page].to_i) : false) ? params[:page].to_i*PER_PAGE : 0 
    pid = @playlist.id

    comments = Comment.where(playlist_id: pid).desc(:created_at).skip(page).limit(per).includes(:user).to_a

    return error 'comments not found' if comments.empty?
    render json: comments.map { |c| c[:user_data] = c.user.show; c }
  end

  def create
    return error 'text nil or less 10 letters' unless text = params[:text] or text.length < 10

    reply_to = nil unless params[:reply_to] =~ /[a-f0-9]{24}/

    comment = Comment.new text: text, reply_to: params[:reply_to]
    comment.user = User.find(session[:user_id].to_i)

    status = @playlist.comments << comment
    render json: {status: status, id: comment.id}
  end

  def update
    return error 'text nil or less 10 letters' unless text = params[:text] or text.length < 10
    comment = @playlist.find(params[:cid])
    if comment.created_at < Time.now - 4.hour
      return error 'it is too late, was more than 4 hour'
    end
    comment.text = text
    status = comment.save
    render json: { status: status, id: comment.id  }
  end

  def delete
    comment = @playlist.find(params[:cid]) 
    unless comment.user_id == session[:user_id].to_i
      return error 'you can not delete comments form others users'
    end
    status = @playlist.comments.find(params[:cid]).destroy
    render json: {status: status, id: comment.id}
  end

  private

  def prepare
    @playlist = Playlist.any_of({url: params[:id]}, {_id: params[:id]}).first
  end
end

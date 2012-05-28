class CommentsController < ApplicationController
  before_filter :check_auth, :prepare

  PER_PAGE = 10
  
  def index
    per = (params[:per] ? (3..3*10).include?(params[:per].to_i) : false) ? params[:per].to_i : PER_PAGE
    page = (params[:page] ? (1..15).include?(params[:page].to_i) : false) ? params[:page].to_i*PER_PAGE : 0 
    pid = @playlist.id

    comments = Comment.where(playlist_id: pid).desc(:created_at).skip(page).limit(per).includes(:user).to_a

    return error 'comments not found' if comments.empty?

    comments.map! { |c| c[:user_data] = c.user.show; c }

    # ids of comments that users respond
    ids = comments.map { |c|c.reply_to }
    ids.reject!(&:nil?).uniq!

    unless ids.empty?
      response_comments = Comment.getByIds ids
      response_comments.map! { |c| c[:user_data] = c.user.show; c }
    end

    comments.map! do |comment|
      if cid = comment.reply_to and not cid.nil?
        comment[:replied_comment] = response_comments.select{ |rc| rc.id.to_s == cid }.first
      end
      comment
    end

    render json: comments
  end

  def create
    return error 'content nil or less 10 letters' unless content = params[:content] or content.length < 10

    if params[:reply_to] =~ /[a-f0-9]{24}/
      reply_to = params[:reply_to]
    else
      reply_to = nil 
    end
    # binding.pry
    comment = Comment.new content: content, reply_to: reply_to
    comment.user = User.find session[:user_id].to_i
    status = @playlist.comments << comment

    if cid = comment.reply_to and not cid.nil?
      comment[:replied_comment] = Comment.find cid
      if comment[:replied_comment]
        comment[:replied_comment][:user_data] = comment[:replied_comment].user.show
      end
    end

    render json: {status: status, id: comment.id, comment: comment}
  end

  def update
    return error 'content nil or less 10 letters' unless content = params[:content] or content.length < 10
    comment = @playlist.find(params[:cid])
    if comment.created_at < Time.now - 4.hour
      return error 'it is too late, was more than 4 hour'
    end
    comment.content = content
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

  def pick(hash, *keys)
    filtered = {}
    hash.each do |key, value| 
      filtered[key.to_sym] = value if keys.include?(key.to_sym) 
    end
    filtered
  end
end

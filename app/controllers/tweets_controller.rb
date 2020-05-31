class TweetsController < ApplicationController
  before_action :set_tweet, only: [:edit, :destroy, :show, :update]
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]
  before_action :blocking_edit_tweet, only: [:edit, :update, :destroy]

  def index
    @tweets = Tweet.includes(:user).order('updated_at desc').page(params[:page]).per(12)
    if params[:tag_name]
      @tweets = Tweet.includes(:user).order('updated_at desc').page(params[:page]).per(12).tagged_with("#{params[:tag_name]}")
    end
  end

  def new
      @tweet = Tweet.new
      @tags= Tweet.tag_counts_on(:tags)
  end

  def create
    @tweet = Tweet.create(tweet_params)
    if @tweet.save
      redirect_to root_path, notice: 'ツイートを投稿しました！'
    else
      flash.now[:alert] = 'メッセージを入力して下さい。'
      render :new
    end
  end

  def edit
  end

  def update
    @tweet.update(tweet_params)
    if @tweet.save
      redirect_to tweet_path(@tweet.id), notice: 'ツイートを編集しました！'
    else
      flash.now[:alert] = 'メッセージを入力して下さい。'
      render :edit
    end
  end

  def show
    @comment = Comment.new
    @comments = @tweet.comments.includes(:user).order('created_at desc')
    @user = @tweet.user
    @donation = Donation.new
    @donations = @tweet.donations.sum(:amount)
  end

  def destroy
    @tweet.destroy
    redirect_to root_path, notice: '投稿を削除しました'
  end

  def likes
    @tweets = Tweet.find(Like.group(:tweet_id).limit(10).order('count(tweet_id) desc').pluck(:tweet_id))
    if params[:tag_name]
      @tweets = Tweet.find(Like.group(:tweet_id).limit(10).order('count(tweet_id) desc').pluck(:tweet_id).tagged_with("#{params[:tag_name]}"))
    end
  end
# .page(params[:page]).per(12)
  def tags
    @tags = Tweet.tag_counts_on(:tags)
  end
    
  private

  def tweet_params
    params.require(:tweet).permit(:title, :text, :image, :tag_list).merge(user_id: current_user.id)
  end

  def set_tweet
    @tweet = Tweet.find(params[:id])
  end

  def blocking_edit_tweet
    unless current_user.admin?
      if @tweet.user.id != current_user.id
        redirect_to root_path, notice: "不正な操作です"
      end
    end
  end

end

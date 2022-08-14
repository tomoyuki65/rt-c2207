class RelationshipsController < ApplicationController
  before_action :logged_in_user

  def create
    @user = User.find(params[:followed_id])
    current_user.follow(@user)
    # 基本的な方法
    #redirect_to user

    # Rails7のHotwireで、SPA風な更新処理をしたい場合、
    # turbo_streamを返す（アクションに対するビューに処理を記述）
    respond_to do |format|
      format.turbo_stream
    end
  end

  def destroy
    @user = Relationship.find(params[:id]).followed
    current_user.unfollow(@user)
    # 基本的な方法
    #redirect_to user
    
    # Rails7のHotwireで、SPA風な更新処理をしたい場合、
    # turbo_streamを返す（アクションに対するビューに処理を記述）
    respond_to do |format|
      format.turbo_stream
    end
  end
end

module RequestSpecHelper
  # ログイン処理
  def log_in_as(user, remember_me: "0")
    get login_path
    post login_path, params: { session: { email: user.email,
                               password: user.password,
                               remember_me: remember_me } }
  end
end
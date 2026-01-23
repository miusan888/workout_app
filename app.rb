require 'sinatra'
require 'sinatra/reloader' if development?
require 'sqlite3'
require 'bcrypt' # パスワードを安全に保存するため

enable :sessions
set :session_secret, 'your_super_secret_key_12345'

# データベース準備
db = SQLite3::Database.new 'workout_app.db'
db.results_as_hash = true

# ユーザーテーブルと運動記録テーブルの作成
db.execute <<-SQL
  CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT UNIQUE,
    password_digest TEXT
  );
SQL

db.execute <<-SQL
  CREATE TABLE IF NOT EXISTS workouts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    name TEXT,
    duration INTEGER,
    date DATE
  );
SQL

# ログインチェック用ヘルパー
helpers do
  def logged_in?
    !session[:user_id].nil?
  end
end

# --- ルーティング ---

get '/' do
  if logged_in?
    @workouts = db.execute("SELECT * FROM workouts WHERE user_id = ? ORDER BY id DESC", [session[:user_id]])
    erb :index
  else
    erb :login
  end
end

# 新規登録
post '/signup' do
  password_hash = BCrypt::Password.create(params[:password])
  begin
    db.execute("INSERT INTO users (username, password_digest) VALUES (?, ?)", [params[:username], password_hash])
    user = db.execute("SELECT * FROM users WHERE username = ?", [params[:username]]).first
    session[:user_id] = user['id']
    redirect '/'
  rescue # 名前が重複していた場合など
    @error = "その名前は使われています"
    erb :login
  end
end

# ログイン
post '/login' do
  user = db.execute("SELECT * FROM users WHERE username = ?", [params[:username]]).first
  if user && BCrypt::Password.new(user['password_digest']) == params[:password]
    session[:user_id] = user['id']
    redirect '/'
  else
    @error = "名前かパスワードが違います"
    erb :login
  end
end

# ログアウト
get '/logout' do
  session.clear
  redirect '/'
end

# 運動追加
post '/add' do
  redirect '/' unless logged_in?
  db.execute("INSERT INTO workouts (user_id, name, duration, date) VALUES (?, ?, ?, ?)",
             [session[:user_id], params[:name], params[:duration], Time.now.strftime('%Y-%m-%d')])
  redirect '/'
end

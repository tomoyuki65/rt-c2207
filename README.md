# Rails7によるマイクロポスト投稿アプリケーション
Railsチュートリアルを参考にしつつ、最新技術を盛り込んだマイクロポスト投稿アプリケーションです。

## 機能一覧
・ユーザー登録・更新・表示・削除機能  
・ログイン・ログアウト機能  
・認可機能  
・アカウント有効化機能（メール送信機能）  
・パスワード再設定機能（メール送信機能）  
・マイクロポスト投稿・表示・削除機能  
・マイクロポストの画像投稿機能（GCSを利用）  
・ユーザーのフォロー機能  
・ステータスフィード表示機能  

## 使用技術
Ruby "3.1.2"  
Ruby on Rails "7.0.3"  
Docker  
docker-compose  
RSpec  
CircleCI  
Heroku  
Google Cloud Storage  
Hotwire(Turbo)  

## 注意点
このアプリの起動には以下が必要です。  
・docker環境  
・db.env（開発環境やテスト環境用のdb接続情報）  
・yarnのインストール（yarn install --frozen-lockfile）  
・master.key（credentials.yml.enc用）  

## 使い方
①ビルド用のコマンド  
```
$ docker compose build --no-cache
```  

<br/>

②起動用のコマンド  
```
$ docker compose up -d
```  

<br/>

③db作成用のコマンド  
```
$ docker compose exec web rails db:create
```  

<br/>

④マイグレーション用のコマンド  
```
$ docker compose exec web rails db:migrate
```

## 環境変数
RAILS_ENV=production  
RAILS_MASTER_KEY=master.key  
RAILS_SERVE_STATIC_FILES=true（アセットパイプライン用）  

## 参考記事
技術ブログも作成していますので、興味がある方は下記の記事を参考にしてみて下さい。  
[・Railsチュートリアルをカスタマイズしてポートフォリオを作成する方法【Docker・Rails7・CircleCI対応】](https://tomoyuki65.com/how-to-customize-a-rails-tutorial-to-create-a-portfolio/)  
[・Railsチュートリアル（第6版）を進めるための参考資料](https://tomoyuki65.com/rails-tutorial-6-reference-material/)  

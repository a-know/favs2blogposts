# favs2blogposts
## About
Twitter での「いいね」（fav）を自動で「はてなブログ」に投稿する heroku app です。

## Setup
### 1. 準備するもの
以下のもの・準備が必要です。

* はてなアカウント
* 投稿先となるはてなブログ
* はてなの[アプリケーション登録](https://www.hatena.ne.jp/oauth/develop)
* Twitter アカウント
* [Twitter app の登録](https://apps.twitter.com/)
* [heroku](https://www.heroku.com/) のアカウント
* Ruby が実行可能な PC
    * Mac なら最初から入っているもので大丈夫（多分）

### 2. はてなアプリケーションの認証情報の取得
[はてなブログ API 用の gem を書いた - blog.kymmt.com](http://blog.kymmt.com/entry/hatenablog_gem) に書いて頂いている手順で認証情報を取得します。（Ruby が必要です。）

```ruby
$ gem install hatenablog
$ get_access_token <コンシューマキー> <コンシューマシークレット>
Visit this website and get the PIN: https://www.hatena.com/oauth/authorize?oauth_token=XXXXXXXXXXXXXXXXXXXX
Enter the PIN: <ここに PIN を入力する> [Enter]
Access token: <アクセストークン>
Access token secret: <アクセストークンシークレット>
```

favs2blogposts の動作には以下の4つの情報が必要です。

* コンシューマーキー
* コンシューマーシークレット
* アクセストークン
* アクセストークンシークレット

### 3. heroku へのデプロイを行う

以下のボタンを押すと、デプロイ設定画面が開きます。

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

[Deploy](https://cloud.githubusercontent.com/assets/1097533/17794851/045d2de4-65ee-11e6-87cb-87ca6cb34eac.png)

開いた画面で、以下の情報を入力してください。

* App Name
    * `ここで指定した文字列.herokuapp.com` というドメイン名になります。
    * 指定しない場合、ランダムな文字列が割り当てられます。
* Runtime Selection
    * 通常は初期設定（ `United States` ）のままで問題ないはずです。
* Config Variables
    * TWITTER_CONSUMER_KEY
        * 登録した Twitter app の管理画面から取得できる consumer key を入力します
    * TWITTER_CONSUMER_SECRET
        * 登録した Twitter app の管理画面から取得できる consumer secret を入力します
    * TWITTER_ACCESS_TOKEN
        * 登録した Twitter app の管理画面から取得できる access token を入力します
    * TWITTER_ACCESS_TOKEN_SECRET
        * 登録した Twitter app の管理画面から取得できる access token secret を入力します
    * HATENA_CONSUMER_KEY
        * 登録した はてなアプリケーション の管理画面から取得できる consumer key を入力します
    * HATENA_CONSUMER_SECRET
        * 登録した はてなアプリケーション の管理画面から取得できる consumer secret を入力します
    * HATENA_ACCESS_TOKEN
        * 登録した はてなアプリケーション の管理画面から取得できる access token を入力します
    * HATENA_ACCESS_TOKEN_SECRET
        * 登録した はてなアプリケーション の管理画面から取得できる access token secret を入力します
    * HATENA_USER_ID
        * はてなブログへ投稿するユーザーのはてなIDを入力します。（id:xxxxx の xxxxx の部分）
    * HATENA_BLOG_ID
        * 登録するはてなブログの初期ドメインを入力します。 `example.hatenablog.com` などです。
        * カスタムドメインを設定している場合でも、初期ドメインを入力してください。
    * USER_SCREEN_NAME
        * 取得対象の Twitter ID を入力します。（ `@a-know` の `a-know` の部分）
    * BLOG_TIMEZONE
        * タイムゾーンを指定します。
        * 通常は初期値（ `Asia/Tokyo` ）のままで問題ないはずです。
        * このタイムゾーンを基準として投稿タイトル（ `yy-mm-dd の favs` ）が決められます。

これらの情報の入力が完了したら、 `Deploy for Free` ボタンを押し、しばらくすると以下の様な表示が出て、デプロイが完了します。

[finished](https://cloud.githubusercontent.com/assets/1097533/17794880/446ffc7c-65ee-11e6-88e6-36990b404bca.png)


### 4. 定期実行の設定
毎日決められた時間に favs の収集・ブログへの投稿を行うよう、スケジュール設定を行う必要があります。

heroku app の管理画面 `https://dashboard.heroku.com/apps/{3. で指定した App Name}` を開き、 `Heroku Scheduler` リンクを押します。

[schedule](https://cloud.githubusercontent.com/assets/1097533/17794888/59d1b5c4-65ee-11e6-8471-1e87cce4286d.png)

するとスケジュール設定画面になりますので、以下の画像を参考に設定をし保存してください。

[Setting schedule](https://cloud.githubusercontent.com/assets/1097533/17794893/7505e66c-65ee-11e6-9737-ffbd9f306be2.png)

注意事項としては、実行時間の指定は UTC での指定になる点です。
おすすめの指定は `15:30` です。これは日本時間でいうと 0:30 になり、そのタイミングで前日の favs を収集し投稿することになります。


## 注意事項
* 収集・投稿できるものは「その日favしたツイート」ではなく、「前回はてなブログに自動投稿されてから今回の自動実行の間までにつぶやかれたツイートのうち、favされたもの」となります。
    * 例えば、昔のツイートをその日にfavしても収集・投稿されません。
* 実行するたびに、「ここまでのツイートをブログに登録した」という情報をアプリケーションが記録しています。
    * 初回はデプロイしたタイミングで記録されますので、最初の投稿はそのタイミング以降のfavが投稿されることになります。
* （適当な作りなので、）1回で100を超えるfavは登録できません。
    * 先頭100件を登録します

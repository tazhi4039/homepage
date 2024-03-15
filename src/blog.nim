import std/[strutils, sequtils, asyncdispatch, sets, hashes, json, sugar]
import karax/[karaxdsl, vdom], jester, ws, ws/jester_extra
import mydb
import db_connector/db_mysql
import md

# try:
# var db = open("0.0.0.0:3307", "root", "password", "mydb")
# db.exec(sql"CREATE TABLE IF NOT EXISTS articles (id SERIAL PRIMARY KEY, title TEXT, body TEXT)")

converter toString(x: VNode): string = $x

converter toText(s: string): VNode = text s

template index*(rest: untyped): untyped =
  buildHtml(html(lang = "en")):
    head:
      meta(charset = "UTF-8", name = "viewport",
          content = "width=device-width, initial-scale=1")
      link(rel = "stylesheet", href = "https://unpkg.com/@picocss/pico@latest/css/pico.min.css")
      script(src = "https://unpkg.com/htmx.org@1.6.0")
      title: text "my blog"
    body:
      nav(class = "container-fluid"):
        ul:
          li: a(href = "/", class = "secondary"): strong: text "azarashillのホームページ"
          li: a(href = "https://github.com/tazhi4039/homepage",
              class = "secondary", target = "_blank"): text "repository"
      main(class = "container"): rest

template articleCard*(article: Article): untyped =
  buildHtml(tdiv(class = "card")):
    tdiv(class = "section"):
      a(hx-get = "/articles/" & article.id.intToStr,
          hx-boost = "true",
          hx-target = "body",
          hx-push-url = "true",
        ): text article.title



proc root(): VNode =
  let hoge: seq[string] = @[
    "## 2024/03/06",
    "CIを入れてみた。動くと嬉しい",
    "## 2024/03/08",
    "CIが動いた。ネットの情報をかき集めてAWSでhttps化した。",
    "#### 次の目標",
    "ローカル開発を楽にする。"
  ]
  index:
    tdiv(id = "main"): "色々と作っていきたい"
    tdiv:
      tdiv:
        for hog in hoge:
          vnim hog
      h2: "2024/03/09"
      tdiv: "普通にローカル実行できた。最近はtasks.jsonを使うのにハマっている。tasks.jsonにビルド&実行を登録していた、のだけれど、"
      tdiv: "サーバーが起動している状態でタスクを開始するとタスクを止めるか再起動するか選べと言われるのが邪魔だった、のだけれど"
      tdiv: "vscodeにはRestart Running Taskというコマンドがあるのを今知った。(stackoverflowに書いてあった)"
      tdiv: "なのでそのコマンドを使って起動している。watchとかも出来ないことはないのでどうとでもなりそう。"
      br: ""
      tdiv: "pico css?はheaderタグにmbをつけているけどこのmarginの付け方は良くない。うっかりするとheaderと関連するものを上のテキストだと勘違いする"
      h4: "課題"
      ul:
        li: "改行の度にtdivを作っていて面倒くさい。txtをimportしたりしたい"
        li: "トップページしか無いのがあんまりよろしくない"
        li: "更新履歴なんかを置いておきたい"
      h2: "2024/03/09 その2"
      tdiv: "この文章を「開発日誌」と位置づけることにする。日記のような内容はここには書かない。早く書きたいので別のページを作りたい。"
      h2: "2024/03/10"
      tdiv: "Formの作り方の難しさについて考えていた。Formはどんな複雑なオブジェクトで、それをどんなに分割しようと最終的に一同に会して機能させなければいけないという点で複雑で"
      tdiv: "おまけにonBlurやらonChangeやらイベントでvalidationを発火させるだのさせないだの、あるいはformatをするだのしないだのが絡んでくるので非常にややこしい。"
      tdiv: "後者のややこしさはソフトウェアエンジニアリングに関わる難しさでもある。僕の言うソフトウェアエンジニアリングは「変化の必要が起きた際に素早く変更しておけるようにしておくこと」"
      tdiv: "それから、「起こらない変化を予期して可能性を閉じたなるべくシンプルな設計にすること」を含む。"
      tdiv: "なんかこの辺りをうまいことやっていきたい。"
      h4: "仮説:Formにはユニットテストが必須である。"
      tdiv: "言ってしまえば当たり前といえば当たり前なんだけど、Formにはユニットテストがあった方が良い。"
      tdiv: "ユニットテストというか、Formコンポーネントに対するコンポーネントテスト。"
      tdiv: "コンポーネントテストはオブジェクト構造がネストしていようとUIがネスト(というか配列？)になっていない限りは平たく扱うことが出来る。"
      tdiv: "階層が複雑になりやすいFormにはユニットテストはかなり有効だと感じる(逆に、それ以外の場面でコンポーネントのテストを行うことに対して私はかなり懐疑的である)"
      tdiv: "後者についても書くつもりがあったんだけど今日は疲れたのでおしまい。開発日誌と位置づけると言いつつ開発日誌ではないものを書いてしまった"
      h4: "課題"
      ul:
        li: "課題が見えづらくなってきた。cssを自分で当てたい。tailwindを入れて、jitを使えるところまで持っていきたい。"
        li: "文章を書くのが楽しすぎてnimないしhtmxの改善に全く踏み込めない。早くなんとかしたい。"

      h2: "2024/03/13"
      tdiv: "メモ"
      tdiv: "ドメインに関わる名刺に適切な動詞を与えないことは直接インターフェースの貧弱さにつながる。"
      tdiv: "同様に、エンティティとエンティティの関係性を「idを紐づける」というようなDB視点の書き方をしてはいけない"
      tdiv: "バックエンドエンジニアが要件定義を行うとなぜかこういうことが起きる。不思議だ。"
      for text in [
        "## 2024/03/15",
        "mdっぽい記法を使って書いてみたいのとnimらしいことをしていなかったのでちょっと試してみる",
        "楽しいけど難しい。ユニットテストもあんまり親切じゃなくてエコサイクルが微妙な言語のデメリットを肌で感じている"]:
        vnim text


router myrouter:
  get "/":
    resp root()
  get "/articles":
    let html = buildHtml:
      form(action = "/articles", `method` = "post", hx-boost = "true"):
        input(name = "title")
        textarea(name = "body")
        button: "Submit"
    resp html

proc main() =
  let settings = newSettings(port = Port 8081)
  var jester = initJester(myrouter, settings = settings)
  jester.serve()

when isMainModule:
  main()

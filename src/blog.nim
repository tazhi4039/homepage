import std/[strutils, sequtils, asyncdispatch, sets, hashes, json, sugar]
import karax/[karaxdsl, vdom], jester, ws, ws/jester_extra
import mydb
import db_connector/db_mysql

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
        ul: li: a(href = "/", class = "secondary"): strong: text "azarashillのホームページ"
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
  # let articles = db.getArticles()
  index:
    tdiv(id = "main"): "色々と作っていきたい"
    tdiv:
      h2: "2024/03/06"
      tdiv: "CIを入れてみた。動くと嬉しい"
      h2: "2024/03/08"
      tdiv: "CIが動いた。ネットの情報をかき集めてAWSでhttps化した。"
      h4: "次の目標"
      tdiv: "ローカル開発を楽にする。"
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
  # post "/articles":
  #   let article = db.saveArticle((title: request.params["title"],
  #       body: request.params["body"]))
  #   redirect "/articles/" & article.id.intToStr
  # get "/articles/@id":
  #   let id = request.params["id"].parseInt()
  #   let article = db.getArticles().filter((a) => a.id == id)[0]
  #   let html = buildHtml tdiv:
  #     h1: text article.title
  #     p: text article.body
  #   resp html


  # get "/":
  #   let html = index:
  #     h1: text "Join a room!"
  #     form(action = "/chat", `method` = "get"):
  #       label:
  #         "Room".text
  #         input(type = "text", name = "room")
  #       label:
  #         text "Username"
  #         input(type = "text", name = "name")
  #       input(type = "submit", value = "Join")
  #   resp html
  # get "/chat":
  #   let html = index:
  #     h1: text @"room"
  #     tdiv(hx-ws = "connect:/chat/" & @"room" & "/" & @"name"):
  #       p(id = "content")
  #       form(hx-ws = "send", id = "message"): chatInput()
  #   resp html
  # get "/chat/@room/@name":
  #   var ws = await newWebSocket(request)
  #   var user = User(name: @"name", socket: ws)
  #   try:
  #     chatrooms.mgetOrPut(@"room", initHashSet[User]()).incl(user)
  #     let joined = buildMessage:
  #       italic: text user.name
  #       italic: text " has joined the room"
  #     chatrooms[@"room"].sendAll(joined)
  #     while user.socket.readyState == Open:
  #       let sentMessage = (await user.socket.receiveStrPacket()).parseJson["message"]
  #       discard user.socket.send(chatInput())
  #       let reply = buildMessage:
  #         bold: text user.name
  #         text ": " & sentMessage.getStr()
  #       chatrooms[@"room"].sendAll(reply)
  #   except:
  #     chatrooms[@"room"].excl(user)
  #     let left = buildMessage:
  #       italic: text user.name
  #       italic: text " has left the room"
  #     chatrooms[@"room"].sendAll(left)
  #   resp ""

proc main() =
  let settings = newSettings(port = Port 8081)
  var jester = initJester(myrouter, settings = settings)
  jester.serve()

when isMainModule:
  main()

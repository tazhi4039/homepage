import std/[strutils, sequtils, asyncdispatch, sets, hashes, json, sugar]
import karax/[karaxdsl, vdom], jester, ws, ws/jester_extra
# import mydb
import db_connector/db_mysql
import diary_db
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

# template articleCard*(article: Article): untyped =
#   buildHtml(tdiv(class = "card")):
#     tdiv(class = "section"):
#       a(hx-get = "/articles/" & article.id.intToStr,
#           hx-boost = "true",
#           hx-target = "body",
#           hx-push-url = "true",
#         ): text article.title



proc root(): VNode =
  let articles = diary_db.getArticles()

  index:
    h2(id = "main"): "色々と作っていきたい"
    # tdiv:
    #   a(hx-get = "/articles/1", hx-boost = "true",
    #       hx-target = "body", hx-push-url = "true", ): "リンク"
    tdiv:
      for article in articles:
        for line in article:
          vnim line

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
  get "/articles/@id":
    let id = request.params["id"].parseInt()
    let article = diary_db.getArticles()[id]
    let html = buildHtml tdiv:
      for line in article:
        vnim line
    resp html

proc main() =
  let settings = newSettings(port = Port 8081)
  var jester = initJester(myrouter, settings = settings)
  jester.serve()

when isMainModule:
  main()

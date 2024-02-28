import std/[strutils, sequtils, sugar]
import db_connector/db_mysql

type ArticleWithoutId* = object of RootObj
  title*: string
  body*: string

type Article* = object of ArticleWithoutId
  id*: int

proc saveArticle*(db: DbConn, article: tuple[title: string,
    body: string]): Article =
  let id = db.insert(sql"INSERT INTO articles (title, body) VALUES (?, ?)",
      "id", article.title, article.body)
  Article(id: id, title: article.title, body: article.body)

proc getArticles*(db: DbConn): seq[Article] =
  let rows = db.getAllRows(sql"SELECT id, title, body FROM articles")
  rows.map((row) => Article(id: row[0].parseInt, title: row[1], body: row[2]))

import ../../src/mydb

let article = ArticleWithoutId(title: "title", body: "body")
doAssert article.title == 0


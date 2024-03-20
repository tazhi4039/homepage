import std/[os]
import std/[sequtils, strutils, algorithm, times]

proc getArticles*(): seq[seq[string]] =
  let directory = getCurrentDir() / "src/diary"
  let articles = toSeq(walkDir(directory))
  type Dir = tuple[kind: PathComponent, path: string]
  let contents = articles.sorted(proc (a, b: Dir): int =
    return a.path.cmp(b.path)
  , Descending).map(proc (article: Dir): string =

    var f = open(article.path)
    let str = f.readAll()
    return str
  ).map(proc (article: string): seq[string] =
    article.split("\n")
  )

  return contents

when isMainModule:
  let articles = getArticles()
  doAssert(articles[0][0] == "## 2024/03/08")

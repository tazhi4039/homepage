import karax/[karaxdsl, vdom]
import macros

proc vnim*(text: string): VNode =
  let rest = text.substr(2)
  echo "substr"
  echo text.substr(0, 1)

  if text.substr(0, 1) == "# ":
    buildHtml(h1): text text.substr(2)
  elif text.substr(0, 2) == "## ":
    buildHtml(h2): text text.substr(3)
  elif text.substr(0, 3) == "### ":
    buildHtml(h3): text text.substr(4)
  elif text.substr(0, 4) == "#### ":
    buildHtml(h4): text text.substr(5)
  else:
    buildHtml(tdiv): text text

when isMainModule:
  var str = ""
  let node = vnim("# Hello, Karax!")
  var str2 = ""
  assert(node.kind == VNodeKind.h1, "hogehogefuggafuga")
  node.toString(str, 2)
  let expected = buildHtml(h1): text "Hello, Karax!"
  expected.toString(str2, 2)
  assert(str == str2)
  # assert(node.text == "Hello, Karax!", "this is " & node.text & "!!!")

let hoge: seq[string] = @[
  "## 2024/03/06",
  "CIを入れてみた。動くと嬉しい"
]

for hog in hoge:
  echo hog

import std/[os, strformat]

task docs, "Deploy doc html + search index to public/ directory":
  let
    name = "bbansi"
    version = gorgeEx("git describe --tags --match 'v*'").output
    srcFile = "src" / (name & ".nim")
    gitUrl = fmt"https://github.com/daylinmorgan/{name}"
  selfExec fmt"doc --project --index:on --git.url:{gitUrl} --git.commit:{version} --outdir:public {srcFile}"
  withDir "public":
    mvFile(name & ".html", "index.html")
    for file in walkDirRec(".", {pcFile}):
      # As we renamed the file, we need to rename that in hyperlinks
      exec(fmt"sed -i -r 's|{name}\.html|index.html|g' {file}")
      # drop 'src/' from titles
      exec(fmt"sed -i -r 's/<(.*)>src\//<\1>/' {file}")

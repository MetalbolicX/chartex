let writeLine = (text: string): unit => StreamIO.writeStdout(text ++ "\n")

let writeErrorLine = (text: string): unit => StreamIO.writeStderr(text ++ "\n")

let run = (): unit => {
  let parsed = Args.parse()

  if parsed.help {
    writeLine(Args.helpText)
    StreamIO.exit(0)
  } else if parsed.version {
    writeLine("chartex cli (rescript)")
    StreamIO.exit(0)
  } else {
    let parser = Parser.create(~format=parsed.options.format, ~noHeader=parsed.options.noHeader)

    StreamIO.readInput(
      ~inputPath=?parsed.inputPath,
      ~onChunk=chunk => parser.pushChunk(chunk),
      ~onEnd=() => {
        switch parser.finish() {
        | Parser.Error(message) => {
            writeErrorLine(message)
            StreamIO.exit(2)
          }
        | Parser.Ok(rows) => {
            let result = Main.runWithOptions(parsed.options, rows)
            if result.success {
              writeLine(result.output)
              StreamIO.exit(0)
            } else {
              writeErrorLine(result.error->Option.getOr("Unknown CLI error"))
              StreamIO.exit(1)
            }
          }
        }
      },
      ~onError=message => {
        writeErrorLine(message)
        StreamIO.exit(1)
      },
    )
  }
}

run()

module P = Bindings.Process

let writeLine = (text: string): unit => StreamIO.writeStdout(text ++ "\n")

let writeErrorLine = (text: string): unit => StreamIO.writeStderr(text ++ "\n")

let run = (): unit => {
  let parsed = Args.parse()

  if parsed.parseError->Option.isSome {
    writeErrorLine(parsed.parseError->Option.getOr("Invalid CLI arguments"))
    P.exit(1)
  } else if parsed.help {
    writeLine(Args.helpText)
    P.exit(0)
  } else if parsed.version {
    writeLine("chartex cli (rescript)")
    P.exit(0)
  } else {
    let parser =
      Parser.create(
        ~format=parsed.options.format,
        ~noHeader=parsed.options.noHeader,
        ~cfg={maxRows: ?parsed.options.maxRows},
      )

    StreamIO.readInput(
      ~inputPath=?parsed.inputPath,
      ~onChunk=chunk => parser.pushChunk(chunk),
      ~onEnd=() => {
        switch parser.finish() {
        | Parser.Error(message) => {
            writeErrorLine(message)
            P.exit(2)
          }
        | Parser.Ok(rows) => {
            let result = Main.runWithOptions(parsed.options, rows)
            if result.success {
              writeLine(result.output)
              P.exit(0)
            } else {
              writeErrorLine(result.error->Option.getOr("Unknown CLI error"))
              P.exit(1)
            }
          }
        }
      },
      ~onError=message => {
        writeErrorLine(message)
        P.exit(1)
      },
    )
  }
}

run()

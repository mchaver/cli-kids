// Main terminal-based app component

open Types

type appMode =
  | MainMenu
  | PlayingLevel(level)

@val external focus: Dom.element => unit = "focus"
@set external setScrollTop: (Dom.element, int) => unit = "scrollTop"
@get external getScrollHeight: Dom.element => int = "scrollHeight"

@react.component
let make = () => {
  let (gameState, setGameState) = React.useState(() => Storage.loadGameState())
  let (mode, setMode) = React.useState(() => MainMenu)
  let (output, setOutput) = React.useState(() => [
    {text: "╔═══════════════════════════════════════════════════════════════╗", isError: false, isCommand: false},
    {text: "║                     CLI KIDS TERMINAL v1.0                   ║", isError: false, isCommand: false},
    {text: "║               Learn Linux Commands The Hard Way              ║", isError: false, isCommand: false},
    {text: "╚═══════════════════════════════════════════════════════════════╝", isError: false, isCommand: false},
    {text: "", isError: false, isCommand: false},
    {text: "Type 'help' for available commands, 'levels' to see missions", isError: false, isCommand: false},
    {text: "", isError: false, isCommand: false},
  ])
  let (input, setInput) = React.useState(() => "")
  let (commandHistory, setCommandHistory) = React.useState(() => [])
  let (historyIndex, setHistoryIndex) = React.useState(() => -1)
  let inputRef = React.useRef(Null.null)
  let outputRef = React.useRef(Null.null)

  // Auto-focus input
  React.useEffect0(() => {
    switch inputRef.current->Null.toOption {
    | Some(element) => element->focus
    | None => ()
    }
    None
  })

  // Auto-scroll to bottom
  React.useEffect1(() => {
    switch outputRef.current->Null.toOption {
    | Some(element) => setScrollTop(element, getScrollHeight(element))
    | None => ()
    }
    None
  }, [output])

  let addOutput = (lines: array<outputLine>) => {
    setOutput(prev => Array.concat(prev, lines))
  }

  let handleMenuCommand = (cmd: string) => {
    switch String.trim(cmd) {
    | "" => ()
    | "help" => {
        addOutput([
          {text: "", isError: false, isCommand: false},
          {text: "AVAILABLE COMMANDS:", isError: false, isCommand: false},
          {text: "  help          Show this help message", isError: false, isCommand: false},
          {text: "  levels        List all available missions", isError: false, isCommand: false},
          {text: "  play <id>     Start a mission (e.g., play 1)", isError: false, isCommand: false},
          {text: "  stats         Show your progress statistics", isError: false, isCommand: false},
          {text: "  clear         Clear the terminal screen", isError: false, isCommand: false},
          {text: "", isError: false, isCommand: false},
        ])
      }
    | "levels" => {
        let levelLines = Array.concat([
          {text: "", isError: false, isCommand: false},
          {text: "AVAILABLE MISSIONS:", isError: false, isCommand: false},
          {text: "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━", isError: false, isCommand: false},
        ], Array.concat(
          Array.mapWithIndex(Levels.allLevels, (level, idx) => {
            let isCompleted = Array.includes(gameState.completedLevels, level.id)
            let status = isCompleted ? "[COMPLETED]" : "[AVAILABLE]"
            let difficulty = switch level.difficulty {
            | Easy => "EASY"
            | Medium => "MEDIUM"
            | Hard => "HARD"
            }
            {text: `  ${Int.toString(idx + 1)}. ${level.title} - ${level.theme} [${difficulty}] ${status}`, isError: false, isCommand: false}
          }),
          [
            {text: "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━", isError: false, isCommand: false},
            {text: "Use 'play <number>' to start a mission (e.g., play 1)", isError: false, isCommand: false},
            {text: "", isError: false, isCommand: false},
          ]
        ))
        addOutput(levelLines)
      }
    | "stats" => {
        addOutput([
          {text: "", isError: false, isCommand: false},
          {text: "YOUR STATISTICS:", isError: false, isCommand: false},
          {text: `  Missions Completed: ${Int.toString(Array.length(gameState.completedLevels))}/${Int.toString(Array.length(Levels.allLevels))}`, isError: false, isCommand: false},
          {text: `  Commands Learned:   ${Int.toString(Array.length(gameState.unlockedCommands))}`, isError: false, isCommand: false},
          {text: `  Achievements:       ${Int.toString(Array.length(gameState.achievements))}`, isError: false, isCommand: false},
          {text: "", isError: false, isCommand: false},
        ])
      }
    | "clear" => {
        setOutput(_ => [])
      }
    | _ => {
        if String.startsWith(cmd, "play ") {
          let levelNum = String.sliceToEnd(cmd, ~start=5)->String.trim
          switch Int.fromString(levelNum) {
          | Some(num) if num >= 1 && num <= Array.length(Levels.allLevels) => {
              switch Levels.allLevels[num - 1] {
              | Some(level) => setMode(_ => PlayingLevel(level))
              | None => addOutput([{text: "Error: Mission not found", isError: true, isCommand: false}])
              }
            }
          | _ => addOutput([{text: "Error: Invalid mission number. Use 'levels' to see available missions.", isError: true, isCommand: false}])
          }
        } else {
          addOutput([{text: `Error: Unknown command '${cmd}'. Type 'help' for available commands.`, isError: true, isCommand: false}])
        }
      }
    }
  }

  let handleLevelComplete = (levelId: string) => {
    setGameState(prev => {
      let newState = Storage.completeLevel(levelId, prev)
      let updatedState = switch Array.length(newState.completedLevels) {
      | 1 => Storage.unlockCommand("mkdir", Storage.unlockCommand("touch", newState))
      | 2 => Storage.unlockCommand("mv", Storage.unlockCommand("rm", newState))
      | 3 => Storage.unlockCommand("cp", newState)
      | 4 => Storage.unlockCommand("echo", newState)
      | 5 => Storage.unlockCommand("grep", Storage.unlockCommand("find", newState))
      | _ => newState
      }

      let withAchievement = if Array.length(newState.completedLevels) == 1 {
        Storage.addAchievement("First Steps", updatedState)
      } else if Array.length(newState.completedLevels) == 3 {
        Storage.addAchievement("Command Master", updatedState)
      } else if Array.length(newState.completedLevels) == Array.length(Levels.allLevels) {
        Storage.addAchievement("Linux Legend", updatedState)
      } else {
        updatedState
      }

      withAchievement
    })

    setMode(_ => MainMenu)
    addOutput([
      {text: "", isError: false, isCommand: false},
      {text: "Mission completed! Returning to main menu...", isError: false, isCommand: false},
      {text: "", isError: false, isCommand: false},
    ])
  }

  let handleKeyDown = (e: ReactEvent.Keyboard.t) => {
    let key = ReactEvent.Keyboard.key(e)
    if key == "ArrowUp" {
      ReactEvent.Keyboard.preventDefault(e)
      if Array.length(commandHistory) > 0 && historyIndex < Array.length(commandHistory) - 1 {
        let newIndex = historyIndex + 1
        setHistoryIndex(_ => newIndex)
        let cmd = commandHistory[Array.length(commandHistory) - 1 - newIndex]
        setInput(_ => cmd->Option.getOr(""))
      }
    } else if key == "ArrowDown" {
      ReactEvent.Keyboard.preventDefault(e)
      if historyIndex > 0 {
        let newIndex = historyIndex - 1
        setHistoryIndex(_ => newIndex)
        let cmd = commandHistory[Array.length(commandHistory) - 1 - newIndex]
        setInput(_ => cmd->Option.getOr(""))
      } else if historyIndex == 0 {
        setHistoryIndex(_ => -1)
        setInput(_ => "")
      }
    }
  }

  let handleSubmit = (e: ReactEvent.Form.t) => {
    ReactEvent.Form.preventDefault(e)
    let cmd = String.trim(input)

    if cmd != "" {
      addOutput([{text: `> ${cmd}`, isError: false, isCommand: true}])
      setCommandHistory(prev => Array.concat(prev, [cmd]))
      setHistoryIndex(_ => -1)
      handleMenuCommand(cmd)
      setInput(_ => "")
    }
  }

  <div className="app">
    {switch mode {
    | MainMenu =>
      <div className="terminal-container">
        <div className="terminal-output" ref={outputRef->Obj.magic}>
          {Array.map(output, line => {
            let className = if line.isCommand {
              "terminal-line command"
            } else if line.isError {
              "terminal-line error"
            } else {
              "terminal-line"
            }
            <div key={Math.random()->Float.toString} className>
              {React.string(line.text)}
            </div>
          })->React.array}
        </div>
        <form className="terminal-input-form" onSubmit={handleSubmit}>
          <span className="terminal-prompt">{React.string("> ")}</span>
          <input
            ref={inputRef->Obj.magic}
            className="terminal-input"
            type_="text"
            value={input}
            onChange={e => {
              let value = ReactEvent.Form.target(e)["value"]
              setInput(_ => value)
            }}
            onKeyDown={handleKeyDown}
            autoFocus={true}
            spellCheck={false}
          />
        </form>
      </div>

    | PlayingLevel(level) =>
      <Terminal
        level
        onComplete={() => handleLevelComplete(level.id)}
        onBack={() => {
          setMode(_ => MainMenu)
          addOutput([{text: "Returned to main menu.", isError: false, isCommand: false}])
        }}
      />
    }}
  </div>
}

@val external focus: Dom.element => unit = "focus"
@set external setScrollTop: (Dom.element, int) => unit = "scrollTop"
@get external getScrollHeight: Dom.element => int = "scrollHeight"

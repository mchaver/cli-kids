// Terminal component

open Types

@val external focus: Dom.element => unit = "focus"
@val external setTimeout: (unit => unit, int) => int = "setTimeout"
@send external repeat: (string, int) => string = "repeat"

@react.component
let make = (
  ~level: level,
  ~onComplete: unit => unit,
) => {
  let (output, setOutput) = React.useState(() => [
    {text: level.story, isError: false, isCommand: false},
    {text: "", isError: false, isCommand: false},
    {text: "Type 'help' for available commands.", isError: false, isCommand: false},
    {text: "", isError: false, isCommand: false},
  ])

  let (input, setInput) = React.useState(() => "")
  let (terminalState, setTerminalState) = React.useState((): CommandExecutor.terminalState => {
    currentPath: [],
    fileSystem: level.initialFileSystem,
    commandHistory: [],
  })

  let (completedObjectives, setCompletedObjectives) = React.useState(() => [])
  let (showHint, setShowHint) = React.useState(() => None)
  let inputRef = React.useRef(Null.null)

  // Auto-focus input
  React.useEffect0(() => {
    switch inputRef.current->Null.toOption {
    | Some(element) => element->focus
    | None => ()
    }
    None
  })

  // Check objectives
  React.useEffect2(() => {
    let newCompleted = Array.filter(level.objectives, obj =>
      obj.checkCompletion(terminalState.commandHistory, terminalState.fileSystem)
    )

    if Array.length(newCompleted) != Array.length(completedObjectives) {
      setCompletedObjectives(_ => Array.map(newCompleted, obj => obj.id))

      // Check if all objectives complete
      if Array.length(newCompleted) == Array.length(level.objectives) {
        setOutput(prev => Array.concat(prev, [
          {text: "", isError: false, isCommand: false},
          {text: "="->repeat(50), isError: false, isCommand: false},
          {text: level.successMessage, isError: false, isCommand: false},
          {text: "="->repeat(50), isError: false, isCommand: false},
          {text: "", isError: false, isCommand: false},
        ]))
        // Delay completion to show message
        let _ = setTimeout(() => onComplete(), 2000)
      }
    }
    None
  }, (terminalState, level))

  let handleSubmit = (e: ReactEvent.Form.t) => {
    ReactEvent.Form.preventDefault(e)

    if String.trim(input) != "" {
      let prompt = {
        let path = Array.length(terminalState.currentPath) == 0
          ? "/"
          : "/" ++ Array.joinWith(terminalState.currentPath, "/")
        `user@cli-kids:${path}$ `
      }

      // Handle clear command specially
      if String.trim(input) == "clear" {
        setOutput(_ => [])
        setInput(_ => "")
      } else {

    // Execute command
    let (result, newState) = CommandExecutor.executeCommand(input, terminalState)

    // Update state
    setTerminalState(_ => {
      ...newState,
      commandHistory: Array.concat(newState.commandHistory, [input]),
    })

    // Add to output
    let newOutput = Array.concat(output, [{text: prompt ++ input, isError: false, isCommand: true}])

    let finalOutput = switch result {
    | Success(text) =>
      if text == "" {
        newOutput
      } else {
        Array.concat(newOutput, [{text, isError: false, isCommand: false}])
      }
    | Error(text) =>
      if text == "" {
        newOutput
      } else {
        Array.concat(newOutput, [{text, isError: true, isCommand: false}])
      }
    }

        setOutput(_ => finalOutput)
        setInput(_ => "")
        setShowHint(_ => None)
      }
    }
  }

  let currentObjective = Array.find(level.objectives, obj =>
    !Array.includes(completedObjectives, obj.id)
  )

  let handleHintClick = () => {
    switch currentObjective {
    | Some(obj) => setShowHint(_ => Some(obj.hint))
    | None => ()
    }
  }

  let prompt = {
    let path = Array.length(terminalState.currentPath) == 0
      ? "/"
      : "/" ++ Array.joinWith(terminalState.currentPath, "/")
    `user@cli-kids:${path}$ `
  }

  <div className="terminal-container">
    <div className="terminal-header">
      <div className="terminal-title">
        {React.string(level.title ++ " - " ++ level.theme)}
      </div>
      <div className="terminal-objectives">
        {React.string("Objectives: " ++ Int.toString(Array.length(completedObjectives)) ++ "/" ++ Int.toString(Array.length(level.objectives)))}
      </div>
    </div>

    <div className="objectives-panel">
      {Array.map(level.objectives, obj => {
        let isCompleted = Array.includes(completedObjectives, obj.id)
        <div key={obj.id} className={isCompleted ? "objective completed" : "objective"}>
          <span className="objective-icon">{React.string(isCompleted ? "✓" : "○")}</span>
          <span className="objective-text">{React.string(obj.description)}</span>
        </div>
      })->React.array}

      {switch (currentObjective, showHint) {
      | (Some(_), None) =>
        <button className="hint-button" onClick={_ => handleHintClick()}>
          {React.string("💡 Show Hint")}
        </button>
      | (Some(_), Some(hint)) =>
        <div className="hint-box">
          <div className="hint-label">{React.string("Hint:")}</div>
          <div className="hint-text">{React.string(hint)}</div>
        </div>
      | (None, _) => React.null
      }}
    </div>

    <div className="terminal-output">
      {Array.map(output, (line) => {
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
      <span className="terminal-prompt">{React.string(prompt)}</span>
      <input
        ref={inputRef->Obj.magic}
        className="terminal-input"
        type_="text"
        value={input}
        onChange={e => {
          let value = ReactEvent.Form.target(e)["value"]
          setInput(_ => value)
        }}
        autoFocus={true}
        spellCheck={false}
      />
    </form>
  </div>
}

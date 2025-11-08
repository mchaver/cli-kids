// Main app component

open Types

type screen =
  | LevelSelect
  | Playing(level)

@react.component
let make = () => {
  let (gameState, setGameState) = React.useState(() => Storage.loadGameState())
  let (screen, setScreen) = React.useState(() => LevelSelect)

  let handleSelectLevel = (levelId: string) => {
    switch Levels.getLevelById(levelId) {
    | Some(level) => setScreen(_ => Playing(level))
    | None => ()
    }
  }

  let handleLevelComplete = (levelId: string) => {
    setGameState(prev => {
      let newState = Storage.completeLevel(levelId, prev)
      // Unlock new commands based on level completion
      let updatedState = switch Array.length(newState.completedLevels) {
      | 1 => Storage.unlockCommand("mkdir", Storage.unlockCommand("touch", newState))
      | 2 => Storage.unlockCommand("mv", Storage.unlockCommand("rm", newState))
      | 3 => Storage.unlockCommand("cp", newState)
      | 4 => Storage.unlockCommand("echo", newState)
      | 5 => Storage.unlockCommand("grep", Storage.unlockCommand("find", newState))
      | _ => newState
      }

      // Add achievement for first level
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

    // Return to level select after a delay
    let _ = setTimeout(() => setScreen(_ => LevelSelect), 2500)
  }

  let handleBackToMenu = () => {
    setScreen(_ => LevelSelect)
  }

  <div className="app">
    {switch screen {
    | LevelSelect =>
      <LevelSelector gameState onSelectLevel={handleSelectLevel} />

    | Playing(level) =>
      <div className="game-screen">
        <button className="back-button" onClick={_ => handleBackToMenu()}>
          {React.string("← Back to Menu")}
        </button>
        <Terminal
          level
          onComplete={() => handleLevelComplete(level.id)}
        />
      </div>
    }}
  </div>
}

@val external setTimeout: (unit => unit, int) => int = "setTimeout"

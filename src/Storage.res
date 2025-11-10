// LocalStorage wrapper for game state

open Types

@val @scope("localStorage")
external getItemRaw: string => option<string> = "getItem"

let getItem = (key: string): option<string> => getItemRaw(key)

@val @scope("localStorage")
external setItem: (string, string) => unit = "setItem"

let storageKey = "cli-kids-game-state"

// Default game state
let defaultGameState: gameState = {
  currentLevel: None,
  completedLevels: [],
  unlockedCommands: ["pwd", "ls", "cd", "cat", "help", "clear"],
  achievements: [],
}

// Save game state
let saveGameState = (state: gameState): unit => {
  let json = JSON.stringifyAny(state)
  switch json {
  | Some(str) => setItem(storageKey, str)
  | None => ()
  }
}

// Load game state
let loadGameState = (): gameState => {
  switch getItem(storageKey) {
  | Some(json) =>
    switch JSON.parseExn(json) {
    | state =>
      // Try to decode the state
      switch state {
      | Object(_) as obj => {
          // Extract fields safely
          let completedLevels = switch obj
            ->JSON.Decode.object
            ->Option.flatMap(dict => Dict.get(dict, "completedLevels"))
            ->Option.flatMap(JSON.Decode.array) {
          | Some(arr) =>
            Array.filterMap(arr, item =>
              switch JSON.Decode.string(item) {
              | Some(str) => Some(str)
              | None => None
              }
            )
          | None => []
          }

          let unlockedCommands = switch obj
            ->JSON.Decode.object
            ->Option.flatMap(dict => Dict.get(dict, "unlockedCommands"))
            ->Option.flatMap(JSON.Decode.array) {
          | Some(arr) =>
            Array.filterMap(arr, item =>
              switch JSON.Decode.string(item) {
              | Some(str) => Some(str)
              | None => None
              }
            )
          | None => defaultGameState.unlockedCommands
          }

          let achievements = switch obj
            ->JSON.Decode.object
            ->Option.flatMap(dict => Dict.get(dict, "achievements"))
            ->Option.flatMap(JSON.Decode.array) {
          | Some(arr) =>
            Array.filterMap(arr, item =>
              switch JSON.Decode.string(item) {
              | Some(str) => Some(str)
              | None => None
              }
            )
          | None => []
          }

          {
            currentLevel: None,
            completedLevels,
            unlockedCommands,
            achievements,
          }
        }
      | _ => defaultGameState
      }
    | exception _ => defaultGameState
    }
  | None => defaultGameState
  }
}

// Mark level as completed
let completeLevel = (levelId: string, state: gameState): gameState => {
  if Array.includes(state.completedLevels, levelId) {
    state
  } else {
    let newState = {
      ...state,
      completedLevels: Array.concat(state.completedLevels, [levelId]),
    }
    saveGameState(newState)
    newState
  }
}

// Unlock command
let unlockCommand = (command: string, state: gameState): gameState => {
  if Array.includes(state.unlockedCommands, command) {
    state
  } else {
    let newState = {
      ...state,
      unlockedCommands: Array.concat(state.unlockedCommands, [command]),
    }
    saveGameState(newState)
    newState
  }
}

// Add achievement
let addAchievement = (achievement: string, state: gameState): gameState => {
  if Array.includes(state.achievements, achievement) {
    state
  } else {
    let newState = {
      ...state,
      achievements: Array.concat(state.achievements, [achievement]),
    }
    saveGameState(newState)
    newState
  }
}

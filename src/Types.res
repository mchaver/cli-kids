// Core types for the game

type rec fileType =
  | File(string) // File with content
  | Directory(dict<fileType>) // Directory with children

type fileSystem = dict<fileType>

type commandResult =
  | Success(string)
  | Error(string)

type outputLine = {
  text: string,
  isError: bool,
  isCommand: bool,
}

type difficulty =
  | Easy // Shows exact command
  | Medium // Shows hints
  | Hard // Figure it out from context

type objective = {
  id: string,
  description: string,
  hint: string,
  checkCompletion: (array<string>, fileSystem) => bool,
}

type level = {
  id: string,
  title: string,
  theme: string,
  story: string,
  initialFileSystem: fileSystem,
  objectives: array<objective>,
  successMessage: string,
  difficulty: difficulty,
}

type gameState = {
  currentLevel: option<string>,
  completedLevels: array<string>,
  unlockedCommands: array<string>,
  achievements: array<string>,
}

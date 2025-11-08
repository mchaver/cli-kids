// Command executor for virtual terminal

open Types

type terminalState = {
  currentPath: array<string>,
  fileSystem: fileSystem,
  commandHistory: array<string>,
}

// Parse command into parts
let parseCommand = (input: string): array<string> => {
  String.trim(input)
  ->String.split(" ")
  ->Array.filter(s => String.length(s) > 0)
}

// Execute a command and return result
let executeCommand = (input: string, state: terminalState): (commandResult, terminalState) => {
  let parts = parseCommand(input)

  switch parts {
  | [] => (Success(""), state)

  // pwd - print working directory
  | ["pwd"] =>
    let path = if Array.length(state.currentPath) == 0 {
      "/"
    } else {
      "/" ++ Array.joinWith(state.currentPath, "/")
    }
    (Success(path), state)

  // ls - list directory
  | ["ls"] | ["ls", ""] =>
    let files = FileSystem.listDirectory(state.currentPath, state.fileSystem)
    let output = Array.length(files) == 0
      ? ""
      : Array.joinWith(files, "  ")
    (Success(output), state)

  | ["ls", path] =>
    // Handle absolute and relative paths
    let targetPath = if String.startsWith(path, "/") {
      String.split(String.sliceToEnd(path, ~start=1), "/")->Array.filter(s => s != "")
    } else if path == "." {
      state.currentPath
    } else if path == ".." {
      Array.slice(state.currentPath, ~start=0, ~end=Array.length(state.currentPath) - 1)
    } else {
      Array.concat(state.currentPath, [path])
    }
    let files = FileSystem.listDirectory(targetPath, state.fileSystem)
    let output = Array.length(files) == 0
      ? `ls: cannot access '${path}': No such file or directory`
      : Array.joinWith(files, "  ")
    let result = Array.length(files) == 0 ? Error(output) : Success(output)
    (result, state)

  // cd - change directory
  | ["cd"] =>
    (Success(""), {...state, currentPath: []})

  | ["cd", path] =>
    let newPath = if path == "/" {
      []
    } else if path == "." {
      state.currentPath
    } else if path == ".." {
      Array.slice(state.currentPath, ~start=0, ~end=Array.length(state.currentPath) - 1)
    } else if String.startsWith(path, "/") {
      String.split(String.sliceToEnd(path, ~start=1), "/")->Array.filter(s => s != "")
    } else {
      Array.concat(state.currentPath, String.split(path, "/")->Array.filter(s => s != ""))
    }

    if FileSystem.isDirectory(Array.slice(newPath, ~start=0, ~end=Array.length(newPath) - 1),
                              newPath[Array.length(newPath) - 1]->Option.getOr(""),
                              state.fileSystem) || Array.length(newPath) == 0 {
      (Success(""), {...state, currentPath: newPath})
    } else {
      (Error(`cd: ${path}: No such file or directory`), state)
    }

  // cat - display file contents
  | ["cat", filename] =>
    switch FileSystem.getFileContent(state.currentPath, filename, state.fileSystem) {
    | Some(content) => (Success(content), state)
    | None => (Error(`cat: ${filename}: No such file or directory`), state)
    }

  // mkdir - create directory
  | ["mkdir", dirname] =>
    if FileSystem.pathExists(state.currentPath, dirname, state.fileSystem) {
      (Error(`mkdir: cannot create directory '${dirname}': File exists`), state)
    } else {
      let newFS = FileSystem.createDirectory(state.currentPath, dirname, state.fileSystem)
      (Success(""), {...state, fileSystem: newFS})
    }

  // touch - create empty file
  | ["touch", filename] =>
    if FileSystem.pathExists(state.currentPath, filename, state.fileSystem) {
      (Success(""), state) // touch doesn't error if file exists
    } else {
      let newFS = FileSystem.createFile(state.currentPath, filename, "", state.fileSystem)
      (Success(""), {...state, fileSystem: newFS})
    }

  // echo - print text (with optional redirect)
  | parts when Array.length(parts) >= 1 && Array.get(parts, 0) == Some("echo") => {
      let rest = Array.sliceToEnd(parts, ~start=1)
      switch rest {
      | [] => (Success(""), state)
      | [text] => (Success(text), state)
      | [text, ">", filename] =>
        let content = String.replaceAll(text, "\"", "")
        let newFS = FileSystem.createFile(state.currentPath, filename, content, state.fileSystem)
        (Success(""), {...state, fileSystem: newFS})
      | [text, ">>", filename] =>
        let content = String.replaceAll(text, "\"", "")
        let existingContent = FileSystem.getFileContent(state.currentPath, filename, state.fileSystem)
        let newContent = switch existingContent {
        | Some(existing) => existing ++ "\n" ++ content
        | None => content
        }
        let newFS = FileSystem.createFile(state.currentPath, filename, newContent, state.fileSystem)
        (Success(""), {...state, fileSystem: newFS})
      | args => (Success(Array.joinWith(args, " ")), state)
      }
    }

  // rm - remove file
  | ["rm", filename] =>
    if FileSystem.pathExists(state.currentPath, filename, state.fileSystem) {
      let newFS = FileSystem.remove(state.currentPath, filename, state.fileSystem)
      (Success(""), {...state, fileSystem: newFS})
    } else {
      (Error(`rm: cannot remove '${filename}': No such file or directory`), state)
    }

  // mv - move/rename
  | ["mv", source, dest] =>
    if FileSystem.pathExists(state.currentPath, source, state.fileSystem) {
      switch FileSystem.move(state.currentPath, source, state.currentPath, dest, state.fileSystem) {
      | Some(newFS) => (Success(""), {...state, fileSystem: newFS})
      | None => (Error(`mv: failed to move '${source}' to '${dest}'`), state)
      }
    } else {
      (Error(`mv: cannot stat '${source}': No such file or directory`), state)
    }

  // cp - copy
  | ["cp", source, dest] =>
    if FileSystem.pathExists(state.currentPath, source, state.fileSystem) {
      switch FileSystem.copy(state.currentPath, source, state.currentPath, dest, state.fileSystem) {
      | Some(newFS) => (Success(""), {...state, fileSystem: newFS})
      | None => (Error(`cp: failed to copy '${source}' to '${dest}'`), state)
      }
    } else {
      (Error(`cp: cannot stat '${source}': No such file or directory`), state)
    }

  // grep - search in file
  | ["grep", pattern, filename] =>
    let results = FileSystem.grep(pattern, state.currentPath, filename, state.fileSystem)
    if Array.length(results) == 0 {
      (Error(""), state) // grep returns empty on no match
    } else {
      (Success(Array.joinWith(results, "\n")), state)
    }

  // find - find files
  | ["find", ".", "-name", pattern] | ["find", "-name", pattern] =>
    let results = FileSystem.find(state.currentPath, pattern, state.fileSystem)
    (Success(Array.joinWith(results, "\n")), state)

  // help - show available commands
  | ["help"] =>
    let helpText = `Available commands:
  pwd        - Show current directory
  ls [path]  - List files in directory
  cd [path]  - Change directory
  cat [file] - Display file contents
  mkdir [dir] - Create directory
  touch [file] - Create empty file
  echo [text] - Print text (use > or >> to write to file)
  rm [file]  - Remove file
  mv [src] [dest] - Move/rename file
  cp [src] [dest] - Copy file
  grep [pattern] [file] - Search for pattern in file
  find -name [pattern] - Find files by name
  clear     - Clear terminal
  help      - Show this help`
    (Success(helpText), state)

  // clear - handled in component
  | ["clear"] => (Success("CLEAR"), state)

  // Unknown command
  | parts when Array.length(parts) >= 1 =>
    switch Array.get(parts, 0) {
    | Some(cmd) => (Error(`${cmd}: command not found. Type 'help' for available commands.`), state)
    | None => (Success(""), state)
    }
  }
}

// Virtual file system implementation

open Types

// Helper to get current directory
let getCurrentDir = (path: array<string>, fs: fileSystem): option<dict<fileType>> => {
  let rec navigate = (index: int, current: dict<fileType>): option<dict<fileType>> => {
    if index >= Array.length(path) {
      Some(current)
    } else {
      let dir = %raw(`path[index]`)
      switch Dict.get(current, dir) {
      | Some(Directory(subDir)) => navigate(index + 1, subDir)
      | _ => None
      }
    }
  }
  navigate(0, fs)
}

// List directory contents
let listDirectory = (path: array<string>, fs: fileSystem): array<string> => {
  switch getCurrentDir(path, fs) {
  | Some(dir) => Dict.keysToArray(dir)
  | None => []
  }
}

// Get file content
let getFileContent = (path: array<string>, filename: string, fs: fileSystem): option<string> => {
  switch getCurrentDir(path, fs) {
  | Some(dir) =>
    switch Dict.get(dir, filename) {
    | Some(File(content)) => Some(content)
    | _ => None
    }
  | None => None
  }
}

// Check if path exists
let pathExists = (path: array<string>, name: string, fs: fileSystem): bool => {
  switch getCurrentDir(path, fs) {
  | Some(dir) => Dict.get(dir, name)->Option.isSome
  | None => false
  }
}

// Check if is directory
let isDirectory = (path: array<string>, name: string, fs: fileSystem): bool => {
  switch getCurrentDir(path, fs) {
  | Some(dir) =>
    switch Dict.get(dir, name) {
    | Some(Directory(_)) => true
    | _ => false
    }
  | None => false
  }
}

// Create directory
let createDirectory = (path: array<string>, name: string, fs: fileSystem): fileSystem => {
  let rec createDir = (index: int, current: dict<fileType>): dict<fileType> => {
    if index >= Array.length(path) {
      let newDir = Dict.copy(current)
      Dict.set(newDir, name, Directory(Dict.make()))
      newDir
    } else {
      let dir = %raw(`path[index]`)
      switch Dict.get(current, dir) {
      | Some(Directory(subDir)) =>
        let newCurrent = Dict.copy(current)
        Dict.set(newCurrent, dir, Directory(createDir(index + 1, subDir)))
        newCurrent
      | _ => current
      }
    }
  }
  createDir(0, fs)
}

// Create file
let createFile = (path: array<string>, name: string, content: string, fs: fileSystem): fileSystem => {
  let rec create = (index: int, current: dict<fileType>): dict<fileType> => {
    if index >= Array.length(path) {
      let newDir = Dict.copy(current)
      Dict.set(newDir, name, File(content))
      newDir
    } else {
      switch Array.get(path, index) {
      | Some(dir) =>
        switch Dict.get(current, dir) {
        | Some(Directory(subDir)) =>
          let newCurrent = Dict.copy(current)
          Dict.set(newCurrent, dir, Directory(create(index + 1, subDir)))
          newCurrent
        | _ => current
        }
      | None => current
      }
    }
  }
  create(0, fs)
}

// Remove file or directory
let remove = (path: array<string>, name: string, fs: fileSystem): fileSystem => {
  let rec removeItem = (index: int, current: dict<fileType>): dict<fileType> => {
    if index >= Array.length(path) {
      let newDir = Dict.copy(current)
      Dict.delete(newDir, name)
      newDir
    } else {
      switch Array.get(path, index) {
      | Some(dir) =>
        switch Dict.get(current, dir) {
        | Some(Directory(subDir)) =>
          let newCurrent = Dict.copy(current)
          Dict.set(newCurrent, dir, Directory(removeItem(index + 1, subDir)))
          newCurrent
        | _ => current
        }
      | None => current
      }
    }
  }
  removeItem(0, fs)
}

// Move/rename file or directory
let move = (
  sourcePath: array<string>,
  sourceName: string,
  destPath: array<string>,
  destName: string,
  fs: fileSystem,
): option<fileSystem> => {
  switch getCurrentDir(sourcePath, fs) {
  | Some(sourceDir) =>
    switch Dict.get(sourceDir, sourceName) {
    | Some(item) =>
      let fsWithoutSource = remove(sourcePath, sourceName, fs)
      // Add to destination
      let rec addItem = (index: int, current: dict<fileType>): dict<fileType> => {
        if index >= Array.length(destPath) {
          let newDir = Dict.copy(current)
          Dict.set(newDir, destName, item)
          newDir
        } else {
          let dir = %raw(`destPath[index]`)
          switch Dict.get(current, dir) {
          | Some(Directory(subDir)) =>
            let newCurrent = Dict.copy(current)
            Dict.set(newCurrent, dir, Directory(addItem(index + 1, subDir)))
            newCurrent
          | _ => current
          }
        }
      }
      Some(addItem(0, fsWithoutSource))
    | None => None
    }
  | None => None
  }
}

// Copy file or directory
let copy = (
  sourcePath: array<string>,
  sourceName: string,
  destPath: array<string>,
  destName: string,
  fs: fileSystem,
): option<fileSystem> => {
  switch getCurrentDir(sourcePath, fs) {
  | Some(sourceDir) =>
    switch Dict.get(sourceDir, sourceName) {
    | Some(item) =>
      // Add to destination
      let rec addItem = (index: int, current: dict<fileType>): dict<fileType> => {
        if index >= Array.length(destPath) {
          let newDir = Dict.copy(current)
          Dict.set(newDir, destName, item)
          newDir
        } else {
          let dir = %raw(`destPath[index]`)
          switch Dict.get(current, dir) {
          | Some(Directory(subDir)) =>
            let newCurrent = Dict.copy(current)
            Dict.set(newCurrent, dir, Directory(addItem(index + 1, subDir)))
            newCurrent
          | _ => current
          }
        }
      }
      Some(addItem(0, fs))
    | None => None
    }
  | None => None
  }
}

// Search for files matching pattern (simple grep)
let grep = (pattern: string, path: array<string>, filename: string, fs: fileSystem): array<string> => {
  switch getFileContent(path, filename, fs) {
  | Some(content) =>
    String.split(content, "\n")
    ->Array.filter(line => String.includes(line, pattern))
  | None => []
  }
}

// Find files by name
let find = (searchPath: array<string>, pattern: string, fs: fileSystem): array<string> => {
  let results = []
  let rec search = (currentPath: array<string>, dir: dict<fileType>) => {
    Dict.keysToArray(dir)->Array.forEach(name => {
      switch Dict.get(dir, name) {
      | Some(item) => {
          if String.includes(name, pattern) {
            let fullPath = Array.concat(currentPath, [name])->Array.joinWith("/")
            Array.push(results, fullPath)->ignore
          }
          switch item {
          | Directory(subDir) => search(Array.concat(currentPath, [name]), subDir)
          | _ => ()
          }
        }
      | None => ()
      }
    })
  }
  switch getCurrentDir(searchPath, fs) {
  | Some(dir) => search(searchPath, dir)
  | None => ()
  }
  results
}

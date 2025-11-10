// Game levels with different themes

open Types

// Helper to create file system
let makeFS = (): fileSystem => Dict.make()

let createFS = (items: array<(string, fileType)>): fileSystem => {
  let fs = Dict.make()
  Array.forEach(items, ((name, item)) => {
    Dict.set(fs, name, item)
  })
  fs
}

// Level 1: Detective Mystery - The Missing Cookie
let level1: level = {
  id: "detective-1",
  title: "The Case of the Missing Cookie",
  theme: "Detective Mystery",
  story: `Detective! A cookie has been stolen from the kitchen!
There are three suspects, and each has left a note.
Use your commands to investigate and find the culprit!

Type 'help' if you need to see available commands.`,
  initialFileSystem: createFS([
    ("suspects", Directory(createFS([
      ("alice.txt", File("I was in the library reading all afternoon. Check my bookmark!")),
      ("bob.txt", File("I was playing video games. My high score proves it!")),
      ("charlie.txt", File("I was baking cookies in the kitchen. Wait... that sounds suspicious!")),
    ]))),
    ("evidence", Directory(createFS([
      ("kitchen.txt", File("Found chocolate chips on the floor.\nFound a recipe book open to page 42.\nFound fresh cookie crumbs!")),
      ("library.txt", File("Found a bookmark on page 156.\nFound reading glasses.\nNo signs of cookies.")),
      ("gameroom.txt", File("Game console is warm.\nHigh score: 9999 by Bob.\nNo cookie evidence.")),
    ]))),
    ("investigation-notes.txt", File("Write your findings here using: echo \"text\" >> investigation-notes.txt")),
  ]),
  objectives: [
    {
      id: "list-suspects",
      description: "List all suspects in the suspects directory",
      hint: "Use 'ls suspects' to see who the suspects are",
      checkCompletion: (history, _fs) => {
        Array.some(history, cmd =>
          String.includes(cmd, "ls") && String.includes(cmd, "suspects")
        )
      },
    },
    {
      id: "read-evidence",
      description: "Read the kitchen evidence file",
      hint: "Use 'cat evidence/kitchen.txt' to read the evidence",
      checkCompletion: (history, _fs) => {
        Array.some(history, cmd =>
          String.includes(cmd, "cat") && String.includes(cmd, "kitchen")
        )
      },
    },
    {
      id: "identify-culprit",
      description: "Read Charlie's statement",
      hint: "Use 'cat suspects/charlie.txt' - he admitted being in the kitchen!",
      checkCompletion: (history, _fs) => {
        Array.some(history, cmd =>
          String.includes(cmd, "cat") && String.includes(cmd, "charlie")
        )
      },
    },
  ],
  successMessage: "Excellent detective work! Charlie confessed to being in the kitchen while baking cookies. Case closed!",
  difficulty: Easy,
}

// Level 2: Space Explorer - Ship Repair
let level2: level = {
  id: "space-1",
  title: "Emergency Ship Repair",
  theme: "Space Explorer",
  story: `ALERT! Your spaceship's computer is damaged!
Oxygen levels critical: 15 minutes remaining!

You need to reorganize the system files to restore life support.
The AI will guide you, but you must act fast!`,
  initialFileSystem: createFS([
    ("ship-systems", Directory(createFS([
      ("oxygen-backup.sys", File("BACKUP SYSTEM READY\nStatus: OFFLINE\nActivation code: LIFE-SUP-042")),
      ("navigation.sys", File("Navigation: ONLINE")),
      ("corrupted-file.tmp", File("ERROR ERROR ERROR")),
    ]))),
    ("home", Directory(createFS([
      ("welcome.txt", File("Welcome aboard the Starship Explorer!")),
      ("mission-log.txt", File("Day 47: All systems normal.\nDay 48: WARNING - Main computer damaged by asteroid.")),
    ]))),
    ("backups", Directory(makeFS())),
    ("ai-helper.txt", File("Hello! I'm your AI assistant.\nTo restore oxygen: Move oxygen-backup.sys to the backups folder, then remove the corrupted file!")),
  ]),
  objectives: [
    {
      id: "read-ai",
      description: "Read the AI helper instructions",
      hint: "Use 'cat ai-helper.txt' to see what the AI says",
      checkCompletion: (history, _fs) => {
        Array.some(history, cmd =>
          String.includes(cmd, "cat") && String.includes(cmd, "ai-helper")
        )
      },
    },
    {
      id: "move-backup",
      description: "Move oxygen-backup.sys to the backups folder",
      hint: "Use 'mv ship-systems/oxygen-backup.sys backups/' to move the file",
      checkCompletion: (_history, fs) => {
        FileSystem.pathExists(["backups"], "oxygen-backup.sys", fs)
      },
    },
    {
      id: "remove-corrupted",
      description: "Remove the corrupted file",
      hint: "Use 'rm ship-systems/corrupted-file.tmp' to delete it",
      checkCompletion: (_history, fs) => {
        !FileSystem.pathExists(["ship-systems"], "corrupted-file.tmp", fs)
      },
    },
  ],
  successMessage: "Life support RESTORED! Oxygen levels stabilizing. Excellent work, Commander!",
  difficulty: Medium,
}

// Level 3: Fantasy RPG - The Enchanted Library
let level3: level = {
  id: "fantasy-1",
  title: "The Enchanted Library",
  theme: "Fantasy RPG",
  story: `You are a young wizard learning the ancient art of Command Magic!
Your first quest: Organize the chaotic spell library.

Each command you type is a spell. Use them wisely!`,
  initialFileSystem: createFS([
    ("spell-library", Directory(createFS([
      ("fire-spells.scroll", File("Fireball\nFlame Shield\nInferno")),
      ("water-spells.scroll", File("Aqua Blast\nHealing Rain\nTidal Wave")),
      ("earth-spells.scroll", File("Stone Armor\nEarthquake\nRock Slide")),
      ("forbidden-spell.scroll", File("Dark Magic - DO NOT USE!\nThis spell must be destroyed!")),
    ]))),
    ("my-spells", Directory(makeFS())),
    ("spell-master.txt", File("Welcome, apprentice!\n\nYour trial:\n1. Create a 'practice' directory in my-spells\n2. Copy water-spells.scroll to your practice directory\n3. Destroy the forbidden spell (remove it!)\n\nComplete this and you shall advance!")),
  ]),
  objectives: [
    {
      id: "create-practice",
      description: "Create a 'practice' directory in my-spells",
      hint: "Use 'mkdir my-spells/practice' to create the directory",
      checkCompletion: (_history, fs) => {
        FileSystem.pathExists(["my-spells"], "practice", fs) &&
        FileSystem.isDirectory(["my-spells"], "practice", fs)
      },
    },
    {
      id: "copy-water-spells",
      description: "Copy water-spells.scroll to my-spells directory",
      hint: "Use 'cp spell-library/water-spells.scroll my-spells/' to copy it",
      checkCompletion: (_history, fs) => {
        FileSystem.pathExists(["my-spells"], "water-spells.scroll", fs)
      },
    },
    {
      id: "destroy-forbidden",
      description: "Destroy the forbidden spell scroll",
      hint: "Use 'rm spell-library/forbidden-spell.scroll' to destroy it",
      checkCompletion: (_history, fs) => {
        !FileSystem.pathExists(["spell-library"], "forbidden-spell.scroll", fs)
      },
    },
  ],
  successMessage: "Magnificent! You have mastered the basic Command Spells! Your journey as a wizard has begun!",
  difficulty: Medium,
}

// Level 4: Pet Simulator - Virtual Pet Care
let level4: level = {
  id: "pets-1",
  title: "Pet Care Day",
  theme: "Pet Simulator",
  story: `Welcome to the Virtual Pet Center!
You have three adorable pets to take care of today.

Check on them, feed them, and make sure they're happy!`,
  initialFileSystem: createFS([
    ("pets", Directory(createFS([
      ("fluffy-cat.txt", File("Name: Fluffy\nType: Cat\nHunger: Very Hungry!\nMood: Lonely")),
      ("buddy-dog.txt", File("Name: Buddy\nType: Dog\nHunger: Hungry\nMood: Playful")),
      ("nibbles-hamster.txt", File("Name: Nibbles\nType: Hamster\nHunger: Satisfied\nMood: Sleeping")),
    ]))),
    ("food", Directory(createFS([
      ("cat-food.txt", File("Delicious tuna flavor!")),
      ("dog-food.txt", File("Chicken and rice!")),
      ("hamster-food.txt", File("Sunflower seeds!")),
    ]))),
    ("play-area", Directory(makeFS())),
    ("care-log.txt", File("Pet Care Log - Day 1\n-------------------\n")),
  ]),
  objectives: [
    {
      id: "check-pets",
      description: "Check on Fluffy the cat's status",
      hint: "Use 'cat pets/fluffy-cat.txt' to see how Fluffy is doing",
      checkCompletion: (history, _fs) => {
        Array.some(history, cmd =>
          String.includes(cmd, "cat") && String.includes(cmd, "fluffy")
        )
      },
    },
    {
      id: "feed-fluffy",
      description: "Add a feeding note to the care log",
      hint: "Use 'echo \"Fed Fluffy\" >> care-log.txt' to log feeding",
      checkCompletion: (_history, fs) => {
        switch FileSystem.getFileContent([], "care-log.txt", fs) {
        | Some(content) => String.includes(content, "Fed") || String.includes(content, "fed")
        | None => false
        }
      },
    },
    {
      id: "move-buddy",
      description: "Move Buddy to the play area",
      hint: "Use 'cp pets/buddy-dog.txt play-area/' to bring Buddy to play!",
      checkCompletion: (_history, fs) => {
        FileSystem.pathExists(["play-area"], "buddy-dog.txt", fs)
      },
    },
  ],
  successMessage: "Great job! Your pets are happy and well cared for! You're a natural pet caretaker!",
  difficulty: Easy,
}

// Level 5: Detective Mystery 2 - The Secret Message
let level5: level = {
  id: "detective-2",
  title: "The Secret Message",
  theme: "Detective Mystery",
  story: `A mysterious message has been hidden in several files!
You need to use your grep skills to find the hidden code words.

Once you find all the pieces, you'll crack the case!`,
  initialFileSystem: createFS([
    ("notes", Directory(createFS([
      ("day1.txt", File("Meeting with informant at cafe.\nThey mentioned the word BLUE.\nNothing else suspicious.")),
      ("day2.txt", File("Followed suspect to the park.\nOverheard them say MOON on the phone.\nLost them in the crowd.")),
      ("day3.txt", File("Found a note that said RISE.\nAddress leads to warehouse district.")),
    ]))),
    ("interviews", Directory(createFS([
      ("witness1.txt", File("I saw someone wearing a BLUE jacket.\nThey were carrying a briefcase.")),
      ("witness2.txt", File("The password they used was WHEN.\nI heard it through the door.")),
      ("witness3.txt", File("Something about a MOON symbol.\nIt was on their badge.")),
    ]))),
    ("solution.txt", File("Secret Code: _ _ _ _\nFind the four code words!")),
  ]),
  objectives: [
    {
      id: "grep-blue",
      description: "Search for 'BLUE' in the notes",
      hint: "Use 'grep BLUE notes/day1.txt' to find mentions of BLUE",
      checkCompletion: (history, _fs) => {
        Array.some(history, cmd =>
          String.includes(cmd, "grep") && String.includes(cmd, "BLUE")
        )
      },
    },
    {
      id: "grep-moon",
      description: "Search for 'MOON' in any file",
      hint: "Try 'grep MOON notes/day2.txt' or search in interviews",
      checkCompletion: (history, _fs) => {
        Array.some(history, cmd =>
          String.includes(cmd, "grep") && String.includes(cmd, "MOON")
        )
      },
    },
    {
      id: "find-all-clues",
      description: "Search for 'WHEN' to find the last clue",
      hint: "Use 'grep WHEN interviews/witness2.txt'",
      checkCompletion: (history, _fs) => {
        Array.some(history, cmd =>
          String.includes(cmd, "grep") && String.includes(cmd, "WHEN")
        )
      },
    },
  ],
  successMessage: "You found all the code words: BLUE MOON WHEN RISE! The secret message is revealed!",
  difficulty: Medium,
}

// Level 6: Advanced - File Organization Challenge
let level6: level = {
  id: "advanced-1",
  title: "The Great File Sort",
  theme: "Organization Challenge",
  story: `The file system is a complete mess!
Your task: Organize everything into proper categories.

This is a test of all your skills. Good luck!`,
  initialFileSystem: createFS([
    ("messy-files", Directory(createFS([
      ("photo1.jpg", File("Family vacation photo")),
      ("recipe.txt", File("Chocolate chip cookies recipe")),
      ("homework.txt", File("Math homework - Chapter 5")),
      ("photo2.jpg", File("Birthday party photo")),
      ("song.mp3", File("Favorite song audio file")),
      ("essay.txt", File("History essay draft")),
      ("photo3.jpg", File("Pet photo")),
      ("music-playlist.txt", File("My favorite songs list")),
    ]))),
    ("organized", Directory(makeFS())),
    ("README.txt", File("Create folders for: photos, documents, music\nThen organize all files from messy-files into the right categories!")),
  ]),
  objectives: [
    {
      id: "create-folders",
      description: "Create photos, documents, and music folders in organized/",
      hint: "Use 'mkdir organized/photos' and similar for documents and music",
      checkCompletion: (_history, fs) => {
        FileSystem.pathExists(["organized"], "photos", fs) &&
        FileSystem.pathExists(["organized"], "documents", fs) &&
        FileSystem.pathExists(["organized"], "music", fs)
      },
    },
    {
      id: "move-photos",
      description: "Move at least one photo to organized/photos",
      hint: "Use 'mv messy-files/photo1.jpg organized/photos/'",
      checkCompletion: (_history, fs) => {
        let hasPhoto1 = FileSystem.pathExists(["organized", "photos"], "photo1.jpg", fs)
        let hasPhoto2 = FileSystem.pathExists(["organized", "photos"], "photo2.jpg", fs)
        let hasPhoto3 = FileSystem.pathExists(["organized", "photos"], "photo3.jpg", fs)
        hasPhoto1 || hasPhoto2 || hasPhoto3
      },
    },
    {
      id: "move-documents",
      description: "Move at least one document to organized/documents",
      hint: "Use 'mv messy-files/recipe.txt organized/documents/'",
      checkCompletion: (_history, fs) => {
        let hasRecipe = FileSystem.pathExists(["organized", "documents"], "recipe.txt", fs)
        let hasHomework = FileSystem.pathExists(["organized", "documents"], "homework.txt", fs)
        let hasEssay = FileSystem.pathExists(["organized", "documents"], "essay.txt", fs)
        hasRecipe || hasHomework || hasEssay
      },
    },
  ],
  successMessage: "Perfect organization! You've mastered file management. You're ready for any challenge!",
  difficulty: Hard,
}

// Export all levels
let allLevels = [level1, level2, level3, level4, level5, level6]

let getLevelById = (id: string): option<level> => {
  Array.find(allLevels, level => level.id == id)
}

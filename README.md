# <® CLI Kids - Learn Linux Commands Through Games

An interactive educational game that teaches children (and beginners!) Linux command line skills through fun, themed adventures.

## < Features

- **Multiple Themed Levels**: Detective mysteries, space exploration, fantasy RPG, and pet care
- **Progressive Learning**: Start with basic commands and gradually learn more advanced ones
- **No API Required**: All game state stored in localStorage
- **All Levels Unlocked**: Jump to any level at any time
- **Interactive Terminal**: Real-time command execution in a safe, virtual environment
- **Hints & Guidance**: Get help when you're stuck
- **Achievements System**: Track your progress and earn badges

## <¯ Game Themes

### = Detective Mystery
Solve cases by investigating files, searching for clues with `grep`, and piecing together evidence.

### =€ Space Explorer
Repair your damaged spaceship by organizing system files and restoring critical functions.

### ” Fantasy RPG
Learn command magic as a wizard's apprentice organizing an enchanted library.

### =1 Pet Simulator
Care for virtual pets by managing their files and keeping track of their needs.

### =Á Organization Challenge
Master file management by sorting and organizing a messy file system.

## =Ú Commands Taught

**Basics:**
- `pwd` - Print working directory
- `ls` - List files
- `cd` - Change directory
- `cat` - Display file contents
- `help` - Show available commands

**File Management:**
- `mkdir` - Create directories
- `touch` - Create files
- `cp` - Copy files
- `mv` - Move/rename files
- `rm` - Remove files
- `echo` - Print text (with redirection)

**Advanced:**
- `grep` - Search in files
- `find` - Find files by name

## =€ Getting Started

### Prerequisites
- Node.js (v16 or higher)
- npm or yarn

### Installation

```bash
# Install dependencies
npm install

# Build ReScript files
npm run res:build

# Start development server
npm start
```

The game will open at `http://localhost:3000`

### Build for Production

```bash
# Build ReScript
npm run res:build

# Build production bundle
npm run build

# Preview production build
npm run preview
```

## <® How to Play

1. **Select a Level**: Choose from any of the available themed levels
2. **Read the Story**: Each level has a unique scenario and objectives
3. **Complete Objectives**: Follow the objectives panel to guide your progress
4. **Use Commands**: Type Linux commands in the terminal to interact with the virtual file system
5. **Get Hints**: Click the hint button if you're stuck
6. **Level Up**: Complete all objectives to finish the level and unlock new commands

## =à Technology Stack

- **ReScript** - Type-safe language that compiles to JavaScript
- **React** - UI framework
- **Vite** - Build tool and dev server
- **LocalStorage** - Game state persistence

## =Ö Educational Value

This game teaches:
- Command line basics
- File system navigation
- File manipulation
- Pattern matching and searching
- Problem-solving skills
- Logical thinking

Perfect for:
- Kids learning programming
- Beginners new to Linux/Unix
- Anyone wanting to learn command line in a fun way
- Computer science education

## <¨ Difficulty Levels

- **Easy**: Commands are shown explicitly
- **Medium**: Hints guide you to the right commands
- **Hard**: Figure it out from context and objectives

## =' Development

```bash
# Watch ReScript files for changes
npm run res:dev

# Clean build artifacts
npm run res:clean
```

## =Ý License

MIT

## > Contributing

Contributions are welcome! Feel free to:
- Add new levels
- Improve existing levels
- Add new commands
- Enhance UI/UX
- Fix bugs

## <“ Future Ideas

- More themed levels (pirate treasure hunt, archaeology, time travel)
- Multiplayer challenges
- Custom level creator
- More advanced commands (pipes, wildcards, permissions)
- Sandbox mode for free exploration
- Leaderboards for speed runs

---

Made with d for learning and fun!

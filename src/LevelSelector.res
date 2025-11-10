// Level selector component

open Types

@react.component
let make = (~gameState: gameState, ~onSelectLevel: string => unit) => {
  let getLevelIcon = (theme: string): string => {
    switch theme {
    | "Detective Mystery" => "🔍"
    | "Space Explorer" => "🚀"
    | "Fantasy RPG" => "⚔️"
    | "Pet Simulator" => "🐱"
    | "Organization Challenge" => "📁"
    | _ => "🎮"
    }
  }

  let getDifficultyColor = (difficulty: difficulty): string => {
    switch difficulty {
    | Easy => "easy"
    | Medium => "medium"
    | Hard => "hard"
    }
  }

  let getDifficultyText = (difficulty: difficulty): string => {
    switch difficulty {
    | Easy => "Easy"
    | Medium => "Medium"
    | Hard => "Hard"
    }
  }

  <div className="level-selector">
    <div className="game-header">
      <h1 className="game-title">{React.string("🎮 CLI Kids")}</h1>
      <p className="game-subtitle">{React.string("Learn Linux Commands Through Fun Games!")}</p>
    </div>

    <div className="stats-panel">
      <div className="stat-item">
        <div className="stat-value">{React.string(Int.toString(Array.length(gameState.completedLevels)))}</div>
        <div className="stat-label">{React.string("Levels Completed")}</div>
      </div>
      <div className="stat-item">
        <div className="stat-value">{React.string(Int.toString(Array.length(gameState.unlockedCommands)))}</div>
        <div className="stat-label">{React.string("Commands Learned")}</div>
      </div>
      <div className="stat-item">
        <div className="stat-value">{React.string(Int.toString(Array.length(gameState.achievements)))}</div>
        <div className="stat-label">{React.string("Achievements")}</div>
      </div>
    </div>

    <div className="levels-grid">
      {Array.map(Levels.allLevels, level => {
        let isCompleted = Array.includes(gameState.completedLevels, level.id)
        let icon = getLevelIcon(level.theme)
        let difficultyClass = getDifficultyColor(level.difficulty)
        let difficultyText = getDifficultyText(level.difficulty)

        <div
          key={level.id}
          className={isCompleted ? "level-card completed" : "level-card"}
          onClick={_ => onSelectLevel(level.id)}>
          <div className="level-icon">{React.string(icon)}</div>
          <div className="level-info">
            <h3 className="level-title">{React.string(level.title)}</h3>
            <p className="level-theme">{React.string(level.theme)}</p>
            <div className="level-meta">
              <span className={"difficulty " ++ difficultyClass}>
                {React.string(difficultyText)}
              </span>
              <span className="objectives-count">
                {React.string(Int.toString(Array.length(level.objectives)) ++ " objectives")}
              </span>
            </div>
            {isCompleted
              ? <div className="completed-badge">{React.string("✓ Completed")}</div>
              : React.null}
          </div>
        </div>
      })->React.array}
    </div>

    <div className="commands-panel">
      <h3>{React.string("Commands You've Learned")}</h3>
      <div className="commands-list">
        {Array.map(gameState.unlockedCommands, cmd =>
          <span key={cmd} className="command-badge">
            {React.string(cmd)}
          </span>
        )->React.array}
      </div>
    </div>
  </div>
}

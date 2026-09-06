export PATH="$HOME/.cargo/bin:$PATH"
# p10k instant prompt disabled: starship owns the prompt

# Path to Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""  # prompt comes from starship

# "z"/"zoxide" left out on purpose — zoxide is started below via eval, and the
# "z" plugin conflicted with zoxide's own z command.
plugins=(git macos colorize web-search)

source $ZSH/oh-my-zsh.sh

# ---------------------------------------------------------------------------
# Aliases (from my-confs/terminal)
# ---------------------------------------------------------------------------

# Git basics
alias gs='git status -sb'
alias ga='git add -A'
alias gc='git commit'
alias gcm='git commit -m'
alias gp='git push'
alias gpl='git pull --rebase'

# Logs
alias gl='git log --oneline --decorate'
alias glg='git log --oneline --graph --decorate --all'

# Branches
alias gb='git branch'
alias gbd='git branch -d'
alias gco='git checkout'
alias gcb='git checkout -b'

# Fixes & undo
alias gfix='git commit --amend --no-edit'
alias gundo='git reset --soft HEAD~1'

# Cleanups
alias gprune='git fetch --prune'
alias gclean='git branch --merged | grep -v "\*\|main\|master\|develop" | xargs git branch -d'

# Power moves
alias gpush='git push -u origin $(git branch --show-current)'
alias gempty='git commit --allow-empty -m "empty" && git push'

# eza replaces ls — colorized, icons, git state
alias ls='eza -lh --group-directories-first --icons=auto'
alias lsa='ls -a'
alias lt='eza --tree --level=2 --long --icons --git'

# Personal shortcuts
alias kopi2='cd ~/Documents/kopi-2'
alias viper='cd ~/Documents/viper'
alias notify="~/dotfiles/scripts/claude-notify.sh"
alias msg="~/dotfiles/scripts/claude-notify.sh 'New Message' 'You have a new message'"

# ---------------------------------------------------------------------------
# Environment
# ---------------------------------------------------------------------------

# bat follows the terminal's ANSI palette instead of its own theme
export BAT_THEME=ansi

# man pages through bat with syntax highlighting
export MANROFFOPT="-c"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# ---------------------------------------------------------------------------
# PATH / toolchains
# ---------------------------------------------------------------------------

[ -d "$HOME/.antigravity-ide/antigravity-ide/bin" ] && export PATH="$HOME/.antigravity-ide/antigravity-ide/bin:$PATH"
[ -d "$HOME/.codeium/windsurf/bin" ]               && export PATH="$HOME/.codeium/windsurf/bin:$PATH"
[ -d "$HOME/.kimi-code/bin" ]                      && export PATH="$HOME/.kimi-code/bin:$PATH"
[ -d "$HOME/.opencode/bin" ]                       && export PATH="$HOME/.opencode/bin:$PATH"

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac

# cargo
[ -s "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

# Android / RN toolchain
if [ -d "$HOME/Library/Android/sdk" ]; then
  export ANDROID_HOME="$HOME/Library/Android/sdk"
  export PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"
fi
[ -d "/Applications/Android Studio.app/Contents/jbr/Contents/Home" ] && \
  export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"

# ---------------------------------------------------------------------------
# Tools
# ---------------------------------------------------------------------------

[ -f /opt/homebrew/opt/asdf/libexec/asdf.sh ] && . /opt/homebrew/opt/asdf/libexec/asdf.sh
command -v direnv >/dev/null && eval "$(direnv hook zsh)"
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"
command -v fzf    >/dev/null && source <(fzf --zsh)

# fzf: Tokyo Night colors
export FZF_DEFAULT_OPTS="--height 40% --reverse --border \
  --color=fg:#c0caf5,bg:#1a1b26,hl:#7aa2f7 \
  --color=fg+:#c0caf5,bg+:#283457,hl+:#7dcfff \
  --color=info:#e0af68,prompt:#7aa2f7,pointer:#bb9af7 \
  --color=marker:#9ece6a,spinner:#bb9af7,header:#545c7e,border:#414868"
export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window down:3:wrap"

# History: shared between tabs, no dupes
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY HIST_IGNORE_ALL_DUPS HIST_REDUCE_BLANKS HIST_VERIFY

# Completion menu + fzf-tab previews
zstyle ':completion:*' menu select
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls -1 $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls -1 $realpath'

# ---------------------------------------------------------------------------
# Prompt (near the end)
# ---------------------------------------------------------------------------
eval "$(starship init zsh)"

# Autosuggestions + syntax highlighting — syntax highlighting must be LAST
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# portable-dev theme
# Shows: conda_env user@host:path (git_branch)

# Conda environment (if active)
conda_prompt_info() {
    if [[ -n "$CONDA_DEFAULT_ENV" ]]; then
        echo "%{$fg[green]%}($CONDA_DEFAULT_ENV)%{$reset_color%} "
    fi
}

# Git info
ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[yellow]%}("
ZSH_THEME_GIT_PROMPT_SUFFIX=")%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[red]%}*"
ZSH_THEME_GIT_PROMPT_CLEAN=""

# Main prompt
PROMPT='$(conda_prompt_info)%{$fg[cyan]%}%n@%m%{$reset_color%}:%{$fg[blue]%}%~%{$reset_color%} $(git_prompt_info)
%{$fg[white]%}$%{$reset_color%} '

# Right prompt (optional - shows time)
RPROMPT='%{$fg[gray]%}%T%{$reset_color%}'

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your oh-my-zsh installation.
export ZSH="${HOME}/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

# Uncomment the following line if pasting URLs and other text is messed up.
DISABLE_MAGIC_FUNCTIONS="true"

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
	git
  docker
  kubectl
	zsh-autosuggestions
	zsh-syntax-highlighting
	zsh-completions
)

# e.g. See Docker aliases exported by docker plugin:
#   https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/docker#aliases

source $ZSH/oh-my-zsh.sh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Environment variables of installed programs
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export JAVA_HOME=/opt/homebrew/opt/openjdk@22
#export JAVA_HOME=/opt/homebrew/opt/openjdk@17
#export JAVA_HOME=/opt/homebrew/opt/openjdk@11
export PATH=$JAVA_HOME/bin:$PATH
export M2_HOME=/opt/homebrew/opt/maven
export PATH=$M2_HOME/bin:$PATH
export PATH="/Users/osmankartal/.local/bin:$PATH"

# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/osmankartal/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions

# osmankartal-aliases
# show initContainers logs: kubectl logs -n h2-dpp <pod-uses-initContainers> -c <initContainers.name> -f

alias cls='clear && printf "\e[3J"'
alias dxcitr='docker exec -it -u root'
alias dpsf='docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}"'
alias dvct='docker volume ls -q | xargs -I {} docker volume inspect {} --format "{{ .Name }} - {{ .CreatedAt }}"'
alias dcl='cd ~/Desktop/deepcloudlabs'
alias dclp='cd ~/Desktop/deepcloudlabs/projects'
alias dpp-ds='cd ~/Desktop/deepcloudlabs/projects/data-space-connector'
alias h2dpp='cd ~/Desktop/deepcloudlabs/projects/h2-dpp && nvm use v20.12.2'
alias h2dppb='cd ~/Desktop/deepcloudlabs/projects/h2-dpp/backend && nvm use v20.12.2'
alias h2dppf='cd ~/Desktop/deepcloudlabs/projects/h2-dpp/frontend && nvm use v20.12.2'
alias insighted='cd ~/Desktop/deepcloudlabs/projects/InsightED'
alias insightedb='cd ~/Desktop/deepcloudlabs/projects/InsightED/backend'
alias insightedf='cd ~/Desktop/deepcloudlabs/projects/InsightED/webui && nvm use v20.12.2'
alias insighted-stt='cd ~/Desktop/deepcloudlabs/projects/InsightED/ai-services/mock-services && poetry run python src/mock_services/main.py -s SPEECH_TO_TEXT -cg consumer-group1'
alias insighted-ts='cd ~/Desktop/deepcloudlabs/projects/InsightED/ai-services/mock-services && poetry run python src/mock_services/main.py -s TOPIC_SEGMENTATION -cg consumer-group2'
alias insighted-ca='cd ~/Desktop/deepcloudlabs/projects/InsightED/ai-services/mock-services && poetry run python src/mock_services/main.py -s CLASS_EVALUATION -cg consumer-group3'
alias insighted-fr='cd ~/Desktop/deepcloudlabs/projects/InsightED/ai-services/mock-services && poetry run python src/mock_services/main.py -s FEEDBACK_REPORT -cg consumer-group4'
alias texdpp='cd ~/Desktop/deepcloudlabs/projects/textile-dpp && nvm use v20.12.2'
alias texdppb='cd ~/Desktop/deepcloudlabs/projects/textile-dpp/backend && nvm use v20.12.2'
alias texdppf='cd ~/Desktop/deepcloudlabs/projects/textile-dpp/frontend && nvm use v20.12.2'
alias texdpps='cd ~/Desktop/deepcloudlabs/projects/textile-dpp/backend/scripts && nvm use v20.12.2'
alias dppk3s='docker cp dpp-dsc:/etc/rancher/k3s/k3s.yaml $(pwd)/k3s.yaml && export KUBECONFIG=$(pwd)/k3s.yaml'
alias texdppadd='cd /Users/osmankartal/Desktop/deepcloudlabs/projects/textile-dpp/backend/scripts && nvm use v20.12.2 && node add-companies.js && node add-dashboard-data.js && node add-passports-without-data-space.js && node add-vcs.js && node add-users.js && node add-products.js && cd /Users/osmankartal/Desktop/deepcloudlabs/projects/textile-dpp'
alias checkapisix='kubectl -n provider get pods | grep provider-apisix'
alias resetapisix='kubectl -n consumer delete pod -l app.kubernetes.io/name=apisix && kubectl -n provider delete pod -l app.kubernetes.io/name=apisix'
alias resetlps='kubectl delete -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.30/deploy/local-path-storage.yaml -n local-path-storage && kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.30/deploy/local-path-storage.yaml -n local-path-storage'
alias agb='code ~/.gemini/antigravity/brain/'
alias ccl='ANTHROPIC_BASE_URL=http://localhost:1234 \
ANTHROPIC_AUTH_TOKEN=lmstudio \
CLAUDE_CODE_ATTRIBUTION_HEADER=0 \
claude --model qwen/qwen3.5-9b'

ytmp4() {
  yt-dlp "$1" -f "bv*[height<=720]+ba/b[height<=720]" --merge-output-format mp4
}

ytclip() {
  if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: ytclip <youtube-url> <start-time-end-time>"
    echo "Example: ytclip \"https://youtube.com/watch?v=xxx\" \"00:10:11-00:15:20\""
    return 1
  fi
  yt-dlp "$1" \
    --download-sections "*$2" \
    -f "bv*[height<=720]+ba/b[height<=720]" \
    --merge-output-format mp4
}

movshrink() {
  if [ -z "$1" ]; then
    echo "Usage: movshrink <input-file>"
    return 1
  fi
  input="$1"
  output="${input%.*}_compressed.mp4"
  ffmpeg -i "$input" -vf "scale=1280:-2" -r 30 -c:v libx264 -crf 26 -c:a aac "$output"
}
alias ytmp3='yt-dlp -x --audio-format mp3 --audio-quality 0'

# video ve metadata
# yt-dlp --write-pages --ignore-no-formats-error "url"

# only metadata
# yt-dlp --write-info-json --write-pages --skip-download --ignore-no-formats-error "url"

# jq -r '.data.tweetResult.result | (.note_tweet.note_tweet_results.result.text // .legacy.full_text)' *_i_api_graphql*

### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="/Users/osmankartal/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)

# Added by Antigravity
export PATH="/Users/osmankartal/.antigravity/antigravity/bin:$PATH"

# Added by Antigravity
export PATH="/Users/osmankartal/.antigravity/antigravity/bin:$PATH"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/osmankartal/.lmstudio/bin"
# End of LM Studio CLI section


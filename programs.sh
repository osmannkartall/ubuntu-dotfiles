#!/bin/bash

readonly SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
readonly GREEN="\033[0;32m"
readonly RED="\033[0;31m"
readonly NC="\033[0m"
readonly SUCCESS=0
readonly FAIL=3
readonly NOT_AVAILABLE=4
readonly SUCCESS_MESSAGE="installed successfully."
readonly FAIL_MESSAGE="installation has an error. It may not be installed correctly."
readonly NOT_AVAILABLE_MESSAGE="has no available installation."
declare -A logger=()

display_installation_results() {
    echo "Installation completed."
    echo "-----------------------"
    for log_code in "${!logger[@]}"; do
        if [[ "${logger[$log_code]}" == $SUCCESS ]]; then
            printf "${GREEN}\"$log_code\": ${SUCCESS_MESSAGE}${NC}\n"
        elif [[ "${logger[$log_code]}" == $FAIL ]]; then
            printf "${RED}\"$log_code\": ${FAIL_MESSAGE}${NC}\n"
        elif [[ "${logger[$log_code]}" == $NOT_AVAILABLE ]]; then
            printf "${RED}\"$log_code\": ${NOT_AVAILABLE_MESSAGE}${NC}\n"
        fi
    done
    echo "Note: You may need to open new terminal to verify installations."
}

run_command() {
    "$@" || exit $FAIL
}

run_installation() {
    result=$SUCCESS
    installer_function=$1
    name=$2

    echo "Installing $name..."
    ($installer_function)
    result=$?

    return $result
}

install_deb() {
    DOWNLOAD_URL=$1
    FILENAME=program.deb

    run_command wget -O ${SCRIPT_DIR}/${FILENAME} $DOWNLOAD_URL
    run_command sudo apt install -y ${SCRIPT_DIR}/${FILENAME}
    run_command sudo rm -r ${SCRIPT_DIR}/${FILENAME}
}

download_latest_release_from_github() {
    OWNER=$1
    REPO_NAME=$2
    SOURCE=$3
    DEST=$4

    GITHUB_API_BASE_URL="https://api.github.com/repos"
    GITHUB_API_REQUEST_HEADER="Accept: application/vnd.github.v3+json"
    LATEST_RELEASE_URL="${GITHUB_API_BASE_URL}/${OWNER}/${REPO_NAME}/releases/latest"
    FIELD_FOR_DOWNLOAD_URL="browser_download_url"

    # https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8
    res=$(curl \
        -H $GITHUB_API_REQUEST_HEADER \
        -s $LATEST_RELEASE_URL)

    message=$(echo "$res" | grep "message" | cut -d '"' -f 4)

    if [[ $message == "Not Found" ]]; then
        exit $FAIL
    else
        echo "$res" | grep "${FIELD_FOR_DOWNLOAD_URL}.*${SOURCE}" \
            | cut -d '"' -f 4 \
            | sudo wget -O $DEST -qi -
    fi
}

install_latest_bin_from_github() {
    DEST=$4
    download_latest_release_from_github $1 $2 $3 $DEST
    run_command sudo chmod +x $DEST
}

install_latest_deb_from_github() {
    DEST=$4
    download_latest_release_from_github $1 $2 $3 $DEST
    run_command sudo dpkg -i $DEST
    run_command rm -r $DEST
}

install_zsh() {
    run_command sudo apt install -y zsh
    run_command sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --unattended"

    # Install zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

    # Install zsh-syntax-highlighting
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

    # Install zsh-completions
    git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-completions

    # Install the Meslo font with icons
    FONTS_DIR="$HOME/.local/share/fonts"
    mkdir -p $FONTS_DIR
    wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf -P "$FONTS_DIR/"
    wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf -P "$FONTS_DIR/"
    wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf -P "$FONTS_DIR/"
    wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf -P "$FONTS_DIR/"

    # Powerlevel10k theme
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
}

# Do not exit the installation when an extension cannot be installed.
install_vscode_extension() {
    extension_id="${1}"
    code --install-extension ${extension_id} --force
}

install_vscode() {
    install_deb "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"

    install_vscode_extension teabyii.ayu
    install_vscode_extension streetsidesoftware.code-spell-checker
    install_vscode_extension ms-azuretools.vscode-docker
    install_vscode_extension mhutchie.git-graph
    install_vscode_extension eamodio.gitlens
    install_vscode_extension yzhang.markdown-all-in-one
    install_vscode_extension pkief.material-icon-theme
    install_vscode_extension christian-kohler.path-intellisense
    install_vscode_extension wayou.vscode-todo-highlight
    install_vscode_extension visualstudioexptteam.vscodeintellicode
    install_vscode_extension redhat.vscode-yaml
}

install_nvm() {
    # https://github.com/nvm-sh/nvm#manual-install

    export NVM_DIR="$HOME/.nvm" && (
        git clone https://github.com/nvm-sh/nvm.git "$NVM_DIR"
        cd "$NVM_DIR"
        git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" $(git rev-list --tags --max-count=1)`
    ) && \. "$NVM_DIR/nvm.sh"

    nvm install --lts
    nvm install-latest-npm
    nvm use node
}

install_postman() {
    run_command wget https://dl.pstmn.io/download/latest/linux64 -O postman.tar.gz
    run_command sudo tar -xzf postman.tar.gz -C /opt
    run_command rm postman.tar.gz
    run_command sudo ln -s /opt/Postman/Postman /usr/bin/postman
    run_command sudo mkdir -p ~/.local/share/applications
    run_command sudo touch ~/.local/share/applications/postman.desktop
    run_command sudo tee -a ~/.local/share/applications/postman.desktop << EOF
[Desktop Entry]
Name=Postman
GenericName=Postman
X-GNOME-FullName=Postman
Comment=Supercharge your API workflow
Keywords=api;
Exec=/opt/Postman/Postman
Terminal=false
Type=Application
Icon=/opt/Postman/app/resources/app/assets/icon.png
Categories=Development;
EOF
}

install_dbeaver() {
    install_deb "https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb"
}

install_jq() {
    install_latest_bin_from_github "stedolan" "jq" "linux64" "/usr/bin/jq"
}

install_bat() {
    # https://github.com/sharkdp/bat#on-ubuntu-using-most-recent-deb-packages
    
    ARCHITECTURE="amd64"
    FILENAME="bat.deb"
    install_latest_deb_from_github "sharkdp" "bat" "bat_.*${ARCHITECTURE}.deb" $FILENAME
}

install_java() {
    version=openjdk-17-jdk

    run_command sudo apt install -y $version
}

install_maven() {
    DOWNLOAD_URL="https://dlcdn.apache.org/maven/maven-3/3.8.3/binaries/apache-maven-3.8.3-bin.tar.gz"
    INSTALL_DIR="/opt/"
    ARCHIVE_NAME=maven.tar.gz

    run_command sudo mkdir -p $INSTALL_DIR
    run_command wget $DOWNLOAD_URL -O $SCRIPT_DIR/$ARCHIVE_NAME
    run_command sudo tar -xzvf $SCRIPT_DIR/$ARCHIVE_NAME -C $INSTALL_DIR
    run_command rm -r $SCRIPT_DIR/$ARCHIVE_NAME
}

install_docker() {
    sudo apt-get update
    sudo apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg \
        lsb-release

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
}

install_python3_addons() {
    sudo apt install -y python3-venv python3-pip
    pip3 install pylint
    #python3 -m pip install -U git+git://github.com/python/mypy.git
}

install_chrome() {
    install_deb "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
}

install_intellij() {
    # https://www.jetbrains.com/idea/download/other.html
    # https://www.jetbrains.com/help/idea/installation-guide.html#standalone

    sudo snap install intellij-idea-community --classic
}

install_discord() {
    install_deb "https://discord.com/api/download?platform=linux&format=deb"
}

install_sublime_merge() {
    wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
    sudo apt-get install -y apt-transport-https
    echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
    sudo apt-get update
    sudo apt-get install -y sublime-merge
}

install_virtualbox() {
    sudo apt install -y virtualbox
}

install_vagrant() {
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
    sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
    sudo apt-get update && sudo apt-get install -y vagrant
}

install_mongodb_v4_4() {
    # https://docs.mongodb.com/v4.4/tutorial/install-mongodb-on-ubuntu/

    wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -
    echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list
    sudo apt-get update
    sudo apt-get install -y mongodb-org=4.4.8 mongodb-org-server=4.4.8 mongodb-org-shell=4.4.8 mongodb-org-mongos=4.4.8 mongodb-org-tools=4.4.8

    # prevent unintended upgrades
    echo "mongodb-org hold" | sudo dpkg --set-selections
    echo "mongodb-org-server hold" | sudo dpkg --set-selections
    echo "mongodb-org-shell hold" | sudo dpkg --set-selections
    echo "mongodb-org-mongos hold" | sudo dpkg --set-selections
    echo "mongodb-org-tools hold" | sudo dpkg --set-selections
}

install_mongodb() {
    # NOTES
    # -----
    # `sudo systemctl start mongod` might fail when your cpu doesn't support versions above 4.4.
    # In this case, try to uninstall the latest version and use install_mongodb_v4_4 function.

    # The latest version is currently 5.0.
    # https://docs.mongodb.com/manual/tutorial/install-mongodb-on-ubuntu/

    wget -qO - https://www.mongodb.org/static/pgp/server-5.0.asc | sudo apt-key add -
    echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/5.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-5.0.list
    sudo apt-get update
    sudo apt-get install -y mongodb-org

    # You can change the ulimit settings for better performance:
    # https://docs.mongodb.com/manual/tutorial/install-mongodb-on-ubuntu/#run-mongodb-community-edition
}

install_tree() {
    sudo apt install -y tree
}

install_htop() {
    sudo apt install -y htop
}

install_netcat() {
    sudo apt install -y netcat
}

install_watch() {
    sudo apt install -y watch
}

declare -A available_installations=(
    ["zsh"]=install_zsh
    ["vscode"]=install_vscode
    ["nvm"]=install_nvm
    ["postman"]=install_postman
    ["dbeaver"]=install_dbeaver
    ["jq"]=install_jq
    ["bat"]=install_bat
    ["java"]=install_java
    ["maven"]=install_maven
    ["docker"]=install_docker
    ["python3_addons"]=install_python3_addons
    ["chrome"]=install_chrome
    ["intellij"]=install_intellij
    ["discord"]=install_discord
    ["sublime-merge"]=install_sublime_merge
    ["virtualbox"]=install_virtualbox
    ["vagrant"]=install_vagrant
    ["mongodb"]=install_mongodb_v4_4
    ["tree"]=install_tree
    ["htop"]=install_htop
    ["netcat"]=install_netcat
    ["watch"]=install_watch
)

install_programs() {
    local -n names=$1

    for pn in "${names[@]}"; do
        if [ -v "available_installations[$pn]" ]; then
            if run_installation "${available_installations[$pn]}" $pn; then
                logger+=([$pn]=$SUCCESS)
            else
                logger+=([$pn]=$FAIL)
            fi
        else
            logger+=([$pn]=$NOT_AVAILABLE)
        fi
    done

    display_installation_results
}

uninstall_programs() {
    sudo apt remove -y zsh zsh-common
    sudo rm -r ${HOME}/.zshrc ${HOME}/.p10k.zsh ${HOME}/.oh-my-zsh

    code --uninstall-extension teabyii.ayu
    code --uninstall-extension streetsidesoftware.code-spell-checker
    code --uninstall-extension ms-azuretools.vscode-docker
    code --uninstall-extension mhutchie.git-graph
    code --uninstall-extension eamodio.gitlens
    code --uninstall-extension yzhang.markdown-all-in-one
    code --uninstall-extension pkief.material-icon-theme
    code --uninstall-extension christian-kohler.path-intellisense
    code --uninstall-extension wayou.vscode-todo-highlight
    code --uninstall-extension visualstudioexptteam.vscodeintellicode
    code --uninstall-extension redhat.vscode-yaml
    sudo apt remove -y code
    sudo rm ${HOME}/.config/Code/User/settings.json ${HOME}/.config/Code/User/keybindings.json

    sudo rm -r "$NVM_DIR"
    sudo rm -r ${HOME}/.npm

    sudo rm -r /opt/Postman
    sudo rm -r /usr/bin/postman

    sudo apt remove -y dbeaver-ce

    sudo rm -r /usr/bin/jq

    sudo apt remove -y bat

    sudo apt-get purge -y openjdk-17*

    sudo rm -r /opt/apache-maven-3.8.3

    sudo apt-get purge -y docker-ce docker-ce-cli containerd.io docker-ce-rootless-extras docker-scan-plugin
    sudo rm -r /var/lib/docker
    sudo rm -r /var/lib/containerd
    sudo rm -r /usr/share/keyrings/docker-archive-keyring.gpg

    sudo apt remove -y python3-venv python3-pip
    pip3 uninstall pylint

    #sudo apt remove -y google-chrome google-chrome-stable
    sudo dpkg -r google-chrome-stable

    sudo snap remove intellij-idea-community

    sudo apt remove -y discord

    sudo apt remove -y sublime-merge

    sudo apt-get purge -y virtualbox

    sudo rm -r /opt/vagrant
    sudo rm -r /usr/bin/vagrant
    sudo apt remove -y vagrant

    sudo service mongod stop
    sudo apt-get purge -y mongodb-org*
    sudo apt remove -y mongodb-database-tools mongodb-mongosh
    sudo rm -r /var/log/mongodb
    sudo rm -r /var/lib/mongodb

    sudo apt remove -y tree

    sudo apt remove -y htop
    
    sudo apt remove -y netcat
    
    sudo apt remove -y watch
}
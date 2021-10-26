# Ubuntu Dotfiles

My personal dotfiles for the Ubuntu desktop environment. Fork the repository to adapt it to your preferences.

## Structure

```bash
config/ 
    git/
    vscode/
    zsh/
    # more personal settings for different programs
configs.sh
programs.sh
run.sh
```

* `config/` directory is where you put all your personal settings that you use in any development environment.

* `configs.sh` contains functions for copying or removing your personal settings.

* `programs.sh` contains all the installation code for programs. This is where you want to add new installation codes or delete existing ones.

* `run.sh` is script that allows you to install all programs and set configurations with a single command.

## Usage

### Installing all available programs and settings

```bash
./run.sh setup
```

### Adding personal settings for a program

1. Put the necessary files in config folder.

2. Add them to `config_paths` array in the `run.sh` script.

    ```bash
    declare -a config_paths=(
        # SOURCE                                # DEST
        # ...
        "<source-path-for-new-config-file>      <destination-path-for-new-config-file>"
    )
    ```

### Selecting the programs to install

* There are available programs by default. Their names are listed in `program_names` array in the `run.sh` script. Remove the name of the program to avoid installing it.

    ```bash
    declare -a program_names=(
        # "zsh"         # Do not install the zsh
        "vscode"
        "nvm"
    )
    ```

### Adding new programs

1. Create a function in `programs.sh` and add the installation code to it.

    ```bash
    install_mongodb() {
        wget -qO - https://www.mongodb.org/static/pgp/server-5.0.asc | sudo apt-key add -
        echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/5.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-5.0.list
        sudo apt-get update
        sudo apt-get install -y mongodb-org
    }
    ```

2. Add this function to `available_installations` dictionary in `programs.sh`.

    ```bash
    declare -A available_installations=(
        # ...
        ["mongodb"]=install_mongodb
    )
    ```

3. Add the new key to `program_names` array in `run.sh`.

    ```bash
    declare -a program_names=(
        # ...
        "mongodb"
    )
    ```

### Uninstalling all programs and settings

Note: Use this for debugging purposes only.

```bash
./run.sh clear
```

## Creating desktop environment with all programs installed

1. Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads) and [Vagrant](https://www.vagrantup.com/docs/installation).

2. Create a virtual machine with Ubuntu desktop installed by using the `Vagrantfile`.

    ```bash
    vagrant up
    ```

3. Use `vagrant` user to login to Ubuntu desktop. The password for `vagrant` user is `vagrant`. See ["vagrant" User](https://www.vagrantup.com/docs/boxes/base#vagrant-user).

## Notes

* If you don't use `zsh` as the default terminal, you may need to copy some environment variables of installed programs into `(~/.bash_profile, ~/.profile, or ~/.bashrc)`. For example:

    ```bash
    # Add these lines to your .bashrc file.
    export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
    export PATH=$JAVA_HOME/bin:$PATH
    ```

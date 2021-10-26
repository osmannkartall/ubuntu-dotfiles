Vagrant.configure("2") do |config|
  config.vm.provider :virtualbox do |v|
      v.gui = true
      v.memory = 4096
  end

  config.vm.box = "ubuntu/focal64"

  config.vm.provision "shell", inline: <<-SHELL
      sudo apt update -y
      sudo apt upgrade -y

      sudo apt install -y --no-install-recommends ubuntu-desktop
      sudo apt install -y --no-install-recommends dkms virtualbox-guest-dkms virtualbox-guest-utils virtualbox-guest-x11
      sudo apt install -y --no-install-recommends yaru-theme-gtk yaru-theme-sound yaru-theme-gnome-shell yaru-theme-icon yaru-theme-unity

      sudo usermod -a -G sudo vagrant
  SHELL

  # Install programs as non-privileged user.
  config.vm.provision "shell", privileged: false, inline: <<-SHELL
      cd /workspace
      ./run.sh setup
  SHELL

  config.vm.provision "shell", inline: "sudo shutdown -r now"

  config.vm.synced_folder ".", "/workspace"
end

#! /usr/bin/env bash

if [ -n "${GUARD_DEPENDENCIES_INCLUDED:-}" ]; then
  return
fi

GUARD_DEPENDENCIES_INCLUDED=1

source "system.sh"
source "prompt.sh"

# Check if user has sudo access
function check_sudo_access() {
  if sudo -n true 2>/dev/null; then
    return 0  # Has sudo access (no password required or already cached)
  elif sudo -v 2>/dev/null; then
    return 0  # Has sudo access (password provided)
  else
    return 1  # No sudo access
  fi
}

# Detect Linux distribution
function detect_distro() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo "$ID"
  elif command -v lsb_release >/dev/null 2>&1; then
    lsb_release -si | tr '[:upper:]' '[:lower:]'
  elif [ -f /etc/redhat-release ]; then
    echo "rhel"
  elif [ -f /etc/debian_version ]; then
    echo "debian"
  else
    echo "unknown"
  fi
}

# Check if Docker Engine is installed and running
function check_docker() {
  if ! is_installed docker; then
    return 1
  fi
  
  # Check if Docker daemon is running
  if ! docker info >/dev/null 2>&1; then
    return 1
  fi
  
  return 0
}

# Check Docker Compose (both modern and legacy)
function check_docker_compose() {
  # Check for modern docker compose (plugin)
  if docker compose version >/dev/null 2>&1; then
    return 0
  fi
  
  # Check for legacy docker-compose (standalone)
  if docker-compose --version >/dev/null 2>&1; then
    return 0
  fi
  
  return 1
}

# Check Docker user permissions
function check_docker_permissions() {
  if ! docker ps >/dev/null 2>&1; then
    return 1
  fi
  return 0
}

# Check for other required dependencies
function check_other_dependencies() {
  local missing_deps=()
  
  if ! is_installed curl; then
    missing_deps+=("curl")
  fi
  
  if ! is_installed whiptail; then
    missing_deps+=("whiptail")
  fi
  
  if ! is_installed git; then
    missing_deps+=("git")
  fi
  
  # Check for pwgen (optional but recommended)
  if ! is_installed pwgen; then
    missing_deps+=("pwgen (recommended)")
  fi
  
  if [ ${#missing_deps[@]} -gt 0 ]; then
    echo "${missing_deps[@]}"
    return 1
  fi
  
  return 0
}

# Install Docker for Ubuntu/Debian
function install_docker_debian() {
  local distro=$1
  
  echo "Installing Docker for $distro..."
  
  # Update package index
  sudo apt-get update
  
  # Install packages to allow apt to use a repository over HTTPS
  sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
  
  # Add Docker's official GPG key
  curl -fsSL https://download.docker.com/linux/$distro/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  
  # Set up the stable repository
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/$distro \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  
  # Install Docker Engine
  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
  
  return $?
}

# Install Docker for RHEL/CentOS/Fedora
function install_docker_rhel() {
  local distro=$1
  
  echo "Installing Docker for $distro..."
  
  # Install yum-utils
  sudo yum install -y yum-utils
  
  # Add Docker repository
  sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
  
  # Install Docker Engine
  sudo yum install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
  
  return $?
}

# Install Docker for Fedora
function install_docker_fedora() {
  echo "Installing Docker for Fedora..."
  
  # Install dnf-plugins-core
  sudo dnf install -y dnf-plugins-core
  
  # Add Docker repository
  sudo dnf config-manager \
    --add-repo \
    https://download.docker.com/linux/fedora/docker-ce.repo
  
  # Install Docker Engine
  sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
  
  return $?
}

# Install Docker for Arch Linux
function install_docker_arch() {
  echo "Installing Docker for Arch Linux..."
  
  # Install Docker
  sudo pacman -S --noconfirm docker
  
  return $?
}

# Install Docker using the convenience script (universal fallback)
function install_docker_convenience_script() {
  echo "Installing Docker using convenience script..."
  
  # Download and run the official Docker installation script
  curl -fsSL https://get.docker.com -o get-docker.sh
  sudo sh get-docker.sh
  rm get-docker.sh
  
  return $?
}

# Main Docker installation function
function install_docker() {
  local distro=$(detect_distro)
  local install_result=1
  
  case "$distro" in
    ubuntu|debian|pop)
      install_docker_debian "$distro"
      install_result=$?
      ;;
    rhel|centos|amzn)
      install_docker_rhel "$distro"
      install_result=$?
      ;;
    fedora)
      install_docker_fedora
      install_result=$?
      ;;
    arch)
      install_docker_arch
      install_result=$?
      ;;
    *)
      echo "Unknown distribution: $distro"
      echo "Falling back to convenience script..."
      install_docker_convenience_script
      install_result=$?
      ;;
  esac
  
  if [ $install_result -eq 0 ]; then
    # Start and enable Docker service
    sudo systemctl start docker
    sudo systemctl enable docker
    
    echo "Docker installed successfully!"
    echo "IMPORTANT: You need to add your user to the docker group:"
    echo "  sudo usermod -aG docker \$USER"
    echo "Then log out and log back in for the changes to take effect."
    
    return 0
  else
    echo "Docker installation failed!"
    return 1
  fi
}

# Install other dependencies
function install_other_dependencies() {
  local distro=$(detect_distro)
  local missing_deps=($(check_other_dependencies 2>/dev/null || true))
  
  if [ ${#missing_deps[@]} -eq 0 ]; then
    return 0
  fi
  
  echo "Installing additional dependencies..."
  
  case "$distro" in
    ubuntu|debian|pop)
      sudo apt-get update
      for dep in "${missing_deps[@]}"; do
        case "$dep" in
          "pwgen (recommended)")
            sudo apt-get install -y pwgen
            ;;
          *)
            sudo apt-get install -y "$dep"
            ;;
        esac
      done
      ;;
    rhel|centos|amzn)
      for dep in "${missing_deps[@]}"; do
        case "$dep" in
          "pwgen (recommended)")
            sudo yum install -y pwgen
            ;;
          *)
            sudo yum install -y "$dep"
            ;;
        esac
      done
      ;;
    fedora)
      for dep in "${missing_deps[@]}"; do
        case "$dep" in
          "pwgen (recommended)")
            sudo dnf install -y pwgen
            ;;
          *)
            sudo dnf install -y "$dep"
            ;;
        esac
      done
      ;;
    arch)
      for dep in "${missing_deps[@]}"; do
        case "$dep" in
          "pwgen (recommended)")
            sudo pacman -S --noconfirm pwgen
            ;;
          *)
            sudo pacman -S --noconfirm "$dep"
            ;;
        esac
      done
      ;;
    *)
      echo "Cannot automatically install dependencies on unknown distribution: $distro"
      return 1
      ;;
  esac
  
  return 0
}

# Check if user needs to log out/in for Docker group
function check_docker_group_refresh() {
  if groups | grep -q docker; then
    return 0  # User is already in docker group
  else
    return 1  # User needs to log out/in
  fi
}

# Comprehensive dependency check with auto-install option
function check_and_install_dependencies() {
  local distro=$(detect_distro)
  local issues=()
  local can_auto_fix=true
  
  echo "Checking dependencies on $distro..."
  
  # Check Docker Engine
  if ! check_docker; then
    issues+=("Docker Engine is not installed or not running")
  fi
  
  # Check Docker Compose
  if ! check_docker_compose; then
    issues+=("Docker Compose is not installed")
  fi
  
  # Check Docker permissions
  if check_docker && ! check_docker_permissions; then
    issues+=("User doesn't have Docker permissions")
    can_auto_fix=false  # This requires user action
  fi
  
  # Check other dependencies
  local other_deps
  if ! other_deps=$(check_other_dependencies 2>/dev/null); then
    issues+=("Missing dependencies: $other_deps")
  fi
  
  # If no issues, we're good
  if [ ${#issues[@]} -eq 0 ]; then
    echo "✅ All dependencies are satisfied!"
    return 0
  fi
  
  # Display issues
  echo ""
  echo "❌ Found dependency issues:"
  for issue in "${issues[@]}"; do
    echo "  • $issue"
  done
  echo ""
  
  # Create a summary message for the dialog
  local dialog_msg="Found dependency issues that need to be resolved:\n\n"
  for issue in "${issues[@]}"; do
    dialog_msg+="• $issue\n"
  done
  dialog_msg+="\nWould you like the installer to automatically fix these issues?"
  
  # Offer to fix automatically
  if confirmbox "Install Dependencies" "$dialog_msg"; then
    echo ""
    
    # Check sudo access before attempting installation
    if ! check_sudo_access; then
      echo "❌ This operation requires sudo access to install packages."
      echo "Please run this installer with a user that has sudo privileges."
      echo ""
      echo "If you have sudo access, you may need to enter your password when prompted."
      return 1
    fi
    
    # Install Docker if needed
    if ! check_docker; then
      echo "Installing Docker..."
      if install_docker; then
        echo "✅ Docker installed successfully"
      else
        echo "❌ Docker installation failed"
        return 1
      fi
    fi
    
    # Install other dependencies if needed
    if ! check_other_dependencies >/dev/null 2>&1; then
      echo "Installing additional dependencies..."
      if install_other_dependencies; then
        echo "✅ Additional dependencies installed"
      else
        echo "❌ Failed to install additional dependencies"
        return 1
      fi
    fi
    
    # Check if user needs to log out/in for Docker permissions
    if ! check_docker_permissions; then
      echo ""
      echo "⚠️  Docker permissions issue detected!"
      echo "Your user account needs to be added to the docker group."
      echo ""
      
      if confirmbox "Fix Docker Permissions" "Add your user to the docker group?"; then
        sudo usermod -aG docker "$USER"
        echo ""
        echo "✅ User added to docker group"
        echo ""
        echo "🔄 IMPORTANT: You must log out and log back in for the changes to take effect."
        echo "   After logging back in, run this installer again."
        echo ""
        exit 0
      else
        echo "❌ Cannot proceed without Docker permissions"
        return 1
      fi
    fi
    
    # Final verification
    echo ""
    echo "Performing final dependency check..."
    if check_docker && check_docker_compose && check_docker_permissions && check_other_dependencies >/dev/null 2>&1; then
      echo "✅ All dependencies are now satisfied!"
      return 0
    else
      echo "❌ Some issues still remain. Please check manually."
      return 1
    fi
  else
    echo "Dependency installation cancelled."
    return 1
  fi
}

# Interactive dependency check dialog
function check_dependencies_dialog() {
  local result
  
  # Run the check and capture output
  if result=$(check_and_install_dependencies 2>&1); then
    msgbox "Dependencies Check" "✅ All dependencies are satisfied!\n\n$result"
  else
    msgbox "Dependencies Check" "❌ Dependency check failed!\n\n$result\n\nPlease resolve the issues and try again."
  fi
}

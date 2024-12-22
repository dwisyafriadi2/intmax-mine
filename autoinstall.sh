#!/bin/bash

# Function to print the banner
print_banner() {
    curl -s https://raw.githubusercontent.com/dwisyafriadi2/logo/main/logo.sh | bash
}

# Function to display process message
process_message() {
    echo -e "\n\e[42m$1...\e[0m\n" && sleep 1
}

# Function to check root/sudo and set home directory
check_root() {
    process_message "Checking root privileges"
    if [ "$EUID" -ne 0 ]; then
        HOME_DIR="/home/$USER"
        echo "Running as user. Files will be saved to $HOME_DIR."
    else
        HOME_DIR="/root"
        echo "Running as root. Files will be saved to $HOME_DIR."
    fi
}

# Function to delete old data
delete_old_data() {
    process_message "Deleting old data and binaries"
    rm -rf "$HOME_DIR/mining-cli*" "$HOME_DIR/mining.log"
    echo "Old data and binaries have been removed."
}

# Function to download the latest miner binary
download_miner() {
    process_message "Downloading the latest mining-cli binary"

    # Ensure necessary tools are installed
    sudo apt update
    sudo apt install -y wget unzip jq

    # Fetch the latest release information from GitHub API
    LATEST_RELEASE=$(curl -s https://api.github.com/repos/InternetMaximalism/intmax2-mining-cli/releases/latest)

    # Extract the download URL for the Linux binary using jq
    DOWNLOAD_URL=$(echo "$LATEST_RELEASE" | jq -r '.assets[] | select(.name == "mining-cli-x86_64-unknown-linux-gnu.zip") | .browser_download_url')

    # Check if the download URL was successfully extracted
    if [ -z "$DOWNLOAD_URL" ]; then
        echo "❌ Failed to fetch the latest release URL. Exiting."
        exit 1
    fi

    # Download and unzip the binary
    wget "$DOWNLOAD_URL" -O "$HOME_DIR/mining-cli.zip"
    unzip -o "$HOME_DIR/mining-cli.zip" -d "$HOME_DIR/"
    chmod +x "$HOME_DIR/mining-cli"
    rm "$HOME_DIR/mining-cli.zip"
    echo "✅ Download and extraction complete."
}



# Function to configure environment variables
configure_environment() {
    process_message "Configuring environment variables"
    # Add any environment configuration here if needed
    echo "Environment configured."
}

# Function to start the miner
start_miner() {
    process_message "Starting miner in the background"
    nohup "$HOME_DIR/mining-cli" > "$HOME_DIR/mining.log" 2>&1 &
    MINER_PID=$!
    echo "Miner started with PID $MINER_PID. Logs are being written to $HOME_DIR/mining.log"
}

# Main function to orchestrate the setup
main() {
    print_banner
    check_root
    delete_old_data
    download_miner
    configure_environment
    start_miner
    echo "Setup complete! The miner is running in the background."
}

# Run the main function
main

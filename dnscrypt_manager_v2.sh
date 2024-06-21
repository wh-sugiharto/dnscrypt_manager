#!/bin/bash

DNSCRYPT_DIR="/usr/local/dnscrypt-proxy"
PLIST_FILE="/Library/LaunchDaemons/dnscrypt-proxy.plist"
LOG_FILE="$DNSCRYPT_DIR/dnscrypt-proxy.log"

install_dnscrypt() {
    echo "Installing dnscrypt-proxy..."
    sudo mkdir -p $DNSCRYPT_DIR
    sudo cp -r dnscrypt-proxy/* $DNSCRYPT_DIR/
    sudo chown -R root:wheel $DNSCRYPT_DIR
    sudo chmod -R 755 $DNSCRYPT_DIR

    cat <<EOL | sudo tee $PLIST_FILE
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>dnscrypt-proxy</string>
    <key>ProgramArguments</key>
    <array>
        <string>$DNSCRYPT_DIR/dnscrypt-proxy</string>
        <string>-config</string>
        <string>$DNSCRYPT_DIR/dnscrypt-proxy.toml</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardErrorPath</key>
    <string>$LOG_FILE</string>
    <key>StandardOutPath</key>
    <string>$LOG_FILE</string>
</dict>
</plist>
EOL

    sudo launchctl unload $PLIST_FILE
    sudo launchctl load -w $PLIST_FILE
    sudo launchctl start dnscrypt-proxy

    echo "dnscrypt-proxy installed and started."
}

uninstall_dnscrypt() {
    echo "Uninstalling dnscrypt-proxy..."
    sudo launchctl unload $PLIST_FILE
    sudo rm -rf $DNSCRYPT_DIR
    sudo rm $PLIST_FILE
    echo "dnscrypt-proxy uninstalled."
}

check_status() {
    sudo launchctl list | grep dnscrypt-proxy
}

check_log() {
    cat $LOG_FILE
}

check_port_53() {
    sudo lsof -i :53
}

menu() {
    echo "Select an option:"
    echo "1. Install dnscrypt-proxy"
    echo "2. Uninstall dnscrypt-proxy"
    echo "3. Check service status"
    echo "4. Check error log"
    echo "5. Check processes using port 53"
    echo "6. Exit"
    read -p "Enter your choice [1-6]: " choice

    case $choice in
        1) install_dnscrypt ;;
        2) uninstall_dnscrypt ;;
        3) check_status ;;
        4) check_log ;;
        5) check_port_53 ;;
        6) exit 0 ;;
        *) echo "Invalid option. Please try again." ;;
    esac
}

while true; do
    menu
done

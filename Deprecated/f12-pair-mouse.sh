
DEVICE_NAME="BM20X"

echo "Restarting Bluetooth service..."
systemctl --user restart bluetooth || sudo systemctl restart bluetooth
sleep 2

echo "Starting bluetoothctl to pair $DEVICE_NAME ..."
bluetoothctl <<'EOF'
power on
agent on
default-agent
scan on
EOF

echo "Scanning for $DEVICE_NAME ..."
for i in {1..15}; do
    DEV_ADDR=$(bluetoothctl devices | grep "$DEVICE_NAME" | awk '{print $2}')
    if [ -n "$DEV_ADDR" ]; then
        echo "Found $DEVICE_NAME at $DEV_ADDR"
        break
    fi
    sleep 1
done

if [ -z "$DEV_ADDR" ]; then
    echo "❌ Could not find $DEVICE_NAME. Make sure it’s in pairing mode."
    exit 1
fi

echo "Pairing and connecting..."
bluetoothctl <<EOF
pair $DEV_ADDR
sleep 3
trust $DEV_ADDR
connect $DEV_ADDR
EOF

echo "✅ Done. You can verify with: bluetoothctl info $DEV_ADDR"
#!/bin/bash

save_private_key() {
    PRIVATE_KEY=$(terraform output -raw outline_private_key)
    OUTPUT_FILE="outline_key.pem"

    echo "$PRIVATE_KEY" > $OUTPUT_FILE

    chmod 400 $OUTPUT_FILE
    echo "Private key saved to $OUTPUT_FILE"
}

"$1" "${2:-""}"

exit 0

#! /usr/bin/env bash

if [ -n "${GUARD_PAYNYM_INCLUDED:-}" ]; then
  return
fi

GUARD_PAYNYM_INCLUDED=1

source "prompt.sh"

# Function to validate Paynym format
function validate_paynym() {
  local paynym="$1"
  
  # Check if paynym is not empty and contains only valid characters
  if [[ -z "$paynym" ]]; then
    return 1
  fi
  
  # Paynyms should be lowercase letters and numbers only, no spaces
  if [[ ! "$paynym" =~ ^[a-z0-9]+$ ]]; then
    return 1
  fi
  
  # Check reasonable length (3-30 characters)
  if [[ ${#paynym} -lt 3 || ${#paynym} -gt 30 ]]; then
    return 1
  fi
  
  return 0
}

# Function to fetch payment code from paynym.is
function fetch_payment_code() {
  local paynym="$1"
  local payment_code
  
  # Fetch the payment code from paynym.rs
  payment_code=$(curl -s "https://paynym.rs/+$paynym" | \
    grep -o '<div class="p-4 font-mono text-lg flex-1 overflow-hidden overflow-ellipsis"[^>]*>[^<]*' | \
    sed 's/<[^>]*>//g' | \
    head -1 | \
    tr -d ' \t\n\r')
  
  # Validate payment code format (should start with PM8T...)
  if [[ -n "$payment_code" && "$payment_code" =~ ^PM8T ]]; then
    echo "$payment_code"
    return 0
  else
    return 1
  fi
}

# Function to update NODE_PAYMENT_CODE in config
function update_payment_code() {
  local payment_code="$1"
  local config_file="samourai-dojo-1.28.2/docker/my-dojo/conf/docker-node.conf"
  local config_dir=$(dirname "$config_file")
  
  # Create config directory if it doesn't exist
  if [[ ! -d "$config_dir" ]]; then
    mkdir -p "$config_dir"
  fi
  
  # Create or update the configuration file
  if [[ -f "$config_file" ]]; then
    # Update the NODE_PAYMENT_CODE line if it exists
    if grep -q "^NODE_PAYMENT_CODE=" "$config_file"; then
      sed -i "s/^NODE_PAYMENT_CODE=.*/NODE_PAYMENT_CODE=$payment_code/" "$config_file"
    else
      # Add NODE_PAYMENT_CODE if it doesn't exist
      echo "NODE_PAYMENT_CODE=$payment_code" >> "$config_file"
    fi
  else
    # Create the file with the payment code
    echo "NODE_PAYMENT_CODE=$payment_code" > "$config_file"
  fi
  
  echo "Payment code updated in configuration file."
  return 0
}

# Main function to setup Paynym payment code
function setup_paynym_payment_code() {
  local paynym
  local payment_code
  local max_attempts=3
  local attempt=1
  
  while [[ $attempt -le $max_attempts ]]; do
    # Ask user for Paynym
    paynym=$(inputbox "Paynym Setup" \
      "Enter your Paynym handle (without the + sign):\n\nExample: stickydrawing36\n\nThis will be used to set your NODE_PAYMENT_CODE for admin authentication.\n\nAttempt $attempt of $max_attempts:")
    
    # Check if user cancelled
    if [[ -z "$paynym" ]]; then
      if confirmbox "Skip Paynym Setup" "Do you want to skip Paynym setup and continue?\n\nYou can always configure this later in the node configuration file." "No" "Yes"; then
        return 0  # User chose to skip
      else
        continue  # User chose to try again
      fi
    fi
    
    # Validate Paynym format
    if ! validate_paynym "$paynym"; then
      msgbox "Invalid Paynym" "The Paynym '$paynym' is not valid.\n\nPaynyms should:\n• Be 3-30 characters long\n• Contain only lowercase letters and numbers\n• Have no spaces or special characters\n\nPlease try again."
      ((attempt++))
      continue
    fi
    
    # Fetch payment code
    payment_code=$(fetch_payment_code "$paynym")
    
    if [[ $? -eq 0 && -n "$payment_code" ]]; then
      # Success! Update configuration
      if update_payment_code "$payment_code"; then
        msgbox "Success!" "Paynym setup completed successfully!\n\nPaynym: +$paynym\nPayment Code: $payment_code\n\nThe payment code has been saved to your node configuration."
        return 0
      else
        msgbox "Configuration Error" "Failed to update the configuration file.\n\nPlease check file permissions and try again."
        return 1
      fi
    else
      msgbox "Paynym Not Found" "Could not find a valid payment code for '+$paynym'.\n\nPlease verify:\n• The Paynym handle is spelled correctly\n• The Paynym exists on paynym.rs\n• You have an internet connection\n\nTry again or check your Paynym handle."
      ((attempt++))
    fi
  done
  
  # Max attempts reached
  if confirmbox "Setup Failed" "Failed to set up Paynym after $max_attempts attempts.\n\nDo you want to:\n• Continue without Paynym setup (you can configure later)\n• Try again" "Continue" "Try Again"; then
    return 0  # User chose to continue
  else
    setup_paynym_payment_code  # User chose to try again
  fi
}

# Function to check if payment code is already configured
function is_payment_code_configured() {
  local config_file="samourai-dojo-1.28.2/docker/my-dojo/conf/docker-node.conf"
  
  if [[ -f "$config_file" ]]; then
    local payment_code=$(grep "^NODE_PAYMENT_CODE=" "$config_file" | cut -d'=' -f2)
    if [[ -n "$payment_code" && "$payment_code" != "" ]]; then
      return 0  # Payment code is configured
    fi
  fi
  
  return 1  # Payment code is not configured
}

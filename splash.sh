#! /usr/bin/env bash

if [ -n "${GUARD_SPLASH_INCLUDED:-}" ]; then
  return
fi

GUARD_SPLASH_INCLUDED=1

source "prompt.sh"

# Display Dojo splash screen with logo (whiptail version)
function show_splash() {
  local splash_text="                                                                  
                                    ,;.                            
                                  ,ckOk,                           
                                .,xWMMMO:;                         
                                ckXMMMMMMWOl.                       
                            odxWNMMMWWNWMMMNWkdo.                   
                        .cX                   :ko.                 
                    .;lk;                     .'.  'Oo;.            
              Ok0XMW0o,;.                ..        'lOWMN0kO       
                  :MMMMMMMWNXXXXKKKKKKKKKXWNNXXNWWMMMMMMMo          
                          lKdMMMMMMMMMMMMMMMMMMMMd                  
                          l'kMMO   ;MMo   cMMM,o                   
                          ;,oMM:   .MM'   ,MMW.l                   
                          OxXMMWKKXNMMWKKXWMMM:d                   
                          ;MM',kc'ddxMlc'dl,;dlX                   
                                00d00KM0kdKOxkKOW                   
                                      :MMMMMO"                      
                                                                                                                                       
                      
  # Display splash screen using whiptail
  if command -v whiptail >/dev/null 2>&1; then
    whiptail --title "⛩️ DOJO INSTALLER v1.28.2 ⛩️" --msgbox "$splash_text" 25 80
  else
    # Fallback to terminal version if whiptail is not available
    show_splash_terminal
  fi
}


#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "\nWelcome to My Salon, how can I help you?\n"


MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  
  #get services
  SERVICES=$($PSQL "select * from services")
  echo -e "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  #user Input
  read SERVICE_ID_SELECTED

  # case $SERVICE_ID_SELECTED in
  #   1) CUT ;;
  #   2) COLOR ;;
  #   3) TRIM ;;
  #   *) MAIN_MENU "I could not find that service. What would you like today?" ;;
  # esac

  
   #input not a number
   if [[  SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
   then
    #sent to main menu
    MAIN_MENU "Sorry..,It's not a valid Number,Please Enter again..!"
    else
    #input valid
    MATCH_SERVICE_NAME_WITH_ID=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED ")
    
      if [[ -z $MATCH_SERVICE_NAME_WITH_ID ]]
      then
        MAIN_MENU "I could not find that service. What would you like today?"
      else
        #get phone number
          echo -e "\nWhat's your phone number?"
          read CUSTOMER_PHONE
    
          #check customer details
          CUSTOMER_ID=$($PSQL "select * from customers where phone='$CUSTOMER_PHONE'")

          #if not found customer id
          if [[ -z $CUSTOMER_ID ]]
          then
            #get user name
            echo -e "\nI don't have a record for that phone number, what's your name?"
            read CUSTOMER_NAME

            #insert name&phone number
            INSERT_C_TABLE=$($PSQL "insert into customers(phone,name) values ('$CUSTOMER_PHONE','$CUSTOMER_NAME') ")

            else
              #found customer id
              CUSTOMER_NAME=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE' ")
              echo -e "\nWelcome back..$(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g') "
            fi

            echo -e "\nWhat time would you like your $(echo $MATCH_SERVICE_NAME_WITH_ID | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')?"
            read SERVICE_TIME

          #insert service time,
          CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE' ")
          INSERT_S_TABLE=$($PSQL "insert into appointments(time,customer_id,service_id) values('$SERVICE_TIME',$CUSTOMER_ID,$SERVICE_ID_SELECTED)")

          #confirm appointment
          echo -e "\nI have put you down for a $(echo $MATCH_SERVICE_NAME_WITH_ID | sed -r 's/^ *| *$//g') at $(echo $SERVICE_TIME | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."

      fi
    fi
  


}


# CUT() {
#   echo cut
  
# }
# COLOR() {
#   echo color
# }
# TRIM() {
#   echo trim
# }

MAIN_MENU

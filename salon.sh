#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon -t -c"

#introduce salon
echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

MAIN_MENU() {
  #if argument exists
  if [[ $1 ]]
  then
    #state the argument
    echo -e "\n$1"
  fi

  #display services
  DISPLAY_SERVICES

  #get service
  GET_SERVICE

}

DISPLAY_SERVICES() {
  #get available services
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

  #format and display services
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME 
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

}

GET_SERVICE() {
  #get service id from customer
  read SERVICE_ID

  #get service name base on id
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id='$SERVICE_ID'")

  #if no such service
  if [[ -z $SERVICE_NAME ]]
  then
    #send to main menu
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    #get phone nnumber
    echo -e "\nWhat's your phone number?"
    read PHONE_NUMBER

    #get customer
    GET_CUSTOMER
  fi
}

GET_CUSTOMER() {
  #get customer name and format
  CUSTOMER_NAME_RAW=$($PSQL "SELECT name FROM customers WHERE phone='$PHONE_NUMBER'")
  CUSTOMER_NAME=$(echo $CUSTOMER_NAME_RAW | sed -r 's/^ *| *$//g')

  #if no existing customer
  if [[ -z $CUSTOMER_NAME ]]
  then
    #get customer name
    echo -e "\nI don't have a record for that phone number. What's your name?"
    read CUSTOMER_NAME

    #insert customer into database
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$PHONE_NUMBER', '$CUSTOMER_NAME')")
  fi

    #set appointment
    SET_APPOINTMENT
}

SET_APPOINTMENT() {
  #get appointment time
  echo -e "\nWhat time would you like your cut, $CUSTOMER_NAME?"
  read APPOINTMENT_TIME

  #get customer id based on phone number
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$PHONE_NUMBER'")

  #insert appointment
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID, '$APPOINTMENT_TIME')")

  #inform customer
  echo -e "\nI have put you down for a cut at $APPOINTMENT_TIME, $CUSTOMER_NAME."
}

MAIN_MENU
#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

DISPLAY_SERVICES() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  AVAILABLE_SERVICES=$($PSQL "SELECT * FROM services")
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  read SERVICE_ID_SELECTED
  SERVICE_EXISTS=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  if [[ -z $SERVICE_EXISTS ]]; then
    DISPLAY_SERVICES "I could not find that service. What would you like today?"
  else
    HANDLE_CUSTOMER
  fi

}

HANDLE_CUSTOMER() {
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  CUSTOMER_NAME_FROM_DB=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  CUSTOMER_NAME=$(echo $CUSTOMER_NAME_FROM_DB | sed 's/^ *//;s/ *$//')

  if [[ -z $CUSTOMER_NAME ]]
  then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  fi

  SERVICE_NAME_FROM_DB=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  SERVICE_NAME=$(echo $SERVICE_NAME_FROM_DB | sed 's/^ *//;s/ *$//')
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

  echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
  read SERVICE_TIME

  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  if [[ $INSERT_APPOINTMENT_RESULT == "INSERT 0 1" ]]
  then
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

DISPLAY_SERVICES

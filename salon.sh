#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

HOME_MENU() {

  if [[ $1 ]]
  then 
    echo -e "\n$1"
  fi 

  SERVICES=$($PSQL "SELECT service_id, name FROM services")

  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  echo "Please select an option:" 
  read SERVICE_ID_SELECTED

  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    HOME_MENU "Please enter a service ID number"
  else 
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    if [[ -z $SERVICE_NAME ]]
    then
      HOME_MENU "Service unavailable"
    else 
      REGISTRATION_MENU "$SERVICE_ID_SELECTED" "$SERVICE_NAME"
    fi
  fi
}

REGISTRATION_MENU() {
  echo "Please enter your phone number:"
  read CUSTOMER_PHONE

  EXISTING_CUSTOMER=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  if [[ -z $EXISTING_CUSTOMER ]]
  then
    echo "Please enter your name"
    read CUSTOMER_NAME
    NEW_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  else
    CUSTOMER_NAME=$EXISTING_CUSTOMER
  fi

  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  echo -e "\nPlease enter an appointment time:"
  read SERVICE_TIME  
  
  NEW_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $1, '$SERVICE_TIME')")
  
  echo -e "I have put you down for a $2 at $SERVICE_TIME, $CUSTOMER_NAME."
  
}

HOME_MENU

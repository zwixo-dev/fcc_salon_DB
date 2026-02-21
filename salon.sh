#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

echo -e "\nWelcome to the salon. Here are the services we offer:"

# Function to display services
DISPLAY_SERVICES() {
  $PSQL "SELECT service_id, name FROM services ORDER BY service_id" | while IFS="|" read SERVICE_ID NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
}

DISPLAY_SERVICES

# Ask user to select a service
read SERVICE_ID_SELECTED

# Check if service exists
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

if [[ -z $SERVICE_NAME ]]
then
  echo -e "\nI could not find that service. Here are the options again:"
  DISPLAY_SERVICES
  read SERVICE_ID_SELECTED
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
fi

# Ask for customer phone number
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

# Check if customer exists
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

# If customer doesn't exist, ask for name and insert into customers table
if [[ -z $CUSTOMER_NAME ]]
then
  echo -e "\nI don't have a record for that phone. What's your name?"
  read CUSTOMER_NAME
  INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
fi

# Ask for appointment time
echo -e "\nWhat time would you like your appointment?"
read SERVICE_TIME

# Get customer_id
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

# Insert appointment
INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

# Output confirmation message
echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."

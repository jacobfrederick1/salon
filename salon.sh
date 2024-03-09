#! /bin/bash 
#Salon Script
PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"
echo -e "\n\n~~Jacob's Salon~~\n\n"
  
echo -e "\nWelcome to Jacob's Salon, how can I help you?"

MAIN_MENU(){
  #List salon services
  SERVICES_RESULT=$($PSQL "Select * FROM services;")
  echo -e "\n$SERVICES_RESULT" | sed 's/|/) /g'

  read SERVICE_ID_SELECTED

  #Identify what the customer wants done
  SERVICE_ID_SELECTED_RESULT=$($PSQL "Select name FROM services WHERE service_id=$SERVICE_ID_SELECTED;")
  
  if [[ -z $SERVICE_ID_SELECTED_RESULT ]]
    then
      echo -e "\nI could not find that service. What would you like today?"
      MAIN_MENU
    else
      echo -e "\nWhat is your phone number?"
      read CUSTOMER_PHONE 
      if [[ $CUSTOMER_PHONE  =~ ^[0-9]{3}-[0-9]{3}-[0-9]{4}$ ]]
        then
          CUSTOMER_PHONE_RESULT=$($PSQL "Select customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")
          #Create a customer if they do not exist
          if [[ -z $CUSTOMER_PHONE_RESULT ]]
            then
                echo -e "\nI don't have a record for that phone number, what's your name?"
                read CUSTOMER_NAME
                INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name,phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE');")
                if [[ $INSERT_CUSTOMER_RESULT == "INSERT 0 1" ]]
                  then
                    CUSTOMER_PHONE_RESULT=$($PSQL "Select customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")
                    CREATE_APPOINTMENT $CUSTOMER_PHONE $CUSTOMER_PHONE_RESULT $SERVICE_ID_SELECTEDE
                else
                  echo Customer failed to be added
                fi
            else
              CREATE_APPOINTMENT $CUSTOMER_PHONE $CUSTOMER_PHONE_RESULT $SERVICE_ID_SELECTED
          fi
        else
          echo -e "\nPhone number did not match the form: ###-###-####"
          MAIN_MENU
      fi
  fi
}

#Create an appointment
CREATE_APPOINTMENT(){
  #CREATE AN appointment
    CUSTOMER_NAME=$($PSQL "Select name FROM customers WHERE phone='$CUSTOMER_PHONE';")
   
    echo -e "\nWhat time would you like your $SERVICE_ID_SELECTED_RESULT, $CUSTOMER_NAME?\n"
    read SERVICE_TIME

    INSERT_CUSTOMER_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES('$CUSTOMER_PHONE_RESULT','$SERVICE_ID_SELECTED','$SERVICE_TIME');")

    if [[ $INSERT_CUSTOMER_APPOINTMENT == "INSERT 0 1" ]]
      then
        echo -e "\nI have put you down for a $SERVICE_ID_SELECTED_RESULT at $SERVICE_TIME, $CUSTOMER_NAME.\n"
    else
      echo -e "\nAppointment could not be schedueled"
    fi
}
MAIN_MENU

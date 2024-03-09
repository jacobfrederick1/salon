#! /bin/bash 
#Salon Script
PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"
echo -e "\n\n~~Jacob's Salon~~\n\n"


MAIN_MENU(){

  #List salon services
  SERVICES_RESULT=$($PSQL "Select * FROM services;")
  echo -e "\n$SERVICES_RESULT\n" | sed 's/|/) /g'

  echo -e "\nWhat are you looking to do today?"
  read CUSTOMER_SERVICE

  #Identify what the customer wants done
  CUSTOMER_SERVICE_RESULT=$($PSQL "Select name FROM services WHERE service_id=$CUSTOMER_SERVICE;")
  
  if [[ -z $CUSTOMER_SERVICE_RESULT ]]
    then
      echo -e "\nPlease select one of the available options"
      MAIN_MENU
    else
      echo -e "\nWhat is your phone number?"
      read PHONE_NUMBER 
      if [[ $PHONE_NUMBER =~ ^[0-9]{3}-[0-9]{3}-[0-9]{4}$ ]]
        then
          CUSTOMER_PHONE_RESULT=$($PSQL "Select customer_id FROM customers WHERE phone='$PHONE_NUMBER';")
          echo $CUSTOMER_PHONE_RESULT
          #Create a customer if they do not exist
          if [[ -z $CUSTOMER_PHONE_RESULT ]]
            then
                echo -e "\nWhat is your name?"
                read NAME
                INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name,phone) VALUES('$NAME','$PHONE_NUMBER');")
                if [[ $INSERT_CUSTOMER_RESULT == "INSERT 0 1" ]]
                  then
                    echo Customer successfully added
                    CUSTOMER_PHONE_RESULT=$($PSQL "Select customer_id FROM customers WHERE phone='$PHONE_NUMBER';")
                    CREATE_APPOINTMENT $PHONE_NUMBER $CUSTOMER_PHONE_RESULT $CUSTOMER_SERVICE $APPOINTMENT_TIME
                else
                  echo Customer failed to be added
                fi
            else
              CREATE_APPOINTMENT $PHONE_NUMBER $CUSTOMER_PHONE_RESULT $CUSTOMER_SERVICE $APPOINTMENT_TIME
          fi
        else
          echo -e "\nPhone number does not match form \#\#\#-\#\#\#-\#\#\#\#"
          MAIN_MENU
      fi
  fi
}
CREATE_APPOINTMENT(){
  #CREATE AN appointment
    echo -e "\nWhat time would you like to come in?"
    read APPOINTMENT_TIME

    NAME=$($PSQL "Select name FROM customers WHERE phone='$PHONE_NUMBER';")
    INSERT_CUSTOMER_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES('$CUSTOMER_PHONE_RESULT','$CUSTOMER_SERVICE','$APPOINTMENT_TIME');")

    if [[ $INSERT_CUSTOMER_APPOINTMENT == "INSERT 0 1" ]]
      then
        echo -e "I have put you down for a $CUSTOMER_SERVICE_RESULT at $APPOINTMENT_TIME, $NAME."
    else
      echo -e "\nAppointment could not be schedueled"
    MAIN_MENU
    fi
}
MAIN_MENU

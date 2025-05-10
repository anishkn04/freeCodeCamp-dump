#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"
if [[ -z $1 ]]
then
  echo Please provide an element as an argument.
else
  if [[ $1 =~ ^[0-9]+ ]]
  then
    RESULT=$($PSQL "select * from elements left join properties using(atomic_number) left join types using(type_id) where atomic_number = $1")
  else
    RESULT=$($PSQL "select * from elements left join properties using(atomic_number) left join types using(type_id) where symbol = '$1' or name = '$1'")
  fi
  if [[ -z $RESULT ]]
  then
    echo "I could not find that element in the database."
  else
    echo "$RESULT" | while IFS='|' read TYPE_ID ATOMIC_NUM SYMBOL NAME ATOMIC_MASS MELTING BOILING TYPE 
    do 
      echo "The element with atomic number $ATOMIC_NUM is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
    done
  fi
fi

#!/bin/bash

echo -e "\nEnter your username:"
read USERNAME
if [[ ${#USERNAME} -gt 22 ]]
then
  echo "Username shall not be more than 22 characters"
else
  PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

  DB_DATA=$($PSQL "SELECT * FROM users where username = '$USERNAME'")

  if [[ -z $DB_DATA ]]
  then
    USER_INS=$($PSQL "INSERT INTO users(username, games_played) values ('$USERNAME', 0)")
    DB_DATA=$($PSQL "SELECT * FROM users where username = '$USERNAME'")
  fi
  echo $DB_DATA | while IFS='|' read USERNAME GAMES_PLAYED BEST_GAME
  do
    if [[ $GAMES_PLAYED = 0 ]]
    then
      echo "Welcome, $USERNAME! It looks like this is your first time here."
    else
      echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
    fi
  done
  GAME_INS=$($PSQL "UPDATE users set games_played = games_played + 1 where username='$USERNAME'")
  RANDOM_GEN=$(($RANDOM/100))
  echo $RANDOM_GEN
  echo -e "Guess the secret number between 1 and 1000:"
  read GUESS
  GUESS_COUNT=1
  while [[ $GUESS -ne $RANDOM_GEN ]]
  do
    if [[ $GUESS =~ ^[0-9]+$ ]]
    then
      GUESS_COUNT=$(($GUESS_COUNT+1))
      if [[ $GUESS -lt $RANDOM_GEN  ]]
      then
        echo "It's higher than that, guess again:"
      else
        echo "It's lower than that, guess again:"
      fi
    else
      echo "That is not an integer, guess again:"
    fi
  read GUESS
  done
  echo "You guessed it in $GUESS_COUNT tries. The secret number was $RANDOM_GEN. Nice job!"
  BEST_GAME=$($PSQL "SELECT best_game from users where username='$USERNAME'")
  if [[ -z $BEST_GAME ]]
  then
    UP_USER=$($PSQL "UPDATE users set best_game=$GUESS_COUNT where username='$USERNAME'")
  else
    if [[ $GUESS_COUNT -lt $BEST_GAME ]]
    then
      UP_USER=$($PSQL "UPDATE users set best_game=$GUESS_COUNT where username='$USERNAME'")
    fi
  fi
fi

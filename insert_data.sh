#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

test = $($PSQL 'select * from games')
echo $($PSQL 'truncate table games, teams')

cat games.csv | while IFS=',' read  YEAR ROUND WINNER OPP WINNERGOALS OPPGOALS
do
  if [[ $YEAR != 'year' ]]
  then
    WINNER_ID=$($PSQL "select team_id from teams where name='$WINNER'")
    if [[ -z $WINNER_ID ]]
    then
      INS=$($PSQL "insert into teams(name) values('$WINNER')")
      echo $INS
      WINNER_ID=$($PSQL "select team_id from teams where name='$WINNER'")
    fi
    OPP_ID=$($PSQL "select team_id from teams where name='$OPP'")
    if [[ -z $OPP_ID ]]
    then
      INSOPP=$($PSQL "insert into teams(name) values('$OPP')")
      echo $INSOPP
      OPP_ID=$($PSQL "select team_id from teams where name='$OPP'")
    fi
    echo $($PSQL "insert into games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) values ($YEAR, '$ROUND', $WINNER_ID, $OPP_ID, $WINNERGOALS, $OPPGOALS )")
  fi
done
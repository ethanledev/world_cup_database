#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo "$($PSQL "TRUNCATE teams, games")"
cat games.csv | while IFS=',' read YEAR ROUND WIN OPP WIN_GOALS OPP_GOALS
do
  if [[ $WIN != winner ]]
  then
    # ***** insert winner to teams *****
    # get winner team_id
    WIN_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WIN'")
    # if not found
    if [[ -z $WIN_ID ]]
    then
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams (name) VALUES ('$WIN')")
      if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
      then
        echo "Inserted $WIN into teams."
      fi
      # get new winner team_id
      WIN_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WIN'")
    fi
    # ***** insert opponent to teams *****
    # get opponent team_id
    OPP_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPP'")
    #if not found
    if [[ -z $OPP_ID ]]
    then
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams (name) VALUES ('$OPP')")
      if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
      then
        echo "Inserted $OPP into teams."
      fi
      # get new opponent team_id
      OPP_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPP'")
    fi
    # ***** insert game to games *****
    # get game_id
    GAME_ID=$($PSQL "SELECT game_id FROM games WHERE year=$YEAR AND round='$ROUND' AND winner_id=$WIN_ID AND opponent_id=$OPP_ID")
    # if not found
    if [[ -z $GAME_ID ]]
    then
      INSERT_GAME_RESULT=$($PSQL "INSERT INTO games (year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($YEAR, '$ROUND', $WIN_ID, $OPP_ID, $WIN_GOALS, $OPP_GOALS)")
      if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
      then
        echo "Inserted game $YEAR $ROUND $WIN $WIN_GOALS - $OPP_GOALS $OPP into games"
      fi
    fi
  fi
done
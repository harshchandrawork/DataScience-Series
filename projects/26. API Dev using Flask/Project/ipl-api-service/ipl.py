import pandas as pd
import numpy as np
import os

# ipl_matches = "https://docs.google.com/spreadsheets/d/e/2PACX-1vRy2DUdUbaKx_Co9F0FSnIlyS-8kp4aKv_I0-qzNeghiZHAI_hw94gKG22XTxNJHMFnFVKsO4xWOdIs/pub?gid=1655759976&single=true&output=csv"

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

# Construct full path to the CSV file in the data folder
ipl_matches_localPath = os.path.join(BASE_DIR, "data", "ipl-matches.csv")
matches = pd.read_csv(ipl_matches_localPath)


def teamAPI():
    teams = list(set(list(matches["Team1"]) + list(matches["Team2"])))
    team_dict = {"teams": teams}
    return team_dict


def teamVteamAPI(team1, team2):
    valid_teams = list(set(list(matches["Team1"]) + list(matches["Team2"])))

    if team1 in valid_teams and team2 in valid_teams:
        mask1 = (matches["Team1"] == team1) & (matches["Team2"] == team2)
        mask2 = (matches["Team1"] == team2) & (matches["Team2"] == team1)
        temp_df = matches[mask1 | mask2]

        total_matches = temp_df.shape[0]

        matches_won_team1 = temp_df["WinningTeam"].value_counts()[team1]
        matches_won_team2 = temp_df["WinningTeam"].value_counts()[team2]
        draws = total_matches - (matches_won_team1 + matches_won_team2)

        response = {
            "total_matches": str(total_matches),
            team1: str(matches_won_team1),
            team2: str(matches_won_team2),
            "draws": str(draws),
        }

        return response

    else:
        return {"message": "invalid team name"}

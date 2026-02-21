import numpy as np
import pandas as pd
import plotly.graph_objects as go
import plotly.express as px
import dash
from dash import html  # dash-html-components
from dash import dcc  # dash-core-components
from dash.dependencies import Input, Output
import dash_bootstrap_components as dbc
from pathlib import Path


# external CSS Stylesheets
# external_stylesheets = [
#     {
#         "href": "https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/css/bootstrap.min.css",
#         "ref": "stylesheet",
#         "crossorigin": "anonymous",
#     }
# ]

# following is the working ext stylesheet
# external_stylesheets = [
#     "https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/css/bootstrap.min.css"
# ]

app = dash.Dash(__name__, external_stylesheets=[dbc.themes.PULSE])

# read datasets and assign variables
BASE_DIR = Path(__file__).resolve().parent
DATASET_PATH = BASE_DIR / "datasets"

patients = pd.read_csv(DATASET_PATH / "IndividualDetails5.csv")
covid19 = pd.read_csv(DATASET_PATH / "covid_19_clean_complete1.csv")

total = patients.shape[0]
active = patients[patients["current_status"] == "Hospitalized"].shape[0]
recovered = patients[patients["current_status"] == "Recovered"].shape[0]
deceased = patients[patients["current_status"] == "Deceased"].shape[0]

covid19["Date"] = pd.to_datetime(covid19["Date"], format="%m/%d/%y")

# create bar graph dropdown options
options = [
    {"label": "All", "value": "All"},
    {"label": "Hospitalized", "value": "Hospitalized"},
    {"label": "Recovered", "value": "Recovered"},
    {"label": "Deceased", "value": "Deceased"},
]

# create data and fig for pie chart
data = (
    covid19.groupby(by="Country/Region")["Confirmed"]
    .sum()
    .sort_values(ascending=False)
    .head(10)
    .reset_index()
)

piechart = px.pie(
    data,
    names="Country/Region",
    values="Confirmed",
    title="Top 10 most Countries/Regions with highest confirmed Covid-19 Cases",
)

date = covid19.groupby("Date")["Confirmed"].sum().reset_index()
linegraph = px.line(
    date,
    x="Date",
    y="Confirmed",
)

app.layout = html.Div(
    [
        html.H1("Corona Virus Pandemic", style={"text-align": "center"}),
        html.Div(
            [
                html.Div(
                    [
                        html.Div(
                            [
                                html.Div(
                                    [
                                        html.H3("Total Cases"),
                                        html.H4(total),
                                    ],
                                    className="card-body",
                                )
                            ],
                            className="card bg-warning",
                        )
                    ],
                    className="col-md-3",
                ),
                html.Div(
                    [
                        html.Div(
                            [
                                html.Div(
                                    [
                                        html.H3("Active Cases"),
                                        html.H4(active),
                                    ],
                                    className="card-body",
                                )
                            ],
                            className="card bg-danger",
                        )
                    ],
                    className="col-md-3",
                ),
                html.Div(
                    [
                        html.Div(
                            [
                                html.Div(
                                    [
                                        html.H3("Recovered"),
                                        html.H4(recovered),
                                    ],
                                    className="card-body",
                                )
                            ],
                            className="card bg-success",
                        )
                    ],
                    className="col-md-3",
                ),
                html.Div(
                    [
                        html.Div(
                            [
                                html.Div(
                                    [
                                        html.H3("Deaths"),
                                        html.H4(deceased),
                                    ],
                                    className="card-body",
                                )
                            ],
                            className="card bg-secondary",
                        )
                    ],
                    className="col-md-3",
                ),
            ],
            className="row",
        ),
        html.Div(
            [
                html.Div([dcc.Graph(figure=piechart)], className="col-md-6"),
                html.Div([dcc.Graph(figure=linegraph)], className="col-md-6"),
            ],
            className="row",
        ),
        html.Div(
            [
                html.Div(
                    [
                        html.Div(
                            [
                                html.Div(
                                    [
                                        dcc.Dropdown(
                                            id="picker", options=options, value="All"
                                        ),
                                        dcc.Graph(id="bar"),
                                    ],
                                    className="card-body",
                                )
                            ],
                            className="card",
                        )
                    ],
                    className="col-md-12",
                )
            ],
            className="row",
        ),
    ],
    className="container",
)


@app.callback(Output("bar", "figure"), [Input("picker", "value")])
def update_graph(type):
    if type == "All":
        pbar = patients["detected_state"].value_counts().reset_index()
        return {
            "data": [go.Bar(x=pbar["detected_state"], y=pbar["count"])],
            "layout": go.Layout(title="State Total Count"),
        }
    else:
        npat = patients[patients["current_status"] == type]
        pbar = npat["detected_state"].value_counts().reset_index()
        return {
            "data": [go.Bar(x=pbar["detected_state"], y=pbar["count"])],
            "layout": go.Layout(title="State Total Count"),
        }


if __name__ == "__main__":
    app.run(debug=True)

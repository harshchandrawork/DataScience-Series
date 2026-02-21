import numpy as np
import pandas as pd
import plotly.graph_objects as go
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

total = patients.shape[0]
active = patients[patients["current_status"] == "Hospitalized"].shape[0]
recovered = patients[patients["current_status"] == "Recovered"].shape[0]
deceased = patients[patients["current_status"] == "Deceased"].shape[0]

# create bar graph dropdown options
options = [
    {"label": "All", "value": "All"},
    {"label": "Hospitalized", "value": "Hospitalized"},
    {"label": "Recovered", "value": "Recovered"},
    {"label": "Deceased", "value": "Deceased"},
]

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
                            className="card",
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
                            className="card",
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
                            className="card",
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
                            className="card",
                        )
                    ],
                    className="col-md-3",
                ),
            ],
            className="row",
        ),
        html.Div([], className="row"),
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

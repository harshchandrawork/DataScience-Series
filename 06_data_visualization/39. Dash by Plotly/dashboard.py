import pandas as pd
import plotly.express as px
import plotly.graph_objs as go
import dash
from dash import html
from dash import dcc
import os

# current_dir = os.path.dirname(os.path.abspath(__file__))
# file_path = os.path.join(current_dir, "gapminder.csv")

data = px.data.gapminder()


# print(data.head())

app = dash.Dash()

app.layout = html.Div(
    [
        html.Div(
            children=[
                html.H1(
                    "My First Dashboard", style={"color": "red", "text-align": "center"}
                )
            ],
            style={
                "border": "1px black solid",
                "float": "left",
                "width": "100%",
                "height": "50px",
            },
        ),
        html.Div(
            children=[
                dcc.Graph(
                    id="scatter-plot",
                    figure={
                        "data": [
                            go.Scatter(
                                x=data["pop"], y=data["gdpPercap"], mode="markers"
                            )
                        ],
                        "layout": go.Layout(title="Scatter Plot"),
                    },
                )
            ],
            style={
                "border": "1px black solid",
                "float": "left",
                "width": "49%",
            },
        ),
        html.Div(
            children=[
                dcc.Graph(
                    id="box-plot",
                    figure={
                        "data": [go.Box(x=data["gdpPercap"])],
                        "layout": go.Layout(title="Boxplot"),
                    },
                )
            ],
            style={
                "border": "1px black solid",
                "float": "left",
                "width": "49%",
            },
        ),
    ]
)

if __name__ == "__main__":
    app.run()

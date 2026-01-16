import nlpcloud


def ner(text):

    client = nlpcloud.Client(
        "en_core_web_lg", "490669c7557d0368860c29ea5fae081a2ead9348", gpu=False
    )
    response = client.entities(
        text,
        searched_entity="programming languages",
    )

    return response

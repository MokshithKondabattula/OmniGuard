from elasticsearch import Elasticsearch
from datetime import datetime

es = Elasticsearch(
    "http://localhost:9200"
)


def index_document(index: str, document: dict):

    doc = {
        **document,
        "@timestamp": document.get(
            "timestamp",
            datetime.now().isoformat()
        )
    }

    es.index(
        index=index,
        document=doc
    )
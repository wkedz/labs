from qdrant_client import QdrantClient
from qdrant_client.models import PointStruct, Filter, FieldCondition, MatchValue
from openai import OpenAI

import uuid

# Konfiguracja klienta
client = QdrantClient(":memory:")  # lokalna instancja w pamięci
collection_name = "documents"

# Utwórz kolekcję
client.recreate_collection(
    collection_name=collection_name,
    vectors_config={"size": 1536, "distance": "Cosine"},
)

# Przykładowy klient OpenAI (upewnij się, że masz ustawiony OPENAI_API_KEY w środowisku)
openai_client = OpenAI()

# Funkcja do embeddingu
def embed(text):
    response = openai_client.embeddings.create(
        model="text-embedding-3-small", input=text
    )
    return response.data[0].embedding

# Dane do kolekcji
documents = [
    {"text": "Python is a great programming language.", "category": "programming"},
    {"text": "The Eiffel Tower is in Paris.", "category": "travel"},
    {"text": "Flask is a Python web framework.", "category": "programming"},
]

# Wstaw punkty z metadanymi
points = [
    PointStruct(
        id=str(uuid.uuid4()),
        vector=embed(doc["text"]),
        payload={"text": doc["text"], "category": doc["category"]},
    )
    for doc in documents
]

client.upsert(collection_name=collection_name, points=points)

# Wyszukiwanie z filtrem: tylko dokumenty z kategorią = "programming"
query = "How to build a web app in Python?"
query_vector = embed(query)

results = client.search(
    collection_name=collection_name,
    query_vector=query_vector,
    limit=3,
    query_filter=Filter(
        must=[
            FieldCondition(
                key="category",
                match=MatchValue(value="programming")
            )
        ]
    )
)

# Wyświetlenie wyników
for hit in results:
    print(f"Score: {hit.score:.3f}, Text: {hit.payload['text']}")

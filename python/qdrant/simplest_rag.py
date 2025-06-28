from openai import OpenAI
import uuid
import os
from qdrant_client import QdrantClient
from qdrant_client.models import PointStruct, Distance, VectorParams


client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

# Połączenie z lokalnym Qdrant
qdrant = QdrantClient("localhost", port=6333)

# Funkcja pobierająca rozmiar embeddingu danego modelu
def get_vector_size(model="text-embedding-3-large"):
    resp = client.embeddings.create(model=model, input="test")
    return len(resp.data[0].embedding)

def embed(text):
    resp = client.embeddings.create(
        model="text-embedding-3-large",
        input=text
    )
    return resp.data[0].embedding

VECTOR_SIZE = get_vector_size()
COLLECTION_NAME = "docs"

# Tworzenie punktów do Qdrant (embedding + metadane)
points = []

# Dokumenty z metadanymi (id generowane automatycznie jako uuid)
raw_documents = [
    {
        "text": "Koty są wspaniałymi zwierzętami domowymi.",
        "category": "zwierzęta",
        "lang": "pl"
    },
    {
        "text": "Psy lubią bawić się na świeżym powietrzu.",
        "category": "zwierzęta",
        "lang": "pl"
    },
    {
        "text": "Papugi potrafią naśladować ludzki głos.",
        "category": "ptaki",
        "lang": "pl"
    }
]

if not qdrant.collection_exists(COLLECTION_NAME):
    # Tworzenie kolekcji
    print(f"Kolekcja '{COLLECTION_NAME}' nie istnieje. Tworzę nową kolekcję...")
    qdrant.create_collection(
        collection_name=COLLECTION_NAME,
        vectors_config=VectorParams(size=VECTOR_SIZE, distance=Distance.COSINE)
    )

    # Przetwarzanie dokumentów i dodawanie ich do Qdrant
    for doc in raw_documents:
        doc_id = str(uuid.uuid4())
        vector = embed(doc["text"])
        payload = {
            "text": doc["text"],
            "category": doc["category"],
            "lang": doc["lang"]
        }
        points.append(PointStruct(id=doc_id, vector=vector, payload=payload))

    qdrant.upsert(collection_name=COLLECTION_NAME, points=points)
    print("Dodano dokumenty do Qdrant.")


# ----------- Retrieval + Generacja (proste RAG) -----------

# Zapytanie użytkownika
query = "Jakie zwierzęta potrafią mówić?"

# Embedding zapytania
query_vector = embed(query)

# Retrieval - pobranie najbliższych dokumentów
search_result = qdrant.query_points(
    collection_name=COLLECTION_NAME,
    query=query_vector,
    limit=2
)

retrieved_texts = [hit.payload["text"] for hit in search_result.points]

# search_result = qdrant.search(
#     collection_name=COLLECTION_NAME,
#     query_vector=query_vector,
#     limit=2
# )

# retrieved_texts = [hit.payload["text"] for hit in search_result]
print("Najbliższe dokumenty:", retrieved_texts)

# Zbuduj prompt do OpenAI (najprostszy przykład)
context = "\n".join(retrieved_texts)
prompt = f"Na podstawie poniższych tekstów odpowiedz na pytanie:\n\n{context}\n\nPytanie: {query}\nOdpowiedź:"

completion = client.chat.completions.create(
    model="gpt-3.5-turbo",
    messages=[
        {"role": "user", "content": prompt}
    ]
)

print("Odpowiedź modelu:", completion.choices[0].message.content)

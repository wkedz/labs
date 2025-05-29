from fastapi import Body, FastAPI

BOOKS = [
    {'title': 'Title One', 'author': 'Author One', 'category': 'science'},
    {'title': 'Title Two', 'author': 'Author Two', 'category': 'science'},
    {'title': 'Title Three', 'author': 'Author Three', 'category': 'history'},
    {'title': 'Title Four', 'author': 'Author Four', 'category': 'math'},
    {'title': 'Title Five', 'author': 'Author Five', 'category': 'math'},
    {'title': 'Title Six', 'author': 'Author Two', 'category': 'math'}
]

app = FastAPI()

## GET

@app.get("/books")
async def read_all_books():
    return BOOKS

# for static path like @app.get("/books/mybook") it must be before the dynamic path, because FastAPI will match dynamic ones first

# Path parameter
@app.get("/books/{book_title}")
async def read_book(book_title: str):
    # curl http://127.0.0.1:8000/books/Title%20One    
    for book in BOOKS:
        if book['title'].lower() == book_title.lower():
            return book
    return {"error": "Book not found1"}

@app.get("/books/")
async def read_book_by_query(category: str):
    books_to_return : list[dict[str, str]] = []
    for book in BOOKS:
        if book['category'].lower() == category.lower():
            books_to_return.append(book)
    if len(books_to_return) == 0:
        return {"error": "Book not found2"}
    return books_to_return

# Get all books from a specific author using path or query parameters
@app.get("/books/byauthor/")
async def read_books_by_author_path(author: str):
    books_to_return = []
    for book in BOOKS:
        if book['author'].lower() == author.lower():
            books_to_return.append(book)

    return books_to_return

# @app.get("/books/{book_author}/")
# async def read_author_category_by_query(book_author: str, category: str):
#     books_to_return = []
#     for book in BOOKS:
#         if book['author'].lower() == book_author.lower() and \
#                 book['category'].lower() == category.lower():
#             books_to_return.append(book)

#     return books_to_return


## POST
@app.post("/books/create_book")
async def create_book(new_book = Body()):
    BOOKS.append(new_book)


## PUT
@app.put("/books/update_book")
async def update_book(updated_book = Body()):
    for i in range(len(BOOKS)):
        if BOOKS[i]['title'].casefold() == updated_book['title'].casefold():
            BOOKS[i] = updated_book
            break


## DELETE
@app.delete("/books/delete_book/{book_title}")
async def delete_book(book_title: str):
    for i in range(len(BOOKS)):
        if BOOKS[i]['title'].casefold() == book_title.casefold():
            BOOKS.pop(i)
            break

## FETCH 
### Using query parameters
@app.get("/books/fetch_books/")
async def fetch_books(author: str):
    books_to_return = []
    for book in BOOKS:
        if book['author'].lower() == author.lower():
            books_to_return.append(book)
    return books_to_return

### Using path parameters
@app.get("/books/fetch_books/{author}/")
async def fetch_books(author: str):
    books_to_return = []
    for book in BOOKS:
        if book['author'].lower() == author.lower():
            books_to_return.append(book)
    return books_to_return
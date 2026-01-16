from fastapi import FastAPI

app = FastAPI(title="Dealership Revenue Intelligence API")

@app.get("/health")
def health():
    return {"status": "ok"}

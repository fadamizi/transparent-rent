from fastapi import FastAPI

app = FastAPI(title="Transparent Rent Verifier")


@app.get("/health")
def health():
    return {"status": "ok"}

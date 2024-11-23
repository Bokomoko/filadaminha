"""
Fila da minha queue management server
This is the main file of the server. It is responsible for starting the server and
configuring the necessary components.
"""

from contextlib import asynccontextmanager

# import common libraries
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

# Get general settings from config.py
from .config import Settings as cfg
from .routes import router


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Lifespan event"""
    # Everything before yield is executed before the server starts
    print("Starting up the server...")

    yield
    # everything after yield is executed after the server stops
    print("Shutting down the server...")

app = FastAPI(
    title=cfg.PROJECT_NAME,
    description=cfg.PROJECT_DESCRIPTION,
    lifespan=lifespan,
    openapi_url=f"{cfg.API_VERSION_STR}/openapi.json",
    url_prefix=cfg.API_VERSION_STR,
)
app.include_router(router,tags=["queue"], prefix="/queue")

# config cors middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure this according to your needs
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

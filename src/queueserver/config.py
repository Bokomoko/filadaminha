"""
General configuration for the Queue Server.

"""

import os
import sys

from dotenv import load_dotenv

load_dotenv()


class Settings:
  PROJECT_NAME: str = "Fila da minha queue management server"
  PROJECT_DESCRIPTION: str = "A simple queue management server"
  API_VERSION_STR: str = "/api/v1"
  SECRET_KEY: str = "secret_key"
  HOST = os.getenv("HOST", "localhost")
  PORT = int(os.getenv("PORT", "3000"))
  SESSION_DURATION_MINUTES = 60


# Token jwt configuration
  ALGORITHM = "HS256"
  TOKEN_URL = "/token"
  SECRET_KEY : str = os.getenv("SECRET_KEY","None")
  if SECRET_KEY is None:
      sys.exit("SECRET_KEY env variable must be set before running")


from datetime import datetime
from enum import Enum
from typing import List, Optional

from pydantic import BaseModel, Field, NonNegativeInt


class QueueStatus(str, Enum):
    ACTIVE = "active"
    ENDED = "ended"

class QueueItem(BaseModel):
    name: str
    position: int
    join_time: datetime
    status: str = "waiting"  # waiting, served, cancelled

class Queue(BaseModel):
    id: str
    name: str
    password: str
    end_time: datetime
    limit_size: int

    time_limit: Optional[NonNegativeInt] = Field(default=None)

    latitude: Optional[float] = None
    longitude: Optional[float] = None
    description: str
    status: QueueStatus = QueueStatus.ACTIVE
    items: List[QueueItem] = []

# In-memory storage (replace with database in production)
queues = {}

class QueueCreate(BaseModel):
    name: str
    password: str
    end_time: datetime
    limit_size: int
    time_limit: Optional[int] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    description: str

class JoinQueue(BaseModel):
    name: str

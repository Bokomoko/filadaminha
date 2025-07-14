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
    queue_url : str
    encoded_qr_url: str
    status: QueueStatus = QueueStatus.ACTIVE
    items: List[QueueItem] = []

    # create a method that automaically adds the encoded qr code of the queue upon creation



class QueueCreate(BaseModel):
    name: str = Field(...,min_length=3,max_length=50)
    password: str = Field(..., min_length=3, max_length=50)
    end_time: datetime
    limit_size: int = Field(..., ge=1)
    time_limit: Optional[int] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    description: str = Field(..., min_length=3, max_length=100)

class JoinQueue(BaseModel):
    name: str

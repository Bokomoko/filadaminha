import uuid
from asyncio import queues

import qrcode
from fastapi import APIRouter

from .models import JoinQueue, Queue, QueueCreate, QueueStatus

router = APIRouter()

@router.post("/queue/create")
async def create_queue(queue_data: QueueCreate):
    queue_id = str(uuid.uuid4())

    new_queue = Queue(
        id=queue_id,
        **queue_data.dict()
    )

    queues[queue_id] = new_queue

    # Generate QR Code
    qr = qrcode.QRCode(version=1, box_size=10, border=5)
    queue_url = f"http://localhost:8000/queue/{queue_id}"
    qr.add_data(queue_url)
    qr.make(fit=True)

    qr_image = qr.make_image(fill_color="black", back_color="white")
    qr_filename = f"qr_{queue_id}.png"
    qr_image.save(qr_filename)

    return {
        "queue_id": queue_id,
        "queue_url": queue_url,
        "qr_code_url": f"http://localhost:8000/qr/{queue_id}"
    }

@router.get("/queue/{queue_id}")
async def show_queue(queue_id: str, password: str):
    if queue_id not in queues:
        raise HTTPException(status_code=404, detail="Queue not found")

    queue = queues[queue_id]
    if queue.password != password:
        raise HTTPException(status_code=401, detail="Invalid password")

    return {
        "queue": queue,
        "serve_url": f"http://localhost:8000/queue/{queue_id}/serve",
        "cancel_url": f"http://localhost:8000/queue/{queue_id}/cancel"
    }

@router.post("/queue/{queue_id}/join")
async def join_queue(queue_id: str, join_data: JoinQueue):
    if queue_id not in queues:
        raise HTTPException(status_code=404, detail="Queue not found")

    queue = queues[queue_id]

    # Check if queue is ended
    if queue.status == QueueStatus.ENDED:
        raise HTTPException(status_code=400, detail="Queue has ended")

    # Check if queue is full
    if queue.limit_size > 0 and len(queue.items) >= queue.limit_size:
        raise HTTPException(status_code=400, detail="Queue is full")

    # Check if name already exists
    if any(item.name == join_data.name for item in queue.items):
        raise HTTPException(status_code=409, detail="Name already in queue")

    # Add to queue
    position = len(queue.items) + 1
    queue_item = QueueItem(
        name=join_data.name,
        position=position,
        join_time=datetime.now()
    )
    queue.items.append(queue_item)

    return {
        "position": position,
        "queue_url": f"http://localhost:8000/queue/{queue_id}"
    }

@router.post("/queue/{queue_id}/serve/{position}")
async def serve_item(queue_id: str, position: int, password: str):
    if queue_id not in queues:
        raise HTTPException(status_code=404, detail="Queue not found")

    queue = queues[queue_id]
    if queue.password != password:
        raise HTTPException(status_code=401, detail="Invalid password")

    for item in queue.items:
        if item.position == position:
            item.status = "served"
            return {"message": "Item marked as served"}

    raise HTTPException(status_code=404, detail="Position not found")

@router.post("/queue/{queue_id}/cancel/{position}")
async def cancel_item(queue_id: str, position: int, password: str):
    if queue_id not in queues:
        raise HTTPException(status_code=404, detail="Queue not found")

    queue = queues[queue_id]
    if queue.password != password:
        raise HTTPException(status_code=401, detail="Invalid password")

    for item in queue.items:
        if item.position == position:
            item.status = "cancelled"
            return {"message": "Item cancelled"}

    raise HTTPException(status_code=404, detail="Position not found")

@router.get("/qr/{queue_id}")
async def get_qr(queue_id: str):
    qr_filename = f"qr_{queue_id}.png"
    if not os.path.exists(qr_filename):
        raise HTTPException(status_code=404, detail="QR code not found")
    return FileResponse(qr_filename)

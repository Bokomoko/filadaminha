import base64
from io import BytesIO

import qrcode

from .config.Settings import BASE_URL


def create_qr_code(queue_id) -> str:  # Generate QR Code
    qr = qrcode.QRCode(version=1, box_size=10, border=5)
    queue_url = f"{BASE_URL}/queue/join/{queue_id}"
    qr.add_data(queue_url)
    qr.make(fit=True)

    with BytesIO() as buffered:
        qr.make_image(fill_color="black", back_color="white").save(buffered )
        return  base64.b64encode(buffered.getvalue()).decode("utf-8")

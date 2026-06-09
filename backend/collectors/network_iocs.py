from scapy.all import sniff, IP
from datetime import datetime
from collections import deque
import threading

network_iocs = deque(maxlen=100)


def process_packet(packet):
    if IP in packet:
        src = packet[IP].src
        dst = packet[IP].dst

        now = datetime.now().isoformat()

        network_iocs.append({
            "value": src,
            "type": "ip",
            "source": "Live Network Capture",
            "severity": "medium",
            "first_seen": now,
        })

        network_iocs.append({
            "value": dst,
            "type": "ip",
            "source": "Live Network Capture",
            "severity": "medium",
            "first_seen": now,
        })


def start_network_ioc_sniffer():
    thread = threading.Thread(
        target=lambda: sniff(
            prn=process_packet,
            store=False
        ),
        daemon=True,
    )

    thread.start()
from scapy.all import sniff
import threading

packet_count = 0

def process(pkt):
    global packet_count
    packet_count += 1

def start_sniffer():

    thread = threading.Thread(
        target=lambda: sniff(
            prn=process,
            store=False
        ),
        daemon=True
    )

    thread.start()
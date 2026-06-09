from scapy.all import sniff
from services.elasticsearch_service import es
from datetime import datetime


def process_packet(packet):

    try:

        if packet.haslayer("IP"):

            data = {
                "src_ip": packet["IP"].src,
                "dst_ip": packet["IP"].dst,
                "protocol": packet["IP"].proto,
                "indexed_at": datetime.utcnow(),
            }

            es.index(
                index="omniguard-network",
                document=data,
            )

    except:
        pass


def start_sniffing():

    sniff(
        prn=process_packet,
        store=False,
    )
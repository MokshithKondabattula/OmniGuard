import psutil

def get_metrics():

    net = psutil.net_io_counters()

    return {
        "cpu": psutil.cpu_percent(),
        "memory": psutil.virtual_memory().percent,
        "disk": psutil.disk_usage("C:/").percent,
        "bytes_sent": net.bytes_sent,
        "bytes_recv": net.bytes_recv,
        "processes": len(psutil.pids())
    }
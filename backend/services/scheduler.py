from apscheduler.schedulers.background import BackgroundScheduler

from routes.logs import get_logs
from routes.threat_intel import threat_intel

scheduler = BackgroundScheduler()


def start_scheduler():

    scheduler.add_job(
        get_logs,
        "interval",
        seconds=20,
    )

    scheduler.add_job(
        threat_intel,
        "interval",
        seconds=40,
    )

    scheduler.start()
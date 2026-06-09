from fastapi import FastAPI, WebSocket
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import Response
from reportlab.pdfgen import canvas
from io import BytesIO
import asyncio
import random
import psutil
import win32evtlog
from scapy.all import sniff
from sklearn.ensemble import IsolationForest


cpu = psutil.cpu_percent()
ram = psutil.virtual_memory().percent
disk = psutil.disk_usage('/').percent

server = 'localhost'
logtype = 'Security'

hand = win32evtlog.OpenEventLog(server, logtype)

events = win32evtlog.ReadEventLog(
    hand,
    win32evtlog.EVENTLOG_BACKWARDS_READ |
    win32evtlog.EVENTLOG_SEQUENTIAL_READ,
    0
)

def process(pkt):
    print(pkt.summary())

sniff(prn=process)


model = IsolationForest(
    contamination=0.02,
    random_state=42
)

prediction = None

anomaly_score = 0.0
threat_intel_score = 0.0
severity_score = 0.0

risk_score = (
    anomaly_score * 0.5 +
    threat_intel_score * 0.3 +
    severity_score * 0.2
)

app = FastAPI(title="OmniGuard")

# =========================
# CORS
# =========================

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# =========================
# Root
# =========================

@app.get("/")
def root():
    return {
        "message": "OmniGuard API Running",
        "status": "healthy"
    }

# =========================
# Logs
# =========================

@app.get("/api/logs")
def get_logs(limit: int = 200):
    return [
        {
            "id": "L001",
            "timestamp": "2026-06-01T10:00:00",
            "source": "Firewall",
            "host": "server01",
            "severity": "high",
            "message": "Multiple failed login attempts"
        },
        {
            "id": "L002",
            "timestamp": "2026-06-01T10:02:00",
            "source": "VPN",
            "host": "vpn-gateway",
            "severity": "medium",
            "message": "Unusual login location"
        }
    ][:limit]

# =========================
# Alerts
# =========================

@app.get("/api/alerts")
def get_alerts():
    return [
        {
            "id": "A001",
            "timestamp": "2026-06-01T10:05:00",
            "title": "Multiple Failed Logins",
            "severity": "high",
            "source": "SIEM",
            "status": "open",
            "score": 92.5
        },
        {
            "id": "A002",
            "timestamp": "2026-06-01T10:07:00",
            "title": "Credential Stuffing",
            "severity": "critical",
            "source": "Threat Engine",
            "status": "investigating",
            "score": 98.2
        }
    ]

# =========================
# Incidents
# =========================

@app.get("/api/incidents")
def get_incidents():
    return [
        {
            "id": "INC001",
            "opened": "2026-06-01T10:10:00",
            "title": "Brute Force Attack",
            "severity": "critical",
            "assignee": "SOC Analyst",
            "status": "investigating",
            "alert_count": 15
        },
        {
            "id": "INC002",
            "opened": "2026-06-01T11:00:00",
            "title": "Suspicious VPN Activity",
            "severity": "medium",
            "assignee": "Tier-1 Analyst",
            "status": "triage",
            "alert_count": 5
        }
    ]

# =========================
# Metrics
# =========================

@app.get("/api/metrics/overview")
def metrics():
    return {
        "events_ingested": 152340,
        "active_alerts": 54,
        "open_incidents": 8,
        "hosts_monitored": 312,

        "events_timeline": [
            1200,1300,1250,1400,1600,1800,
            2000,2200,2500,2700,2900,3100,
            3000,2800,2600,2400,2200,2100,
            2300,2500,2700,2900,3100,3300
        ],

        "severity_breakdown": {
            "info": 5000,
            "low": 2100,
            "medium": 800,
            "high": 250,
            "critical": 30
        },

        "top_sources": [
            {"name": "Firewall", "count": 45000},
            {"name": "VPN", "count": 32000},
            {"name": "EDR", "count": 28000},
            {"name": "Windows Logs", "count": 25000},
            {"name": "CloudTrail", "count": 22000}
        ]
    }
# =========================
# Threat Intel
# =========================


@app.get("/api/analytics")
def analytics():

    score = random.randint(70,100)

    return {
        "anomaly_score": score,

        "anomaly_detected": score > 85,

        "model": "Isolation Forest",

        "predictions": [
            {
                "source": "Firewall",
                "risk_score": random.randint(60,100)
            },
            {
                "source": "VPN",
                "risk_score": random.randint(60,100)
            },
            {
                "source": "EDR",
                "risk_score": random.randint(60,100)
            }
        ],

        "top_attack_types": [
            "Credential Stuffing",
            "Brute Force",
            "Data Exfiltration",
            "Privilege Escalation"
        ]
    }

@app.get("/api/dashboard/live")
def live_dashboard():
    return {
        "cpu": psutil.cpu_percent(),
        "memory": psutil.virtual_memory().percent,
        "disk": psutil.disk_usage('/').percent,
        "network_sent": psutil.net_io_counters().bytes_sent,
        "network_recv": psutil.net_io_counters().bytes_recv,
    }
    

@app.get("/api/threat-intel/feeds")
def threat_feed():
    return [
        {
            "value": "185.12.44.2",
            "type": "ip",
            "source": "AlienVault OTX",
            "severity": "high",
            "first_seen": "2026-06-01T08:00:00"
        },
        {
            "value": "malicious-domain.xyz",
            "type": "domain",
            "source": "VirusTotal",
            "severity": "critical",
            "first_seen": "2026-06-01T09:30:00"
        }
    ]

# =========================
# Incident Response
# =========================

@app.post("/api/incidents/{incident_id}/respond")
def respond(incident_id: str):
    return {
        "incident": incident_id,
        "playbook": "isolate_host",
        "status": "executed",
        "actions": [
            "block_ip",
            "disable_user",
            "notify_soc_team"
        ]
    }

# =========================
# AI Endpoint
# =========================

@app.post("/api/analyze")
def analyze():
    score = random.randint(70, 100)

    return {
        "anomaly_detected": score > 85,
        "threat_score": score,
        "risk_level": (
            "CRITICAL"
            if score > 95 else
            "HIGH"
            if score > 85 else
            "MEDIUM"
        )
    }

# =========================
# Compliance PDF
# =========================

@app.get("/api/compliance/{framework}/report")
def compliance_report(framework: str):

    buffer = BytesIO()

    pdf = canvas.Canvas(buffer)

    pdf.drawString(
        100,
        800,
        f"{framework.upper()} Compliance Report"
    )

    pdf.drawString(
        100,
        780,
        "Generated by OmniGuard"
    )

    pdf.save()

    pdf_bytes = buffer.getvalue()

    buffer.close()

    return Response(
        content=pdf_bytes,
        media_type="application/pdf"
    )

# =========================
# WebSocket Real-Time Alerts
# =========================

@app.websocket("/ws/anomalies")
async def websocket_endpoint(websocket: WebSocket):

    await websocket.accept()

    attack_types = [
        "Credential Stuffing",
        "Brute Force",
        "SQL Injection",
        "Lateral Movement",
        "Privilege Escalation",
        "Malware Beaconing"
    ]

    while True:

        score = random.randint(70,100)

        await websocket.send_json({
            "severity":
                "critical" if score > 95 else
                "high" if score > 85 else
                "medium",

            "score": score,

            "attack":
                random.choice(attack_types),

            "source":
                random.choice([
                    "Firewall",
                    "VPN",
                    "EDR",
                    "CloudTrail"
                ]),

            "message":
                "AI detected suspicious activity"
        })

        await asyncio.sleep(2)
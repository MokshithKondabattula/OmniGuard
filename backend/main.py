from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from routes.logs import router as logs_router
from routes.alerts import router as alerts_router
from routes.incidents import router as incidents_router
from routes.metrics import router as metrics_router
from routes.threat_intel import router as threat_intel_router
from routes.compliance import router as compliance_router
from routes.analytics import router as analytics_router
from routes.websocket import router as websocket_router
from collectors.network_sniffer import start_sniffer
from collectors.network_iocs import start_network_ioc_sniffer
from services.scheduler import start_scheduler

start_sniffer()

app = FastAPI(
    title="OmniGuard AI SOC",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# =========================
# Register Routes
# =========================

app.include_router(logs_router)
app.include_router(alerts_router)
app.include_router(incidents_router)
app.include_router(metrics_router)
app.include_router(threat_intel_router)
app.include_router(compliance_router)
app.include_router(analytics_router)
app.include_router(websocket_router)

# =========================
# Root Endpoint
# =========================

@app.get("/")
def root():
    return {
        "message": "OmniGuard AI SOC Running",
        "status": "healthy"
    }
    
@app.on_event("startup")
def startup():
    start_network_ioc_sniffer()
    
@app.on_event("startup")
def startup_event():
    start_scheduler()
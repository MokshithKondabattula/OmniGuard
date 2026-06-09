from fastapi import APIRouter
from state import alerts

router = APIRouter()

@router.get("/api/alerts")
def get_alerts():
    return alerts[-20:]
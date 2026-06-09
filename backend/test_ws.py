import asyncio
import websockets

MAX_MESSAGES = 10

async def test():

    async with websockets.connect(
        "ws://127.0.0.1:8000/ws/anomalies"
    ) as ws:

        for i in range(MAX_MESSAGES):

            msg = await ws.recv()

            print(f"[{i+1}] {msg}")

    print("\nWebSocket test completed.")


asyncio.run(test())
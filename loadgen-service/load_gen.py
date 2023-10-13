import asyncio
import time
from aiohttp import ClientSession
from collections import deque, Counter
import random 
import string
import os 
from pprint import pprint
import numpy as np


async def user_workflow(session, histogram):
    start_time = time.time()
    
    # Generate a random string of 100 characters
    random_str = ''.join(random.choices(string.ascii_letters + string.digits, k=100))
    
    # # First request to demo-service in singleton-app namespace
    # async with session.get('http://nginx.simple-us.svc.cluster.local') as response:
    #     await response.read()
    
    # Second request to demo-service in singleton-app namespace for encoding
    async with session.get(f'http://nginx.simple-us.svc.cluster.local/encode/{random_str}') as response:
        await response.read()
    
    end_time = time.time()
    elapsed_time = end_time - start_time
    #histogram.append(elapsed_time)
"""
async def update_histogram(histogram, interval):
    while True:
        await asyncio.sleep(interval)
        print("Current Histogram:")
        length = len(histogram)
        print(f"Length of list: {length}")

        percentiles = [50, 75, 90, 95, 99, 99.99, 100]

        for percentile in percentiles:
            value = np.percentile(histogram, percentile)
            print(f"{percentile}%: {value}")

        histogram.clear()
"""
async def load_generator(rate, histogram):
    async with ClientSession() as session:
        while True:
            start_time = time.time()
            asyncio.create_task(user_workflow(session, histogram))
            elapsed = time.time() - start_time
            await asyncio.sleep(max(0, 1.0 / rate - elapsed))

if __name__ == "__main__":
    rate = int(os.environ.get('RATE', "1000"))
    interval = int(os.environ.get('REPORTING_INTERVAL', "30"))
    print(f"Starting load generator with rate: {rate} and reporting interval: {interval}")
    histogram = deque()
    
    loop = asyncio.get_event_loop()
    loop.run_until_complete(asyncio.gather(
        load_generator(rate, histogram)
        #,
        #update_histogram(histogram, interval)
    ))


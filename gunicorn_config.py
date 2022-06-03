import os

bind = "0.0.0.0:8000"

workers = int(os.getenv("CONCURRENCY", default=2))
worker_class = "sync"

preload_app = True

timeout = 10
graceful_timeout = 30

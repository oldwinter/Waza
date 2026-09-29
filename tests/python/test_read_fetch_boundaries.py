import importlib.util
import os
from pathlib import Path
from unittest import TestCase, mock

ROOT = Path(__file__).resolve().parents[2]

def load(name, relative):
    spec = importlib.util.spec_from_file_location(name, ROOT / relative)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module

local = load("waza_fetch_local", "skills/read/scripts/fetch_local.py")
feishu = load("waza_fetch_feishu", "skills/read/scripts/fetch_feishu.py")

class Response:
    def __init__(self, payload=b"ok", headers=None):
        self.payload = payload
        self.headers = headers or {}
    def __enter__(self): return self
    def __exit__(self, *args): return False
    def read(self, limit=-1): return self.payload if limit < 0 else self.payload[:limit]

class ReadFetchBoundaries(TestCase):
    def test_local_fetch_rejects_file_scheme(self):
        with self.assertRaisesRegex(ValueError, "http"):
            local.fetch_html("file:///etc/passwd")

    def test_local_fetch_rejects_declared_oversize(self):
        response = Response(headers={"Content-Length": str(local.MAX_RESPONSE_BYTES + 1)})
        with mock.patch.object(local.urllib.request, "urlopen", return_value=response):
            with self.assertRaisesRegex(ValueError, "exceeds"):
                local.fetch_html("https://example.com")

    def test_invalid_feishu_url_is_rejected(self):
        self.assertEqual(feishu.parse_url("https://example.com/not-feishu"), (None, None))
        self.assertIn("Unsupported", feishu.fetch_feishu("https://example.com/not-feishu")["error"])

    def test_feishu_request_failure_is_structured(self):
        class Requests:
            RequestException = RuntimeError
            @staticmethod
            def post(*args, **kwargs): raise RuntimeError("offline")
        old = feishu.requests
        feishu.requests = Requests
        try:
            with mock.patch.dict(os.environ, {"FEISHU_APP_ID": "id", "FEISHU_APP_SECRET": "secret"}):
                self.assertIn("offline", feishu.fetch_feishu("abc123")["error"])
        finally:
            feishu.requests = old

    def test_feishu_repeated_page_token_stops(self):
        class Reply:
            text = ""
            def json(self): return {"code": 0, "data": {"items": [], "has_more": True, "page_token": "same"}}
        class Requests:
            @staticmethod
            def get(*args, **kwargs): return Reply()
        old = feishu.requests
        feishu.requests = Requests
        try:
            blocks, error = feishu.get_blocks("token", "doc")
            self.assertIsNone(blocks)
            self.assertIn("repeated", error)
        finally:
            feishu.requests = old

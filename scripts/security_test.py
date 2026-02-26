#!/usr/bin/env python3
"""
OWASP Top 10 Security Test Suite for JY-Companion Backend API.

Tests the FastAPI backend against the OWASP Top 10 (2021) categories:
  A01 - Broken Access Control
  A02 - Cryptographic Failures
  A03 - Injection
  A04 - Insecure Design
  A05 - Security Misconfiguration
  A06 - Vulnerable and Outdated Components
  A07 - Identification and Authentication Failures
  A08 - Software and Data Integrity Failures
  A09 - Security Logging and Monitoring Failures
  A10 - Server-Side Request Forgery (SSRF)

Usage:
  python scripts/security_test.py
  python scripts/security_test.py --host http://localhost:8000
  python scripts/security_test.py --admin-user admin --admin-pass secret

Requirements:
  pip install httpx
"""

from __future__ import annotations

import argparse
import asyncio
import base64
import json
import math
import secrets
import string
import sys
import time
import uuid
from dataclasses import dataclass, field
from enum import Enum
from typing import Any


# ---------------------------------------------------------------------------
# Try importing httpx -- give a clear message if missing.
# ---------------------------------------------------------------------------
try:
    import httpx
except ImportError:
    print("ERROR: httpx is required.  Install it with:  pip install httpx")
    sys.exit(1)


# ====================================================================
# Result types
# ====================================================================

class Verdict(Enum):
    PASS = "PASS"
    FAIL = "FAIL"
    WARN = "WARN"
    SKIP = "SKIP"
    INFO = "INFO"


@dataclass
class TestResult:
    category: str
    test_name: str
    verdict: Verdict
    detail: str = ""


@dataclass
class TestReport:
    results: list[TestResult] = field(default_factory=list)

    def add(self, category: str, name: str, verdict: Verdict, detail: str = "") -> None:
        self.results.append(TestResult(category=category, test_name=name, verdict=verdict, detail=detail))

    # -- Presentation --

    _COLORS = {
        Verdict.PASS: "\033[92m",
        Verdict.FAIL: "\033[91m",
        Verdict.WARN: "\033[93m",
        Verdict.SKIP: "\033[90m",
        Verdict.INFO: "\033[94m",
    }
    _RESET = "\033[0m"

    def _colored(self, v: Verdict) -> str:
        return f"{self._COLORS.get(v, '')}{v.value:4s}{self._RESET}"

    def print_report(self) -> None:
        """Print a formatted report grouped by OWASP category."""
        print()
        print("=" * 80)
        print("  OWASP Top 10 Security Test Report  --  JY-Companion API")
        print("=" * 80)

        current_cat = ""
        for r in self.results:
            if r.category != current_cat:
                current_cat = r.category
                print(f"\n--- {current_cat} ---")
            detail_suffix = f"  ({r.detail})" if r.detail else ""
            print(f"  [{self._colored(r.verdict)}]  {r.test_name}{detail_suffix}")

        # Summary
        total = len(self.results)
        counts = {v: 0 for v in Verdict}
        for r in self.results:
            counts[r.verdict] += 1

        print()
        print("=" * 80)
        print("  SUMMARY")
        print("=" * 80)
        for v in Verdict:
            print(f"  {v.value:4s}: {counts[v]}")
        print(f"  TOTAL: {total}")

        # Security score: PASS=1.0, WARN=0.5, INFO=0, SKIP=0, FAIL=0
        scorable = counts[Verdict.PASS] + counts[Verdict.FAIL] + counts[Verdict.WARN]
        if scorable > 0:
            score = (counts[Verdict.PASS] + 0.5 * counts[Verdict.WARN]) / scorable * 100
        else:
            score = 0.0
        print(f"\n  Security Score: {score:.1f} / 100")
        if score >= 80:
            print("  Rating: GOOD -- Most checks passed.")
        elif score >= 50:
            print("  Rating: MODERATE -- Several issues need attention.")
        else:
            print("  Rating: POOR -- Significant security gaps detected.")
        print("=" * 80)
        print()


# ====================================================================
# Helpers
# ====================================================================

def random_string(length: int = 12) -> str:
    alphabet = string.ascii_lowercase + string.digits
    return "".join(secrets.choice(alphabet) for _ in range(length))


async def register_user(
    client: httpx.AsyncClient,
    base: str,
    username: str | None = None,
    password: str | None = None,
    display_name: str | None = None,
    role: str = "student",
) -> tuple[dict[str, Any] | None, int]:
    """Register a user and return (response_json, status_code)."""
    username = username or f"sectest_{random_string(8)}"
    password = password or f"SecTest!{random_string(10)}"
    display_name = display_name or f"Security Tester {random_string(4)}"
    payload = {
        "username": username,
        "password": password,
        "display_name": display_name,
        "role": role,
    }
    resp = await client.post(f"{base}/api/v1/auth/register", json=payload)
    try:
        return resp.json(), resp.status_code
    except Exception:
        return None, resp.status_code


async def login_user(
    client: httpx.AsyncClient, base: str, username: str, password: str
) -> tuple[dict[str, Any] | None, int]:
    payload = {"username": username, "password": password}
    resp = await client.post(f"{base}/api/v1/auth/login", json=payload)
    try:
        return resp.json(), resp.status_code
    except Exception:
        return None, resp.status_code


def auth_header(token: str) -> dict[str, str]:
    return {"Authorization": f"Bearer {token}"}


def make_fake_jwt(payload_dict: dict, alg: str = "none") -> str:
    """Build a minimal JWT with the given payload and algorithm header."""
    header = {"alg": alg, "typ": "JWT"}
    h = base64.urlsafe_b64encode(json.dumps(header).encode()).rstrip(b"=").decode()
    p = base64.urlsafe_b64encode(json.dumps(payload_dict).encode()).rstrip(b"=").decode()
    return f"{h}.{p}."


# ====================================================================
# A01 -- Broken Access Control
# ====================================================================

async def test_a01(client: httpx.AsyncClient, base: str, report: TestReport, tokens: dict) -> None:
    cat = "A01 - Broken Access Control"

    # 1. Accessing protected endpoints without auth
    for path, method in [
        ("/api/v1/chat/conversations", "GET"),
        ("/api/v1/academic/learning-records", "GET"),
        ("/api/v1/admin/users", "GET"),
        ("/api/v1/admin/stats", "GET"),
    ]:
        if method == "GET":
            resp = await client.get(f"{base}{path}")
        else:
            resp = await client.post(f"{base}{path}", json={})
        if resp.status_code in (401, 403):
            report.add(cat, f"No-auth blocked on {method} {path}", Verdict.PASS,
                       f"Status {resp.status_code}")
        else:
            report.add(cat, f"No-auth blocked on {method} {path}", Verdict.FAIL,
                       f"Expected 401/403, got {resp.status_code}")

    # 2. Student accessing admin endpoints
    student_token = tokens.get("student_token")
    if student_token:
        for path in ["/api/v1/admin/users", "/api/v1/admin/stats", "/api/v1/admin/alerts"]:
            resp = await client.get(f"{base}{path}", headers=auth_header(student_token))
            if resp.status_code == 403:
                report.add(cat, f"Student role blocked from {path}", Verdict.PASS,
                           "403 Forbidden")
            elif resp.status_code == 401:
                report.add(cat, f"Student role blocked from {path}", Verdict.PASS,
                           "401 Unauthorized")
            else:
                report.add(cat, f"Student role blocked from {path}", Verdict.FAIL,
                           f"Expected 403, got {resp.status_code}")
    else:
        report.add(cat, "Student accessing admin endpoints", Verdict.SKIP,
                   "No student token available")

    # 3. Horizontal privilege escalation -- try accessing another user's conversations
    #    by using a fabricated conversation UUID
    if student_token:
        fake_conv_id = str(uuid.uuid4())
        resp = await client.get(
            f"{base}/api/v1/chat/conversations/{fake_conv_id}/messages",
            headers=auth_header(student_token),
        )
        if resp.status_code in (403, 404):
            report.add(cat, "IDOR on conversation messages", Verdict.PASS,
                       f"Returned {resp.status_code} for non-owned resource")
        else:
            report.add(cat, "IDOR on conversation messages", Verdict.WARN,
                       f"Returned {resp.status_code} -- verify ownership check")

    # 4. IDOR on admin user status endpoint with student token
    if student_token:
        fake_user_id = str(uuid.uuid4())
        resp = await client.put(
            f"{base}/api/v1/admin/users/{fake_user_id}/status",
            headers=auth_header(student_token),
            json={"is_active": False},
        )
        if resp.status_code in (401, 403):
            report.add(cat, "Student cannot modify user status via admin endpoint", Verdict.PASS,
                       f"Status {resp.status_code}")
        else:
            report.add(cat, "Student cannot modify user status via admin endpoint", Verdict.FAIL,
                       f"Expected 401/403, got {resp.status_code}")

    # 5. Vertical escalation: register with role=admin
    admin_uname = f"escalate_{random_string(6)}"
    body, status = await register_user(client, base, username=admin_uname, role="admin")
    if status == 201 and body and body.get("role") == "admin":
        report.add(cat, "Role escalation via registration (role=admin)", Verdict.FAIL,
                   "Allowed self-registration as admin")
    elif status in (400, 403, 422):
        report.add(cat, "Role escalation via registration (role=admin)", Verdict.PASS,
                   f"Rejected with status {status}")
    elif status == 201 and body and body.get("role") != "admin":
        report.add(cat, "Role escalation via registration (role=admin)", Verdict.PASS,
                   "Server ignored/overrode admin role request")
    else:
        report.add(cat, "Role escalation via registration (role=admin)", Verdict.WARN,
                   f"Unexpected status {status}")


# ====================================================================
# A02 -- Cryptographic Failures
# ====================================================================

async def test_a02(client: httpx.AsyncClient, base: str, report: TestReport, tokens: dict) -> None:
    cat = "A02 - Cryptographic Failures"

    # 1. Check Strict-Transport-Security header
    resp = await client.get(f"{base}/api/v1/health")
    hsts = resp.headers.get("strict-transport-security")
    if hsts:
        report.add(cat, "HSTS header present", Verdict.PASS, hsts)
    else:
        if base.startswith("http://"):
            report.add(cat, "HSTS header present", Verdict.INFO,
                       "HTTP connection -- HSTS not expected on localhost")
        else:
            report.add(cat, "HSTS header present", Verdict.WARN,
                       "Missing Strict-Transport-Security header")

    # 2. Check secure cookie flags (if any cookies set)
    resp = await client.get(f"{base}/api/v1/health")
    set_cookie = resp.headers.get("set-cookie", "")
    if set_cookie:
        flags_lower = set_cookie.lower()
        if "secure" in flags_lower and "httponly" in flags_lower:
            report.add(cat, "Cookie Secure + HttpOnly flags", Verdict.PASS)
        else:
            missing = []
            if "secure" not in flags_lower:
                missing.append("Secure")
            if "httponly" not in flags_lower:
                missing.append("HttpOnly")
            report.add(cat, "Cookie Secure + HttpOnly flags", Verdict.FAIL,
                       f"Missing flag(s): {', '.join(missing)}")
    else:
        report.add(cat, "Cookie Secure + HttpOnly flags", Verdict.INFO,
                   "No Set-Cookie header returned (API uses Bearer tokens)")

    # 3. Token entropy: check access_token length / base64 entropy
    student_token = tokens.get("student_token")
    if student_token:
        parts = student_token.split(".")
        if len(parts) == 3:
            report.add(cat, "JWT structure valid (3-part)", Verdict.PASS)
            # Check if payload has standard claims
            try:
                padded = parts[1] + "=" * (4 - len(parts[1]) % 4)
                payload = json.loads(base64.urlsafe_b64decode(padded))
                has_exp = "exp" in payload
                has_sub = "sub" in payload
                if has_exp and has_sub:
                    report.add(cat, "JWT has 'exp' and 'sub' claims", Verdict.PASS)
                else:
                    missing_claims = []
                    if not has_exp:
                        missing_claims.append("exp")
                    if not has_sub:
                        missing_claims.append("sub")
                    report.add(cat, "JWT has 'exp' and 'sub' claims", Verdict.FAIL,
                               f"Missing: {', '.join(missing_claims)}")
            except Exception as e:
                report.add(cat, "JWT payload decodable", Verdict.WARN, str(e))
        else:
            report.add(cat, "JWT structure valid (3-part)", Verdict.FAIL,
                       f"Token has {len(parts)} parts")
    else:
        report.add(cat, "JWT token analysis", Verdict.SKIP, "No token available")

    # 4. Check X-Content-Type-Options
    x_cto = resp.headers.get("x-content-type-options")
    if x_cto and x_cto.lower() == "nosniff":
        report.add(cat, "X-Content-Type-Options: nosniff", Verdict.PASS)
    else:
        report.add(cat, "X-Content-Type-Options: nosniff", Verdict.WARN,
                   "Missing or incorrect X-Content-Type-Options header")

    # 5. Check that password is not returned in registration response
    test_user = f"crypttest_{random_string(6)}"
    test_pass = f"CryptTest!{random_string(10)}"
    body, status = await register_user(client, base, username=test_user, password=test_pass)
    if body and status == 201:
        body_str = json.dumps(body)
        if test_pass in body_str:
            report.add(cat, "Password not leaked in registration response", Verdict.FAIL,
                       "Plaintext password found in response body")
        elif "password_hash" in body_str:
            report.add(cat, "Password not leaked in registration response", Verdict.FAIL,
                       "Password hash found in response body")
        else:
            report.add(cat, "Password not leaked in registration response", Verdict.PASS)
    else:
        report.add(cat, "Password not leaked in registration response", Verdict.SKIP,
                   f"Registration returned status {status}")


# ====================================================================
# A03 -- Injection
# ====================================================================

async def test_a03(client: httpx.AsyncClient, base: str, report: TestReport, tokens: dict) -> None:
    cat = "A03 - Injection"
    student_token = tokens.get("student_token")
    headers = auth_header(student_token) if student_token else {}

    # ---- SQL Injection in query parameters ----
    sqli_payloads = [
        ("' OR '1'='1", "basic-or"),
        ("1; DROP TABLE users;--", "drop-table"),
        ("' UNION SELECT null,null,null--", "union-select"),
        ("1' AND SLEEP(2)--", "time-based"),
        ("admin'--", "comment-bypass"),
    ]

    for payload_val, label in sqli_payloads:
        # Test in page parameter
        resp = await client.get(
            f"{base}/api/v1/admin/users",
            params={"page": payload_val, "size": "20"},
            headers=headers,
        )
        # If 422 (validation) or 400 or 403 -- input was rejected properly
        if resp.status_code in (400, 403, 422):
            report.add(cat, f"SQLi in ?page ({label})", Verdict.PASS,
                       f"Rejected: status {resp.status_code}")
        elif resp.status_code == 500:
            report.add(cat, f"SQLi in ?page ({label})", Verdict.FAIL,
                       "Server error 500 -- possible SQL injection")
        elif resp.status_code == 200:
            report.add(cat, f"SQLi in ?page ({label})", Verdict.WARN,
                       "200 OK -- verify parameterized queries")
        else:
            report.add(cat, f"SQLi in ?page ({label})", Verdict.INFO,
                       f"Status {resp.status_code}")

    # SQLi in role filter parameter
    resp = await client.get(
        f"{base}/api/v1/admin/users",
        params={"role": "admin' OR '1'='1"},
        headers=headers,
    )
    if resp.status_code in (400, 403, 422):
        report.add(cat, "SQLi in ?role filter parameter", Verdict.PASS,
                   f"Rejected: status {resp.status_code}")
    elif resp.status_code == 500:
        report.add(cat, "SQLi in ?role filter parameter", Verdict.FAIL,
                   "Server error 500 -- possible SQL injection")
    else:
        report.add(cat, "SQLi in ?role filter parameter", Verdict.WARN,
                   f"Status {resp.status_code} -- verify parameterized queries")

    # ---- XSS payloads in user input fields ----
    xss_payloads = [
        ('<script>alert("xss")</script>', "script-tag"),
        ('<img src=x onerror=alert(1)>', "img-onerror"),
        ('"><svg/onload=alert(1)>', "svg-onload"),
        ("javascript:alert(1)", "javascript-uri"),
        ("{{constructor.constructor('return this')()}}", "template-injection"),
    ]

    for payload_val, label in xss_payloads:
        username = f"xss_{random_string(6)}"
        body, status = await register_user(
            client, base,
            username=username,
            display_name=payload_val,
        )
        if status in (400, 422):
            report.add(cat, f"XSS in display_name ({label})", Verdict.PASS,
                       "Input rejected by validation")
        elif status == 201 and body:
            returned_name = body.get("display_name", "")
            if payload_val == returned_name:
                report.add(cat, f"XSS in display_name ({label})", Verdict.WARN,
                           "Stored as-is -- ensure output encoding on frontend")
            else:
                report.add(cat, f"XSS in display_name ({label})", Verdict.PASS,
                           "Input was sanitized or encoded")
        else:
            report.add(cat, f"XSS in display_name ({label})", Verdict.INFO,
                       f"Status {status}")

    # ---- NoSQL Injection patterns ----
    nosql_payloads = [
        ({"username": {"$gt": ""}, "password": "test"}, "nosql-gt-operator"),
        ({"username": {"$regex": ".*"}, "password": "test"}, "nosql-regex"),
        ({"username": {"$ne": ""}, "password": {"$ne": ""}}, "nosql-ne-operator"),
    ]
    for payload_body, label in nosql_payloads:
        resp = await client.post(f"{base}/api/v1/auth/login", json=payload_body)
        if resp.status_code in (400, 422):
            report.add(cat, f"NoSQL injection in login ({label})", Verdict.PASS,
                       "Input rejected")
        elif resp.status_code == 200:
            report.add(cat, f"NoSQL injection in login ({label})", Verdict.FAIL,
                       "Login succeeded with NoSQL payload")
        else:
            report.add(cat, f"NoSQL injection in login ({label})", Verdict.PASS,
                       f"Rejected with status {resp.status_code}")

    # ---- Command injection in potential file paths ----
    cmd_payloads = [
        ("; cat /etc/passwd", "semicolon-cat"),
        ("| ls -la", "pipe-ls"),
        ("$(whoami)", "subshell"),
        ("`id`", "backtick"),
    ]
    if student_token:
        for payload_val, label in cmd_payloads:
            resp = await client.post(
                f"{base}/api/v1/chat/conversations",
                headers=auth_header(student_token),
                json={"title": payload_val, "agent_type": "academic"},
            )
            if resp.status_code in (400, 422):
                report.add(cat, f"Command injection in title ({label})", Verdict.PASS,
                           "Input rejected")
            elif resp.status_code == 500:
                report.add(cat, f"Command injection in title ({label})", Verdict.FAIL,
                           "Server error 500 -- possible command injection")
            elif resp.status_code == 201 or resp.status_code == 200:
                report.add(cat, f"Command injection in title ({label})", Verdict.WARN,
                           "Input accepted -- verify no server-side execution")
            else:
                report.add(cat, f"Command injection in title ({label})", Verdict.INFO,
                           f"Status {resp.status_code}")


# ====================================================================
# A04 -- Insecure Design
# ====================================================================

async def test_a04(client: httpx.AsyncClient, base: str, report: TestReport, tokens: dict) -> None:
    cat = "A04 - Insecure Design"

    # 1. Rate limiting: send requests rapidly and check for 429
    rate_limited = False
    responses_200 = 0
    for i in range(15):
        resp = await client.get(f"{base}/api/v1/health")
        if resp.status_code == 429:
            rate_limited = True
            break
        if resp.status_code == 200:
            responses_200 += 1

    if rate_limited:
        report.add(cat, "Rate limiting enforced on health endpoint", Verdict.PASS,
                   f"429 after {i + 1} requests")
    else:
        report.add(cat, "Rate limiting enforced on health endpoint", Verdict.INFO,
                   f"No 429 in 15 rapid requests (may have higher limit)")

    # 2. Brute-force login protection
    brute_user = f"bruteforce_{random_string(6)}"
    brute_pass = f"BruteForce!{random_string(8)}"
    await register_user(client, base, username=brute_user, password=brute_pass)

    login_blocked = False
    for i in range(20):
        _, status = await login_user(client, base, brute_user, f"wrong_password_{i}")
        if status == 429:
            login_blocked = True
            break

    if login_blocked:
        report.add(cat, "Brute-force login rate limiting", Verdict.PASS,
                   f"Blocked after {i + 1} failed attempts")
    else:
        report.add(cat, "Brute-force login rate limiting", Verdict.WARN,
                   "No rate limiting detected after 20 failed logins")

    # 3. Mass registration (account enumeration / resource exhaustion)
    reg_count = 0
    reg_blocked = False
    for i in range(10):
        _, status = await register_user(client, base, username=f"massreg_{random_string(8)}")
        if status == 429:
            reg_blocked = True
            break
        if status == 201:
            reg_count += 1

    if reg_blocked:
        report.add(cat, "Mass registration rate limiting", Verdict.PASS,
                   f"Blocked after {reg_count + 1} registrations")
    else:
        report.add(cat, "Mass registration rate limiting", Verdict.WARN,
                   f"Created {reg_count} accounts without rate limiting")

    # 4. Predictable resource IDs
    student_token = tokens.get("student_token")
    if student_token:
        resp = await client.get(
            f"{base}/api/v1/chat/conversations",
            headers=auth_header(student_token),
        )
        if resp.status_code == 200:
            try:
                convs = resp.json()
                if isinstance(convs, list) and len(convs) > 0:
                    first_id = str(convs[0].get("id", ""))
                    try:
                        uuid.UUID(first_id)
                        report.add(cat, "Resource IDs use UUIDs (not sequential)", Verdict.PASS,
                                   f"ID sample: {first_id[:12]}...")
                    except ValueError:
                        if first_id.isdigit():
                            report.add(cat, "Resource IDs use UUIDs (not sequential)", Verdict.FAIL,
                                       f"Sequential integer ID: {first_id}")
                        else:
                            report.add(cat, "Resource IDs use UUIDs (not sequential)", Verdict.WARN,
                                       f"Non-UUID, non-integer ID: {first_id[:20]}")
                else:
                    report.add(cat, "Resource IDs use UUIDs (not sequential)", Verdict.INFO,
                               "No conversations to inspect")
            except Exception:
                report.add(cat, "Resource IDs use UUIDs (not sequential)", Verdict.INFO,
                           "Could not parse response")
    else:
        report.add(cat, "Resource IDs use UUIDs (not sequential)", Verdict.SKIP,
                   "No student token")

    # 5. Account enumeration via registration error messages
    known_user = f"enumtest_{random_string(6)}"
    await register_user(client, base, username=known_user)
    _, dup_status = await register_user(client, base, username=known_user)
    if dup_status == 400:
        report.add(cat, "Account enumeration via registration", Verdict.WARN,
                   "Duplicate username returns 400 -- may reveal account existence")
    elif dup_status == 409:
        report.add(cat, "Account enumeration via registration", Verdict.WARN,
                   "Duplicate username returns 409 -- reveals account existence")
    else:
        report.add(cat, "Account enumeration via registration", Verdict.INFO,
                   f"Duplicate registration status: {dup_status}")


# ====================================================================
# A05 -- Security Misconfiguration
# ====================================================================

async def test_a05(client: httpx.AsyncClient, base: str, report: TestReport, tokens: dict) -> None:
    cat = "A05 - Security Misconfiguration"

    # 1. Debug endpoints exposure
    debug_endpoints = [
        ("/docs", "Swagger UI"),
        ("/redoc", "ReDoc"),
        ("/openapi.json", "OpenAPI schema"),
    ]
    for path, label in debug_endpoints:
        resp = await client.get(f"{base}{path}")
        if resp.status_code == 200:
            report.add(cat, f"Debug endpoint exposed: {label} ({path})", Verdict.WARN,
                       "Accessible in current environment -- ensure disabled in production")
        elif resp.status_code == 404:
            report.add(cat, f"Debug endpoint exposed: {label} ({path})", Verdict.PASS,
                       "Not found (disabled)")
        else:
            report.add(cat, f"Debug endpoint exposed: {label} ({path})", Verdict.INFO,
                       f"Status {resp.status_code}")

    # 2. CORS configuration
    resp = await client.options(
        f"{base}/api/v1/health",
        headers={
            "Origin": "https://evil-site.example.com",
            "Access-Control-Request-Method": "GET",
        },
    )
    acao = resp.headers.get("access-control-allow-origin", "")
    if acao == "*":
        report.add(cat, "CORS: Allow-Origin wildcard", Verdict.WARN,
                   "Access-Control-Allow-Origin: * (overly permissive)")
    elif "evil-site.example.com" in acao:
        report.add(cat, "CORS: Allow-Origin wildcard", Verdict.FAIL,
                   "Reflects arbitrary origin -- very dangerous")
    elif acao:
        report.add(cat, "CORS: Allow-Origin restricted", Verdict.PASS, f"Origin: {acao}")
    else:
        report.add(cat, "CORS: Allow-Origin header", Verdict.INFO,
                   "No ACAO header on OPTIONS response")

    acac = resp.headers.get("access-control-allow-credentials", "")
    if acac.lower() == "true" and acao == "*":
        report.add(cat, "CORS: credentials + wildcard origin", Verdict.FAIL,
                   "allow-credentials: true with wildcard origin is a vulnerability")
    elif acac.lower() == "true":
        report.add(cat, "CORS: credentials flag", Verdict.INFO,
                   "allow-credentials: true (ensure origin is restricted)")
    else:
        report.add(cat, "CORS: credentials flag", Verdict.PASS,
                   "Credentials not exposed to cross-origin")

    # 3. Server header information leakage
    resp = await client.get(f"{base}/api/v1/health")
    server_header = resp.headers.get("server", "")
    if server_header:
        report.add(cat, "Server header information leakage", Verdict.WARN,
                   f"Server: {server_header}")
    else:
        report.add(cat, "Server header information leakage", Verdict.PASS,
                   "No Server header exposed")

    # 4. Error message information disclosure (trigger a 404/422)
    resp = await client.get(f"{base}/api/v1/nonexistent_endpoint")
    try:
        error_body = resp.json()
        error_str = json.dumps(error_body)
        sensitive_patterns = ["traceback", "stack trace", "file \"", "line ", "sqlalchemy", "postgresql"]
        leaked = [p for p in sensitive_patterns if p.lower() in error_str.lower()]
        if leaked:
            report.add(cat, "Error response information disclosure", Verdict.FAIL,
                       f"Sensitive patterns found: {', '.join(leaked)}")
        else:
            report.add(cat, "Error response information disclosure", Verdict.PASS,
                       "No sensitive information in error response")
    except Exception:
        report.add(cat, "Error response information disclosure", Verdict.PASS,
                   "Non-JSON 404 response (no detail leak)")

    # 5. Default credentials check
    default_creds = [
        ("admin", "admin"),
        ("admin", "password"),
        ("admin", "123456"),
        ("root", "root"),
        ("test", "test"),
        ("administrator", "administrator"),
    ]
    default_login_found = False
    for uname, pwd in default_creds:
        _, status = await login_user(client, base, uname, pwd)
        if status == 200:
            report.add(cat, f"Default credentials: {uname}/{pwd}", Verdict.FAIL,
                       "Login succeeded with default credentials")
            default_login_found = True
            break

    if not default_login_found:
        report.add(cat, "Default credentials check", Verdict.PASS,
                   "No default credential pairs succeeded")

    # 6. HTTP methods not restricted (PUT/DELETE on read-only endpoints)
    resp = await client.delete(f"{base}/api/v1/health")
    if resp.status_code == 405:
        report.add(cat, "HTTP method restriction (DELETE /health)", Verdict.PASS,
                   "405 Method Not Allowed")
    elif resp.status_code == 200:
        report.add(cat, "HTTP method restriction (DELETE /health)", Verdict.WARN,
                   "DELETE accepted on health endpoint")
    else:
        report.add(cat, "HTTP method restriction (DELETE /health)", Verdict.INFO,
                   f"Status {resp.status_code}")

    # 7. X-Frame-Options / Content-Security-Policy
    xfo = resp.headers.get("x-frame-options", "")
    csp = resp.headers.get("content-security-policy", "")
    if xfo or ("frame-ancestors" in csp.lower()):
        report.add(cat, "Clickjacking protection (X-Frame-Options / CSP)", Verdict.PASS,
                   f"XFO={xfo or 'N/A'}, CSP frame-ancestors={'yes' if 'frame-ancestors' in csp.lower() else 'N/A'}")
    else:
        report.add(cat, "Clickjacking protection (X-Frame-Options / CSP)", Verdict.WARN,
                   "No X-Frame-Options or CSP frame-ancestors header")


# ====================================================================
# A06 -- Vulnerable and Outdated Components
# ====================================================================

async def test_a06(client: httpx.AsyncClient, base: str, report: TestReport, tokens: dict) -> None:
    cat = "A06 - Vulnerable Components"

    resp = await client.get(f"{base}/api/v1/health")

    # Check common version-disclosing headers
    version_headers = [
        "server",
        "x-powered-by",
        "x-aspnet-version",
        "x-runtime",
        "x-generator",
    ]
    disclosed = []
    for h in version_headers:
        val = resp.headers.get(h, "")
        if val:
            disclosed.append(f"{h}: {val}")

    if disclosed:
        report.add(cat, "Version information in response headers", Verdict.WARN,
                   "; ".join(disclosed))
    else:
        report.add(cat, "Version information in response headers", Verdict.PASS,
                   "No version-disclosing headers found")

    # Check if OpenAPI schema exposes framework version
    resp_schema = await client.get(f"{base}/openapi.json")
    if resp_schema.status_code == 200:
        try:
            schema = resp_schema.json()
            info_version = schema.get("info", {}).get("version", "")
            description = schema.get("info", {}).get("description", "")
            # FastAPI automatically includes its version in some setups
            schema_str = json.dumps(schema)
            if "fastapi" in schema_str.lower() or "starlette" in schema_str.lower():
                report.add(cat, "Framework version in OpenAPI schema", Verdict.WARN,
                           "Framework name found in OpenAPI schema")
            else:
                report.add(cat, "Framework version in OpenAPI schema", Verdict.PASS,
                           "No framework identification in schema")
        except Exception:
            report.add(cat, "Framework version in OpenAPI schema", Verdict.INFO,
                       "Could not parse OpenAPI schema")
    else:
        report.add(cat, "Framework version in OpenAPI schema", Verdict.PASS,
                   "OpenAPI schema not publicly accessible")

    # Check X-Process-Time header (custom header revealing internals)
    x_process = resp.headers.get("x-process-time", "")
    if x_process:
        report.add(cat, "X-Process-Time header exposed", Verdict.WARN,
                   f"Value: {x_process} ms -- may aid timing attacks")
    else:
        report.add(cat, "X-Process-Time header exposed", Verdict.PASS,
                   "Not present")


# ====================================================================
# A07 -- Identification and Authentication Failures
# ====================================================================

async def test_a07(client: httpx.AsyncClient, base: str, report: TestReport, tokens: dict) -> None:
    cat = "A07 - Authentication Failures"

    # 1. Weak password acceptance
    weak_passwords = [
        ("123456", "numeric-only"),
        ("password", "common-word"),
        ("abc", "too-short"),
        ("a", "single-char"),
        ("", "empty"),
    ]
    for pwd, label in weak_passwords:
        uname = f"weakpwd_{random_string(6)}"
        _, status = await register_user(client, base, username=uname, password=pwd)
        if status in (400, 422):
            report.add(cat, f"Weak password rejected: {label}", Verdict.PASS,
                       f"Status {status}")
        elif status == 201:
            report.add(cat, f"Weak password rejected: {label}", Verdict.FAIL,
                       "Registration succeeded with weak password")
        else:
            report.add(cat, f"Weak password rejected: {label}", Verdict.INFO,
                       f"Status {status}")

    # 2. Expired token reuse (craft a JWT that looks expired)
    expired_payload = {
        "sub": str(uuid.uuid4()),
        "role": "student",
        "exp": 1000000000,  # ~2001 -- long expired
        "type": "access",
    }
    expired_token = make_fake_jwt(expired_payload, alg="HS256")
    resp = await client.get(
        f"{base}/api/v1/chat/conversations",
        headers=auth_header(expired_token),
    )
    if resp.status_code == 401:
        report.add(cat, "Expired/invalid token rejected", Verdict.PASS,
                   "401 Unauthorized")
    else:
        report.add(cat, "Expired/invalid token rejected", Verdict.FAIL,
                   f"Expected 401, got {resp.status_code}")

    # 3. Refresh token validation
    resp = await client.post(
        f"{base}/api/v1/auth/refresh",
        json={"refresh_token": "totally.invalid.token"},
    )
    if resp.status_code in (401, 422):
        report.add(cat, "Invalid refresh token rejected", Verdict.PASS,
                   f"Status {resp.status_code}")
    elif resp.status_code == 200:
        report.add(cat, "Invalid refresh token rejected", Verdict.FAIL,
                   "Refresh succeeded with invalid token")
    else:
        report.add(cat, "Invalid refresh token rejected", Verdict.INFO,
                   f"Status {resp.status_code}")

    # 4. Refresh token rotation: use a refresh token, then try reusing it
    student_creds = tokens.get("student_creds")
    if student_creds:
        login_body, login_status = await login_user(
            client, base, student_creds["username"], student_creds["password"]
        )
        if login_status == 200 and login_body:
            refresh_tok = login_body.get("refresh_token", "")
            if refresh_tok:
                # First refresh -- should succeed
                resp1 = await client.post(
                    f"{base}/api/v1/auth/refresh",
                    json={"refresh_token": refresh_tok},
                )
                # Second refresh with same token -- ideally rejected if rotation is enforced
                resp2 = await client.post(
                    f"{base}/api/v1/auth/refresh",
                    json={"refresh_token": refresh_tok},
                )
                if resp1.status_code == 200 and resp2.status_code in (401, 403):
                    report.add(cat, "Refresh token rotation enforced", Verdict.PASS,
                               "Reuse blocked after first refresh")
                elif resp1.status_code == 200 and resp2.status_code == 200:
                    report.add(cat, "Refresh token rotation enforced", Verdict.WARN,
                               "Same refresh token accepted twice -- no rotation")
                else:
                    report.add(cat, "Refresh token rotation enforced", Verdict.INFO,
                               f"First: {resp1.status_code}, Second: {resp2.status_code}")
    else:
        report.add(cat, "Refresh token rotation enforced", Verdict.SKIP,
                   "No student credentials available")

    # 5. Concurrent session handling (login twice, check both tokens work)
    if student_creds:
        body1, _ = await login_user(client, base, student_creds["username"], student_creds["password"])
        body2, _ = await login_user(client, base, student_creds["username"], student_creds["password"])
        if body1 and body2:
            token1 = body1.get("access_token", "")
            token2 = body2.get("access_token", "")
            r1 = await client.get(f"{base}/api/v1/chat/conversations", headers=auth_header(token1))
            r2 = await client.get(f"{base}/api/v1/chat/conversations", headers=auth_header(token2))
            if r1.status_code == 200 and r2.status_code == 200:
                report.add(cat, "Concurrent sessions allowed", Verdict.INFO,
                           "Both session tokens valid simultaneously (review if policy requires single-session)")
            elif r1.status_code == 401 and r2.status_code == 200:
                report.add(cat, "Concurrent sessions allowed", Verdict.PASS,
                           "First session invalidated on second login")
            else:
                report.add(cat, "Concurrent sessions allowed", Verdict.INFO,
                           f"Session 1: {r1.status_code}, Session 2: {r2.status_code}")


# ====================================================================
# A08 -- Software and Data Integrity Failures
# ====================================================================

async def test_a08(client: httpx.AsyncClient, base: str, report: TestReport, tokens: dict) -> None:
    cat = "A08 - Data Integrity Failures"

    # 1. JWT alg=none attack
    none_payload = {
        "sub": str(uuid.uuid4()),
        "role": "admin",
        "exp": 9999999999,
        "type": "access",
    }
    none_token = make_fake_jwt(none_payload, alg="none")
    resp = await client.get(
        f"{base}/api/v1/admin/users",
        headers=auth_header(none_token),
    )
    if resp.status_code in (401, 403):
        report.add(cat, "JWT alg=none attack rejected", Verdict.PASS,
                   f"Status {resp.status_code}")
    elif resp.status_code == 200:
        report.add(cat, "JWT alg=none attack rejected", Verdict.FAIL,
                   "Admin endpoint accessible with alg=none token!")
    else:
        report.add(cat, "JWT alg=none attack rejected", Verdict.PASS,
                   f"Status {resp.status_code} (not 200)")

    # 2. JWT with different alg variations
    for alg_name in ["None", "NONE", "nOnE"]:
        token = make_fake_jwt(none_payload, alg=alg_name)
        resp = await client.get(
            f"{base}/api/v1/chat/conversations",
            headers=auth_header(token),
        )
        if resp.status_code == 401:
            report.add(cat, f"JWT alg={alg_name} variant rejected", Verdict.PASS)
        elif resp.status_code == 200:
            report.add(cat, f"JWT alg={alg_name} variant rejected", Verdict.FAIL,
                       "Token accepted!")
        else:
            report.add(cat, f"JWT alg={alg_name} variant rejected", Verdict.PASS,
                       f"Status {resp.status_code}")

    # 3. JWT signature stripping (send header.payload without signature)
    student_token = tokens.get("student_token")
    if student_token:
        parts = student_token.split(".")
        if len(parts) == 3:
            stripped = f"{parts[0]}.{parts[1]}."
            resp = await client.get(
                f"{base}/api/v1/chat/conversations",
                headers=auth_header(stripped),
            )
            if resp.status_code == 401:
                report.add(cat, "JWT signature stripping rejected", Verdict.PASS)
            elif resp.status_code == 200:
                report.add(cat, "JWT signature stripping rejected", Verdict.FAIL,
                           "Accepted token without signature!")
            else:
                report.add(cat, "JWT signature stripping rejected", Verdict.PASS,
                           f"Status {resp.status_code}")
    else:
        report.add(cat, "JWT signature stripping rejected", Verdict.SKIP,
                   "No student token")

    # 4. JWT with tampered role claim
    if student_token:
        parts = student_token.split(".")
        if len(parts) == 3:
            try:
                padded = parts[1] + "=" * (4 - len(parts[1]) % 4)
                payload = json.loads(base64.urlsafe_b64decode(padded))
                payload["role"] = "admin"
                tampered_payload = base64.urlsafe_b64encode(
                    json.dumps(payload).encode()
                ).rstrip(b"=").decode()
                tampered_token = f"{parts[0]}.{tampered_payload}.{parts[2]}"
                resp = await client.get(
                    f"{base}/api/v1/admin/users",
                    headers=auth_header(tampered_token),
                )
                if resp.status_code in (401, 403):
                    report.add(cat, "JWT role tampering detected", Verdict.PASS,
                               f"Status {resp.status_code}")
                elif resp.status_code == 200:
                    report.add(cat, "JWT role tampering detected", Verdict.FAIL,
                               "Admin endpoint accessible with tampered role!")
                else:
                    report.add(cat, "JWT role tampering detected", Verdict.PASS,
                               f"Status {resp.status_code}")
            except Exception as e:
                report.add(cat, "JWT role tampering detected", Verdict.INFO,
                           f"Could not decode token: {e}")

    # 5. Verify Content-Type enforcement (send non-JSON to JSON endpoint)
    resp = await client.post(
        f"{base}/api/v1/auth/login",
        content="username=admin&password=admin",
        headers={"Content-Type": "application/x-www-form-urlencoded"},
    )
    if resp.status_code == 422:
        report.add(cat, "Content-Type enforcement (non-JSON rejected)", Verdict.PASS,
                   "422 for form-urlencoded body on JSON endpoint")
    elif resp.status_code == 200:
        report.add(cat, "Content-Type enforcement (non-JSON rejected)", Verdict.WARN,
                   "Endpoint accepted non-JSON content type")
    else:
        report.add(cat, "Content-Type enforcement (non-JSON rejected)", Verdict.PASS,
                   f"Status {resp.status_code}")


# ====================================================================
# A09 -- Security Logging and Monitoring Failures
# ====================================================================

async def test_a09(client: httpx.AsyncClient, base: str, report: TestReport, tokens: dict) -> None:
    cat = "A09 - Logging Failures"

    # We cannot directly verify server-side logs from the client.
    # However, we can check indirectly:

    # 1. Failed auth attempts should eventually trigger rate limiting (evidence of monitoring)
    fail_count = 0
    rate_limited = False
    for i in range(25):
        _, status = await login_user(client, base, f"nonexistent_{random_string(4)}", "wrongpwd")
        fail_count += 1
        if status == 429:
            rate_limited = True
            break

    if rate_limited:
        report.add(cat, "Failed login attempts trigger rate limiting (implies logging)", Verdict.PASS,
                   f"429 after {fail_count} failed attempts")
    else:
        report.add(cat, "Failed login attempts trigger rate limiting (implies logging)", Verdict.WARN,
                   f"No 429 after {fail_count} failed login attempts")

    # 2. Check if error responses avoid leaking stack traces (indicator of proper error handling)
    resp = await client.post(
        f"{base}/api/v1/auth/login",
        json={"username": None, "password": None},
    )
    try:
        body = resp.json()
        body_str = json.dumps(body)
        if "traceback" in body_str.lower() or "stack" in body_str.lower():
            report.add(cat, "Error responses do not leak stack traces", Verdict.FAIL,
                       "Stack trace found in error response")
        else:
            report.add(cat, "Error responses do not leak stack traces", Verdict.PASS,
                       "Clean error response")
    except Exception:
        report.add(cat, "Error responses do not leak stack traces", Verdict.PASS,
                   "Non-JSON error response")

    # 3. X-Request-ID or correlation header for traceability
    resp = await client.get(f"{base}/api/v1/health")
    req_id = resp.headers.get("x-request-id") or resp.headers.get("x-correlation-id")
    if req_id:
        report.add(cat, "Request tracing header (X-Request-ID)", Verdict.PASS,
                   f"Value: {req_id}")
    else:
        report.add(cat, "Request tracing header (X-Request-ID)", Verdict.WARN,
                   "No X-Request-ID or X-Correlation-ID header (harder to trace incidents)")


# ====================================================================
# A10 -- Server-Side Request Forgery (SSRF)
# ====================================================================

async def test_a10(client: httpx.AsyncClient, base: str, report: TestReport, tokens: dict) -> None:
    cat = "A10 - SSRF"
    student_token = tokens.get("student_token")
    headers = auth_header(student_token) if student_token else {}

    # SSRF payloads targeting internal services
    ssrf_urls = [
        "http://127.0.0.1:6379/",          # Redis
        "http://localhost:5432/",            # PostgreSQL
        "http://169.254.169.254/latest/",    # AWS metadata
        "http://[::1]/",                     # IPv6 loopback
        "file:///etc/passwd",                # local file
        "http://0.0.0.0:8080/",             # LLM service
    ]

    # Test URL payloads in avatar_url field (user update)
    for url_payload in ssrf_urls:
        label = url_payload[:40]

        # Try via registration with avatar_url-like fields
        resp = await client.post(
            f"{base}/api/v1/auth/register",
            json={
                "username": f"ssrf_{random_string(6)}",
                "password": f"SsrfTest!{random_string(8)}",
                "display_name": "SSRF Test",
                "email": url_payload,
            },
        )
        if resp.status_code in (400, 422):
            report.add(cat, f"SSRF payload rejected in email ({label})", Verdict.PASS,
                       f"Status {resp.status_code}")
        elif resp.status_code == 201:
            report.add(cat, f"SSRF payload rejected in email ({label})", Verdict.INFO,
                       "Accepted (email field) -- verify no server-side fetching")
        else:
            report.add(cat, f"SSRF payload rejected in email ({label})", Verdict.INFO,
                       f"Status {resp.status_code}")

    # Test URL payloads in chat conversation title/content (if any fetch occurs)
    if student_token:
        for url_payload in ssrf_urls[:3]:  # Test a subset
            label = url_payload[:40]
            resp = await client.post(
                f"{base}/api/v1/chat/conversations",
                headers=headers,
                json={"title": url_payload, "agent_type": "academic"},
            )
            if resp.status_code in (400, 422):
                report.add(cat, f"SSRF payload rejected in conversation title ({label})", Verdict.PASS,
                           f"Status {resp.status_code}")
            elif resp.status_code in (200, 201):
                report.add(cat, f"SSRF payload rejected in conversation title ({label})", Verdict.INFO,
                           "Accepted as title text -- verify no server-side URL fetching")
            else:
                report.add(cat, f"SSRF payload rejected in conversation title ({label})", Verdict.INFO,
                           f"Status {resp.status_code}")


# ====================================================================
# Main Orchestrator
# ====================================================================

async def setup_test_users(
    client: httpx.AsyncClient,
    base: str,
    admin_user: str | None,
    admin_pass: str | None,
) -> dict:
    """Create test users and obtain tokens for testing."""
    tokens: dict[str, Any] = {}

    # Create a student user
    student_uname = f"sectest_student_{random_string(6)}"
    student_pwd = f"StudentPwd!{random_string(8)}"
    body, status = await register_user(
        client, base,
        username=student_uname,
        password=student_pwd,
        display_name="Security Test Student",
        role="student",
    )
    if status == 201:
        login_body, login_status = await login_user(client, base, student_uname, student_pwd)
        if login_status == 200 and login_body:
            tokens["student_token"] = login_body.get("access_token")
            tokens["student_refresh"] = login_body.get("refresh_token")
            tokens["student_creds"] = {"username": student_uname, "password": student_pwd}
            print(f"  [OK] Student user created: {student_uname}")
        else:
            print(f"  [!!] Student login failed: status {login_status}")
    else:
        print(f"  [!!] Student registration failed: status {status}")

    # Create a teacher user
    teacher_uname = f"sectest_teacher_{random_string(6)}"
    teacher_pwd = f"TeacherPwd!{random_string(8)}"
    body, status = await register_user(
        client, base,
        username=teacher_uname,
        password=teacher_pwd,
        display_name="Security Test Teacher",
        role="teacher",
    )
    if status == 201:
        login_body, login_status = await login_user(client, base, teacher_uname, teacher_pwd)
        if login_status == 200 and login_body:
            tokens["teacher_token"] = login_body.get("access_token")
            tokens["teacher_creds"] = {"username": teacher_uname, "password": teacher_pwd}
            print(f"  [OK] Teacher user created: {teacher_uname}")
        else:
            print(f"  [!!] Teacher login failed: status {login_status}")
    else:
        print(f"  [!!] Teacher registration failed: status {status}")

    # Admin token (from CLI args or skip)
    if admin_user and admin_pass:
        login_body, login_status = await login_user(client, base, admin_user, admin_pass)
        if login_status == 200 and login_body:
            tokens["admin_token"] = login_body.get("access_token")
            tokens["admin_creds"] = {"username": admin_user, "password": admin_pass}
            print(f"  [OK] Admin user logged in: {admin_user}")
        else:
            print(f"  [!!] Admin login failed: status {login_status}")
    else:
        print("  [--] No admin credentials provided (--admin-user / --admin-pass)")

    return tokens


async def run_all_tests(host: str, admin_user: str | None, admin_pass: str | None) -> None:
    report = TestReport()

    print()
    print("=" * 80)
    print("  OWASP Top 10 Security Tests  --  JY-Companion API")
    print(f"  Target: {host}")
    print("=" * 80)

    # Check connectivity
    async with httpx.AsyncClient(timeout=httpx.Timeout(15.0), follow_redirects=True) as client:
        try:
            resp = await client.get(f"{host}/api/v1/health")
            if resp.status_code != 200:
                print(f"\n  WARNING: Health endpoint returned {resp.status_code}")
                print("  The server may not be fully operational. Continuing anyway.\n")
            else:
                try:
                    health = resp.json()
                    print(f"  Health: {health.get('status', 'unknown')} "
                          f"(v{health.get('version', '?')})")
                except Exception:
                    print(f"  Health: status {resp.status_code}")
        except httpx.ConnectError:
            print(f"\n  ERROR: Cannot connect to {host}")
            print("  Make sure the backend server is running.\n")
            sys.exit(1)
        except Exception as e:
            print(f"\n  ERROR: {e}\n")
            sys.exit(1)

        # Setup test users
        print("\n--- Setting up test users ---")
        tokens = await setup_test_users(client, host, admin_user, admin_pass)

        # Run tests sequentially to avoid overwhelming the server
        print("\n--- Running OWASP Top 10 tests ---")

        test_suites = [
            ("A01 - Broken Access Control", test_a01),
            ("A02 - Cryptographic Failures", test_a02),
            ("A03 - Injection", test_a03),
            ("A04 - Insecure Design", test_a04),
            ("A05 - Security Misconfiguration", test_a05),
            ("A06 - Vulnerable Components", test_a06),
            ("A07 - Authentication Failures", test_a07),
            ("A08 - Data Integrity Failures", test_a08),
            ("A09 - Logging Failures", test_a09),
            ("A10 - SSRF", test_a10),
        ]

        for label, test_fn in test_suites:
            print(f"  Running {label} ...")
            try:
                await test_fn(client, host, report, tokens)
            except Exception as e:
                report.add(label, "Test suite error", Verdict.SKIP, str(e))
                print(f"    ERROR in {label}: {e}")

    report.print_report()


# ====================================================================
# CLI Entry Point
# ====================================================================

def main() -> None:
    parser = argparse.ArgumentParser(
        description="OWASP Top 10 Security Tests for JY-Companion API",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python scripts/security_test.py
  python scripts/security_test.py --host http://localhost:8000
  python scripts/security_test.py --admin-user admin --admin-pass mysecret
        """,
    )
    parser.add_argument(
        "--host",
        default="http://localhost:8000",
        help="Base URL of the API server (default: http://localhost:8000)",
    )
    parser.add_argument(
        "--admin-user",
        default=None,
        help="Admin username for privileged endpoint tests",
    )
    parser.add_argument(
        "--admin-pass",
        default=None,
        help="Admin password for privileged endpoint tests",
    )
    args = parser.parse_args()

    # Normalize host (remove trailing slash)
    host = args.host.rstrip("/")

    asyncio.run(run_all_tests(host, args.admin_user, args.admin_pass))


if __name__ == "__main__":
    main()

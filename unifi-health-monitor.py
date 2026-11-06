#!/usr/bin/env python3
#
# Script Name: unifi-health-monitor.py
# Description: Queries UniFi Controller API to check site health and device statuses.
#

import requests
import urllib3

# Suppress self-signed cert warnings common on local UniFi controllers
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

UNIFI_URL = "https://192.168.1.1:8443"
USERNAME = "admin"
PASSWORD = "your_secure_password"
SITE = "default"

def check_unifi_health():
    session = requests.Session()
    
    # Authenticate
    login_url = f"{UNIFI_URL}/api/login"
    payload = {"username": USERNAME, "password": PASSWORD}
    
    try:
        response = session.post(login_url, json=payload, verify=False)
        if response.status_code != 200:
            print(f"[ERROR]: Authentication failed with status code {response.status_code}")
            return

        # Fetch site health metrics
        health_url = f"{UNIFI_URL}/api/s/{SITE}/stat/health"
        health_res = session.get(health_url, verify=False)
        
        if health_res.status_code == 200:
            data = health_res.json().get('data', [])
            print("==========================================")
            print(" UniFi Controller Site Health Summary")
            print("=========================================="
            for subsystem in data:
                sub = subsystem.get('subsystem', 'unknown')
                status = subsystem.get('status', 'unknown')
                print(f"Subsystem: {sub.upper()} -> Status: {status}")
        else:
            print("[ERROR]: Failed to retrieve site health metrics.")
            
    except Exception as e:
        print(f"[ERROR]: Connection to UniFi Controller failed: {e}")
    finally:
        # Logout
        session.post(f"{UNIFI_URL}/api/logout", verify=False)

if __name__ == "__main__":
    check_unifi_health()

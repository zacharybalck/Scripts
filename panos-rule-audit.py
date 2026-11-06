#!/usr/bin/env python3
#
# Script Name: panos-rule-audit.py
# Description: Audits Palo Alto firewall security rules for overly permissive settings.
#

import requests
import xml.etree.ElementTree as ET
import urllib3

urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

FW_IP = "192.168.50.1"
API_KEY = "your_panos_api_key_here"

def audit_security_rules():
    url = f"https://{FW_IP}/api/?type=config&action=get&xpath=/config/devices/entry[@name='localhost.localdomain']/vsys/entry[@name='vsys1']/rulebase/security/rules&key={API_KEY}"
    
    response = requests.get(url, verify=False)
    if response.status_code != 200:
        print(f"[ERROR]: Failed to connect to firewall API. Status code: {response.status_code}")
        return

    root = ET.fromstring(response.content)
    rules = root.findall(".//entry")

    print("==========================================")
    print(" Palo Alto Security Rule Permissive Audit")
    print("==========================================")

    for rule in rules:
        rule_name = rule.get('name')
        
        # Extract fields
        source = [elem.text for elem in rule.findall(".//source/member")]
        destination = [elem.text for elem in rule.findall(".//destination/member")]
        service = [elem.text for elem in rule.findall(".//service/member")]
        action = rule.find(".//action")
        action_text = action.text if action is not None else "allow"

        is_permissive = ("any" in source or "any" in destination) and action_text == "allow"

        if is_permissive:
            print(f"[WARNING]: Rule '{rule_name}' is overly permissive!")
            print(f"   -> Source: {source} | Destination: {destination} | Action: {action_text}")
        else:
            print(f"[SECURE]: Rule '{rule_name}' is restricted properly.")

if __name__ == "__main__":
    audit_security_rules()

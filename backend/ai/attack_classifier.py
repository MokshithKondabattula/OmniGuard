import random

ATTACKS = [
    "Brute Force",
    "DDoS",
    "Malware",
    "Phishing",
    "Privilege Escalation"
]

def classify_attack():

    return {
        "attack_type":
            random.choice(ATTACKS),

        "confidence":
            round(random.uniform(80,99),2)
    }
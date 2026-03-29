import requests
import json
from faker import Faker
import random
from pyotp import otp_time, totp

# User Agent List
USER_AGENT = [
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/98.0.4757.102 Safari/537.36",
    "Mozilla/5.0 (Macintosh; macOS 10.15.0; Catalina) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/98.0.4757.102 Safari/537.36",
    "Mozilla/5.0 (Windows NT 11.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4979.108 Safari/537.36",
]

# Email List
EMAILS = [
    "user1@example.com", "user2@gmail.com", "user3@yahoo.com", "user4@outlook.com",
]

def generate_password(length=8):
    characters = "abcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()"
    password = ''.join([random.choice(characters) for _ in range(length)])
    return password

def create_account():
    # Generate random data
    fake = Faker()
    full_name = fake.name()
    user_email = random.choice(EMAILS).replace("user", str(random.randint(1000, 9999)))
    password = generate_password()
    device_id = str(random.randint(10000000, 99999999))

    # Create JSON data for signup request
    data = {
        "email": user_email,
        "password": password,
        "first_name": fake.first_name(),
        "last_name": fake.last_name(),
        "telephone_number": f"{random.randint(1000, 9999)}-{random.randint(1000, 9999)}-{random.randint(1000, 9999)}", # Example
        "device_id": device_id,
    }

    # Set headers
    headers = {
        "Content-Type": "application/json",
        "User-Agent": random.choice(USER_AGENT),
    }

    # Send signup request to Facebook
    try:
        response = requests.post("https://www.facebook.com/email/shuri/", json=data, headers=headers)
        response.raise_for_status()  # Raise HTTPError for bad responses (4xx or 5xx)

        # Parse JSON response
        json_data = response.json()

        # Check status code and message
        if json_data["status"] == "success":
            print("Account created successfully!")
            return True
        elif json_data["status"] == "email_taken":
            print(f"Email '{user_email}' already taken.")
            return False
        else:
            print(f"Error creating account: {json_data.get('message', 'Unknown Error')}")
            return False

    except requests.exceptions.RequestException as e:
        print(f"Connection error: {e}")
        return False


def main():
    num_accounts = int(input("Enter the number of accounts to create: "))
    success_count = 0
    total_attempts = 0

    for i in range(num_accounts):
        if create_account():
            success_count += 1
        total_attempts += 1
        print(f"Account {i+1}/{num_accounts} created.") # Print progress
        random.seed()  # Reset seed for each account

    success_rate = (success_count / total_attempts) * 100 if total_attempts > 0 else 0
    print("\n--- Summary ---")
    print(f"Total Accounts Created: {success_count}")
    print(f"Success Rate: {int(success_rate)}%")


if __name__ == "__main__":
    main()

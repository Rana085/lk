from faker import Faker
import random
import secrets
import asyncio
import aiohttp
import json

# Generate fake data
fake = Faker()
email = f"{fake.name}@{fake.domain}"
password = secrets.token_alphanumeric(16)
useragent = f"Mozilla/5.0 (Android; Chrome; 99.0; Mobile; OPPO A74; WxMDTS)"

# Function to generate a random IP address
def get_random_ip():
    return "".join([str((int)(random.getrandbits(8))) for _ in range(2)]) + "." \
           "".join([str((int)(random.getrandbits(8))) for _ in range(2)]) + "." \
           "".join([str((int)(random.getrandbits(8))) for _ in range(2)]) + "." \
           "".join([str((int)(random.getrandbits(8))) for _ in range(2)])

# Function to generate random device address
def get_random_device_address():
    return f"::FFFF:{random.randint(0, 255)}.{random.randint(0, 255)}.{random.randint(0, 255)}"

# Login data structure
login_data = {
    "email": email,
    "password": password,
    "device_id": secrets.token_urlsafe(16),
    "device_type": "Android",
    "timezone": fake.timezone(),
    "locale": fake.languagecode()
}

# Function to create Facebook account with aiohttp post request
async def create_account():
    try:
        # Create JSON data from login data
        data = json.dumps(login_data)

        headers = {
            "Content-Type": "application/json",
            "User-Agent": useragent
        }

        async with aiohttp.ClientSession() as session:
            async with session.post("https://graph.facebook.com/stateboard/useraccounts", headers=headers, data=data.encode()) as response:
                response_json = await response.json()

                # Check if account creation was successful
                if response_json["result"]["id"]:
                    print(f"Account created successfully! Email: {email}, Password: {password}")
                    return True
                else:
                    print(f"Account creation failed. Error: {response_json['message']}")
                    return False

    except Exception as e:
        print(f"An error occurred during account creation: {e}")
        return False

# Main function to run the script
if __name__ == "__main__":
    asyncio.run(create_account())

import pyotp
import faker
import fake_email
import asyncio
from aiohttp import *
import json
import random


# Configuration (feel free to adjust these)
EMAIL = "test456789@gmail.com"  # Replace with your desired email domain
PASSWORD = "RandomPassword123!" # Change this for each account! Use pyotp for PIN
OTP = "123456" # PIN from the OTP generator, it must match what you enter into Facebook

USER_AGENT_PREFIX = "AutoFacebookAccount/"
NUMBER_OF_ACCOUNTS = 3  # Set how many accounts to create.
ACCOUNT_TYPE = 'male' # or 'female', 'other'


class AutoAccountCreator:
    def __init__(self):
        self.fake = faker.Faker()
        self.client_session = None

    async def create_account(self, account_number=1):
        """Creates a single Facebook auto account."""

        # Generate name and email
        full_name = f"{self.fake.first_name()} {self.fake.last_name()}"
        email = f"{self.fake.email().replace('@gmail.com','{}.com')}".format(account_number)
        password = self.fake.password()

        # Generate OTP PIN
        otp = pyotp.QRCodeOTPGenerator(email, password=password).totext() # Replace email with the generated email

        print(f"\nAccount #{account_number} created: \nEmail: {email}\nPassword: {password}\nOTP: {otp}")

        # Create aiohttp Session
        try:
            self.client_session = AIOHTTP().create()
            await self.client_session.get('https://www.facebook.com/login.php')
        except Exception as e:
            print(f"Error initializing session: {e}")
            return

        # Prepare request data
        data = json.dumps({
            'email': email,
            'password': password,
            'device_id': f"{account_number}", # Use a random device ID for each account
            'package': 'com.facebook.android',
            'client_app': 'FacebookAndroid',
            'version': "10.0",
            'locale': "en\_US",
            'device_model': "SM-G973U", # Replace with a random device model
            'os_name': 'Android',
            'os_version': "12.0",
            'user_type': 8,  # New account type
            'token': OTP,   # Use the generated OTP PIN
        })

        try:
            async with self.client_session.post(
                url="https://www.facebook.com/login.php?locale=en_US&email=${EMAIL}&password=${PASSWORD}",
                json=data,
            ) as response:
                if response.status == 201:
                    print("Account Created Successfully")
                else:
                    print(f"Error creating account (Status code {response.status}): \n{await response.text()}")

        except Exception as e:
            print(f"\nError during login request for Account #{account_number}: {e}")


    async def run(self):
        """Runs the account creation process."""
        # Create multiple accounts in parallel
        tasks = []
        for i in range(1, NUMBER_OF_ACCOUNTS + 1):
            task = asyncio.create_task(self.create_account(i))
            tasks.append(task)

        await asyncio.gather(*tasks) # Run all tasks simultaneously


# Main Execution Block
if __name__ == "__main__":
    async def main():
        creator = AutoAccountCreator()
        await creator.run()
    
    asyncio.run(main())  # Start the asynchronous program

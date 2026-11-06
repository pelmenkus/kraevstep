import requests

url = "https://api.trongrid.io/wallet/createtransaction"

payload = "{\n    \"to_address\": \"416380244957c995730fb9e4c7991c9bdad5a540ed\",\n    \"owner_address\": \"41f71b0493b470b2be6fd074596873a30b570cdfb4\",\n    \"amount\": 1\n}"
headers = {
    'Content-Type': "application/json",
    'TRON-PRO-API-KEY': "86cc895c-0989-43e9-b82a-25ffe1c172b2"
    }
response = requests.request("POST", url, data=payload, headers=headers)
print(response.text)
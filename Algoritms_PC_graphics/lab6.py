from tronpy import Tron
from tronpy.keys import PrivateKey
from tronpy.providers import HTTPProvider
priv_key = PrivateKey(bytes.fromhex('7b504b48b09eca648994c4a163acc36647d8b5ce2ea0126cf75162f239086d12'))
provider = HTTPProvider(api_key="86cc895c-0989-43e9-b82a-25ffe1c172b2")
client = Tron(provider)
txn = (
    client.trx.transfer('TNsPJKQttVnDdXLSTNQ2rcxa6FAv6PUTzH', 'TK3KQVeMmnR9fPjn8XpgHWf814bnXvtek9', 2_0000)
    .build()
    .inspect()
    .sign(priv_key)
    .broadcast()
)

print(txn)
# > {'result': True, 'txid': '5182b96bc0d74f416d6ba8e22380e5920d8627f8fb5ef5a6a11d4df030459132'}
print(txn.wait())
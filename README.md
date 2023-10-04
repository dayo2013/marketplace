ERC721 Marketplace template

marketlist:
order creator;
token address;
tokenid;
price;
signature;
deadline;


Conditon check:
Creator:check owner most be == msg.sender

token address:check that most have  approved (address(this))to spend token address.
tokenid :check that the owner is the really owner of the tokenid.

precondition;
tokenaddress:check that address is not address(0)
check that the address smartcontract address that contain code.

price: check that price is > 0

signature---

deadline : most be > block.stamp with 1hour

code logic
store in a storage(state)
increment id for listing
emit event

code execution
-check that listingId< public counter
- check that msg.value == listing.price
- check that block.timestamp <= listing.deadline
- check that signature is signed by listing.owner


logic

- retrieve data from storage
- transfer ether from buyer to seller
- transfer nft from seller to buyer
- emit event
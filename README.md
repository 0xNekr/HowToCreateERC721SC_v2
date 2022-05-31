# Create an ERC721 smart contract
**Update of the previous version that you can find here :**
https://github.com/0xNekr/HowToCreateERC721SC_v1

Creation of a basic ERC721 contract that allows :
### Previous version
- A supply (number of NFT) of **100**.
- ~~A price of **0.00001 ether**~~.
- Return to **IPFS** metadata.
- Allows to mint **several NFTs** at once.
- Allows to **withdraw money** from the smart contract by the owner.

### New features
- Adding **sales steps**.
- Add a **whitelist** before the public sale.
- A whitelist price of **0.005 ether**.
- A public price of **0.01 ether**.
- Un **arbre de merkle** pour éviter de payer **trop de frais** de gas en whitelist.
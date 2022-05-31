//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
// Start new imports
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
// End new imports


contract NekrIsERC721_v2 is ERC721, Ownable {
    using Counters for Counters.Counter;
    using Strings for uint;

    Counters.Counter private _tokenIds;

    // Start new variables
    enum Step {
        SaleNotStarted,
        WhitelistSale,
        PublicSale,
        SoldOut
    }

    Step public sellingStep;

    bytes32 public merkleRoot;

    uint public constant MAX_WHITELIST = 10;
    uint public constant WHITELIST_PRICE = 0.005 ether;

    mapping(address => uint) public amountNFTbyWalletForWL;

    // End new variables

    uint public constant MAX_SUPPLY = 100;
    uint public constant PRICE = 0.01 ether;

    string public baseTokenURI;

    constructor(string memory baseURI, bytes32 rootOfMerkle) ERC721("Nekr Collection V2", "NEKRV2") {
        setBaseURI(baseURI);
        setMerkleRoot(rootOfMerkle);
    }

    function setBaseURI(string memory _baseTokenURI) public onlyOwner {
        baseTokenURI = _baseTokenURI;
    }

    function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
        require(_exists(_tokenId),"ERC721Metadata: URI query for nonexistent token");
        return string(abi.encodePacked(baseTokenURI, _tokenId.toString(),".json"));
    }

    // Start updated function
    function mintNFTs(uint _count,  bytes32[] calldata _proof) external payable {
        require(sellingStep == Step.WhitelistSale || sellingStep == Step.PublicSale, "The sale is not open or closed ");
        uint current_price = getCurrentPrice();
        uint totalMinted = _tokenIds.current();

        if (sellingStep == Step.WhitelistSale) {
            require(isWhitelisted(msg.sender, _proof), "Not whitelisted");
            require(amountNFTbyWalletForWL[msg.sender] + _count <= 1, "You can't only get 1 NFT on the whitelist sale");
            require(totalMinted + _count  <= MAX_WHITELIST, "Max supply exceeded");
        }

        require(totalMinted + _count <= MAX_SUPPLY, "The total supply has been reached.");
        require(msg.value >= current_price * _count, "Not enough funds to purchase.");

        for (uint i = 0; i < _count; i++) {
            uint newTokenID = _tokenIds.current();
            _mint(msg.sender, newTokenID);
            _tokenIds.increment();
        }
    }
    // End updated function

    function withdraw() public payable onlyOwner {
        uint balance = address(this).balance;
        require(balance > 0, "No ether left to withdraw");

        (bool success, ) = (msg.sender).call{value: balance}("");
        require(success, "Transfer failed.");
    }

    // Start new functions
    function getCurrentPrice() public view virtual returns (uint) {
        if (sellingStep == Step.WhitelistSale) {
            return WHITELIST_PRICE;
        } else {
            return PRICE;
        }
    }

    function setMerkleRoot(bytes32 _merkleRoot) public onlyOwner {
        merkleRoot = _merkleRoot;
    }

    function setStep(uint _step) external onlyOwner {
        sellingStep = Step(_step);
    }

    function isWhitelisted(address _account, bytes32[] calldata proof) internal view returns(bool) {
        return _verify(_leaf(_account), proof);
    }

    function _leaf(address _account) internal pure returns(bytes32) {
        return keccak256(abi.encodePacked(_account));
    }

    function _verify(bytes32 leaf, bytes32[] memory proof) internal view returns(bool) {
        return MerkleProof.verify(proof, merkleRoot, leaf);
    }
    // End new functions
}
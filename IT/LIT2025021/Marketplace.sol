// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "./PlatformToken.sol";
import "./OnChainNFT.sol";

contract Marketplace {
    PlatformToken public token;
    OnChainNFT public nft;

    struct Listing {
        uint256 tokenId;
        address seller;
        uint256 price;
        bool sold;
    }

    Listing[] private listings;
    mapping(address => uint256[]) private purchases;

    event NFTListed(uint256 tokenId, uint256 price);
    event NFTSold(uint256 tokenId, address buyer);

    constructor(address tokenAddress, address nftAddress) {
        token = PlatformToken(tokenAddress);
        nft = OnChainNFT(nftAddress);
    }

    function listNFT(uint256 tokenId, uint256 price) external {
        require(nft.ownerOf(tokenId) == msg.sender, "Not NFT owner");

        nft.transferNFT(tokenId, address(this));

        listings.push(Listing(
            tokenId,
            msg.sender,
            price,
            false
        ));

        emit NFTListed(tokenId, price);
    }

    function buyNFT(uint256 listingId) external {
        Listing storage item = listings[listingId];
        require(!item.sold, "Already sold");

        token.transferFrom(msg.sender, item.seller, item.price);
        nft.transferNFT(item.tokenId, msg.sender);

        item.sold = true;
        purchases[msg.sender].push(item.tokenId);

        emit NFTSold(item.tokenId, msg.sender);
    }

    // 1️⃣ View all listed (unsold) NFTs
    function viewListedNFTs() external view returns (Listing[] memory) {
        return listings;
    }

    // 2️⃣ View all sold NFTs
    function viewSoldNFTs() external view returns (Listing[] memory) {
        uint count;
        for (uint i = 0; i < listings.length; i++) {
            if (listings[i].sold) count++;
        }

        Listing[] memory sold = new Listing[](count);
        uint index;
        for (uint i = 0; i < listings.length; i++) {
            if (listings[i].sold) {
                sold[index++] = listings[i];
            }
        }
        return sold;
    }

    // 3️⃣ View NFT by tokenId
    function viewNFT(uint256 tokenId) external view returns (OnChainNFT.NFT memory) {
        return nft.getNFT(tokenId);
    }
    
    // 4️⃣ View NFTs purchased by user
    function viewNFTsPurchasedBy(address user) external view returns (uint256[] memory) {
        return purchases[user];
    }
}
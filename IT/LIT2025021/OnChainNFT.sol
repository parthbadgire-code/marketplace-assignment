// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract OnChainNFT {
    uint256 public tokenCounter;

    struct NFT {
        uint256 tokenId;
        string name;
        string description;
        address owner;
    }

    mapping(uint256 => NFT) private nfts;
    mapping(address => uint256[]) private ownedNFTs;

    event NFTMinted(uint256 tokenId, address owner);

    function mintNFT(string calldata name, string calldata description) external {
        tokenCounter++;

        nfts[tokenCounter] = NFT(
            tokenCounter,
            name,
            description,
            msg.sender
        );

        ownedNFTs[msg.sender].push(tokenCounter);

        emit NFTMinted(tokenCounter, msg.sender);
    }

    function transferNFT(uint256 tokenId, address to) external {
        require(nfts[tokenId].owner == msg.sender, "Not owner");

        nfts[tokenId].owner = to;
        ownedNFTs[to].push(tokenId);
    }

    function getNFT(uint256 tokenId) external view returns (NFT memory) {
        return nfts[tokenId];
    }

    function getAllNFTs() external view returns (NFT[] memory) {
        NFT[] memory all = new NFT[](tokenCounter);
        for (uint256 i = 1; i <= tokenCounter; i++) {
            all[i - 1] = nfts[i];
        }
        return all;
    }

    function ownerOf(uint256 tokenId) external view returns (address) {
        return nfts[tokenId].owner;
    }
}

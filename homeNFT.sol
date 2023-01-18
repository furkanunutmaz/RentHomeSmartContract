// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract HomeToken is ERC721, ERC721Burnable, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("homeNFT", "YTH") {}

    struct HomeToken {
        uint nftID;
        uint HomeID;
        uint CustomerID;
        uint createDate;
        uint validDay;
    }

    mapping(uint => HomeToken) public idtoCustomer;

    function safeMint(address to, 
                      uint _customerID,
                      uint _homeID,
                      uint _validDay) public onlyOwner {
        uint tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
   
        HomeToken memory hometoken;
        hometoken.nftID = tokenId;
        hometoken.CustomerID =_customerID;
        hometoken.HomeID = _homeID;
        hometoken.createDate = block.timestamp;
        hometoken.validDay = _validDay;
        idtoCustomer[tokenId] = hometoken;
        _safeMint(to, tokenId);
    }

    function viewNFT(uint _id) public view returns(HomeToken memory){
        return idtoCustomer[_id];
    }

    function burn(uint256 tokenId) NFTvalidCheck public override{
        _burn(tokenId);
    }

    modifier NFTvalidCheck() {
        uint256 tokenId;
        HomeToken storage hometoken = idtoCustomer[tokenId];
        require(block.timestamp > hometoken.createDate + hometoken.validDay, "NFT is already valid !");
        _;
    }


}

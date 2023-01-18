pragma solidity ^0.8.7;

import "./homeNFT.sol";

contract RentHome { 

    HomeToken public hometoken;

    constructor(address _homeNFTContract) {
        hometoken = HomeToken(_homeNFTContract);
    }

    enum BathroomType {
        Private, // 0
        Shared // 1
    }

    enum HomeType {
        Home, // 0
        Room, // 1
        Bed   // 2
    }

    // Home Information
    struct Home {
        uint HomePrice;
        string HouseHolder;
        address payable HouseOwnerAdress;
        HomeType HomeType;
        BathroomType BathroomType;
    }

    // Customer Information
    struct Customer{
        string CustomerName;
    }

    // Customer rent home
    struct RentTransaction {
        uint HomeID;
        uint CustomerID;
        uint CreateDate;
        uint ValidDay;
    }


    Home[] public homes;
    Customer[] public customers;
    RentTransaction[] public rent;


    // Add home function for rent
    function AddHome(uint _homePrice,
                     string memory _houseHolder,
                     address payable _houseOwnerAdress,
                     HomeType _homeType,
                     BathroomType _bathroomType) external returns(uint) {

        Home memory home;
        home.HomePrice = _homePrice;
        home.HouseHolder = _houseHolder;
        home.HouseOwnerAdress = _houseOwnerAdress;
        home.HomeType = _homeType;
        home.BathroomType = _bathroomType;
        homes.push(home);

        return homes.length - 1; 
    }


    // Add customer to chain
    function AddCustomer(string memory _customerName) external returns(uint){
        
        Customer memory customer;

        customer.CustomerName = _customerName;
        customers.push(customer);

        return customers.length - 1;
    }

    mapping(address => uint256) public balances;

    
    function CreateRent(uint _homeID,
                        uint _customerID,
                        uint _validDay) external payable returns (uint) {
        
        RentTransaction memory renttransaction;
        renttransaction.HomeID = _homeID;
        renttransaction.CustomerID = _customerID;
        renttransaction.CreateDate = block.timestamp;
        renttransaction.ValidDay = _validDay;
        rent.push(renttransaction);


        // Rent info
        uint homeprice = homes[_homeID].HomePrice;
        address payable homeOwnerAdress = homes[_homeID].HouseOwnerAdress;

        // withdraw transaction
        homeOwnerAdress.transfer(homeprice);
        balances[homeOwnerAdress] += homeprice;
        balances[msg.sender] -= homeprice;

        // NFT Mint 
        hometoken.safeMint(msg.sender,
                           _homeID,
                           _customerID,
                           _validDay);


        return rent.length - 1;
    }
    
    function sendEtherToContract() payable external {
        balances[msg.sender] = msg.value;
    }

    function showBalance() external view returns(uint) {
        return balances[msg.sender];
    }


    event HouseHolderAddressChanged(uint256 _homeID, address payable _houseOwnerAdress);

    function updateHome(uint256 _homeID, 
                        address payable _houseOwnerAdress) external {
         Home storage home = homes[_homeID];
         // Address can change just address owner !!
         require( home.HouseOwnerAdress == msg.sender , "You are not authorized.");
         home.HouseOwnerAdress = _houseOwnerAdress ;

         emit HouseHolderAddressChanged(_homeID, _houseOwnerAdress);
    }

/*
    modifier checkHomeId(uint256 _homeID) {
        require( homes.HouseOwnerAdress != msg.sender , "You aren't authorized.");
        _;

    }
*/

}
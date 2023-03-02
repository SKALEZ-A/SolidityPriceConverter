// SPDX-License-Identifier: MIT
// Using ChainLink VFR 
// Floating point math in solidity
pragma solidity ^0.8.0;

import "./PriceConverter.sol";

error NotOwner();

contract FundMe {
    address public immutable i_owner;
    using PriceConverter for uint256;
    uint256 public constant MINIMUM_USD = 50 * 10^18;

    // to keep track of the people that sent mkney to the contract 
    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;

    constructor() {
        i_owner = msg.sender;
    }
    modifier onlyOwner() {
        // require(i_owner == msg.sender, "Sender is not owner");
        if(msg.sender != i_owner){revert NotOwner();}   // another way to reduce gas.
        _;
    }

    function fund() public payable {
        require(msg.value.getConversionRate() > MINIMUM_USD, "Didnt send enough ether");
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] = msg.value;
    }
    function getBalance() public view returns(uint){
        return address(this).balance;
    }

    function withdraw() public onlyOwner {
        // looping through all addresses 
        for (uint funderIndex = 0; funderIndex < funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }

        // resetting the array
        funders = new address[](0);

        // withdrawing the funds 
        // payable(msg.sender).transfer(address(this).balance);     // transfer 

        // //send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);    // send
        // require(sendSuccess, "Send failed");

        //call
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");    
    }

    // what happens if ETH is sent to the smart contract without calling the fund() (receive and fallback)
    receive() external payable {
        fund()
    }
    fallback() external payable {
        fund()
    }

    
}
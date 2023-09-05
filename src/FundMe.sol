// Get funds from users
// Withdraw funds
// Send a minimum funding value in USD

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {PriceConverter} from "./PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

error FundMe_NotOwner();
// Note that if we deploy the contract to Javascript VM then fund, withdraw (basically the ones involving ether) won't work 
// cause for that we need a network

// constant, immutable

// error NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    uint256 public myvalue = 1;

    // uint256 public minimumUSD = 5 * (10 ** 18);
    // uint256 public minimumUSD = 5e18;
    // global variables are by default stored in storage
    // constant variable are part of solidity bytecode itself
    // variables inside functions are also not added to storage, they only exist for the duration of functions
    uint256 public constant minimumUSD = 5e18; // This is done to reduce gas cost

    address[] public s_funders;

    mapping(address funder => uint256 amountFunded) public s_addressToAmountFunded;

    address private immutable i_owner; // Those whose values are only set once
    AggregatorV3Interface private s_priceFeed;

    constructor(address priceFeed) {
        i_owner = msg.sender;    
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    function fund() public payable {
        myvalue = myvalue + 2;
        // require(getConversionRate(msg.value) >= minimumUSD, "didn't send enough ETH");
        require(msg.value.getConversionRate(s_priceFeed) >= minimumUSD, "didn't send enough ETH");
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] = s_addressToAmountFunded[msg.sender] + msg.value;
        // What is a revert?
        // Undo any action that has been done and send the remaining gas back
    }

    function cheaperWithdraw() public onlyOwner {
        uint256 fundersLength = s_funders.length;
        for (uint256 funderIndex = 0; funderIndex < fundersLength; funderIndex++) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        // transfer
        // msg.sender = address
        // payable(msg.sender) = payable address
        payable (msg.sender).transfer(address(this).balance);

        // send
        bool sendSuccess = payable (msg.sender).send(address(this).balance);
        require(sendSuccess, "Send failed");

        // call
        (bool callSuccess, bytes memory dataReturned) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    function withdraw() public onlyOwner {
        // require(msg.sender == owner, "Must be owner!");

        for(uint256 funderIndex=0; funderIndex<s_funders.length; funderIndex++) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);

        // transfer
        // send
        // call

        // transfer
        // msg.sender = address
        // payable(msg.sender) = payable address
        payable (msg.sender).transfer(address(this).balance);

        // send
        bool sendSuccess = payable (msg.sender).send(address(this).balance);
        require(sendSuccess, "Send failed");

        // call
        (bool callSuccess, bytes memory dataReturned) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    modifier onlyOwner() {
        require(msg.sender == i_owner, "Sender is not owner!");
        // if (msg.sender != owner) { revert NotOwner(); }
        _;
    }

    // What happens if someone sends this contract ETH without calling fundMe

    // receive()
    receive() external payable {
        fund();
    }
    // fallback()
    fallback() external payable {
        fund();
    }

    function getVersion() public view returns(uint256) {
        // AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        // return priceFeed.version();
        return s_priceFeed.version();
    }

    function getAddressToAmountFunded(address fundingAddress) external view returns(uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getFunder(uint256 index) external view returns(address) {
        return s_funders[index];
    }

    function getOwner() external view returns(address) {
        return i_owner;
    }
}
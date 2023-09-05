// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// This line is not working in our editor so we need to install it
// forge install smartcontractkit/chainlink-brownie-contracts
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    // This function is used to get the price of Ether
    function getPrice(AggregatorV3Interface priceFeed) internal view returns(uint256) {
        // Address 0x694AA1769357215DE4FAC081bf1f309aDC325306
        // ABI 
        // AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        (, int256 price,,,) = priceFeed.latestRoundData();
        
        // Solidity does not work with decimals
        // Price of ETH in USD
        // 2000.00000000
        return uint256(price * 1e10);        
    }

    function getConversionRate(uint256 ethAmount, AggregatorV3Interface priceFeed) internal view returns(uint256) {
        // 1 ETH?
        // 2000_000000000000000000
        uint256 ethPrice = getPrice(priceFeed);
        // (2000_000000000000000000 * 1_000000000000000000) / 1e18
        // $2000 = 1 ETH
        // Ofcourse it will be 2000 dollars with 18 decimal places
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;
        return ethAmountInUsd;
    }
}
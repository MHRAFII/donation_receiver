// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
error notOwner();


contract fundReceiver {

    address[] public funders;
    mapping(address Funder => uint256 amount) public addressToAmount;
    address internal  immutable i_owner;

    function fund() public payable {

        funders.push(msg.sender);
        addressToAmount[msg.sender] = addressToAmount[msg.sender] + msg.value;
    }

    function getPrice() public view returns(uint256) {

         AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        (,int256 price,,,) = priceFeed.latestRoundData();

        return uint256(price * 1e10);
    }

    function getConversionRate(uint256 ethAmount) public view returns(uint256) {
        uint256 ethprice = getPrice();
        uint256 ethInUSD = (ethprice * ethAmount) / 1e18;
        return ethInUSD;
    }

    function withDraw() public onlyOwener {
        for(uint256 i = 0; i < funders.length; i++) {
            address funder = funders[i];
            addressToAmount[funder] = 0;
        }
        funders = new address[](0);

        (bool success,) = payable(msg.sender).call{value: address(this).balance}("");
        require(success);
    }







    constructor() {
        i_owner = msg.sender;
    }
    receive() external payable { 
        fund();
    }
    fallback() external payable {
        fund();
     }
    modifier onlyOwener() {
        if(msg.sender != i_owner) {
            revert notOwner();
        }
        _;
    }

     

}

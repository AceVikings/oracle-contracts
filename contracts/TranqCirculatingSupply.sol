// SPDX-License-Identifier: MIT

pragma solidity >=0.6.6;

import "openzeppelin-solidity/contracts/access/Ownable.sol";
import '@uniswap/v2-periphery/contracts/libraries/SafeMath.sol';
import '@uniswap/v2-periphery/contracts/interfaces/IERC20.sol';

import "./UniswapPairTwapOracle.sol";

/**
 * @title TRANQ circulating supply calculator
 * @author Tranquil Finance
 * @notice Calculates the circulating supply of TRANQ on-chain
 */
contract TranqCirculatingSupply is Ownable {
    using SafeMath for uint256;

    IERC20 public tranqToken;
    address[] public nonCirculatingAddresses;

    /**
     * @notice Sets the canonical TRANQ token
     * @param _tranqToken The TRANQ token.
     */
    function setTranqToken(IERC20 _tranqToken) external onlyOwner {
      tranqToken = _tranqToken;
    }

    /**
     * @notice Adds an address whose TRANQ balance is considered non-circulating.
     * @param _nonCirculatingAddress The non-circulating address.
     */
    function addNonCirculatingAddress(address _nonCirculatingAddress) external onlyOwner {
      nonCirculatingAddresses.push(_nonCirculatingAddress);
    }

    /**
     * @return The number of non-circulating addresses.
     */
    function nonCirculatingAddressCount() external view returns (uint256) {
      return nonCirculatingAddresses.length;
    }

    /**
     * @return The circulating supply of TRANQ.
     */
    function circulatingSupply() external view returns (uint256) {
      uint256 supply = tranqToken.totalSupply();

      for (uint i = 0; i < nonCirculatingAddresses.length; ++i) {
        uint256 addressBalance = tranqToken.balanceOf(nonCirculatingAddresses[i]);
        supply = SafeMath.sub(supply, addressBalance);        
      }

      return supply;
    }
}
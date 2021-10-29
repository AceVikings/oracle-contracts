// SPDX-License-Identifier: MIT

pragma solidity >=0.6.6;

import "./UniswapOracle.sol";
import "./FallbackOracle.sol";

import "openzeppelin-solidity/contracts/access/Ownable.sol";


/**
 * @dev Simple interface for a TqToken.
 */
interface TqToken {
    function underlying() external view returns (address);
    function symbol() external view returns (string memory);
}

/**
 * @dev Simple interface for a PriceOracle expected by the Comptroller.
 */
abstract contract PriceOracle {
    bool public constant isPriceOracle = true;

    function getUnderlyingPrice(TqToken tqToken) external view virtual returns (uint);
}

/**
 * @title Top-level price oracle for Tranquil Finance
 * @author Tranquil Finance
 * @notice This oracle uses two sub-oracles, UniswapOracle and FallbackOracle, to
 * get the price of supported assets. The main price is queried from the UniswapOracle, but 
 * when the price is not reliable, we use the FallbackOracle.
 */
contract TranquilPriceOracle is PriceOracle, Ownable {
    UniswapOracle public uniswapOracle;
    FallbackOracle public fallbackOracle;
    address public woneAddress;

    constructor(UniswapOracle _uniswapOracle, 
                FallbackOracle _fallbackOracle, 
                address _woneAddress) public {
      uniswapOracle = _uniswapOracle;
      fallbackOracle = _fallbackOracle;
      woneAddress = _woneAddress;
    }

    function setUniswapOracle(UniswapOracle _uniswapOracle) external onlyOwner {
      uniswapOracle = _uniswapOracle;
    }

    function setFallbackOracle(FallbackOracle _fallbackOracle) external onlyOwner {
      fallbackOracle = _fallbackOracle;
    }

    /**
      * @notice Get the underlying price of a tqToken asset
      * @param tqToken The tqToken to get the underlying price of
      * @return The underlying asset price mantissa (scaled by 1e18).
      */
    function getUnderlyingPrice(TqToken tqToken) external view override returns (uint) {
      // Use WONE as the underlying token if the market is for ONE.
      address erc20TokenAddress;
      if (compareStrings(tqToken.symbol(), "tqONE")) {
        erc20TokenAddress = woneAddress;
      } else {
        erc20TokenAddress = tqToken.underlying();
      }

      if (uniswapOracle.hasReliablePrice(erc20TokenAddress)) {
        return uniswapOracle.getPrice(erc20TokenAddress);
      } else {
        return fallbackOracle.getPrice(erc20TokenAddress);
      }
    }

    function compareStrings(string memory a, string memory b) internal pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }
}
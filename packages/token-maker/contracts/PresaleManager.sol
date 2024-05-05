// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./CommonERC20.sol";
import {IAlgebraPool} from "@cryptoalgebra/integral-core/contracts/interfaces/IAlgebraPool.sol";
import {INonfungiblePositionManager} from "@cryptoalgebra/integral-periphery/contracts/interfaces/INonfungiblePositionManager.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract PresaleManager is Ownable, IERC721Receiver {
    mapping(address => bool) public presaleMakers;
    address public releaseExecutor;
    address public immutable WNativeToken;
    mapping(address => Presale) public presales;
    INonfungiblePositionManager public positionManager;
    mapping(uint256 => address) public tokenMakers;


    constructor(address _WNativeToken, INonfungiblePositionManager _positionManager) Ownable() {
        WNativeToken = _WNativeToken;
        positionManager = _positionManager;
    }

    function putPresaleMaker(address presaleMaker) external onlyOwner {
        presaleMakers[presaleMaker] = true;
    }

    function removePresaleMaker(address presaleMaker) external onlyOwner {
        presaleMakers[presaleMaker] = false;
    }

    function putReleaseExecutor(address _releaseExecutor) external onlyOwner {
        releaseExecutor = _releaseExecutor;
    }

    function putPresale(Presale memory presale) external {
        require(presaleMakers[msg.sender], "");
        presales[presale.pair] = presale;
        emit PresaleCreated(
            presale.name,
            presale.symbol,
            presale.presaleAmount,
            presale.token,
            presale.pair,
            presale.totalSupply,
            presale.minterAllocation,
            presale.data
        );
    }

    function getPresale(address pair) external view returns (Presale memory) {
        return presales[pair];
    }

    function getProgress(address poolAddress) public view returns (uint256) {
        IAlgebraPool pool = IAlgebraPool(poolAddress);
        Presale memory presale = presales[poolAddress];
        (uint256 reserve0, uint256 reserve1) = pool.getReserves();

        if (pool.token0() == WNativeToken) {
            return (100 * reserve0) / presale.presaleAmount;
        } else {
            return (100 * reserve1) / presale.presaleAmount;
        }
    }

    function exit(address poolAddress) external {
        require(msg.sender == owner() || msg.sender == releaseExecutor, "PresaleManager: FORBIDDEN");
        uint256 tokenId = presales[poolAddress].positionTokenId;
        positionManager.transferFrom(address(this), msg.sender, tokenId);
    }

    function onERC721Received(
        address operator,
        address,
        uint256 tokenId,
        bytes calldata
    ) external returns (bytes4) {
        return this.onERC721Received.selector;
    }

    event PresaleCreated(
        string name,
        string symbol,
        uint256 presaleAmount,
        address token,
        address pairAddress,
        uint256 totalSupply,
        uint256 minterAllocation,
        string data
    );
}

struct Presale {
    string name;
    string symbol;
    uint256 presaleAmount;
    address token;
    address pair;
    uint256 totalSupply;
    uint256 minterAllocation;
    string data;
    uint256 positionTokenId;
    bool released;
}
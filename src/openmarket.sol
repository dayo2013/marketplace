// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "solmate/tokens/ERC721.sol";
import "openzeppelin-contracts/contracts/utils/Strings.sol";
import "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import "openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";
import "openzeppelin-contracts/contracts/utils/Counters.sol";



contract Openmarket {
    using ECDSA for bytes32;
    using Counters for Counters.Counter;

    enum OrderStatus { Inactive, Active }

    struct Order {
        address tokenOwner;
        address tokenAddress;
        uint256 tokenId;
        uint256 price;
        OrderStatus status;
        uint256 deadline;
        bytes signature;
    }

    mapping(uint256 => Order) public orders;
    Counters.Counter private orderIdCounter;

    modifier onlyTokenOwner(uint256 orderId) {
        require(msg.sender == orders[orderId].tokenOwner, "Not the token owner");
        _;
    }

    modifier onlyActiveOrder(uint256 orderId) {
        require(orders[orderId].status == OrderStatus.Active, "Order is not active");
        _;
    }

    modifier onlyBeforeDeadline(uint256 orderId) {
        require(block.timestamp <= orders[orderId].deadline, "Order has expired");
        _;
    }

    event OrderCreated(uint256 orderId, address tokenOwner, address tokenAddress, uint256 tokenId, uint256 price, uint256 deadline);
    event OrderCancelled(uint256 orderId);
    event OrderFulfilled(uint256 orderId, address buyer);

    function createOrder(
        address _tokenAddress,
        uint256 _tokenId,
        uint256 _price,
        uint256 _deadline,
        bytes memory _signature
    ) external {
        require(_price > 0, "Price must be greater than zero");
        require(_deadline > block.timestamp, "Deadline must be in the future");

        bytes32 orderHash = keccak256(abi.encodePacked(_tokenAddress, _tokenId, _price, msg.sender, _deadline));
        require(orderHash.recover(_signature) == msg.sender, "Invalid signature");

        orders[orderIdCounter.current()] = Order({
            tokenOwner: msg.sender,
            tokenAddress: _tokenAddress,
            tokenId: _tokenId,
            price: _price,
            status: OrderStatus.Active,
            deadline: _deadline,
            signature: _signature
        });

        emit OrderCreated(
            orderIdCounter.current(),
            msg.sender,
            _tokenAddress,
            _tokenId,
            _price,
            _deadline
        );

        orderIdCounter.increment();
    }

    function cancelOrder(uint256 orderId) external onlyTokenOwner(orderId) onlyActiveOrder(orderId) {
        orders[orderId].status = OrderStatus.Inactive;
        emit OrderCancelled(orderId);
    }

    function fulfillOrder(uint256 orderId) external payable onlyActiveOrder(orderId) onlyBeforeDeadline(orderId) {
        require(msg.value == orders[orderId].price, "Incorrect payment amount");

        
        IERC721(orders[orderId].tokenAddress).transferFrom(orders[orderId].tokenOwner, msg.sender, orders[orderId].tokenId);

        
        payable(orders[orderId].tokenOwner).transfer(msg.value);


        orders[orderId].status = OrderStatus.Inactive;

        emit OrderFulfilled(orderId, msg.sender);
    }

}
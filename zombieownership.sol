pragma solidity >=0.5.0 <0.6.0;

import "./zombieattack.sol";
import "./erc721.sol";

/// @title A contract that manages transfering zombie ownership
/// @author Beed
/// @dev Compliant with OpenZeppelin's implementation of the ERC721 spec draft
contract ZombieOwnership is ZombieAttack, ERC721 {

    mapping (uint => address) zombieApprovals;

    /// @notice Check the zombies balance of an address
    /// @param _owner the address to check.
    /// @return _ the number of zombies owned
    function balanceOf(address _owner) external view returns (uint256) {
        return ownerZombieCount[_owner];
    }

    /// @notice Get the owner of a zombie
    /// @param _tokenId the token to check
    /// @return _ the owner
    function ownerOf(uint256 _tokenId) external view returns (address) {
        return zombieToOwner[_tokenId];
    }

    /// @notice transfer a token
    /// @param _from the address to take from
    /// @param _to the address to send to
    /// @param _tokenId the token to transfer
    function _transfer(address _from, address _to, uint256 _tokenId) private {
        ownerZombieCount[_to] = ownerZombieCount[_to].add(1);
        ownerZombieCount[_from] = ownerZombieCount[_from].sub(1);
        zombieToOwner[_tokenId] = _to;
        emit Transfer(_from,_to,_tokenId);
    }

    /// @notice verify that the sender is authorized and transfer a token
    /// @param _from the address to take from
    /// @param _to the address to send to
    /// @param _tokenId the token to transfer
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable {
        require(zombieToOwner[_tokenId] == msg.sender || zombieApprovals[_tokenId] == msg.sender);
        _transfer(_from,_to,_tokenId);
    }

    /// @notice give approval to an address to transfer a token
    /// @param _approved the address to take from
    /// @param _tokenId the token to transfer
    function approve(address _approved, uint256 _tokenId) external payable onlyOwnerOf(_tokenId){
        zombieApprovals[_tokenId] = _approved;
        emit Approval(msg.sender,_approved,_tokenId);
    }
}

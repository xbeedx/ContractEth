# ERC721 & Crypto Collectibles 
- [Token](#token)
- [Why does it matter?](#why-does-it-matter)
- [Other token standards](#other-token-standards)
- [ERC721 Standard, Multiple Inheritance](#erc721-standard-multiple-inheritance)
- [Implementing a token contract](#implementing-a-token-contract)
- [balanceOf & ownerOf](#balanceof--ownerof)
  - [balanceOf](#balanceof)
  - [ownerOf](#ownerof)
- [ERC721: Transfer Logic](#erc721-transfer-logic)
- [Contract security enhancements: Overflows and Underflows](#contract-security-enhancements-overflows-and-underflows)
- [Using SafeMath](#using-safemath)
- [Syntax for comments](#syntax-for-comments)

<br>

# Token
 A token on Ethereum is basically just a smart contract that follows some common rules — namely it implements a standard set of functions that all other token contracts share, such as transferFrom(address _from, address _to, uint256 _amount) and balanceOf(address _owner).

Internally the smart contract usually has a mapping, mapping(address => uint256) balances, that keeps track of how much balance each address has.

So basically a token is just a contract that keeps track of who owns how much of that token, and some functions so those users can transfer their tokens to other addresses.

<br>

# Why does it matter?

Since all ERC20 tokens share the same set of functions with the same names, they can all be interacted with in the same ways.

This means if you build an application that is capable of interacting with one ERC20 token, it's also capable of interacting with any ERC20 token. That way more tokens can easily be added to your app in the future without needing to be custom coded. You could simply plug in the new token contract address, and boom, your app has another token it can use.

One example of this would be an exchange. When an exchange adds a new ERC20 token, really it just needs to add another smart contract it talks to. Users can tell that contract to send tokens to the exchange's wallet address, and the exchange can tell the contract to send the tokens back out to users when they request a withdraw.

The exchange only needs to implement this transfer logic once, then when it wants to add a new ERC20 token, it's simply a matter of adding the new contract address to its database.


<br>

# Other token standards 

ERC20 tokens are cool for tokens that act like currencies. 
There's another token standard that's a much better fit for crypto-collectibles and they're called ERC721 tokens.

ERC721 tokens are not interchangeable since each one is assumed to be unique and are not divisible. You can only trade them in whole units, and each one has a unique ID.

<br>

# ERC721 Standard, Multiple Inheritance 

```solidity
contract ERC721 {
  event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
  event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

  function balanceOf(address _owner) external view returns (uint256);
  function ownerOf(uint256 _tokenId) external view returns (address);
  function transferFrom(address _from, address _to, uint256 _tokenId) external payable;
  function approve(address _approved, uint256 _tokenId) external payable;
}
```

<br>

# Implementing a token contract

When implementing a token contract, the first thing we do is copy the interface to its own Solidity file and import it, import "./erc721.sol";. 

Then we have our contract inherit from it, and we override each method with a function definition.

in Solidity, your contract can inherit from multiple contracts as follows:
```solidity
contract SatoshiNakamoto is NickSzabo, HalFinney {
  // Omg, the secrets of the universe revealed!
}
```

<br>

# balanceOf & ownerOf

## balanceOf 
This function simply takes an address, and returns how many tokens that address owns.

## ownerOf 
This function takes a token ID , and returns the address of the person who owns it.

<br>

# ERC721: Transfer Logic

Note that the ERC721 spec has 2 different ways to transfer tokens:
```solidity
function transferFrom(address _from, address _to, uint256 _tokenId) external payable;
```
and
```solidity
function approve(address _approved, uint256 _tokenId) external payable;

function transferFrom(address _from, address _to, uint256 _tokenId) external payable;
```
The first way is the token's owner calls transferFrom with his address as the _from parameter, the address he wants to transfer to as the _to parameter, and the _tokenId of the token he wants to transfer.

The second way is the token's owner first calls approve with the address he wants to transfer to, and the _tokenID . The contract then stores who is approved to take a token, usually in a mapping (uint256 => address). Then, when the owner or the approved address calls transferFrom, the contract checks if that msg.sender is the owner or is approved by the owner to take the token, and if so it transfers the token to him.

Notice that both methods contain the same transfer logic. In one case the sender of the token calls the transferFrom function; in the other the owner or the approved receiver of the token calls it.
So it makes sense for us to abstract this logic into its own private function, _transfer, which is then called by transferFrom.

<br>

# Contract security enhancements: Overflows and Underflows

We're going to look at one major security feature you should be aware of when writing smart contracts: Preventing overflows and underflows.

### What's an overflow?

Let's say we have a uint8, which can only have 8 bits. That means the largest number we can store is binary 11111111 (or in decimal, 2^8 - 1 = 255).

If we stole 256 in a uint8, we cause it to overflow — so number is counterintuitively now equal to 0 even though we increased it. (If you add 1 to binary 11111111, it resets back to 00000000, like a clock going from 23:59 to 00:00).

An underflow is similar, where if you subtract 1 from a uint8 that equals 0, it will now equal 255 (because uints are unsigned, and cannot be negative).

<br>

# Using SafeMath

To prevent this, OpenZeppelin has created a library called SafeMath that prevents these issues by default.

A library is a special type of contract in Solidity. One of the things it is useful for is to attach functions to native data types.

For example, with the SafeMath library, we'll use the syntax using SafeMath for uint256. The SafeMath library has 4 functions — add, sub, mul, and div. And now we can access these functions from uint256 as follows:
```solidity
using SafeMath for uint256;

uint256 a = 5;
uint256 b = a.add(3); // 5 + 3 = 8
uint256 c = a.mul(2); // 5 * 2 = 10

```
For our purposes, libraries allow us to use the using keyword, which automatically tacks on all of the library's methods to another data type.

Note that the mul and add functions each require 2 arguments, but when we declare using SafeMath for uint, the uint we call the function on (a) is automatically passed in as the first argument.
```solidity
function add(uint256 a, uint256 b) internal pure returns (uint256) {
  uint256 c = a + b;
  assert(c >= a);
  return c;
}
```
Basically add just adds 2 uints like +, but it also contains an assert statement to make sure the sum is greater than a. This protects us from overflows.

Assert is similar to require, where it will throw an error if false. 

The difference between assert and require is that require will refund the user the rest of their gas when a function fails, whereas assert will not. 

So most of the time you want to use require in your code; assert is typically used when something has gone horribly wrong with the code (like a uint overflow).

<br>

# Syntax for comments

Commenting in Solidity is just like JavaScript.
Just add double // anywhere and you're commenting. 

We also have multi-line comments: /* comment */

The standard in the Solidity community is to use a format called natspec, which looks like this:
```solidity
/// @title A contract for basic math operations
/// @author H4XF13LD MORRIS 
/// @notice For now, this contract just adds a multiply function
contract Math {
  /// @notice Multiplies 2 numbers together
  /// @param x the first uint.
  /// @param y the second uint.
  /// @return z the product of (x * y)
  /// @dev This function does not currently check for overflows
  function multiply(uint x, uint y) returns (uint z) {
    // This is just a normal comment, and won't get picked up by natspec
    z = x * y;
  }
}
```
@title and @author are straightforward. <br>
@notice explains to a user what the contract / function does. <br>
@dev is for explaining extra details to developers. <br>
@param and @return are for describing what each parameter and return value of a function are for. <br>

Note that you don't always have to use all of these tags for every function — all tags are optional. But at the very least, leave a @dev note explaining what each function does.


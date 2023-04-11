# Making the Zombie Factory

- [State Variables & Integers](#state-variables--integers)
- [Math Operations](#math-operations)
- [Structs](#structs)
- [Arrays](#arrays)
    - [Public Arrays](#public-arrays)
- [Function Declarations](#function-declarations)
- [Working with Structs and Arrays](#working-with-structs-and-arrays)
- [Private/Public functions](#privatepublic-functions)
- [More on functions](#more-on-functions)
    - [Return values](#return-values)
    - [Function modifiers](#function-modifiers)
- [Keccak256 and Typecasting](#keccak256-and-typecasting)
    - [Keccak256](#keccak256)
    - [Typecasting](#typecasting)
- [Events](#events)
- [Web3.js](#web3js)



# State Variables & Integers

**States variables** are permanently stored in contract storage. This means they’re written to the Ethereum blockchain. 
```solidity
contract Example {
  // This will be stored permanently in the blockchain
  uint myUnsignedInteger = 100;
}
```
The uint data type is an unsigned integer, meaning it’s value must be non-negative. int is for signed integers.  
Note: In solidity uint is an alias for uint256, a 256 bits unsigned integer. You can declare uint with less bits – uint8, uint16, uint32… 

<br>

# Math Operations

Math in Solidity is pretty straightforward. The following operations are the same as in most programming languages:
- Addition: x + y
- Subtraction: x - y
- Multiplication: x * y
- Division: x / y
- Modulus / remainder: x % y

Solidity also supports exponential operator 
```solidity
uint x = 5 ** 2; // equal to 5^2 = 25
```

<br>

# Structs

Structs allow you to create more complicated data types that have multiple properties.
```solidity
struct Person {
  uint age;
  string name;
}
```

<br>

# Arrays

When you want a collection of something, you can use an array. There are two types of arrays in Solidity: **fixed** arrays and **dynamic** arrays:
```solidity
// Array with a fixed length of 2 elements:
uint[2] fixedArray;
// another fixed Array, can contain 5 strings:
string[5] stringArray;
// a dynamic Array - has no fixed size, can keep growing:
uint[] dynamicArray;
```

You can also create an array of **structs**. Using the previous chapter's Person struct:
```solidity
Person[] people; // dynamic Array, we can keep adding to it
```

## Public Arrays
You can declare an array as public, and Solidity will automatically create a getter method for it. The syntax looks like:
```solidity
Person[] public people;
```

<br>

# Function Declarations

A function declaration in solidity looks like the following:
```solidity
function eatHamburgers(string memory _name, uint _amount) public {
...
}
```
We're providing instructions about where the _name variable should be stored- in **memory**. This is required for all reference types such as arrays, structs, mappings, and strings.

<br>

# Working with Structs and Arrays

```solidity
// create a New Person:
Person satoshi = Person(172, "Satoshi");

// Add that person to the Array:
people.push(satoshi);
```

We can also combine these together and do them in one line of code to keep things clean:
```solidity
people.push(Person(16, "Vitalik"));
```

*Note that array.push() add something to the end of the array.*

<br>

# Private/Public functions 

In Solidity, functions are **public** by default. This means anyone (or any other contract) can call your contract's function and execute its code.

Obviously, this isn't always desirable, and can make your contract vulnerable to attacks. Thus, it's good practice to mark your functions as **private** by default, and then only make **public** the functions you want to expose to the world.

it's convention to start **private** function names with an underscore (_).

<br>

# More on functions

## 	Return values
To return a value from a function, the declaration looks like this:
```solidity
string greeting = "What's up dog";

function sayHello() public returns (string memory) {
  return greeting;
}
```

## 	Function modifiers

The above function doesn't actually change state in Solidity — e.g. it doesn't change any values or write anything.

So in this case we could declare it as a **view** function, meaning it's only viewing the data but not modifying it:
```solidity
function sayHello() public view returns (string memory) {}
```
Solidity also contains **pure** functions, which means you're not even accessing any data in the app. Consider the following:
```solidity
function _multiply(uint a, uint b) private pure returns (uint) {
  return a * b;
}
```

<br>

# Keccak256 and Typecasting 

## Keccak256

Ethereum has the hash function **keccak256** built in, which is a version of SHA3. A hash function basically maps an input into a random 256-bit hexadecimal number. A slight change in the input will cause a large change in the hash.

Also important, **keccak256** expects a single parameter of type **bytes**. This means that we have to "pack" any parameters before calling **keccak256**:
```solidity
//6e91ec6b618bb462a4a6ee5aa2cb0e9cf30f7a052bb467b0ba58b8748c00d2e5
keccak256(abi.encodePacked("aaaab"));
//b1f078126895a1424524de5321b339ab00408010b7cf0e6ed451514981e58aa9
keccak256(abi.encodePacked("aaaac"));
``` 

*Note: Secure random-number generation in blockchain is a very difficult problem. Our method here is insecure, but since security isn't top priority for our Zombie DNA, it will be good enough for our purposes.*

## Typecasting
Sometimes you need to convert between data types. Take the following example:
```solidity
uint8 a = 5;
uint b = 6;
// throws an error because a * b returns a uint, not uint8:
uint8 c = a * b;
// we have to typecast b as a uint8 to make it work:
uint8 c = a * uint8(b);
```

<br>

# Events

**Events** are a way for your contract to communicate that something happened on the blockchain to your app front-end, which can be 'listening' for certain events and take action when they happen.

```solidity
// declare the event
event IntegersAdded(uint x, uint y, uint result);

function add(uint _x, uint _y) public returns (uint) {
  uint result = _x + _y;
  // fire an event to let the app know the function was called:
  emit IntegersAdded(_x, _y, result);
  return result;
}
```

Your app front-end could then listen for the event. A JavaScript implementation would look something like:

```js
YourContract.IntegersAdded(function(error, result) {
  // do something with result
})
```

*id. array.push() returns a uint of the new length of the array*

<br>

# Web3.js

Our Solidity contract is complete! Now we need to write a JavaScript frontend that interacts with the contract. Ethereum has a JavaScript library called **Web3.js**.
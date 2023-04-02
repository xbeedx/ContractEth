# App Front-ends & Web3.js
- [What is Web3.js?](#what-is-web3js)
- [Getting started](#getting-started)
- [Web3 Providers](#web3-providers)
- [Infura](#infura)
- [Metamask](#metamask)
- [Using Metamask's web3 provider](#using-metamasks-web3-provider)
- [Talking to Contracts](#talking-to-contracts)
  - [Contract Address](#contract-address)
  - [Contract ABI](#contract-abi)
- [Instantiating a Web3.js Contract](#instantiating-a-web3js-contract)
- [Calling Contract Functions](#calling-contract-functions)
  - [Call](#call)
  - [Send](#send)
- [Getting the user's account in MetaMask](#getting-the-users-account-in-metamask)
- [What's a Wei?](#whats-a-wei)
- [Subscribing to Events](#subscribing-to-events)
- [Using indexed](#using-indexed)
- [Querying past events](#querying-past-events)



<br>

# What is Web3.js?
<br>

Remember, the Ethereum network is made up of nodes, with each containing a copy of the blockchain. When you want to call a function on a smart contract, you need to query one of these nodes and tell it:
- The address of the smart contract
- The function you want to call, and
- The variables you want to pass to that function.

Ethereum nodes only speak a language called JSON-RPC, which isn't very human-readable. 

A query to tell the node you want to call a function on a contract looks something like this:
``` json
{"jsonrpc":"2.0","method":"eth_sendTransaction","params":[{"from":"0xb60e8dd61c5d32be8058bb8eb970870f07233155","to":"0xd46e8dd67c5d32be8058bb8eb970870f07244567","gas":"0x76c0","gasPrice":"0x9184e72a000","value":"0x9184e72a","data":"0xd46e8dd67c5d32be8d46e8dd67c5d32be8058bb8eb970870f072445675058bb8eb970870f072445675"}],"id":1}
```
Luckily, Web3.js hides these nasty queries below the surface, so you only need to interact with a convenient and easily readable JavaScript interface.

Instead of needing to construct the above query, calling a function in your code will look something like this:
``` js
CryptoZombies.methods.createRandomZombie("Vitalik Nakamoto")
  .send({ from: "0xb60e8dd61c5d32be8058bb8eb970870f07233155", gas: "3000000" })

```

<br>


# Getting started

Depending on your project's workflow, you can add Web3.js to your project using most package tools:
```
// Using NPM
npm install web3

// Using Yarn
yarn add web3

// Using Bower
bower install web3

// ...etc.

```

Or you can simply download the minified .js file from github and include it in your project:
``` html
<script language="javascript" type="text/javascript" src="web3.min.js"></script>
```

<br>

# Web3 Providers

The first thing we need is a Web3 Provider.

Remember, Ethereum is made up of nodes that all share a copy of the same data. Setting a Web3 Provider in Web3.js tells our code which node we should be talking to handle our reads and writes. It's kind of like setting the URL of the remote web server for your API calls in a traditional web app.

You could host your own Ethereum node as a provider. However, there's a third-party service that makes your life easier so you don't need to maintain your own Ethereum node in order to provide a DApp for your users — Infura.

<br>

# Infura

Infura is a service that maintains a set of Ethereum nodes with a caching layer for fast reads, which you can access for free through their API. Using Infura as a provider, you can reliably send and receive messages to/from the Ethereum blockchain without needing to set up and maintain your own node.

You can set up Web3 to use Infura as your web3 provider as follows:

```js
    var web3 = new Web3(new Web3.providers.WebsocketProvider("wss://mainnet.infura.io/ws"));
```
However, since our DApp is going to be used by many users — and these users are going to WRITE to the blockchain and not just read from it — we'll need a way for these users to sign transactions with their private key.

<br>

# Metamask

Metamask is a browser extension for Chrome and Firefox that lets users securely manage their Ethereum accounts and private keys, and use these accounts to interact with websites that are using Web3.js. 

(If you haven't used it before, you'll definitely want to go and install it — then your browser is Web3 enabled, and you can now interact with any website that communicates with the Ethereum blockchain!).

And as a developer, if you want users to interact with your DApp through a website in their web browser (like we're doing with our CryptoZombies game), you'll definitely want to make it Metamask-compatible.

<br>

# Using Metamask's web3 provider

Metamask injects their web3 provider into the browser in the global JavaScript object web3. So your app can check to see if web3 exists, and if it does use web3.currentProvider as its provider.

Here's some template code provided by Metamask for how we can detect to see if the user has Metamask installed, and if not tell them they'll need to install it to use our app:
```js
window.addEventListener('load', function() {

  // Checking if Web3 has been injected by the browser (Mist/MetaMask)
  if (typeof web3 !== 'undefined') {
    // Use Mist/MetaMask's provider
    web3js = new Web3(web3.currentProvider);
  } else {
    // Handle the case where the user doesn't have web3. Probably
    // show them a message telling them to install Metamask in
    // order to use our app.
  }

  // Now you can start your app & access web3js freely:
  startApp()

})
```
You can use this boilerplate code in all the apps you create in order to require users to have Metamask to use your DApp.

<sub>Note: There are other private key management programs your users might be using besides MetaMask, such as the web browser Mist. However, they all implement a common pattern of injecting the variable web3, so the method we describe here for detecting the user's web3 provider will work for these as well. <sub>

<br>

# Talking to Contracts

Now that we've initialized Web3.js with MetaMask's Web3 provider, let's set it up to talk to our smart contract.

Web3.js will need 2 things to talk to your contract: its address and its ABI.

<br>

## Contract Address
After you finish writing your smart contract, you will compile it and deploy it to Ethereum.
After you deploy your contract, it gets a fixed address on Ethereum where it will live forever.
You'll need to copy this address after deploying in order to talk to your smart contract.

## Contract ABI
The other thing Web3.js will need to talk to your contract is its ABI.
ABI stands for Application Binary Interface. Basically it's a representation of your contracts' methods in JSON format that tells Web3.js how to format function calls in a way your contract will understand.
When you compile your contract to deploy to Ethereum, the Solidity compiler will give you the ABI, so you'll need to copy and save this in addition to the contract address.

<br>

# Instantiating a Web3.js Contract

Once you have your contract's address and ABI, you can instantiate it in Web3 as follows:
```js
// Instantiate myContract
var myContract = new web3js.eth.Contract(myABI, myContractAddress);
````

<br>

# Calling Contract Functions

## Call
Call is used for view and pure functions. It only runs on the local node, and won't create a transaction on the blockchain. 

Using Web3.js, you would call a function named myMethod with the parameter 123 as follows:
```js
myContract.methods.myMethod(123).call()
```

## Send
Send will create a transaction and change data on the blockchain. 

You'll need to use send for any functions that aren't view or pure. Using Web3.js, you would send a transaction calling a function named myMethod with the parameter 123 as follows:
```js
myContract.methods.myMethod(123).send()
```

<br>

# Getting the user's account in MetaMask

MetaMask allows the user to manage multiple accounts in their extension.
We can see which account is currently active on the injected web3 variable via:

```js
var userAccount = web3.eth.accounts[0]
```
Because the user can switch the active account at any time in MetaMask, our app needs to monitor this variable to see if it has changed and update the UI accordingly. 

When they change their account in MetaMask, we'll want to update the page for the new account they've selected.

We can do that with a setInterval loop as follows:
```js
var accountInterval = setInterval(function() {
  // Check if account has changed
  if (web3.eth.accounts[0] !== userAccount) {
    userAccount = web3.eth.accounts[0];
    // Call some function to update the UI with the new account
    updateInterface();
  }
}, 100);
```
What this does is check every 100 milliseconds to see if userAccount is still equal web3.eth.accounts[0] (i.e. does the user still have that account active). 

If not, it reassigns userAccount to the currently active account, and calls a function to update the display.

<br>

# What's a Wei?

A wei is the smallest sub-unit of Ether — there are 10^18 wei in one ether.
That's a lot of zeroes to count — but luckily Web3.js has a conversion utility that does this for us.
```js
// This will convert 1 ETH to Wei
web3js.utils.toWei("1");
```

<br>

# Subscribing to Events

In Web3.js, you can subscribe to an event so your web3 provider triggers some logic in your code every time it fires:
```js
cryptoZombies.events.NewZombie()
.on("data", function(event) {
  let zombie = event.returnValues;
  // We can access this event's 3 return values on the `event.returnValues` object:
  console.log("A new zombie was born!", zombie.zombieId, zombie.name, zombie.dna);
}).on("error", console.error);
```
What if we only wanted alerts for the current user?

<br>

# Using indexed

In order to filter events and only listen for changes related to the current user, our Solidity contract would have to use the indexed keyword.
```js
event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
```
In this case, because _from and _to are indexed, that means we can filter for them in our event listener in our front end:
```js
// Use `filter` to only fire this code when `_to` equals `userAccount`
cryptoZombies.events.Transfer({ filter: { _to: userAccount } })
.on("data", function(event) {
  let data = event.returnValues;
  // The current user just received a zombie!
  // Do something here to update the UI to show it
}).on("error", console.error);
```
As you can see, using events and indexed fields can be quite a useful practice for listening to changes to your contract and reflecting them in your app's front-end.

<br>

# Querying past events

We can even query past events using getPastEvents, and use the filters fromBlock and toBlock to give Solidity a time range for the event logs ("block" in this case referring to the Ethereum block number):
```js
cryptoZombies.getPastEvents("NewZombie", { fromBlock: 0, toBlock: "latest" })
.then(function(events) {
  // `events` is an array of `event` objects that we can iterate, like we did above
  // This code will get us a list of every zombie that was ever created
});
```
Because you can use this method to query the event logs since the beginning of time, this presents an interesting use case: Using events as a cheaper form of storage.

If you recall, saving data to the blockchain is one of the most expensive operations in Solidity.

But using events is much much cheaper in terms of gas.

The tradeoff here is that events are not readable from inside the smart contract itself. But it's an important use-case to keep in mind if you have some data you want to be historically recorded on the blockchain so you can read it from your app's front-end.
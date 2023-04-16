# Deploying DApps with Truffle
- [Truffle](#truffle)
    - [Install](#install)
    - [Error](#error)
- [Getting Started with Truffle](#getting-started-with-truffle)
    - [Truffle's Default Directory Structure](#truffles-default-directory-structure)
    - [truffle-hdwallet-provider](#truffle-hdwallet-provider)
- [Compiling the Source Code](#compiling-the-source-code)
    - [Using the Solidity Compiler](#using-the-solidity-compiler)
- [Migrations](#migrations)
    - [Creating a New Migration](#creating-a-new-migration)
- [Configuration Files](#configuration-files)
    - [Ethereum Test Networks](#ethereum-test-networks)
    - [The truffle.js(truffle-config.js) configuration file](#the-trufflejstruffle-configjs-configuration-file)
    - [Truffle's HD Wallet Provider](#truffle-hdwallet-provider)
    - [Set up Truffle for Rinkeby and Ethereum main net](#set-up-truffle-for-rinkeby-and-ethereum-main-net)


<br>

# Truffle

Truffle is the most popular blockchain development framework for good reason - it's packed with lots of useful features:

- easy smart contract compilation
- automated ABI generation
- integrated smart contract testing - there's even support for Mocha and Chai!
- support for multiple networks - code can be deployed to Rinkeby, Ethereum or even to Loom. 

## Install 

```
npm install truffle -g
```

<br>

## Error 

If you get the following error : 
```
 [Error: EACCES: permission denied, mkdir '/usr/local/lib/node_modules/truffle']
```
It is probly denying access because the node_module folder is owned by root.
First check who owns the directory.
```
ls -la /usr/local/lib/node_modules
```
```
drwxr-xr-x   3 root    wheel  192 Apr 16 15:10 .
```
This needs to be changed by changing root to your user but first run command below to check your current user.

```id-un``` OR ```whoami```

Then change owner
```
sudo chown -R [owner]:[owner] /usr/local/lib/node_modules
```
OR
```
sudo chown -R ownerName: /usr/local/lib/node_modules
```
OR
```
sudo chown -R $USER /usr/local/lib/node_modules
```

[reference](https://stackoverflow.com/questions/48910876/error-eacces-permission-denied-access-usr-local-lib-node-modules)
<br>

# Getting Started with Truffle

Now that we've installed Truffle, it's time to initialize our new project by running truffle init. All it is doing is to create a set of folders and config files with the following structure:
```
├── contracts
    ├── Migrations.sol
├── migrations
    ├── 1_initial_migration.js
└── test
truffle-config.js
truffle.js
```

## Truffle's Default Directory Structure

- **contracts**: this is the place where Truffle expects to find all our smart contracts. To keep the code organized, we can even create nested folders such as contracts/tokens.

- **migrations**: a migration is a JavaScript file that tells Truffle how to deploy a smart contract.

- **test**: here we are expected to put the unit tests which will be JavaScript or Solidity files. Remember, once a contract is deployed it can't be changed, making it essential that we test our smart contracts before we deploy them.

- truffle.js and truffle-config.js: config files used to store the network settings for deployment. Truffle needs two config files because on Windows having both truffle.js and truffle.exe in the same folder might generate conflicts. Long story short - if you are running Windows, it is advised to delete truffle.js and use truffle-config.js as the default config file. Check out Truffle's [official documentation](https://trufflesuite.com/docs/truffle/reference/configuration/) to further your understanding.

<br>

## truffle-hdwallet-provider

We can use Infura to deploy our code to Ethereum. This way, we can run the application without needing to set up our own Ethereum node or wallet. However, to keep things secure, Infura does not manage the private keys, which means it can't sign transactions on our behalf. Since deploying a smart contract requires Truffle to sign transactions, we are going to need a tool called truffle-hdwallet-provider. Its only purpose is to handle the transaction signing.

```
npm install truffle-hdwallet-provider
```

<br>

# Compiling the Source Code

The Ethereum Virtual Machine can't directly understand Solidity source code as we write it. Thus, we need to run a compiler that will "translate" our smart contract into machine-readable bytecode. The virtual machine then executes the **bytecode**, and completes the actions required by our smart contract.



## Using the Solidity Compiler

Now that we're talking about the Solidity compiler, we should mention that the devs managed to bake in some nifty features.

Let's pretend we'd want to modify the definition of the add function included in SafeMath:

```
function add(uint16 a, uint16 b) internal returns (uint16) {
    uint16 c = a + b;
    assert(c >= a);
    return c;
}
```
If we're going to compile this function, the Solidity compiler will throw a **warning**:
```
safemath.sol:110:11: Warning: Function state mutability can be restricted to pure
          function add(uint16 a, uint16 b) internal returns (uint16) {
          ^ (Relevant source part starts here and spans across multiple lines).
```

What the compiler is trying to say is that our function does not read or write from/to the blockchain and that we should use the pure modifier.

Making a function **pure** or **view** saves us gas. Since these functions are not going to modify the state of the blockchain, there is no need for miners to execute them. To put it in a few words, pure and view functions can be called for free.

Execute truffle compile. This command should create the build artifacts and place them in the ./build/contracts directory.

<br>

# Migrations

To deploy to Ethereum we will have to create something called a migration.

Migrations are JavaScript files that help Truffle deploy the code to Ethereum. Note that truffle init created a special contract called Migrations.sol that keeps track of the changes you're making to your code. The way it works is that the history of changes is saved onchain. Thus, there's no way you will ever deploy the same code twice.


## Creating a New Migration

We'll start from the file truffle init already created for us- ./contracts/1_initial_migration.js. Let's take a look at what's inside:

```
var Migrations = artifacts.require("./Migrations.sol");
module.exports = function(deployer) {
  deployer.deploy(Migrations);
};
```
First, the script tells Truffle that we'd want to interact with the Migrations contract.

Next, it exports a function that accepts an object called deployer as a parameter. This object acts as an interface between you (the developer) and Truffle's deployment engine.

<br>

# Configuration Files

## Ethereum Test Networks

Several public Ethereum test networks let you test your contracts for free before you deploy them to the main net (remember once you deploy a contract to the main net it can't be altered). These test networks use a different consensus algorithm to the main net (usually PoA), and Ether is free to encourage thorough testing.

We will be using Rinkeby, a public test network created by The Ethereum Foundation.

## The truffle.js(truffle-config.js) configuration file

Let's take a look at the default Truffle configuration file:
```
$ cat truffle.js *(OR truffle-config.js)*
/*
 * NB: since truffle-hdwallet-provider 0.0.5 you must wrap HDWallet providers in a
 * function when declaring them. Failure to do so will cause commands to hang. ex:
 *
 * mainnet: {
 *     provider: function() {
 *       return new HDWalletProvider(mnemonic, 'https://mainnet.infura.io/<infura-key>')
 *     },
 *     network_id: '1',
 *     gas: 4500000,
 *     gasPrice: 10000000000,
 *   },
 */
```

## Truffle's HD Wallet Provider

We want to edit our configuration file to use HDWalletProvider. To get this to work we'll add a line at the top of the file:

```js
const HDWalletProvider = require("truffle-hdwallet-provider");
```

Next, we'll create a new variable to store our mnemonic:
```js
const mnemonic = "onions carrots beans ...";
```


## Set up Truffle for Rinkeby and Ethereum main net

Next, to make sure Truffle "knows" the networks we want to deploy to, we will have to create two separate objects- one for Rinkeby and the other one for the Ethereum main net:

```js
networks: {
  // Configuration for mainnet
  mainnet: {
    provider: function () {
      // Setting the provider with the Infura Mainnet address and Token
      return new HDWalletProvider(mnemonic, "https://mainnet.infura.io/v3/YOUR_TOKEN")
    },
    network_id: "1"
  },
  // Configuration for rinkeby network
  rinkeby: {
    // Special function to setup the provider
    provider: function () {
      // Setting the provider with the Infura Rinkeby address and Token
      return new HDWalletProvider(mnemonic, "https://rinkeby.infura.io/v3/YOUR_TOKEN")
    },
    // Network id is 4 for Rinkeby
    network_id: 4
  }
```



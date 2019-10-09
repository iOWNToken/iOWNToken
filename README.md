<p align="center">
  <img src="./assets/iown-logo.png">
</p>

# iOWN Token

An ERC-223 Ethereum based token for iOWN project.

[![Telegram icon](./assets/telegram-follow.png)](https://t.me/iOWNToken)

## More information

More information about iOWN available here:

* [Website](https://www.iowntoken.com) - iOWN Token official website.
* [Whitepaper](https://www.iowntoken.com/whitepaper) - iOWN Token official whitepaper.

## Ethereum Token Address

iOWN Token is deployed on this address:
* [ERC223](https://etherscan.io/token/0x555d051538c7a13712f1f590fa6b4c176ca4529f) - iOWN Token ERC223 Contract Address.

Important: Original Smart contract (ERC20) was deployed here:
* [ERC20](https://etherscan.io/token/0x870ff0b9214ee330674dd143bc1836f8b11a627a) - iOWN Token ERC20 (Inactive Cotnract).

## About iOWN

iOWN is a Blockchain based crowdfunding platform concept coupled with a comprehensive ecosystem, 
aiming to bridge the gaps between investors and business seeking funding in tranditional investment environments.

The platform serves a marketplace for listing and participating in fundraising campaigns.
The ecosystem realizes the platform services including qualification process of campaigns, auditing, account, operations, etc...

### Prerequisites

This reporistory depends on the following:

* [node](https://nodejs.org) - NodeJS v11.8.0 (npm v6.9.0)
* [truffle](https://truffleframework.com) - Truffle Framework v5.0.13
* [Infura](https://infura.io) - Infura 

Packages should be pre-installed

Other requirements:

* [truffle-flattener](https://github.com/nomiclabs/truffle-flattener) - Truffle Flattener v1.3.0
* [EthLint](https://github.com/duaraghav8/Ethlint) - EthLint (Solium) v1.2.4

All steps and environment is based on Ubuntu 18.04

### Installing

Install and preparing:

```
npm install
```

## Compiling

Install and preparing:

```
truffle compile (--all)
```

### Migrations

Before running truffle migrate

The following files are required:

```
vi ~/.keys/owner.key
chmod 600 ~/.keys/owner.key
```

Infura configuration

```
vi ~/.keys/infura.key
chmod 600 ~/.keys/infura.key
```

Alternatively edit `truffle-config.js` to remove references for files

### Testing

(TODO) Add unit tests code to repo

## Deployment

Smart contracts can be deployed via truffle, but verification process will be troublesome on [Etherscan](https://etherscan.io) because of multi-file contarcts (despite flattening)

As such its recommended to "flatten" the contracts using tuffle-flattner:

```
truffle-flattener ./contracts/iown/IownToken.sol > ./build/IownToken-flattended.sol
```

Then you can use `./build/IownToken-flattended.sol` on [Remix](https://remix.ethereum.org) along with [MetaMask](https://metamask.io).
The same flattended file can then be used on etherscan verification process.

To generate constructor arguments (abi encoded), [HashEx](https://abi.hashex.org) can be used.

## Authors

* **Alexander Sayegh** - *Initial work* - [LinkedIn](https://www.linkedin.com/in/alexandersayegh/)

## Contact Us

You can also reach us here [info@iowntoken.com](mailto:info@iowntoken.com).

## License

This project is licensed under the MIT License.

## Acknowledgments

* Hat tip to anyone worked on OpenZeppelin, Ethereum and all frameworks and code used here
Remix

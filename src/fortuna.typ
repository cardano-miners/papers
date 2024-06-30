#import "@preview/unequivocal-ams:0.1.0": ams-article, theorem, proof

#show: ams-article.with(
  title: [Fortuna - A Randomness Beacon],
  authors: (
    (
      name: "Kasey White",
      department: [Survey Corps],
      organization: [Cardano Foundation],
      location: [Dammstrasse 16, 6300 Zug, CH],
      email: "kasey.white@cardanofoundation.org",
      url: "https://github.com/microproofs"
    ),
    (
      name: "Lucas Rosa",
      department: [Survey Corps],
      organization: [Cardano Foundation],
      location: [Dammstrasse 16, 6300 Zug, CH],
      email: "lucas.rosa@cardanofoundation.org",
      url: "https://rvcas.dev"
    ),
  ),
  abstract: "Fortuna is a Proof of Work protocol for verifying mining transactions on the Cardano blockchain. The protocol explores what the minimum moving parts are required to verify Proof of Work in a extremely limited environment like the PlutusVM. The work done with Fortuna could help inspire a new wave of Proof of Work protocols which are verifiable in a smart contract. For today, we will explore the Fortuna protocol and its possible use cases like randonmness and consensus in dApps on Cardano. We will also explore the FortunaV2 design and how it improves upon the FortunaV1 design. Finally we will go over the governance of FortunaV2 which allows Fortuna to mimic the upgradability that Bitcoin and other Proof of Work blockchains have.",
  bibliography: bibliography("fortuna.bib"),
)

= Why Fortuna?
There are dApps in DeFi (Decentralized Finance) that require sources of future randomness or some fair way to select a winner for consensus. On other chains, like Ethereum, one way dApps have enforced randomness is by depending on data from the block mined that is made available to the contract on execution. Note there is also VRFs via Chainlink on Ethereum too. In Cardano, a transaction does not have any notion of the block it is located in, so for any dApp the source for randomness must be determined in advance. This is where Fortuna comes in. Fortuna can act as a source of randomness for dApps on Cardano. Fortuna also can be leveraged for consensus algorithms on Cardano. A dApp can pay miners additional funds besides the protocol reward to determine ordering or selection on some consensus algorithm. This is a way to further incentivize the importance of the Fortuna protocol. An example of this is L2's which require some ordering mechanism when posting proofs of existing state to the main chain.


= What is Fortuna?

Fortuna is a protocol enforced by a spend and mint validator that verifies Proof of Work
transactions on the Cardano blockchain. By mimicing the attributes of
a Bitcoin block header inside a datum, Fortuna is able to dynamically adjust its difficulty
based on the demand of the network. This averages out to a Fortuna transaction
every 10 minutes. The Fortuna protocol pays out TUNA to the creator of the transaction
as a reward for their work. Fortuna's token is freely tradable within the Cardano ecosystem.

There are 3 core concepts behind how a proof of work algorithm works on-chain.

  1. The key concept behind Fortuna is taking a PoW alogorithm and isolating the validation of the "Work" done to be verifiable in a smart contract. Smart Contracts have a very limited execution and memory size budgets. On Cardano you can only pass in about a max of 14kb of information to a smart contract. Anything that does not fit into that size must be created on-chain or reworked to fit into the budget. In the case of FortunaV1 and FortunaV2, the validation of the work can be done via a hash of the previous Fortuna state and the miner nonce. This hash is then compared against a byte array formed from the current blocks difficulty.

  2. This leads us to the next part of Fortuna how tracks when a block was mined. In order to keep an average of 10 minutes per block the state must keep track of the time each time a block is mined. In Cardano, we are given a posix time range the transaction took place in. By placing a max range between the upper and lower bounds we can use the average to give us generally accurate estimates to the exact time a block was mined.

  3. The final part about Fortuna is the difficulty adjustment. The difficulty is currently adjusted based on a similar cadence to bitcoin, every 2016 blocks (an epoch). The time from the epoch is tracked and compared to the actual time of 2 weeks which is the expected time for 2016 blocks to be mined. The difficulty is adjusted based on the difference between the expected time and the actual time. The difficulty can be adjusted upward a max of 4x or downward a min of 1/4x. This is to prevent the difficulty from being gamed too far in either direction by miners.

= FortunaV1 Design

== Overview
At its core, Fortuna is a piece of state stored in a datum in a utxo on Cardano. We use an NFT to uniquely identify the datum. Miners race to solve a PoW puzzle to create a new Fortuna state. The difficulty is updated to average a new Fortuna state every 10 minutes. The Fortuna state contains a hash of the previous Fortuna state and the miner nonce.

The Fortuna State fields are diagrammed below:

```
type State {
  // Current Fortuna block number
  block_number: Int,
  // Hash of the previous Fortuna state and the miner nonce
  current_hash: ByteArray,
  // Number of leading zeros that must be in the found hash
  leading_zeros: Int,
  // If leading zeros are equal, then the first 2 non-zero bytes of the hash
  // must be less than the target
  target_number: Int,
  // Unix Time in milliseconds since last difficult adjustment.
  // Based on time interval used by the miners in a tx
  epoch_time: Int,
  // Posix time based on time interval used by the miner in the last tx
  current_posix_time: Int,
  // A flexible storage field for any use case
  extra: Data,
  // Tracks the superblock hashes in previous blocks
  // Based on how exponentially smaller the found hash is compared to the difficulty
  interlink: List<Data>,
}
```

The Redeemer is just a simple bytearray as shown below:
The nonce can be any value and any size and is purely used only for hashing purposes.

```
type InputNonce =
  ByteArray
```

The state hashed is not exactly the Fortuna State. Instead it is some of the fields from the Fortuna State plus the miner nonce.

```
type TargetState {
  nonce: ByteArray,
  block_number: Int,
  current_hash: ByteArray,
  leading_zeros: Int,
  target_number: Int,
  epoch_time: Int,
}
```


This is double sha-256 hashed and then compared against the current blocks difficulty. The difficulty comparison is found by
converting the found hash to two values. Leading zeros present in the hash and the first 2 non-zero bytes of the hash.
The leading zeros are checked to be either greater than or equals to the Fortuna State's leading zeros.
If equal then the 2 non-zero bytes are checked to be less than the Fortuna State's target number.
If either conditions is met the transaction is considered valid and the Fortuna State is updated.


Fortuna transaction diagram here

== Pros
- FortunaV1 is a really simple protocol consisting of 2 validators in a single script and a datum and NFT.
- FortunaV1 is a (possibly self-sufficient) decentralized source of randomness for dApps on Cardano.
- FortunaV1 can serve as a source of consensus for scaling solutions on Cardano.


== Cons
- FortunaV1 did not enforce the miner credential in the transaction submitted, which allowed for front-runners to use the same nonce in their own tx.
- FortunaV1 did not have a governance mechanism to adjust the protocol or PoW algorithm. The policy id was tied to the spend validator, which made it impossible to change the PoW algorithm without a hard fork.
- FortunaV1 kept it's history as an interlink, Which allowed for easy creation of light nodes that could verify the fortuna history, but this is only usable to off-chain entities.
- Bloated datum size due to the interlink history.

== More on Interlink

Interlink is a nice to have as a marker of previous fortuna history. The idea is the validity of the current Fortuna hash could be validated quickly without the
need for Cardano's history or a trust in the validators.

In Fortuna V2 we opted for a far more succint structure (Sparse Merkle Trees, or in the final implementation Merkle Patricia Forestry).

= How to Hard Fork from an active policy

The only way to fork from an active policy is to create a new policy and have a migration step for the old policy.
In the case of Fortuna we have a few key advantages that help simplify the migration to a new policy.
We have an emission schedule purely based on the block number.
Thus similar to how a hard fork works in an L1, we can choose a predetermined future block number to switch to the new policy.
The previous token holders can lock up their tokens in the old policy and mint new tokens in the new policy.
One key importance is the old policy has no concept of this new policy, so new tokens can still be minted under the old policy.
But one fortunate part is that your cutoff for migration can be based on the amount of tokens rather than a time deadline.
Users would have a chance to migrate before new tokens are minted under the old policy.
The cutoff is necessary to prevent the old policy from being used to mint tokens at a lower difficulty than the new policies difficulty in the farther future.

For the Hard Fork design, I went with a single simple multivalidator to lock tokens.
Then FortunaV2 checks the locked tokens in the tx to allow for redemption of FortunaV2 tokens.
Originally I created a contract that makes use of the extra data field and gathers current token holder votes.
But the current Fortuna V1 was not being mined. So it made more sense to have a simple lockup to fork contract.

== Hard Fork Design

The Hard Fork design consists of two actions geenesis and lock.
Redeem is a separate action that exists in the minting policy of FortunaV2.
The genesis action simply creates the NFT and datum for the Hard Fork state.
The lock action allows a user to lock their FortunaV1 tokens in the Hard Fork contract up to the emission amount based on the block height of the hardfork.

The lockstate at the utxo with the NFT contains the following fields:
```
type LockState {
  // The block height of the hard fork
  block_height: Int,
  // The amount of FortunaV1 tokens locked in the contract
  // Once the emission amount is reached this number will not increase
  current_locked_tuna: Int,
}
```

Hard Fork Genesis transaction here

Hard Fork Redeem transaction here

= FortunaV2 Design

== Overview
Like FortunaV1, FortunaV2 is a piece of state stored in a datum in a utxo on Cardano.
We use an NFT to uniquely identify the datum.
Miners race to solve a PoW puzzle to create a new Fortuna state.
The difficulty is updated to average a new Fortuna state every 10 minutes. T
he Fortuna state is a hash of the previous Fortuna state and the miner nonce.
The key differences come from the new features, backwards compatibility support for V1 token holders, and governance.
Also there is another NFT locked with the Fortuna State that is used to track the current block height.



Fortuana V2 datum matches the Fortuna V1 datum with the removal the extra and interlink fields.
Instead of interlink, we have a merkle root of all the FortunaV2 blocks ever mined. And the extra
field is moved to the redeemer and is now used to produce the next hash.

```
pub type Statev2 {
  block_number: Int,
  current_hash: ByteArray,
  leading_zeros: Int,
  target_number: Int,
  epoch_time: Int,
  current_posix_time: Int,
  // The merkle root of all the existing FortunaV2 blocks ever mined
  // Includes the current hash of this datum in the set too.
  merkle_root: ByteArray,
}
```


FortunaV2 Redeemers' tables here

Table here of Hashable State for FortunaV2
This is double sha-256 hashed and then compared against the current blocks difficulty.

FortunaV2 transaction diagram here





== Differences from FortunaV1

 To have upgradability, Fortuna separates the minting policy out from the spending validator and allows changing to a new script for the spending validator. This allows for switching the PoW algorithm, changing the difficulty, and even altering the emission schedule and rate of the old policy without changing the supply cap. The minting policy uses a counter token to track each emission and caps out after seven million emissions. This enforces a hard cap on the total supply, but allows flexibility in every other way by allowing the spending validator to change and possibly be the emitter. The minting policy also enforces the governance process to change to a new spending validator. So both governance and token emission are enforced by the minting policy.

 The spending validator in Fortuna currently enforces all the previous rules from FortunaV1 with the addition of one more. The fortunaV2 hashable state includes a hash of the miner credential given by the Miner Redeemer. The spending validator enforces that the miner credential is also present in the same transaction.

== Pros

== Cons

== How Parameters are forever encoded into the minting policy


= FortunaV2 Governance


== Why Governance?

== How Voting Works



== The Future of Fortuna

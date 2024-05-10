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
  abstract: lorem(100),
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





= FortunaV1 Design

== Overview
At its core, Fortuna is a piece of state stored in a datum in a utxo on Cardano. We use an NFT to uniquely identify the datum. Miners race to solve a PoW puzzle to create a new Fortuna state. The difficulty is updated to average a new Fortuna state every 10 minutes. The Fortuna state is a hash of the previous Fortuna state and the miner nonce.

Table here for FortunaV1 utxo state

Table here for FortunaV1 Redeemer

Table here of Hashable State for FortunaV1
This is double sha-256 hashed and then compared against the current blocks difficulty.

Fortuna transaction diagram here

== Pros
- FortunaV1 is a really simple protocol consisting of 2 validators in a single script and a datum and NFT.
- FortunaV1 is a (possibly self-sufficient) decentralized source of randomness for dApps on Cardano.
- FortunaV1 can serve as a source of consensus for scaling solutions on Cardano.



== Cons
- FortunaV1 did not enforce the miner credential in the transaction submitted, which allowed for front-running to steal a miners rewards.
- FortunaV1 did not have a governance mechanism to adjust the protocol or PoW algorithm.
- FortunaV1 kept it's history as an interlink, Which allowed for easy creation of light nodes that could verify the fortuna history, but this is only usable to off-chain entities.
- Bloated datum size due to the interlink history.


= How to Hard Fork from an active policy

The only way to fork from an active policy is to create a new policy and have a migration step for the old policy. In the case of Fortuna we have a few key advantages that help simplify the migration to a new policy. We have an emission schedule purely based on the block number. Thus similar to how a hard fork works in an L1, we can choose a predetermined future block number to switch to the new policy. The previous token holders can lock up their tokens in the old policy and mint new tokens in the new policy. One key importance is the old policy has no concept of this new policy, so new tokens can still be minted under the old policy. But one fortunate part is that your cutoff for migration can be based on the amount of tokens rather than a time deadline. Users would have a chance to migrate before new tokens are minted under the old policy. The cutoff is necessary to prevent the old policy from being used to mint tokens at a lower difficulty than the new policies difficulty in the farther future.

Hard Fork state datum here

Hard Fork genesis transaction here

Hard Fork redeemer transaction here

= FortunaV2 Design



== Overview
Like FortunaV1, FortunaV2 is a piece of state stored in a datum in a utxo on Cardano. We use an NFT to uniquely identify the datum. Miners race to solve a PoW puzzle to create a new Fortuna state. The difficulty is updated to average a new Fortuna state every 10 minutes. The Fortuna state is a hash of the previous Fortuna state and the miner nonce. The key differences come from the new features, backwards compatibility support for V1 token holders, and governance.


FortunaV2 utxo state table here

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




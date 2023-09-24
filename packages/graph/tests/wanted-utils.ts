import { newMockEvent } from "matchstick-as"
import { ethereum, BigInt, Address, Bytes } from "@graphprotocol/graph-ts"
import { BountyClaimed, BountyCreated } from "../generated/Wanted/Wanted"

export function createBountyClaimedEvent(
  bountyId: BigInt,
  claimer: Address,
  amount: BigInt
): BountyClaimed {
  let bountyClaimedEvent = changetype<BountyClaimed>(newMockEvent())

  bountyClaimedEvent.parameters = new Array()

  bountyClaimedEvent.parameters.push(
    new ethereum.EventParam(
      "bountyId",
      ethereum.Value.fromUnsignedBigInt(bountyId)
    )
  )
  bountyClaimedEvent.parameters.push(
    new ethereum.EventParam("claimer", ethereum.Value.fromAddress(claimer))
  )
  bountyClaimedEvent.parameters.push(
    new ethereum.EventParam("amount", ethereum.Value.fromUnsignedBigInt(amount))
  )

  return bountyClaimedEvent
}

export function createBountyCreatedEvent(
  bountyId: BigInt,
  owner: Address,
  amount: BigInt,
  leadingBytes: Bytes
): BountyCreated {
  let bountyCreatedEvent = changetype<BountyCreated>(newMockEvent())

  bountyCreatedEvent.parameters = new Array()

  bountyCreatedEvent.parameters.push(
    new ethereum.EventParam(
      "bountyId",
      ethereum.Value.fromUnsignedBigInt(bountyId)
    )
  )
  bountyCreatedEvent.parameters.push(
    new ethereum.EventParam("owner", ethereum.Value.fromAddress(owner))
  )
  bountyCreatedEvent.parameters.push(
    new ethereum.EventParam("amount", ethereum.Value.fromUnsignedBigInt(amount))
  )
  bountyCreatedEvent.parameters.push(
    new ethereum.EventParam(
      "leadingBytes",
      ethereum.Value.fromBytes(leadingBytes)
    )
  )

  return bountyCreatedEvent
}

import {
  BountyClaimed as BountyClaimedEvent,
  BountyCreated as BountyCreatedEvent
} from "../generated/Wanted/Wanted"
import { BountyClaimed, BountyCreated } from "../generated/schema"

export function handleBountyClaimed(event: BountyClaimedEvent): void {
  let entity = new BountyClaimed(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.bountyId = event.params.bountyId
  entity.claimer = event.params.claimer
  entity.amount = event.params.amount

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleBountyCreated(event: BountyCreatedEvent): void {
  let entity = new BountyCreated(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.bountyId = event.params.bountyId
  entity.owner = event.params.owner
  entity.amount = event.params.amount
  entity.leadingBytes = event.params.leadingBytes

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

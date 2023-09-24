<script>

import { web3Modal } from 'svelte-wagmi';
import { connected, chainId, signerAddress } from 'svelte-wagmi';
import { keccak256 } from 'viem';
import { stringToHex } from 'viem'
import { concat,slice,toBytes } from 'viem'


import { toRlp } from 'viem'


let saltStr = '';
$: saltBytes32 = stringToHex( saltStr, { size: 32 });


$: senderSalt = ($signerAddress && saltBytes32) ? keccak256(concat([toRlp($signerAddress), toRlp(saltBytes32)])):'';



// TODO: set factory address
const FACTORY_ADDR = toBytes('0x1bDf03E0fF5EcC3628Ba54A1630352E7F6067BA8');
const PROXY_BYTECODE_HASH =toBytes('0x21c35dbe1b344a2488cf3321d6ce542f8e9f305544ff09e4993a62319a497c1fn');
$: proxy = slice(keccak256(concat([toBytes('0xff'), FACTORY_ADDR, senderSalt, PROXY_BYTECODE_HASH])),12);

$: contract = slice(
keccak256(
                        concat([
                            // 0xd6 = 0xc0 (short RLP prefix) + 0x16 (length of: 0x94 ++ proxy ++ 0x01)
                            // 0x94 = 0x80 + 0x14 (0x14 = the length of an address, 20 bytes, in hex)
                            toBytes('0xd694'),
                            proxy,
                            toBytes('0x01') // Nonce of the proxy contract (1)
])), 12);



/*
const D694 = 0xd694n
const _01 = 0x01n

const getRandomContract = (sender) => {
    const salt = randomBytes(12);
    const senderSalt = concat([sender, salt]);

    const proxy = keccak('keccak256').update(concat([
        FF,
        FACTORY_ADDR,
        senderSalt,
        PROXY_BYTECODE_HASH,
    ]))
        .digest()
        .slice(12);
*/
</script>

<svelte:head>
	<title>Home</title>
	<meta name="description" content="Svelte demo app" />
</svelte:head>

<div class="container">
	<div class="mx-auto max-w-sm">
	<h1>Mint a contract vanity address</h1>
	<p>Easy to use!</p>
	{#if !$connected}
	<p>

		{#if $web3Modal}
	<button on:click="{() =>$web3Modal.openModal()}"> Connect to Ethereum</button>
	{:else}
	Wait for Web3Modal
	{/if}
	</p>
	{:else}
	
	<article class="grid">
        <div>
          <hgroup>
            <h1>MINT ADDRESS</h1>
            <h2>A minimalist demo</h2>
          </hgroup>
          <form>
			<label for="salt">Salt</label>
            <input
              type="text"
			  bind:value={saltStr}
              name="Salt text"
              placeholder="Login"
              aria-label="Login"
              required
            />
			<label for="salt">Salt (bytes32)</label>
            <input
              type="text"
			  readonly
			  value={saltBytes32}
              name="Bytes32"
              placeholder="Bytes32"
            />
			<label>Predicted address:</label>
			<input
              type="text"
			  readonly
			  value={contract}
              name="address"
              placeholder="address"
            />
            <button type="submit" onclick="event.preventDefault()">MINT</button>
          </form>
        </div>
      </article>
	  {/if}
</div>
  </div>


	
	


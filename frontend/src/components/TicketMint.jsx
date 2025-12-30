import React, {useState} from 'react'
import { getProvider } from '../wallet'
import { ethers } from 'ethers'

export default function TicketMint({address}){
  const [eventId, setEventId] = useState('')
  const [price, setPrice] = useState('10000000000000000')
  const [maxTickets, setMaxTickets] = useState('100')
  const [contractAddress, setContractAddress] = useState(process.env.VITE_CONTRACT_ADDRESS || '')
  const [log, setLog] = useState('')

  async function createEvent(){
    if(!address) return setLog('Connect wallet first')
    const provider = getProvider()
    if(!provider) return setLog('provider not found')
    const signer = await provider.getSigner()
    const abi = ["function createEvent(string,uint256,uint256) returns (uint256)"]
    const contract = new ethers.Contract(contractAddress, abi, signer)
    try{
      const tx = await contract.createEvent('ipfs://example', price, maxTickets)
      setLog('tx sent: '+tx.hash)
      await tx.wait()
      setLog('event created')
    }catch(e){ setLog('error:'+e.message) }
  }

  async function mint(){
    if(!address) return setLog('Connect wallet first')
    const provider = getProvider()
    if(!provider) return setLog('provider not found')
    const signer = await provider.getSigner()
    const abi = ["function mintTicket(uint256) payable returns (uint256)"]
    const contract = new ethers.Contract(contractAddress, abi, signer)
    try{
      const tx = await contract.mintTicket(eventId, { value: price })
      setLog('mint tx: '+tx.hash)
      await tx.wait()
      setLog('minted')
    }catch(e){ setLog('error:'+e.message) }
  }

  return (
    <div className="card">
      <strong>Create / Mint Tickets</strong>
      <div style={{marginTop:8}}>
        <div>
          <label>Contract Address: </label>
          <input value={contractAddress} onChange={e=>setContractAddress(e.target.value)} style={{width:'60%'}} />
        </div>
        <div style={{marginTop:8}}>
          <label>Price (wei): </label>
          <input value={price} onChange={e=>setPrice(e.target.value)} />
        </div>
        <div style={{marginTop:8}}>
          <label>Max tickets: </label>
          <input value={maxTickets} onChange={e=>setMaxTickets(e.target.value)} />
        </div>
        <div style={{marginTop:8}}>
          <button onClick={createEvent}>Create Event</button>
        </div>

        <hr />

        <div>
          <label>Event ID to mint: </label>
          <input value={eventId} onChange={e=>setEventId(e.target.value)} />
          <button onClick={mint} style={{marginLeft:8}}>Mint Ticket</button>
        </div>
        <div style={{marginTop:8}}><em>{log}</em></div>
      </div>
    </div>
  )
}

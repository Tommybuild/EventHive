import React, {useEffect, useState} from 'react'
import { initWeb3Modal, connectWallet, disconnectWallet, getProvider } from './wallet'
import TicketMint from './components/TicketMint'

export default function App(){
  const [address, setAddress] = useState(null)

  useEffect(()=>{
    initWeb3Modal()
  },[])

  async function onConnect(){
    const acct = await connectWallet()
    setAddress(acct)
  }

  async function onDisconnect(){
    await disconnectWallet()
    setAddress(null)
  }

  return (
    <div className="container">
      <h1>EventHive — Demo</h1>
      <div className="card">
        <strong>Wallet</strong>
        <div style={{marginTop:8}}>
          {address ? (
            <>
              <div>Connected: {address}</div>
              <button onClick={onDisconnect}>Disconnect</button>
            </>
          ) : (
            <button onClick={onConnect}>Connect Wallet (WalletConnect)</button>
          )}
        </div>
      </div>

      <TicketMint address={address} />
    </div>
  )
}

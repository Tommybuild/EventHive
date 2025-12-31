import React, {useEffect, useState} from 'react'
import { initWeb3Modal, connectWallet, disconnectWallet, getProvider } from './wallet'
import { initReown, reownLogin, reownGetUser, reownLogout } from './reown'
import TicketMint from './components/TicketMint'

export default function App(){
  const [address, setAddress] = useState(null)

  useEffect(()=>{
    initWeb3Modal()
    // initialize Reown AppKit if API key provided
    initReown(process.env.VITE_REOWN_API_KEY).catch(()=>{})
  },[])

  async function onConnect(){
    const acct = await connectWallet()
    setAddress(acct)
  }

  async function onDisconnect(){
    await disconnectWallet()
    setAddress(null)
  }

  const [reownUser, setReownUser] = useState(null)

  async function onReownLogin(){
    try{
      await reownLogin()
      const u = await reownGetUser()
      setReownUser(u)
    }catch(e){
      console.warn('Reown login failed', e)
    }
  }

  async function onReownLogout(){
    try{
      await reownLogout()
      setReownUser(null)
    }catch(e){ console.warn(e) }
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

      <div className="card">
        <strong>Reown AppKit</strong>
        <div style={{marginTop:8}}>
          {reownUser ? (
            <>
              <div>Reown user: {JSON.stringify(reownUser)}</div>
              <button onClick={onReownLogout}>Logout Reown</button>
            </>
          ) : (
            <>
              <div>Use Reown to sign in (if configured)</div>
              <button onClick={onReownLogin}>Login with Reown</button>
            </>
          )}
        </div>
      </div>

      <TicketMint address={address} />
    </div>
  )
}

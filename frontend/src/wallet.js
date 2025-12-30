import Web3Modal from 'web3modal'
import WalletConnectProvider from '@walletconnect/web3-provider'
import { ethers } from 'ethers'

let web3Modal
let provider

export function initWeb3Modal(){
  if(web3Modal) return
  const providerOptions = {
    walletconnect: {
      package: WalletConnectProvider,
      options: {
        rpc: {
          // chainId 8453 is Base mainnet; user should set RPC via VITE_RPC_URL or change accordingly
          8453: process.env.VITE_RPC_URL || 'https://mainnet.base.org'
        }
      }
    }
  }
  web3Modal = new Web3Modal({ cacheProvider: true, providerOptions })
}

export async function connectWallet(){
  provider = await web3Modal.connect()
  const web3Provider = new ethers.BrowserProvider(provider)
  const signer = await web3Provider.getSigner()
  const address = await signer.getAddress()
  return address
}

export async function disconnectWallet(){
  if(provider && provider.disconnect) await provider.disconnect()
  if(web3Modal) web3Modal.clearCachedProvider()
  provider = null
}

export function getProvider(){
  if(!provider) return null
  return new ethers.BrowserProvider(provider)
}

import Web3 from 'web3';
import Web3Modal from 'web3modal';
import WalletConnectProvider from '@walletconnect/web3-provider';
import { useUser } from '../context/UserContext';

const providerOptions = {
  walletconnect: {
    package: WalletConnectProvider,
    options: {
      rpc: {
        4: 'https://bsc-dataseed.binance.org/',
        97: 'https://data-seed-prebsc-1-s1.binance.org:8545/',
      },
      qrcodeModalOptions: {
        mobileLinks: ['rainbow', 'metamask', 'argent', 'trust', 'imtoken', 'pillar'],
      },
      bridge: 'https://bridge.walletconnect.org',
    },
  },
};

export const connectWeb3Modal = async () => {
  const web3Modal = new Web3Modal({
    cacheProvider: false, // optional
    network: 'mainnet',
    providerOptions, // required
  });
  const provider = await web3Modal.connect();
  const web3 = new Web3(provider);

  let chainId = await web3.eth.net.getId();

  if (chainId === 4 || chainId === 97) {
    let accounts = await web3.eth.getAccounts();
    console.log(accounts);

    if (accounts.length > 0) {
      return accounts[0];
    }
  }

  // Subscribe to accounts change
  provider.on('accountsChanged', async accounts => {
    console.log(accounts[0]);
  });

  // Subscribe to chainId change
  provider.on('chainChanged', chainId => {
    if (chainId === 4 || chainId === 97) {
    } else {
      alert('Please change to Binance Smart Chain Mainnet or Testnet');
    }
  });

  // Subscribe to provider connection
  provider.on('connect', info => {
    console.log(info);
  });

  // Subscribe to provider disconnection
  provider.on('disconnect', error => {
    console.log(error);
  });
};

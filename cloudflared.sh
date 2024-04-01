#!/bin/bash

# install cloudflared for tunnel

if (stat cloudflared-linux-$(dpkg --print-architecture).deb)
then 
  echo "cloudflared-linux-$(dpkg --print-architecture).deb already downloaded"
else
  echo "downloading cloudflared-linux-$(dpkg --print-architecture).deb"
  curl -OJL https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-$(dpkg --print-architecture).deb 
fi

if (cloudflared --version)
then 
  echo "cloudlfared already installed"
else
 echo "installing cloudflared"
 sudo dpkg -i cloudflared-linux-$(dpkg --print-architecture).deb
fi

if (cloudflared tunnel token 209bits)
then  
  echo "cloudflare tunnel already authenticated"
else
  echo "authenticating cloudflare tunnel"
  cloudflared tunnel login 
fi

if (systemctl is-active cloudflared)
then 
  echo "cloudflared service already active"
else
  echo "activating cloudflared service"
  sudo cloudflared service install $(cloudflared tunnel login)
fi
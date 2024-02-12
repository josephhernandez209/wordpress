
if (multipass version)
then
  echo "multipass already installed"
else
  echo "installing multipass"
  sudo snap install multipass
  sleep 5
fi

if (sudo snap services | grep 'multipass.multipassd' | grep active)
then 
  echo "multipass already active"
else
  echo "restarting multipass"
  sudo snap restart multipass.multipassd
  sleep 5
fi

if (multipass info wordpress)
then
  echo "wordpress vm already exists"
else 
  echo "launching wordpress vm"
  multipass launch --name wordpress -c 4 -m 4G
fi

multipass transfer wordpress.sh wordpress:. && multipass exec wordpress -- bash wordpress.sh && multipass exec wordpress -- bash cloudflared.sh

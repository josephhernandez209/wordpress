
if (multipass version)
then
  echo "multipass already installed"
else
  echo "installing multipass"
  sudo snap install multipass
  sleep 2
fi

multipass launch --name wordpress -c 2 -m 2G
multipass transfer wordpress.sh wordpress:. && multipass shell wordpress

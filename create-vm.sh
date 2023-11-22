
if (multipass version)
then
  echo "multipass already installed"
else
  echo "installing multipass"
  sudo snap install multipass
  sleep 2
fi

multipass launch --name wordpress 
multipass transfer wordpress.sh wordpress:. && multipass shell wordpress

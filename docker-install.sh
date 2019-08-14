#Script para instalar docker-ce en ubuntu server o debian
#dist=debian, ubuntu, raspbian
#arch=amd64,armhf,arm64
#branch=stable,nightly,test

dist=ubuntu
version=$(lsb_release -cs)
arch=$(dpkg --print-architecture)
branch=stable


case "$dist" in
	ubuntu)
	apt-get update
	apt-get install -y \
	    apt-transport-https \
	    ca-certificates \
	    curl \
	    gnupg-agent \
	    software-properties-common
	;;

	debian|raspbian)
	apt-get update
	apt-get install -y \
	    apt-transport-https \
	    ca-certificates \
	    gnupg2 \
	    curl \
	    software-properties-common
	;;
	*)
	echo "Distro no soportada"
	exit 1
	;;
esac

curl -fsSL "https://download.docker.com/linux/$dist/gpg" | apt-key add -
# Verificar clave: 9DC8 5822 9FC7 DD38 854A  E2D8 8D81 803C 0EBF CD88
apt-key fingerprint 9DC858229FC7DD38854AE2D88D81803C0EBFCD88

if [ "$dist" = "ubuntu" ] || [ "$dist" = "debian" ]; then
	add-apt-repository \
	   "deb [arch=$arch] https://download.docker.com/linux/$dist \
	   $version $branch"
else
	echo "deb [arch=$arch] https://download.docker.com/linux/$dist $version $branch" > "/etc/apt/sources.list.d/docker.list"
fi

apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io

#verificar
docker run hello-world

#version
docker version
#Ref:
#https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-using-the-repository

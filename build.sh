docker build . --network host -t $(cat TAG) --platform linux/amd64, linux/arm64 --build-arg="TZ=Europe/Madrid" --build-arg="VERSION=$(cat TAG | awk -F ':' '{print $2}')"


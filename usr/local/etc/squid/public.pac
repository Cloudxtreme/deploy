function FindProxyForURL(url, host) {
    if (isInNet(myIpAddress(), "192.168.255.0", "255.255.255.0"))
        return "PROXY 192.168.255.201:3128";
}

# vm_build_risc_v

# Installation image licheepi4a-dpdk-image

## Building
```sh
make build
make yocto
```

## Flashing an image
```
./scripts/flash.sh
```


## Using UART
```sh
sudo minicom -D /dev/ttyUSB1 -b 115200
```



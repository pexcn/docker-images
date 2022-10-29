# chinadns-ng

## Usage

```sh
docker run -d \
  --name chinadns-ng \
  --restart unless-stopped \
  --network host \
  -e TZ=Asia/Taipei \
  -v $(pwd)/chinadns-ng-data:/etc/chinadns-ng \
  pexcn/docker-images:chinadns-ng \
    -b 0.0.0.0 \
    -l 5353 \
    -c 223.5.5.5 \
    -t 127.0.0.1#5300 \
    -g /etc/chinadns-ng/gfwlist.txt \
    -m /etc/chinadns-ng/chinalist.txt \
    -o 3 \
    -p 3 \
    -f \
    -r
```

# chinadns-ng

## Usage

```bash
docker run --rm \
  --name chinadns-ng \
  --network host \
  -v /etc/localtime:/etc/localtime:ro \
  pexcn/docker-images:chinadns-ng --help

docker run -d \
  --name chinadns-ng \
  --restart unless-stopped \
  --network host \
  -v /etc/localtime:/etc/localtime:ro \
  pexcn/docker-images:chinadns-ng -b 0.0.0.0 -l 5353 -c 223.5.5.5 -t 127.0.0.1#5300 -g /etc/chinadns-ng/gfwlist.txt -m /etc/chinadns-ng/chinalist.txt -o 3 -p 4 -r
```

# UnixBench

## Usage

```sh
docker run -it --rm \
  --name unixbench \
  -v /etc/localtime:/etc/localtime:ro \
  pexcn/docker-images:unixbench

docker run -d \
  --name unixbench \
  -v /etc/localtime:/etc/localtime:ro \
  pexcn/docker-images:unixbench
```

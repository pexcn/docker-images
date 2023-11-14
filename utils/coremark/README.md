# CoreMark

## Usage

```sh
docker run -it --rm \
  --name coremark \
  -v /etc/localtime:/etc/localtime:ro \
  pexcn/docker-images:coremark

docker run -d \
  --name coremark \
  -v /etc/localtime:/etc/localtime:ro \
  pexcn/docker-images:coremark
```

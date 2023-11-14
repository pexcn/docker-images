# CoreMark

## Usage

```sh
docker run -it --rm \
  --name coremark \
  --net host \
  pexcn/docker-images:coremark

docker run -d \
  --name coremark \
  --net host \
  pexcn/docker-images:coremark
docker logs coremark
docker rm coremark
```

# dsm-open-vm-tools

## Usage

```bash
# Only for Synology DSM
sudo mkdir /root/.ssh
sudo docker run -d \
  --name open-vm-tools \
  --restart always \
  --network host \
  -v /root/.ssh/:/root/.ssh/ \
  pexcn/docker-images:dsm-open-vm-tools
```

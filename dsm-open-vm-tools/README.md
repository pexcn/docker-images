## Usage

SSH into your DSM and run this command:
```bash
sudo mkdir /root/.ssh
sudo docker run -d --restart=always --net=host -v /root/.ssh/:/root/.ssh/ --name open-vm-tools pexcn/docker-images:dsm-open-vm-tools
```

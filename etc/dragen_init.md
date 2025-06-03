sudo yum update -y
sudo yum install -y tmux emacs rclone
sudo dnf install -y fuse fuse3 fuse-common fuse3-libs fuse3-devel


wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh

bash Miniconda3-latest-Linux-x86_64.sh

sudo mkdir /fsx
sudo chmod a+wrx /fsx
sudo chmod a+wrx /fsx/
cd fsx/
mkdir data
mkdir logs
mkdir tmp
mkdir scratch
mkdir resources
mkdir analysis_results
mkdir analysis_results/ubuntu
mkdir resources/environments
mkdir resources/environments/containers
mkdir resources/environments/conda


mkdir resources/environments/conda/ec2-user
mkdir resources/environments/conda/ubunt
mkdir resources/environments/container/ubuntu
mkdir resources/environments/container/
mkdir resources/environments/container/ubuntu
mkdir resources/environments/container/ec2-user

mkdir resources/environments/container/ec2-user/$(hostname)
mkdir resources/environments/container/ubuntu/$(hostname)
mkdir analysis_results/ec2-user
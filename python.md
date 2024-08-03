# Set Up Python Workstation

> This guide assumes Ubuntu 20.04 as host OS

```bash
# check default Python version
python3 --version

# upgrade default pip installation
python3 -m pip install --upgrade pip

# configure and update package manager
sudo apt update && sudo apt upgrade -y
sudo apt install software-properties-common
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt update

# install Python (repeat for each required version)
sudo apt install python3.9
sudo apt install python3.10

# configure Python alternatives
sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1
sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.9 2
sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 3
sudo update-alternatives --config python3 # choose the current default version
python3 --version # confirm selection

# install Python Dev Tools
sudo apt install jq unzip python3-dev libkrb5-dev python3.10 python3.10-dev python3.10-venv

# install latest Pip for your default Python version
curl -sS https://bootstrap.pypa.io/get-pip.py | python3.10
python3 -m pip --version

# install Pipenv
python3 -m pip install pipenv
alias pipenv="python3 -m pipenv"
echo "alias pipenv=\"python3 -m pipenv\"" >> ~/.bashrc
echo "alias pipenv=\"python3 -m pipenv\"" >> ~/.profile
pipenv --version

# create virtual environment with specific Python version
# sudo update-alternatives --config python3 # choose the current default version
pipenv --python 3.9
```
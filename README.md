# OttoGroup

```
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9
echo 'deb http://cran.stat.sfu.ca/bin/linux/ubuntu trusty/' | sudo tee --append /etc/apt/sources.list > /dev/null
sudo apt-get update
sudo apt-get -y install libcurl4-openssl-dev libxml2-dev
sudo apt-get -y install r-base r-base-dev
sudo apt-get -y install git
Rscript -e "install.packages(c('RCurl','XML'))"
git clone https://github.com/hetong007/OttoGroup.git
```



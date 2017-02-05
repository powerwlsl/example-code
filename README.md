# [Petro Recruit is launched!](http://petrorecruit.co/) 
## About Us
Petro Recruit is a startup company focused on employment in oil and gas verticals by providing a streamline platform for companies and candidates to connect. You don't have to fill out multiple applications, we do that for you. Decrease time spent on filling applications, increase time-to-market and be part of a curated list of oil and gas talent. We create a super-efficient way for talent in the oil and gas industry to get exposed to new opportunities with great companies.

## Our Stack

* Ruby 2.2.3p173
* Rails 4.2.4
* Gem 2.4.8
* PostgreSQL
* Devise Authentication
* Elasticsearch
* ERB/Slim, sass front end
* Heroku hosting
* bugsnag debugger
* AWS and paperclip, image/resume hosting

## Setup
1. `brew install postgresql` (mac only)

### Ubuntu Bootstrap
```sh
cd ~
apt-get update
sudo apt-get -y install libpq-dev # for Postgres
sudo apt-get -y install libsqlite3-dev # for sqlite3
apt-get -y install git
apt-get -y install bundler
wget -O- https://toolbelt.heroku.com/install-ubuntu.sh | sh # for scraper
git clone https://github.com/kevintpeng/Petro-Recruit.git
wget -O ruby-install-0.6.0.tar.gz https://github.com/postmodern/ruby-install/archive/v0.6.0.tar.gz
tar -xzvf ruby-install-0.6.0.tar.gz
cd ruby-install-0.6.0/
apt-get install make
sudo make install
ruby-install ruby 2.3.1
cd ..
wget -O chruby-0.3.9.tar.gz https://github.com/postmodern/chruby/archive/v0.3.9.tar.gz
tar -xzvf chruby-0.3.9.tar.gz
cd chruby-0.3.9/
sudo make install
sudo ./scripts/setup.sh

# Restart
chruby 2.3.1
cd ..
cd Petro-Recruit
bundle install

# ------------------ VPN SETUP ------------------- #
# set "connection" mark of connection from eth0 when first packet of connection arrives
sudo iptables -t mangle -A PREROUTING -i eth0 -m conntrack --ctstate NEW -j CONNMARK --set-mark 1234

# set "firewall" mark for response packets in connection with our connection mark
sudo iptables -t mangle -A OUTPUT -m connmark --mark 1234 -j MARK --set-mark 4321

# our routing table with eth0 as gateway interface
sudo ip route add default dev eth0 table 3412

# route packets with our firewall mark using our routing table
sudo ip rule add fwmark 4321 table 3412

sudo apt-get -y install openvpn
sudo update-rc.d -f openvpn remove
mkdir ~/ipvanish
cd ~/ipvanish
wget http://www.ipvanish.com/software/configs/ipvanish-US-San-Jose-sjc-a14.ovpn
wget http://www.ipvanish.com/software/configs/ca.ipvanish.com.crt
sudo openvpn --config ~/ipvanish/ipvanish-US-San-Jose-sjc-a14.ovpn --ca ~/ipvanish/ca.ipvanish.com.crt 
```

Standard rails setup, installation, rake db:migrate

### Running elasticsearch as a service
Reference link: https://www.elastic.co/guide/en/elasticsearch/reference/current/setup-service.html
Summary:
For Ubuntu 15:
- sudo /bin/systemctl daemon-reload
- sudo /bin/systemctl enable elasticsearch.service
- sudo /bin/systemctl start elasticsearch.service
- [For local setup (for testing or something) see elasticsearch installation for details.](https://github.com/kevintpeng/Learn-Something-Everyday/blob/master/Web-Technologies/Elasticsearch.md)

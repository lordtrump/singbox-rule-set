#!/bin/bash

set -e -o pipefail

VERSION=$(curl -s https://api.github.com/repos/SagerNet/sing-box/releases/latest \
| grep tag_name \
| cut -d ":" -f2 \
| sed 's/\"//g;s/\,//g;s/\ //g;s/v//')

curl -Lo sing-box.tar.gz "https://github.com/SagerNet/sing-box/releases/download/v${VERSION}/sing-box-${VERSION}-linux-amd64.tar.gz"
curl -Lo geoip.db "https://github.com/malikshi/sing-box-geo/releases/latest/download/geoip.db"
curl -Lo geosite.db "https://github.com/malikshi/sing-box-geo/releases/latest/download/geosite.db"

tar -xzvf sing-box.tar.gz
mv ./sing-box-${VERSION}-linux-amd64/sing-box .
chmod +x sing-box

geoipAddresses=("cloudflare" "cloudfront" "geoid" "firewall" "malicious" "facebook" "google" "netflix" "telegram" "twitter")
geositeDomains=("oisd-full" "oisd-nsfw" "rule-ads" "rule-doh" "rule-gaming" "rule-indo" "rule-playstore" "rule-sosmed" "rule-streaming" "rule-umum" "rule-ipcheck" "videoconference" "rule-malicious")

for item in "${geoipAddresses[@]}"; do
    ./sing-box geoip export "$item"
done

for item in "${geositeDomains[@]}"; do
    ./sing-box geosite export "$item"
done

for item in *.json; do
    ./sing-box rule-set compile "$item"
    mv "${item%.json}.srs" bin/
    mv "$item" rule-set/
done

rm -rf sing-box.tar.gz sing-box-${VERSION}-linux-amd64/ geoip.db geosite.db sing-box

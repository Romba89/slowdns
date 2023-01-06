#!/bin/bash
clear
#——————————————————
# CRIADOR POR @VPSPLUS71
# VERSAO 2.0
# SLOW DNS TUNNEL
#——————————————————
[[ ! -e $HOME/.dialogrc ]] && {
    cat <<-EOF >$HOME/.dialogrc
    aspect = 0
    separate_widget = ""
    tab_len = 0
    visit_items = OFF
    use_shadow = OFF
    use_colors = ON
    screen_color = (GREEN,BLACK,ON)
    shadow_color = (BLACK,BLACK,ON)
    dialog_color = (GREEN,WHITE,OFF)
    title_color = (BLACK,WHITE,ON)
    border_color = (GREEN,WHITE,ON)
    button_active_color = (WHITE,RED,ON)
    button_inactive_color = dialog_color
    button_key_active_color = button_active_color
    button_key_inactive_color = (RED,WHITE,OFF)
    button_label_active_color = (WHITE,RED,ON)
    button_label_inactive_color = (BLACK,WHITE,ON)
    inputbox_color = dialog_color
    inputbox_border_color = dialog_color
    searchbox_color = dialog_color
    searchbox_title_color = title_color
    searchbox_border_color = border_color
    position_indicator_color = title_color
    menubox_color = dialog_color
    menubox_border_color = border_color
    item_color = dialog_color
    item_selected_color = button_active_color
    tag_color = title_color
    tag_selected_color = button_label_active_color
    tag_key_color = button_key_inactive_color
    tag_key_selected_color = (RED,WHITE,ON)
    check_color = dialog_color
    check_selected_color = button_active_color
    uarrow_color = (GREEN,WHITE,ON)
    darrow_color = uarrow_color
    itemhelp_color = (WHITE,BLACK,OFF)
    form_active_text_color = button_active_color
    form_text_color = (WHITE,CYAN,ON)
    form_item_readonly_color = (CYAN,WHITE,ON)
    gauge_color = tag_key_selected_color
    border2_color = dialog_color
    inputbox_border2_color = dialog_color
    searchbox_border2_color = dialog_color
    menubox_border2_color = dialog_color
EOF
}
echo -e '\e[6 q'
echo -ne "\033]12;#ff0000\007"
comand='whiptail'
BACKTITLE="$(echo -e "\t\tSSLHTUNNELMAX SLOWDNS")"

instalacao() {
    check=$1
    if [[ $check == '1' ]]; then
        echo -e "\n\t\tPLEASE WAIT..."
        unset LD_PRELOAD > /dev/null 2>&1
        cd $HOME
        sleep 2
    elif [[ $check == '2' ]]; then
        echo -e "\n\t\tAPPLYING PERMISSIONS..."
        echo -e '#!/bin/bash\n$HOME/slowdns' > $PREFIX/bin/slowdns
        chmod +x $PREFIX/bin/slowdns
        sleep 2
    elif [[ $check == '3' ]]; then
        echo -e "\n\t\tAPPLYING SETTINGS..."
        [[ $(grep -c 'slowdns' $PREFIX/etc/profile) == '0' ]] && echo 'slowdns' >> $PREFIX/etc/profile
        sleep 1
    elif [[ $check == '4' ]]; then
        echo -e "\n\t\tCHECK MODULE..."
        curl -O https://raw.githubusercontent.com/Romba89/slowdns/main/dns > /dev/null 2>&1
        chmod +x dns
    else
        echo -e "\n\t\tFINISHED..."
        sleep 2
    fi
}

menu_dns() {
    OPTIONS=(1 " CLOUDFLARE DNS "
        2 " GOOGLE DNS "
        3 " ORTELMOBILE DNS "
        4 " CUSTOM DNS "
        5 " DELETE SLOWDNS ")

    CHOICE=$($comand --clear \
        --title " ✦ SSLHTUNNELMAX SLOWDNS ✦ " \
        --menu "\nSELECT A DNS TO START CONNECTION " \
        10 50 0 "${OPTIONS[@]}" \
        2>&1 >/dev/tty)

    case $CHOICE in
    1)
        echo "DNS CLOUDFLARE"
        dns='1.1.1.1'
        ;;
    2)
        echo "DNS GOOGLE"
        dns='8.8.8.8'
        ;;
    3)
        echo "DNS ORTELMOBILE"
        dns='62.109.121.17'
        ;;
    4)
        echo "DNS CUSTOM"
        dns=$($comand --clear --title " CUSTOM DNS " --inputbox "INFORM DNS:" 8 50 3>&1 1>&2 2>&3)
        [[ $dns == '' ]] && {
            echo 'INVALID DNS !'
            exit
        }
        ;;
    5)
        sed -i '/slowdns/d' $PREFIX/etc/profile > /dev/null 2>&1
        rm $HOME/credenciais dns > /dev/null 2>&1
        rm $PREFIX/bin/slowdns > /dev/null 2>&1
        clean
        echo -e "\nSCRIPT REMOVED !"
        ;;
    *)
        echo "Exit...."
        sleep 1
        clear
        exit
        ;;
    esac
    unset LD_PRELOAD > /dev/null 2>&1
    ns=$(sed -n 1p $HOME/credenciais)
    chave=$(sed -n 2p $HOME/credenciais)
    $HOME/dns -udp ${dns}:53 -pubkey ${chave} ${ns} 127.0.0.1:88 > /dev/null 2>&1 &
    $comand --clear \
        --backtitle "$BACKTITLE" \
        --title " SLOWDNS STARTED " \
        --ok-button " DISCONNECT " \
        --msgbox "\nDNS CONNECTION STARTED, STAY ON THIS SCREEN AND CONNECT TO A VPN APPLICATION AND MARK TERMUX IN YOUR FILTER !\n" 8 50
    piddns=$(ps x| grep -w 'dns' | grep -v 'grep'| awk -F' ' {'print $1'})
    [[ ${piddns} != '' ]] && kill ${piddns} > /dev/null 2>&1
    exit
}

[[ ! -e $HOME/credenciais ]] && {
    ns=$1
    [[ -z "$ns" ]] && {
        echo -e "\nINCOMPLETE COMMAND"
        exit 0
    }
    chave=$2
    [[ -z "$chave" ]] && {
        echo -e "\nINCOMPLETE COMMAND"
        exit 0
    }
    echo -e "$ns\n$chave" >$HOME/credenciais
}

[[ ! -e $HOME/dns ]] && {
    $comand --clear \
        --backtitle "$BACKTITLE" \
        --title " INSTALLATION " \
        --msgbox "\nYOU ARE ABOUT TO INSTALL SLOWDNS, NEXT TIME RUN ONLY THE slowdns COMMAND, EVEN IF YOU'RE OFFLINE !\n" 8 50
    yes| termux-setup-storage > /dev/null 2>&1
    sleep 2
    for i in {1..5}; do
        sleep 0.1
        echo XXX
        echo $((i * 20))
        instalacao $i
        echo XXX
    done | $comand --clear --backtitle "$BACKTITLE" --title " INSTALLATION " --gauge "$(echo -e "\n\t\tSTARTING INSTALLATION...")" 8 50 0
    sleep 1
    menu_dns
} || {
    menu_dns
}

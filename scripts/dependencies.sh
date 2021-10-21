#Colors
red="\e[1;31m"
green="\e[1;32m"
yellow="\e[1;33m"
blue="\e[1;34m"
purple="\e[1;35m"
cyan="\e[1;36m"
white="\e[1;37m"
end="\e[0m"

clear; dependencias=(aircrack-ng macchanger hcxdumptool hcxpcaptool hostapd dnsmasq php )
echo -e "${blue}[]${end} ${green}Comprobando programas necesarios...${end}"
sleep 2
for program in ${dependencias[@]}; do
	echo -ne "${blue}[]${end} ${purple}Herramienta ${end}${cyan}$program${end}${purple} ...${end}"
	test -f /usr/bin/$program
	if [[ $(echo $?) == "0" ]]; then
		echo -e "${green}\t[]${end}"
		sleep 1
	else
		test -f /usr/sbin/$program
		if [[ $(echo $?) == "0" ]]; then
			echo -e "${green}\t[]${end}"
			sleep 1
		else
			echo -e "${red}\t[]${end}"
			sleep 1
			echo -e "${cyan}\t[] Instalando...${end}"
			sleep 1
			apt install $program -y > /dev/null 2>&1
			echo -e "${green}\t[] Instalado!.${end}"
			sleep 1
		fi
	 fi
done; sleep 2; clear

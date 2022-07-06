#!/bin/bash
rm prioridad.temp;
rm datosIntroducidos.txt; # borra archivos para relizar programa con nuevos datos
echo -ne "\x1B]11;#000000\x1B\\"
clear                # borra lo anterior por pantalla
#DECLARACION DE VARIABLES DE COLORES

#Variables que asignan colores con sus respectivos nombres. (R=resaltado)
amarilloR='\x1B[1;33m'
amarillo='\x1B[0;33m'
verdeR='\x1B[1;32m'
verde='\x1B[0;32m'
moradoR='\x1B[1;35m'
morado='\x1B[0;35m'
rojoR='\x1B[1;31m'
rojo='\x1B[0;31m'
cyanR='\x1B[1;36m'
cyan='\x1B[0;36m'
negroR='\x1B[1;30m'
negro='\x1B[0;30m'
azulR='\x1B[1;34m'
azul='\x1B[0;34m'
blancoR='\x1B[1;39m'
blanco='\x1B[0;39m'
NC='\x1B[0m' # No Color




#A través de este bucle elaboramos un vector de colores
ir=0
for (( a=0; a<20; a++ ))do
	for(( k=1; k<=6; k++ ))do
	    colores[$ir]="\E[1;3$k""m"
	    let ir++
    	done
done


#Declaramos algunos de los vectores y variables que vamos a utilizar a lo largo del programa.
memor=0;    	#Acoge el valor del tamaño de cada proceso
memori=();		# ""    "" 	"" 	"" 	"" 	"" 	""  
map=0;			#Representa el tamaño de cada una de las particiones
proceso=();		#Nombre del proceso
tiempo=();		#Tiempo de ejecución del proceso
prioridad=();	#Prioridad del proceso
contador2=0
num_proc=0
sumatiempo=0
sumatiempodos=0
ficherocreado=0
p2=0
opcion2=0

#Función encargada de introducir por teclado cada una de las características de la memoria y particiones.
function crea_particiones {
	local aux=0
	local aux2=0
	local j=0
	local i=0
	cap_memoria=0
	cap_maxima=0
	comprueba_particion=0
	n_particiones=1
	part_init={}
	part_fin={}
	part_cap={}
	part_cap[0]=0
	echo ""
	while [ $j -eq 0 ]; do
		if [ $i -eq 0 ]; then
			part_init[$i]=0
		else
			let part_init[$i]=part_fin[$(expr $i-1)]+1
		fi
		local aux3=0
		while [ $aux3 -eq 0 ]; do
			printf "Introduce el tamaño de la partición nº$n_particiones: "
			read aux
			if [ $aux -gt 0 -a $? -eq 0 ] 2> /dev/null; then
					for (( k=0;k<=i;k++ ));do
						if [[ "$aux" -eq "${part_cap[$k]}" ]]; then
							echo -e "${rojoR}ERROR: ${rojo}No se pueden introducir particiones iguales${NC}"
							aux3=0
							break;
						else
							aux3=1
						fi
					done
			else
				echo -e "${rojoR}ERROR: ${rojo}El tamaño de partición es incorrecto${NC}"
			fi
		done
		printf "\n" >> informeColor.txt
		printf "Introduce el tamaño de la partición nº$n_particiones: $aux\n" >> informeColor.txt
		printf "\n" >>informeBN.txt
		printf "Introduce el tamaño de la partición nº$n_particiones: $aux\n" >>informeBN.txt
		cap_memoria=`expr $cap_memoria + $aux`
		part_cap[$i]=$aux
      	let part_fin[$i]=part_init[$i]+aux
      	let part_fin[$i]=part_fin[$i]-1
		let i=i+1
		aux2=0
		while [ $aux2 -eq 0 ];do
        	printf "¿Quiere añadir mas particiones? [S]i, [n]o: "
			read tecla
       		if [ -z $tecla ];then
	  			tecla="s"
          		aux2=1
				n_particiones=`expr $n_particiones + 1`
        	elif [ $tecla = "S" -o $tecla = "s" -o $tecla = "n" -o $tecla = "N" ];then
	            aux2=1
				n_particiones=`expr $n_particiones + 1`
        	fi
      	done
		printf "¿Quiere añadir mas particiones? [S]i, [n]o: $tecla\n" >> informeColor.txt
		printf "¿Quiere añadir mas particiones? [S]i, [n]o: $tecla\n" >>informeBN.txt
		if [ $tecla = "N" -o $tecla = "n" ];then
			n_particiones=`expr $n_particiones - 1`
			j=1
		fi
	done

	for (( j=0; j<${#part_cap[@]}; j++ ));do
		if [ ${part_cap[$j]} -gt $cap_maxima ];then
			cap_maxima=${part_cap[$j]}
		fi
	done

	for ((k=0;k<$i;k++));do
		printf "${part_cap[$k]};">>$ENTRADA
	done
	echo -e "">>$ENTRADA

	echo -e ""
	echo -e "${verdeR}Todas las particiones estan creadas${NC}"
	echo -e "Las particiones empiezan en	${part_init[@]}"
	echo -e "Las particiones acaban en	${part_fin[@]}"
	echo -e "Tamaño completo de la memoria	$cap_memoria"
	echo -e "" >> informeColor.txt
	echo -e "${verdeR}Todas las particiones estan creadas${NC}" >> informeColor.txt
	echo -e "Las particiones empiezan en	${part_init[@]}" >> informeColor.txt
	echo -e "Las particiones acaban en	${part_fin[@]}" >> informeColor.txt
	echo -e "Tamaño completo de la memoria	$cap_memoria" >> informeColor.txt
	echo -e "" >>informeBN.txt
	echo -e "Todas las particiones estan creadas" >>informeBN.txt
	echo -e "Las particiones empiezan en	${part_init[@]}" >>informeBN.txt
	echo -e "Las particiones acaban en	${part_fin[@]}" >>informeBN.txt
	echo -e "Tamaño completo de la memoria	$cap_memoria" >>informeBN.txt
}

#Función encarga de pedir por teclado los valores máximo y minimo correspondientes a la prioridad.
function crea_prioridad {
	
	echo ""
	printf "Introduce la prioridad mínima: "
	read pri_minima
	printf "Introduce la prioridad máxima: " 
	read pri_maxima
	printf "\n" >> informeColor.txt
	printf "Introduce la prioridad mínima: $pri_minima\n" >> informeColor.txt
	printf "Introduce la prioridad máxima: $pri_maxima\n"  >> informeColor.txt
	printf "\n" >>informeBN.txt
	printf "Introduce la prioridad mínima: $pri_minima\n" >>informeBN.txt
	printf "Introduce la prioridad máxima: $pri_maxima\n" >>informeBN.txt

	echo "$pri_minima;$pri_maxima;" >> $ENTRADA
	calcularTipoPrioridad $pri_minima $pri_maxima

	echo -e "${NC}La prioridad de cada proceso debe de estar entre ${NC}$pri_minima y $pri_maxima${NC}"
	echo -e "${NC}La prioridad de cada proceso debe de estar entre ${NC}$pri_minima y $pri_maxima${NC}" >> informeColor.txt
	printf "\n" >>informeColor.txt
	echo -e "La prioridad de cada proceso debe de estar entre $pri_minima y $pri_maxima" >>informeBN.txt
	printf "\n" >> informeBN.txt
}

#Función encargada de calcular qué tipo de prioridad se ha asignado, para transformar los valores dados en un rango de 0 a x
function calcularTipoPrioridad {
	if [[ ($1 -lt 0 && $2 -ge 0) || ($1 -lt 0 && $2 -lt 0 && $1 -lt $2) ]];then
		tipo_prioridad=0
		dato_primin=$(calculoSegunTipoPrioridad $tipo_prioridad $pri_minima)
		dato_primax=$(calculoSegunTipoPrioridad $tipo_prioridad $pri_maxima)
	elif [[ ($1 -ge 0 && $2 -lt 0) || ($1 -ge 0 && $2 -ge 0 && $1 -gt $2) || ($1 -lt 0 && $2 -lt 0 && $1 -gt $2) ]];then
		tipo_prioridad=1
		dato_primin=$(calculoSegunTipoPrioridad $tipo_prioridad $pri_minima)
		dato_primax=$(calculoSegunTipoPrioridad $tipo_prioridad $pri_maxima)
	elif [[ $1 -ge 0 && $2 -ge 0 && $1 -lt $2 ]];then
		tipo_prioridad=2
		dato_primin=$(calculoSegunTipoPrioridad $tipo_prioridad $pri_minima)
		dato_primax=$(calculoSegunTipoPrioridad $tipo_prioridad $pri_maxima)
		fi
}
#Función encargada de aplicar las operaciones correspondientes en una prioridad dada, para transformarla en un valor compatible con el rango de 0 a x
function calculoSegunTipoPrioridad {
	operando=0
	resultado=0
	case "$1" in
	0)
		let operando=pri_minima*-1
		let resultado=$2+operando
		echo "$resultado"
	;;
	1)
		let operando=$2*-1
		let resultado=operando+pri_minima
		echo "$resultado"
	;;
	2)
		let resultado=$2-pri_minima
		echo "$resultado"
	;;
	esac
}

#Función encargada de representar gráficamente el nombre del proceso asociado a la memoria ocupada en cada partición.	
function ImprimeLineaProcesos {
	printf "    |"
	printf "    |" >> informeColor.txt
	l=0
	
    for (( je1=0;je1<$cap_memoria;je1++ ));do
    	if [[ $je1 -eq ${part_init[$wr1]} ]];then
			let carac1=carac1+3
			if [[ $(expr longitud-carac1) -ge 0 ]];then
				printf " "
				printf "   " >> informeColor.txt
			else
				break;
			fi

			let carac1=carac1+3
			if [[ $(expr longitud-carac1) -ge 0 ]];then

				printf "${mapp[$je1]}"
				
				printf "${mapp[$je1]}" >> informeColor.txt
			else
				break;
			fi
			let wr1++      
    	else
			let carac1=carac1+3
			if [[ $(expr longitud-carac1) -ge 0 ]];then
				printf "${mapp[$je1]}"
        		printf "${mapp[$je1]}" >> informeColor.txt
			else
				break;
			fi
        fi
    done
}

#Función (B&W) encargada de representar gráficamente el nombre del proceso asociado a la memoria ocupada en cada partición.	
function ImprimeLineaProcesosBW {
	printf "    |" >>informeBN.txt
	l=0
    for (( je1;je1<$cap_memoria;je1++ ));do
    	if [[ $je1 -eq ${part_init[$wr1]} ]];then
			let carac1=carac1+3
			if [[ `expr longitud-carac1` -ge 0 ]];then
				printf "   " >>informeBN.txt
			else
				break;
			fi

			let carac1=carac1+3
			if [[ `expr longitud-carac1` -ge 0 ]];then
				printf "${mappb[$je1]}" >>informeBN.txt
			else
				break;
			fi
			let wr1++      
    	else
			let carac1=carac1+3
			if [[ `expr longitud-carac1` -ge 0 ]];then
				printf "${mappb[$je1]}" >>informeBN.txt
			else
				break;
			fi
        fi
    done
}

#Función encargada de representar gráficamente la memoria
function ImprimeMemoria {
	l=0
	if [ $je2 -eq 0 ];then
		printf " BM |"
		printf " BM |" >> informeColor.txt
	else
		printf "    |"
		printf "    |" >> informeColor.txt
	fi
    for (( je2;je2<=$cap_memoria;je2++ ));do
		if [[ $je2 -eq ${part_init[$wr2]} ]];then
			let carac2=carac2+3
			if [[ `expr longitud-carac2` -ge 0 ]];then
				printf "|"
				printf "|" >> informeColor.txt
			else
				break;
			fi

			let carac2=carac2+3
			if [[ `expr longitud-carac2` -ge 0 ]];then
				printf "${map[$je2]}"
				printf "${map[$je2]}" >> informeColor.txt
			else
				break;
			fi
			let wr2++

		elif [ $je2 -eq $cap_memoria ];then
			printf "| M=$cap_memoria "	
			printf "|" >> informeColor.txt
			terminar=1
		else
			let carac2=carac2+3
			if [[ `expr longitud-carac2` -ge 0 ]];then
				printf "${map[$je2]}"
    			printf "${map[$je2]}" >> informeColor.txt
			else
				break;
			fi
			
		fi
		
    done
}

#Función (B&W) encargada de representar gráficamente la memoria
function ImprimeMemoriaBW {
	l=0
	if [ $je2 -eq 0 ];then
		printf " BM |" >>informeBN.txt
	else
		printf "    |" >>informeBN.txt
	fi
    for (( je2;je2<=$cap_memoria;je2++ ));do
		if [[ $je2 -eq ${part_init[$wr2]} ]];then
			let carac2=carac2+3
			if [[ `expr longitud-carac2` -ge 0 ]];then
				printf " | " >>informeBN.txt
			else
				break;
			fi

			let carac2=carac2+3
			if [[ `expr longitud-carac2` -ge 0 ]];then
				printf "${mapb[$je2]}" >>informeBN.txt
			else
				break;
			fi
			let wr2++

		elif [ $je2 -eq $cap_memoria ];then
			printf "|" >>informeBN.txt
			terminar=1
		else
			let carac2=carac2+3
			if [[ `expr longitud-carac2` -ge 0 ]];then
				printf "${mapb[$je2]}" >>informeBN.txt
			else
				break;
			fi
		fi
    done
}

#Función encargada de representar gráficamente el tamaño inicial y final asociado a cada partición.
function ImprimeLineaFinal {
	l=0
	mapafinal
	mapamemorialibre
	printf "    |"
	printf "    |" >> informeColor.txt

    for (( je3;je3<$cap_memoria;je3++ ));do
		if [[ $je3 -eq ${part_init[$wr3]} ]]; then
			if [ "${part_init[$wr3]}" -eq 0 ];then
				let carac3=carac3+3
				if [[ `expr longitud-carac3` -ge 0 ]];then
					printf "%1d" "${part_init[0]}"
					printf "%3d" "${part_init[0]}" >> informeColor.txt
				else
					break;
				fi
			else
				let carac3=carac3+3
				if [[ `expr longitud-carac3` -ge 0 ]];then
					printf ""
					printf "   " >> informeColor.txt
				else
					break;
				fi
				let carac3=carac3+3
				if [[ `expr longitud-carac3` -ge 0 ]];then
					printf "%4d" "${part_init[$wr3]}"
					printf "%3d" "${part_init[$wr3]}" >> informeColor.txt
				else
					break;
				fi
			fi
			let wr3++
		else
			let carac3=carac3+3
			if [[ `expr longitud-carac3` -ge 0 ]];then
        		printf "%3s" "${mapf[$je3]}"
        		printf "%3s" "${mapf[$je3]}" >> informeColor.txt
			else
				break;
			fi
		fi
    done
}

#Función (B&W) encargada de representar gráficamente el tamaño inicial y final asociado a cada partición.
function ImprimeLineaFinalBW {
	l=0
	mapafinal
	mapamemorialibre
	printf "    |" >>informeBN.txt

    for (( je3;je3<$cap_memoria;je3++ ));do
		if [[ $je3 -eq ${part_init[$wr3]} ]]; then
			if [ "${part_init[$wr3]}" -eq 0 ];then
				let carac3=carac3+3
				if [[ `expr longitud-carac3` -ge 0 ]];then
					printf "%3d" "${part_init[0]}" >>informeBN.txt
				else
					break;
				fi
			else
				let carac3=carac3+3
				if [[ `expr longitud-carac3` -ge 0 ]];then
					printf "   " >>informeBN.txt
				else
					break;
				fi
				let carac3=carac3+3
				if [[ `expr longitud-carac3` -ge 0 ]];then
					printf "%3d" "${part_init[$wr3]}" >>informeBN.txt
				else
					break;
				fi
			fi
			let wr3++
		else
			let carac3=carac3+3
			if [[ `expr longitud-carac3` -ge 0 ]];then
        		printf "%3s" "${mapf[$je3]}" >>informeBN.txt
			else
				break;
			fi
		fi
    done
}

function ImprimeLineaParticiones {
	printf "    |"
	printf "    |" >> informeColor.txt
	l=0
	
    for (( je4=0;je4<$cap_memoria;je4++ ));do
    	if [[ $je4 -eq ${part_init[$wr4]} ]];then
			let carac4=carac4+3
			if [[ $(expr longitud-carac4) -ge 0 ]];then
				printf "P"

				printf "   " >> informeColor.txt
			else
				break;
			fi

			let carac4=carac4+3
			if [[ $(expr longitud-carac4) -ge 0 ]];then
				printf "RT${wr4}"
				printf "RT${wr4}" >> informeColor.txt
				printf "${mapp[$je4]}" >> informeColor.txt
			else
				break;
			fi
			let wr4++      
    	else
			let carac4=carac4+3
			if [[ $(expr longitud-carac4) -ge 0 ]];then
				printf "${mapp[$je4]}"
        		printf "${mapp[$je4]}" >> informeColor.txt
			else
				break;
			fi
        fi
    done
	
}

#Función encargada de asociar procesos a la gráfica del tiempo.
function ImprimeProcesos {

	l=0
	printf "    |"
	printf "    |" >> informeColor.txt
	for (( je1=0;je1<=$clock;je1++ ));do
		let carac1=carac1+3
		if [[ `expr longitud-carac1` -ge 0 ]];then
        	printf "${mappd[$je1]}"
        	printf "${mappd[$je1]}" >> informeColor.txt
		else
			break;
		fi        
    done
	
}

#Función (B&W) encargada de asociar procesos a la gráfica del tiempo.
function ImprimeProcesosBW {
	l=0
	printf "    |" >>informeBN.txt
	for (( je1;je1<=$clock;je1++ ));do
		let carac1=carac1+3
		if [[ `expr longitud-carac1` -ge 0 ]];then
        	printf "${mappdb[$je1]}" >>informeBN.txt
		else
			break;
		fi        
    done
}

#Función encargada de representar la gráfica que indica la ejecución de cada uno de los procesos respecto al tiempo.
function ImprimeGrafica {
	l=0
	if [[ $je2 -eq 0 ]];then
		#printf "    |"
		printf " BT |"
		printf " BT |" >> informeColor.txt
	else
		printf "    |"
		printf "    |" >> informeColor.txt
	fi
    for (( je2;je2<=$clock;je2++ ));do
		let carac2=carac2+3
		if [[ `expr longitud-carac2` -ge 0 ]];then
        	printf "${mapg[$je2]}"
        	printf "${mapg[$je2]}" >> informeColor.txt
		else
			break;
		fi      
    done
	
	while [[ $terminar -eq 0 ]];do
		if [[ $imprimir_status -eq -1 ]];then
			let carac2=carac2+3
			if [[ `expr longitud-carac2` -ge 0 ]];then
				printf "   "
				printf "   " >> informeColor.txt
				imprimir_status=0
			else
				break;
			fi
		elif [[ $imprimir_status -eq 0 ]];then
			let carac2=carac2+3
			if [[ `expr longitud-carac2` -ge 0 ]];then
				printf "|T= "
				printf "|T=" >> informeColor.txt
				imprimir_status=1
			else
				break;
			fi
		else
			let carac2=carac2+3
			if [[ `expr longitud-carac2` -ge 0 ]];then
				printf "%3d" $clock
				printf "%3d" $clock >> informeColor.txt
				terminar=1
			else
				break;
			fi
		fi
	done
}

#Función (B&W) encargada de representar la gráfica que indica la ejecución de cada uno de los procesos respecto al tiempo.
function ImprimeGraficaBW {
	l=0
	if [[ $je2 -eq 0 ]];then
		printf " BT |" >>informeBN.txt
	else
		printf "    |" >>informeBN.txt
	fi
    for (( je2;je2<=$clock;je2++ ));do
		let carac2=carac2+3
		if [[ `expr longitud-carac2` -ge 0 ]];then
        	printf "${mapgb[$je2]}" >>informeBN.txt
		else
			break;
		fi      
    done
	
	while [[ $terminar -eq 0 ]];do
		if [[ $imprimir_status -eq -1 ]];then
			let carac2=carac2+3
			if [[ `expr longitud-carac2` -ge 0 ]];then
				printf "   " >>informeBN.txt
				imprimir_status=0
			else
				break;
			fi
		elif [[ $imprimir_status -eq 0 ]];then
			let carac2=carac2+3
			if [[ `expr longitud-carac2` -ge 0 ]];then
				printf "|T=" >>informeBN.txt
				imprimir_status=1
			else
				break;
			fi
		else
			let carac2=carac2+3
			if [[ `expr longitud-carac2` -ge 0 ]];then
				printf "%3d" $clock >>informeBN.txt
				terminar=1
			else
				break;
			fi
		fi
	done
}

#Función encargada de asociar el tiempo a la gráfica del tiempo.
function ImprimeLineaTemporal {
	l=0
	printf "    |"
	printf "|" >> informeColor.txt
    for (( je3;je3<=$clock;je3++ ));do
		let carac3=carac3+1
		if [[ `expr longitud-carac3` -ge 0 ]];then
			if [[ ${mapnum[$je3]} -ne "" ]];then
        		printf "%3d" "${mapnum[$je3]}"
        		printf "%3d" "${mapnum[$je3]}" >> informeColor.txt    
			else
				printf "${mapnum[$je3]}"
				printf "${mapnum[$je3]}" >> informeColor.txt
			fi
		else
			break;
		fi
    done
}

#Función (B&W) encargada de asociar el tiempo a la gráfica del tiempo.
function ImprimeLineaTemporalBW {
	l=0
	printf "    |" >>informeBN.txt
    for (( je3;je3<=$clock;je3++ ));do
		let carac3=carac3+3
		if [[ `expr longitud-carac3` -ge 0 ]];then
			if [[ ${mapnum[$je3]} -ne "   " ]];then
        		printf "%3d" "${mapnum[$je3]}" >>informeBN.txt    
			else
				printf "${mapnum[$je3]}" >>informeBN.txt
			fi
		else
			break;
		fi
    done
}

#Función que imprime en pantalla y en el informe una tabla con cada una de las caracteristicas de los procesos introducidos.
function State {
	echo ""
	echo "" >> informeColor.txt
	echo "" >> informeBN.txt
	printf "┌────┬─────┬─────┬─────┬─────┬──────┬──────┬──────┬──────┬───────────────────┐\n"	
	printf "│Ref │ Tll │ Tej │ Mem │ Pri │ Tesp │ Tret │ Trej │ Part │ Estado            │\n"
	printf "├────┼─────┼─────┼─────┼─────┼──────┼──────┼──────┼──────┼───────────────────┤\n"

	printf "Ref │ Tll │ Tej │ Mem │ Pri │ Tesp │ Tret │ Trej │ Part │ Estado \n">> informeColor.txt
	printf "Ref │ Tll │ Tej │ Mem │ Pri │ Tesp │ Tret │ Trej │ Part │ Estado \n">> informeBN.txt

	for (( i2=0;i2<${#memori[@]};i2++));do

		if [[ ${proc_status[$i2]} -eq 0 ]];then
			printf "│${colores[$i2]}%s${NC} │ ${colores[$i2]}%3d${NC} │ ${colores[$i2]}%3d${NC} │ ${colores[$i2]}%3d${NC} │${blanco} ${colores[$i2]}%3d${blanco} │    ${colores[$i2]}-${NC} ${colores[$i2]}${blanco}│    -${NC} ${colores[$i2]}${blanco}│    -${NC} ${colores[$i2]}${blanco}│    - ${blanco}│${NC} ${colores[$i2]}%s${NC} │\n" "${procesosc[$i2]}" "${templl[$i2]}" "${tiempofijo[$i2]}" "${memori[$i2]}" "${prioridad[$i2]}" "${estado[$i2]}"
			printf " ${colores[$i2]}%s${NC} ${colores[$i2]}%3d${NC} ${colores[$i2]}%3d${NC} ${colores[$i2]}%3d${NC} ${colores[$i2]}%3d${NC} ${colores[$i2]}   -${NC} ${colores[$i2]}   -${NC} ${colores[$i2]}   -${NC} ${colores[$i2]}   -${NC} ${colores[$i2]}%s${NC}\n" "${procesosc[$i2]}" "${templl[$i2]}" "${tiempofijo[$i2]}" "${memori[$i2]}" "${prioridad[$i2]}" "${estado[$i2]}" >> informeColor.txt
			printf " %s %3d %3d %3d %3d -    -    -    - %s\n" "${procesosc[$i2]}" "${templl[$i2]}" "${tiempofijo[$i2]}" "${memori[$i2]}" "${prioridad[$i2]}" "${estado[$i2]}" >> informeBN.txt
		elif [[ ${proc_status[$i2]} -eq 1 || ${proc_status[$i2]} -eq 4 ]]; then
			printf "│${colores[$i2]}%s${NC} │ ${colores[$i2]}%3d${NC} │ ${colores[$i2]}%3d${NC} │ ${colores[$i2]}%3d${NC} │ ${colores[$i2]}%3d${NC} │ ${colores[$i2]}%4s${NC} | ${colores[$i2]}%4s${NC} | ${colores[$i2]}   -${NC} | ${colores[$i2]}   - ${NC}| ${colores[$i2]}%s${NC} │\n" "${procesosc[$i2]}" "${templl[$i2]}" "${tiempofijo[$i2]}" "${memori[$i2]}" "${prioridad[$i2]}" "${esperav[$i2]}" "${retornov[$i2]}" "${estado[$i2]}"
			printf " ${colores[$i2]}%s${NC} ${colores[$i2]}%3d${NC} ${colores[$i2]}%3d${NC} ${colores[$i2]}%3d${NC} ${colores[$i2]}%3d${NC} ${colores[$i2]}%4s${NC} ${colores[$i2]}%4s${NC} ${colores[$i2]}   -${NC} ${colores[$i2]}   -${NC} ${colores[$i2]}%s${NC}\n" "${procesosc[$i2]}" "${templl[$i2]}" "${tiempofijo[$i2]}" "${memori[$i2]}" "${prioridad[$i2]}" "${esperav[$i2]}" "${retornov[$i2]}" "${estado[$i2]}" >> informeColor.txt
			printf " %s %3d %3d %3d %3d %4s %4s    -    - %s\n" "${procesosc[$i2]}" "${templl[$i2]}" "${tiempofijo[$i2]}" "${memori[$i2]}" "${prioridad[$i2]}" "${esperav[$i2]}" "${retornov[$i2]}" "${estado[$i2]}" >> informeBN.txt
		else
			printf "│${colores[$i2]}%s${NC} | ${colores[$i2]}%3d${NC} | ${colores[$i2]}%3d${NC} | ${colores[$i2]}%3d${NC} | ${colores[$i2]}%3d${NC} | ${colores[$i2]}%4s${NC} | ${colores[$i2]}%4s${NC} | ${colores[$i2]}%4s${NC} | ${colores[$i2]}%4s${NC} | ${colores[$i2]}%s${NC}      │\n" "${procesosc[$i2]}" "${templl[$i2]}" "${tiempofijo[$i2]}" "${memori[$i2]}" "${prioridad[$i2]}" "${esperav[$i2]}" "${retornov[$i2]}" "${tiempo[$i2]}" "${partition_pos[$i2]}" "${estado[$i2]}"
			printf " ${colores[$i2]}%s${NC} ${colores[$i2]}%3d${NC} ${colores[$i2]}%3d${NC} ${colores[$i2]}%3d${NC} ${colores[$i2]}%3d${NC} ${colores[$i2]}%4s${NC} ${colores[$i2]}%4s${NC} ${colores[$i2]}%4s${NC} ${colores[$i2]}%4s${NC} ${colores[$i2]}%s${NC}\n" "${procesosc[$i2]}" "${templl[$i2]}" "${tiempofijo[$i2]}" "${memori[$i2]}" "${prioridad[$i2]}" "${esperav[$i2]}" "${retornov[$i2]}" "${tiempo[$i2]}" "${partition_pos[$i2]}" "${estado[$i2]}" >> informeColor.txt
			printf " %s %3d %3d %3d %3d %4s %4s %4s %4s %s\n" "${procesosc[$i2]}" "${templl[$i2]}" "${tiempofijo[$i2]}" "${memori[$i2]}" "${prioridad[$i2]}" "${esperav[$i2]}" "${retornov[$i2]}" "${tiempo[$i2]}" "${partition_pos[$i2]}" "${estado[$i2]}" >> informeBN.txt
		fi
	done
	printf "└────┴─────┴─────┴─────┴─────┴──────┴──────┴──────┴──────┴───────────────────┘\n"
}

#Función encargada de la implementación gráfica de las particiones.
function mapa {
	for(( l=0;l<cap_memoria;l++ ));do
		map[$l]="███"
	done
}

#Función encargada de la implementación gráfica de las particiones.
function mapaBW {
	for(( l=0;l<cap_memoria;l++ ));do
		mapb[$l]="███"
	done
}

#Función encargada de la implementación gráfica de los intervalos de tiempo de ejecución de cada uno de los procesos.
function mapagrafica {
	for ((i=0; i<num_proc;i++));do
		sumatiempo=`expr ${tiempofijo[$i]} + $sumatiempo`
		sumatiempodos=`expr $sumatiempo + ${templl[$i]}`
	done
	for(( l=1;l<=$sumatiempodos;l++ ));do
		mapg[$l]="███"
	done
}

#Función encargada de la implementación gráfica de los intervalos de tiempo de ejecución de cada uno de los procesos.
function mapagraficaBW {
	for ((i=0; i<num_proc;i++));do
		sumatiempo=`expr ${tiempofijo[$i]} + $sumatiempo`
		sumatiempodos=`expr $sumatiempo + ${templl[$i]}`
	done
	for(( l=1;l<=$sumatiempodos;l++ ));do
		mapgb[$l]="███"
	done
}

#Función encargada de la implementación gráfica de la linea de procesos en la gráfica temporal.
function mapaprocesosdos {
	for(( l=0;l<$sumatiempo;l++ ));do
		mappd[$l]="   "
	done
}

#Función encargada de la implementación gráfica de la linea de procesos en la gráfica temporal.
function mapaprocesosdosBW {
	for(( l=0;l<$sumatiempo;l++ ));do
		mappdb[$l]="   "
	done
}

#Función encargada de la implementación gráfica de la linea de procesos en la gráfica de las particiones.
function mapaprocesos {
	for(( l=0;l<cap_memoria;l++ ));do
		mapp[$l]="   "
	done
}



function mapaprocesosBW {
	for(( l=0;l<cap_memoria;l++ ));do
		mappb[$l]="   "
	done
}

#Función encargada de la implementación gráfica de la linea del tamaño que ocupa cada partición.
function mapafinal {
	mapf[0]="${part_init[$wr]}"
	for(( l=1;l<cap_memoria;l++ ));do
		mapf[$l]="   "
	done
}

function mapamemorialibre {
	local aux
	local aux2
	for (( i=0;i<n_particiones;i++ ));do
		aux=${partition_free[$i]}
		let aux2=part_fin[$i]+1
		for (( j=0;j<cap_memoria;j++ ));do
			if [[ $j -eq $aux && $aux -ne 0 && $aux -ne $aux2 ]];then
				mapf[$j]=$aux
			fi
		done
	done
}

#Función encargada de la implementación gráfica de la linea del tiempo en la gráfica temporal.
function mapatemporal {
	for(( l=0;l<$sumatiempodos;l++ ));do
		mapt[$l]=""
	done
}

#Función encargada de la correcta implementación de las unidades en la banda de tiempo
function mapatiempos {
	for(( l=0;l<$sumatiempodos;l++ ));do
		mapnum[$l]="   "
	done
}
#Función encargada de añadir los números que deben de aparecer en las unidades de la banda de tiempo
function ocupamapatiempos {
	if [[ $clock -lt 10 ]];then
		mapnum[$1]="$1"
	elif [[ $clock -lt 100 ]];then
		mapnum[$1]="$1"
	else
		mapnum[$1]=$1
	fi
}

#Función encargada de ocupar con los procesos las particiones gráficamente sustituyendo el caracter que simboliza el tamaño de la partición (█) por el color asociado al proceso.
function OcupaMemoria() {
	#$1: part_init[x] //Tamaño inicial de la partición
	#$2: memori[y] // Tamaño del proceso
	local r=0
	local t=$1
	local u=$2
	let r=t+u
	for((y=$t;y<$r;y++));do
		map[$y]="${colores[$proc]}███${NC}"

	done
}

#Función encargada de situar encima de cada partición el nombre del proceso que está alojado en ella.
function OcupaProceso() {
	mapp[$1]="${colores[$proc]}$2${NC}"
}

#Función (B&W) encargada de situar encima de cada partición el nombre del proceso que está alojado en ella.
function OcupaProcesoBW() {
	mappb[$1]="$2"
}

#Función encargada de situar encima de cada intervalo temporal el nombre del proceso correspondiente.
function OcupaProcesoDos() {
	mappd[$1]="${colores[$proc_exe]}${procesosc[$proc_exe]}${NC}"
}

#Función encargada de situar encima de cada intervalo temporal el nombre del proceso correspondiente.
function OcupaProcesoDosBW() {
	mappdb[$1]="${procesosc[$proc_exe]}"

}

#Función encargada de rellenar cada intervalo temporal
function OcupaTiempo() {
	mapg[$1]="${colores[$proc_exe]}███${NC}"
}

#Función encargada de ocupar debajo de cada intervalo temporal el tiempo en el que acaba de ejecutarse el proceso correspondiente.
function OcupaLineaTemporal() {
	mapt[$1]="${colores[$proc_exe]}$clock${NC}-"
}

#Función que desocupa la memoria sustituyendo gráficamente el nombre del proceso por el caracter que simboliza la partición (█).
function DesocupaMemoria() {
	#$1: part_inic[x]
	#$2: part_fin[x]
	for((y=$1;y<=$2;y++));do
		map[$y]="███"
	done
}

#Función que desaloja el nombre del proceso que se encuentra en una partición determinada.
function DesocupaProceso() {
	#$1: part_inic[x]
	#$2: part_fin[x]
	for((y=$1;y<=$2;y++));do
		mapp[$y]="   "
	done
}

function DesocupaProcesoBW() {
	#$1: part_inic[x]
	#$2: part_fin[x]
	for((y=$1;y<=$2;y++));do
		mappb[$y]="   "
	done
}

#Función que calcula la diferencia mínima entre la memoria que ocupa un proceso y todas las particiones, para ver en cuál se ajusta mejor
function CalculaDiferenciaMinima {
	dif_minima=100
	for (( cont_cdm=0;cont_cdm<n_particiones;cont_cdm++ ));do
		if [[ ${part_cap[$cont_cdm]} -ge ${memori[$proc]} && ${partition[$cont_cdm]} -eq 0 ]];then
			let diferenciaMem=part_cap[$cont_cdm]-memori[$proc]
			if [[ $dif_minima -ge $diferenciaMem ]];then
				dif_minima=$diferenciaMem
			fi
		fi
	done
}

#Función que introduce los procesos en la partición que mejor se ajuste, para ello, mediante un bucle, realizamos las comprobaciones pertinentes.
function AsignaMemoriaPrimerAjuste {
	#Se pone en espera a los procesos fuera del sistema
		proc=$1
	if [ ${proc_status[$proc]} -eq 0 ];then
		proc_status[$proc]=1
		evento=1
	fi

	#Si el proceso que está arriba en la cola está en espera
	if [[ $proc -ne 0 ]];then
		let proc_ant=proc-1
		if [[ ${proc_status[$proc_ant]} -eq 1 ]];then
			flag_stop=1
		fi
	fi

	for (( cont_amma=0;cont_amma<n_particiones;cont_amma++ ));do
		if [[ $flag_stop -eq 1 ]];then
			break;
		fi
		if [[ ${part_cap[$cont_amma]} -ge ${memori[$proc]} ]];then
				if [[ ${partition[$cont_amma]} -eq 0 && ${proc_status[$proc]} -eq 1 ]];then
					partition[$cont_amma]=1
					partition_pos[$proc]=$cont_amma
					let partition_free[$cont_amma]=part_init[$cont_amma]+memori[$proc]
					OcupaMemoria ${part_init[$cont_amma]} ${memori[$proc]} ${proceso[$proc]}
					OcupaProceso ${part_init[$cont_amma]} ${procesosc[$proc]}	
					OcupaProcesoBW ${part_init[$cont_amma]} ${procesosc[$proc]}	
					evento=1		
					proc_partition[$proc]=${part_init[$cont_amma]}
					proc_partition_end[$proc]=${part_fin[$cont_amma]}
					proc_status[$proc]=2
				fi
			fi
		
	done
}

#Función encargada de inicializar cada uno de los estados asociados a cada proceso.
function estadosiniciales {
	for ((i=0;i<$num_proc;i++));do
		proc_status[$i]=0
	done

	for (( i=0;i<${#part_init[@]};i++ ));do
		partition_free[$i]=0
	done

	for (( i=0;i<${#part_init[@]};i++ ));do
		partition[$i]=0
	done
}

#Función encargada de todo lo relacionado con la ejecución del algoritmo
function GestionDeMemoria {

	declare partition[${#part_init[@]}]
	declare partition_free[${#part_init[@]}]
	declare partition_pos[${#memori[@]}]
	declare proc_partition[${#memori[@]}]
	declare proc_partition_end[${#memori[@]}]
	declare proc_status[${#memori[@]}]
	mapa #Dibuja los cuadrados en $map
	mapaBW
	mapaprocesos #Inserta espacios en $mapp
	mapaprocesosBW
	mapafinal #Inserta espacios en $mapf
	mapagrafica 
	mapagraficaBW
	mapatemporal
	mapaprocesosdos
	mapaprocesosdosBW
	mapatiempos
	finbucle=0
	clock=0
	evento=0
	enEjecucion=0
	procEjecutados=0
	estadosiniciales


	while [ $finbucle -eq 0 ];do
	flag_stop=0
		for (( i=0;i<num_proc;i++ ));do
			if [[ ${templl[$i]} -le $clock && ${proc_status[$i]} -ne 4 ]];then
				AsignaMemoriaPrimerAjuste $i
			fi
		done
		clear

		if [[ $clock -eq 0 ]];then
			ocupamapatiempos $clock
		fi

		if [[ $enEjecucion -eq 0 ]];then
			priorit=$dato_primax
			momintro=-1
			for (( j=0;j<num_proc;j++ ));do
				if [[ ${templl[$j]} -le $clock && ${proc_status[$j]} -eq 2 ]];then
					if [[ ${dato_prioridad[$j]} -lt $priorit ]];then
		    			proc_exe=$j
		    			priorit=${dato_prioridad[$j]}
						momintro=${tiempintro[$j]}		
		    		elif [[ ${dato_prioridad[$j]} -eq $priorit ]];then
						if [[ $momintro -ne -1 ]];then
							if [[ ${tiempintro[$j]} -lt $momintro ]];then
								proc_exe=$j
		    					priorit=${dato_prioridad[$j]}
								momintro=${tiempintro[$j]}
							fi
						fi
					fi
				fi
			done	
			if [ -n "$proc_exe" ];then
				evento=1
				enEjecucion=1	
				proc_status[$proc_exe]=3
				OcupaProcesoDos $clock
				OcupaProcesoDosBW $clock
				flag_siguienteProceso=0				
				ocupamapatiempos $clock
			fi
		fi

		for (( i=0;i<num_proc;i++ ));do
		case ${proc_status[$i]} in
			0)
			estado[i]="Fuera del sistema"
			;;
			1)
			estado[i]="En espera        "
			;;
			2)
			estado[i]="En memoria  "
			;;
			3)
			estado[i]="En ejecución"
			;;
			4)
			estado[i]="Terminado        "
		esac
		done

		if [[ $enEjecucion -eq 1 ]];then
			let momento_ejec=$clock+1
			OcupaTiempo $momento_ejec
		fi

		if [[ $flag_siguienteProceso -eq 1 ]];then
			#let momento_ejec=$clock+1
			ocupamapatiempos $clock
			flag_siguienteProceso=0
		fi
		
		contador_division=0
		sumaEspera=0
		sumaRetorno=0
		for (( cont_numprocm=0;cont_numprocm<num_proc;cont_numprocm++ ));do
			if [[ ${proc_status[$cont_numprocm]} -ge 1 ]];then
				let sumaEspera=sumaEspera+esperav[$cont_numprocm]
				let sumaRetorno=sumaRetorno+retornov[$cont_numprocm]
				let contador_division++
			fi
		done
		if [[ $contador_division -gt 0 ]];then
			#medEspera=$(printf "%3.2f\n" $(echo "scale=2; $sumaEspera/$contador_division" | bc))
			medEspera=$(echo "$sumaEspera $contador_division" | awk '{printf "%f", $1 / $2}')
			medRetorno=$(echo "$sumaRetorno $contador_division" | awk '{printf "%f", $1 / $2}')

		else
			medEspera=0.00
			medRetorno=0.00
		fi
		#Impresión de datos en caso de que haya ocurrido algo
		if [[ $evento -eq 1 || $clock -eq 0 ]];then
			printf " PriMenor-FNI-Primer\n"
			printf " PriMenor-FNI-Primer\n" >> informeColor.txt
			printf " PriMenor-FNI-Primer\n" >>informeBN.txt
			printf " T=$clock\tPart="
			printf " T=$clock\tPart=" >> informeColor.txt
			printf " T=$clock\tPart=" >>informeBN.txt
			local count=0
			for (( i=0; i<$n_particiones; i++ )); do
			count=`expr $i + 1`
				if [ $count -eq "$n_particiones" ]; then
					printf "%d" "${part_cap[$i]}"
					printf "%d" "${part_cap[$i]}" >> informeColor.txt
					printf "%d" "${part_cap[$i]}" >>informeBN.txt
				else
					printf "%d-" "${part_cap[$i]}" 
					printf "%d-" "${part_cap[$i]}" >> informeColor.txt
					printf "%d-" "${part_cap[$i]}" >>informeBN.txt
				fi
			done
			printf "\tRango de pri=(%d,%d)" "$pri_minima" "$pri_maxima"
			printf "\tRango de pri=(%d,%d)" "$pri_minima" "$pri_maxima" >> informeColor.txt
			printf "\tRango de pri=(%d,%d)" "$pri_minima" "$pri_maxima" >>informeBN.txt
			
			State
			echo "--------------------------------------------------------------------" 
			printf " Tiempo medio de espera=$medEspera\tTiempo medio de retorno=$medRetorno\n"
			echo "--------------------------------------------------------------------" 
			printf " Tiempo medio de espera=$medEspera\tTiempo medio de retorno=$medRetorno\n" >> informeColor.txt
			printf " Tiempo medio de espera=$medEspera\tTiempo medio de retorno=$medRetorno\n" >>informeBN.txt
			longitud=$(tput cols)
			#let longitud=longitud-1
			je1=0
			carac1=5
			wr1=1
			je2=0
			carac2=5
			wr2=1
			je3=0
			carac3=5
			wr3=0
			wr4=0
			je4=0
			carac4=5
			terminar=0
			while [[ $terminar -eq 0 ]];do
				ImprimeLineaParticiones
				printf "\n"
				ImprimeLineaProcesos
				printf "\n"
				printf "\n" >> informeColor.txt
 				ImprimeMemoria
				printf "\n"
				printf "\n" >> informeColor.txt
				ImprimeLineaFinal
				printf "\n"
				printf "\n" >> informeColor.txt
				carac1=5
				carac2=5
				carac3=5
				carac4=5
			done
			je1=0
			carac1=5
			wr1=1
			je2=0
			carac2=5
			wr2=1
			je3=0
			carac3=5
			wr3=0
			wr4=0
			je4=0
			carac4=5
			terminar=0
			while [[ $terminar -eq 0 ]];do
				ImprimeLineaProcesosBW
				printf "\n" >>informeBN.txt
 				ImprimeMemoriaBW
				printf "\n" >>informeBN.txt
				ImprimeLineaFinalBW
				printf "\n" >>informeBN.txt
				carac1=5
				carac2=5
				carac3=5
				carac4=5
			done
			je1=0
			carac1=5
			wr1=0
			je2=0
			carac2=2
			wr2=0
			je3=0
			carac3=5
			wr3=0
			terminar=0
			wr4=0
			je4=0
			carac4=5
			imprimir_status=-1
			while [[ $terminar -eq 0 ]];do
				ImprimeProcesos
				printf "\n"
				printf "\n" >> informeColor.txt
				ImprimeGrafica
				printf "\n"
				printf "\n" >> informeColor.txt
				ImprimeLineaTemporal
				printf "\n"
				printf "\n" >> informeColor.txt
				carac1=5
				carac2=5
				carac3=5
				carac4=5
			done
			je1=0
			carac1=5
			wr1=0
			je2=0
			carac2=2
			wr2=0
			je3=0
			carac3=5
			wr3=0
			wr4=0
			je4=0
			carac4=5
			terminar=0
			imprimir_status=-1
			while [[ $terminar -eq 0 ]];do
				ImprimeProcesosBW
				printf "\n" >>informeBN.txt
				ImprimeGraficaBW
				printf "\n" >>informeBN.txt
				ImprimeLineaTemporalBW
				printf "\n" >>informeBN.txt
				carac1=5
				carac2=5
				carac3=5
				carac4=5
			done
			printf "\n" >> informeColor.txt
			printf "\n" >>informeBN.txt
    		printf " Pulsa Enter para ir al siguiente evento "
			read -p ""
		fi 

		evento=0
		if [ -n "$proc_exe" ];then
			let tiempo[$proc_exe]--
			let retornov[$proc_exe]++
			if [ ${tiempo[$proc_exe]} -eq 0 ];then
				proc_status[$proc_exe]=4
				evento=1
				resta
				OcupaLineaTemporal $clock
				let intervalo=clock-ini_ejec
				let intervalo=intervalo+1
				DesocupaMemoria ${proc_partition[$proc_exe]} ${proc_partition_end[$proc_exe]}
				DesocupaProceso ${proc_partition[$proc_exe]} ${proc_partition_end[$proc_exe]}
				DesocupaProcesoBW ${proc_partition[$proc_exe]} ${proc_partition_end[$proc_exe]}
				t=${partition_pos[$proc_exe]}
    			partition[$t]=0
				partition_free[$t]=0
				enEjecucion=0
				let procEjecutados++
				proc_exe=""
				flag_siguienteProceso=1
			fi
		fi

		for ((i=0;i<$num_proc;i++));do
			if [[ ${proc_status[$i]} -eq 2 || ${proc_status[$i]} -eq 1 ]];then
				let esperav[$i]++
				let retornov[$i]++
			fi
		done
		
		let clock++
		clear

		if [ $procEjecutados -eq ${#memori[@]} ];then
			finbucle=1
		fi
	done
}
function GestionDeMemoriaAutomatico {
	declare partition[${#part_init[@]}]
	declare partition_free[${#part_init[@]}]
	declare partition_pos[${#memori[@]}]
	declare proc_partition[${#memori[@]}]
	declare proc_partition_end[${#memori[@]}]
	declare proc_status[${#memori[@]}]
	mapa #Dibuja los cuadrados en $map
	mapaBW
	mapaprocesos #Inserta espacios en $mapp
	mapaprocesosBW
	mapafinal #Inserta espacios en $mapf
	mapagrafica 
	mapagraficaBW
	mapatemporal
	mapaprocesosdos
	mapaprocesosdosBW
	mapatiempos
	finbucle=0
	clock=0
	evento=0
	enEjecucion=0
	procEjecutados=0
	estadosiniciales


	while [ $finbucle -eq 0 ];do
	flag_stop=0
		for (( i=0;i<num_proc;i++ ));do
			if [[ ${templl[$i]} -le $clock && ${proc_status[$i]} -ne 4 ]];then
				AsignaMemoriaPrimerAjuste $i
			fi
		done
		clear

		if [[ $clock -eq 0 ]];then
			ocupamapatiempos $clock
		fi

		if [[ $enEjecucion -eq 0 ]];then
			priorit=$dato_primax
			momintro=-1
			for (( j=0;j<num_proc;j++ ));do
				if [[ ${templl[$j]} -le $clock && ${proc_status[$j]} -eq 2 ]];then
					if [[ ${dato_prioridad[$j]} -lt $priorit ]];then
		    			proc_exe=$j
		    			priorit=${dato_prioridad[$j]}
						momintro=${tiempintro[$j]}		
		    		elif [[ ${dato_prioridad[$j]} -eq $priorit ]];then
						if [[ $momintro -ne -1 ]];then
							if [[ ${tiempintro[$j]} -lt $momintro ]];then
								proc_exe=$j
		    					priorit=${dato_prioridad[$j]}
								momintro=${tiempintro[$j]}
							fi
						fi
					fi
				fi
			done	
			if [ -n "$proc_exe" ];then
				evento=1
				enEjecucion=1	
				proc_status[$proc_exe]=3
				OcupaProcesoDos $clock
				OcupaProcesoDosBW $clock
				flag_siguienteProceso=0				
				ocupamapatiempos $clock
			fi
		fi

		for (( i=0;i<num_proc;i++ ));do
		case ${proc_status[$i]} in
			0)
			estado[i]="Fuera del sistema"
			;;
			1)
			estado[i]="En espera        "
			;;
			2)
			estado[i]="En memoria  "
			;;
			3)
			estado[i]="En ejecución"
			;;
			4)
			estado[i]="Terminado        "
		esac
		done

		if [[ $enEjecucion -eq 1 ]];then
			let momento_ejec=$clock+1
			OcupaTiempo $momento_ejec
		fi

		if [[ $flag_siguienteProceso -eq 1 ]];then
			#let momento_ejec=$clock+1
			ocupamapatiempos $clock
			flag_siguienteProceso=0
		fi
		
		contador_division=0
		sumaEspera=0
		sumaRetorno=0
		for (( cont_numprocm=0;cont_numprocm<num_proc;cont_numprocm++ ));do
			if [[ ${proc_status[$cont_numprocm]} -ge 1 ]];then
				let sumaEspera=sumaEspera+esperav[$cont_numprocm]
				let sumaRetorno=sumaRetorno+retornov[$cont_numprocm]
				let contador_division++
			fi
		done
		if [[ $contador_division -gt 0 ]];then
			#medEspera=$(printf "%3.2f\n" $(echo "scale=2; $sumaEspera/$contador_division" | bc))
			medEspera=$(echo "$sumaEspera $contador_division" | awk '{printf "%f", $1 / $2}')
			medRetorno=$(echo "$sumaRetorno $contador_division" | awk '{printf "%f", $1 / $2}')

		else
			medEspera=0.00
			medRetorno=0.00
		fi
		#Impresión de datos en caso de que haya ocurrido algo
		if [[ $evento -eq 1 || $clock -eq 0 ]];then
			printf " PriMenor-FNI-Primer\n"
			printf " PriMenor-FNI-Primer\n" >> informeColor.txt
			printf " PriMenor-FNI-Primer\n" >>informeBN.txt
			printf " T=$clock\tPart="
			printf " T=$clock\tPart=" >> informeColor.txt
			printf " T=$clock\tPart=" >>informeBN.txt
			local count=0
			for (( i=0; i<$n_particiones; i++ )); do
			count=`expr $i + 1`
				if [ $count -eq "$n_particiones" ]; then
					printf "%d" "${part_cap[$i]}"
					printf "%d" "${part_cap[$i]}" >> informeColor.txt
					printf "%d" "${part_cap[$i]}" >>informeBN.txt
				else
					printf "%d-" "${part_cap[$i]}" 
					printf "%d-" "${part_cap[$i]}" >> informeColor.txt
					printf "%d-" "${part_cap[$i]}" >>informeBN.txt
				fi
			done
			printf "\tRango de pri=(%d,%d)" "$pri_minima" "$pri_maxima"
			printf "\tRango de pri=(%d,%d)" "$pri_minima" "$pri_maxima" >> informeColor.txt
			printf "\tRango de pri=(%d,%d)" "$pri_minima" "$pri_maxima" >>informeBN.txt
			
			State
			echo "--------------------------------------------------------------------" 
			printf " Tiempo medio de espera=$medEspera\tTiempo medio de retorno=$medRetorno\n"
			echo "--------------------------------------------------------------------" 
			printf " Tiempo medio de espera=$medEspera\tTiempo medio de retorno=$medRetorno\n" >> informeColor.txt
			printf " Tiempo medio de espera=$medEspera\tTiempo medio de retorno=$medRetorno\n" >>informeBN.txt
			longitud=$(tput cols)
			#let longitud=longitud-1
			je1=0
			carac1=5
			wr1=1
			je2=0
			carac2=5
			wr2=1
			je3=0
			carac3=5
			wr3=0
			terminar=0
			while [[ $terminar -eq 0 ]];do
				ImprimeLineaProcesos
				printf "\n"
				printf "\n" >> informeColor.txt
 				ImprimeMemoria
				printf "\n"
				printf "\n" >> informeColor.txt
				ImprimeLineaFinal
				printf "\n"
				printf "\n" >> informeColor.txt
				carac1=5
				carac2=5
				carac3=5
			done
			je1=0
			carac1=5
			wr1=1
			je2=0
			carac2=5
			wr2=1
			je3=0
			carac3=5
			wr3=0
			terminar=0
			while [[ $terminar -eq 0 ]];do
				ImprimeLineaProcesosBW
				printf "\n" >>informeBN.txt
 				ImprimeMemoriaBW
				printf "\n" >>informeBN.txt
				ImprimeLineaFinalBW
				printf "\n" >>informeBN.txt
				carac1=5
				carac2=5
				carac3=5
			done
			je1=0
			carac1=5
			wr1=0
			je2=0
			carac2=2
			wr2=0
			je3=0
			carac3=5
			wr3=0
			terminar=0
			imprimir_status=-1
			while [[ $terminar -eq 0 ]];do
				ImprimeLineaParticiones
				printf "\n"
				ImprimeProcesos
				printf "\n"
				printf "\n" >> informeColor.txt
				ImprimeGrafica
				printf "\n"
				printf "\n" >> informeColor.txt
				ImprimeLineaTemporal
				printf "\n"
				printf "\n" >> informeColor.txt
				carac1=5
				carac2=5
				carac3=5
			done
			je1=0
			carac1=5
			wr1=0
			je2=0
			carac2=2
			wr2=0
			je3=0
			carac3=5
			wr3=0
			terminar=0
			imprimir_status=-1
			while [[ $terminar -eq 0 ]];do
				ImprimeProcesosBW
				printf "\n" >>informeBN.txt
				ImprimeGraficaBW
				printf "\n" >>informeBN.txt
				ImprimeLineaTemporalBW
				printf "\n" >>informeBN.txt
				carac1=5
				carac2=5
				carac3=5
			done
			printf "\n" >> informeColor.txt
			printf "\n" >>informeBN.txt
    		printf " Esperando $secs segundos."
			sleep $secs
		fi 

		evento=0
		if [ -n "$proc_exe" ];then
			let tiempo[$proc_exe]--
			let retornov[$proc_exe]++
			if [ ${tiempo[$proc_exe]} -eq 0 ];then
				proc_status[$proc_exe]=4
				evento=1
				resta
				OcupaLineaTemporal $clock
				let intervalo=clock-ini_ejec
				let intervalo=intervalo+1
				DesocupaMemoria ${proc_partition[$proc_exe]} ${proc_partition_end[$proc_exe]}
				DesocupaProceso ${proc_partition[$proc_exe]} ${proc_partition_end[$proc_exe]}
				DesocupaProcesoBW ${proc_partition[$proc_exe]} ${proc_partition_end[$proc_exe]}
				t=${partition_pos[$proc_exe]}
    			partition[$t]=0
				partition_free[$t]=0
				enEjecucion=0
				let procEjecutados++
				proc_exe=""
				flag_siguienteProceso=1
			fi
		fi

		for ((i=0;i<$num_proc;i++));do
			if [[ ${proc_status[$i]} -eq 2 || ${proc_status[$i]} -eq 1 ]];then
				let esperav[$i]++
				let retornov[$i]++
			fi
		done
		
		let clock++
		clear

		if [ $procEjecutados -eq ${#memori[@]} ];then
			finbucle=1
		fi
	done

		
}
function GestionDeMemoriaCompleta {
	declare partition[${#part_init[@]}]
	declare partition_free[${#part_init[@]}]
	declare partition_pos[${#memori[@]}]
	declare proc_partition[${#memori[@]}]
	declare proc_partition_end[${#memori[@]}]
	declare proc_status[${#memori[@]}]
	mapa #Dibuja los cuadrados en $map
	mapaBW
	mapaprocesos #Inserta espacios en $mapp
	mapaprocesosBW
	mapafinal #Inserta espacios en $mapf
	mapagrafica 
	mapagraficaBW
	mapatemporal
	mapaprocesosdos
	mapaprocesosdosBW
	mapatiempos
	finbucle=0
	clock=0
	evento=0
	enEjecucion=0
	procEjecutados=0
	estadosiniciales


	while [ $finbucle -eq 0 ];do
	flag_stop=0
		for (( i=0;i<num_proc;i++ ));do
			if [[ ${templl[$i]} -le $clock && ${proc_status[$i]} -ne 4 ]];then
				AsignaMemoriaPrimerAjuste $i
			fi
		done
		clear

		if [[ $clock -eq 0 ]];then
			ocupamapatiempos $clock
		fi

		if [[ $enEjecucion -eq 0 ]];then
			priorit=$dato_primax
			momintro=-1
			for (( j=0;j<num_proc;j++ ));do
				if [[ ${templl[$j]} -le $clock && ${proc_status[$j]} -eq 2 ]];then
					if [[ ${dato_prioridad[$j]} -lt $priorit ]];then
		    			proc_exe=$j
		    			priorit=${dato_prioridad[$j]}
						momintro=${tiempintro[$j]}		
		    		elif [[ ${dato_prioridad[$j]} -eq $priorit ]];then
						if [[ $momintro -ne -1 ]];then
							if [[ ${tiempintro[$j]} -lt $momintro ]];then
								proc_exe=$j
		    					priorit=${dato_prioridad[$j]}
								momintro=${tiempintro[$j]}
							fi
						fi
					fi
				fi
			done	
			if [ -n "$proc_exe" ];then
				evento=1
				enEjecucion=1	
				proc_status[$proc_exe]=3
				OcupaProcesoDos $clock
				OcupaProcesoDosBW $clock
				flag_siguienteProceso=0				
				ocupamapatiempos $clock
			fi
		fi

		for (( i=0;i<num_proc;i++ ));do
		case ${proc_status[$i]} in
			0)
			estado[i]="Fuera del sistema"
			;;
			1)
			estado[i]="En espera        "
			;;
			2)
			estado[i]="En memoria  "
			;;
			3)
			estado[i]="En ejecución"
			;;
			4)
			estado[i]="Terminado        "
		esac
		done

		if [[ $enEjecucion -eq 1 ]];then
			let momento_ejec=$clock+1
			OcupaTiempo $momento_ejec
		fi

		if [[ $flag_siguienteProceso -eq 1 ]];then
			#let momento_ejec=$clock+1
			ocupamapatiempos $clock
			flag_siguienteProceso=0
		fi
		
		contador_division=0
		sumaEspera=0
		sumaRetorno=0
		for (( cont_numprocm=0;cont_numprocm<num_proc;cont_numprocm++ ));do
			if [[ ${proc_status[$cont_numprocm]} -ge 1 ]];then
				let sumaEspera=sumaEspera+esperav[$cont_numprocm]
				let sumaRetorno=sumaRetorno+retornov[$cont_numprocm]
				let contador_division++
			fi
		done
		if [[ $contador_division -gt 0 ]];then
			#medEspera=$(printf "%3.2f\n" $(echo "scale=2; $sumaEspera/$contador_division" | bc))
			medEspera=$(echo "$sumaEspera $contador_division" | awk '{printf "%f", $1 / $2}')
			medRetorno=$(echo "$sumaRetorno $contador_division" | awk '{printf "%f", $1 / $2}')

		else
			medEspera=0.00
			medRetorno=0.00
		fi
		#Impresión de datos en caso de que haya ocurrido algo
		if [[ $evento -eq 1 || $clock -eq 0 ]];then
			printf " PriMenor-FNI-Primer\n"
			printf " PriMenor-FNI-Primer\n" >> informeColor.txt
			printf " PriMenor-FNI-Primer\n" >>informeBN.txt
			printf " T=$clock\tPart="
			printf " T=$clock\tPart=" >> informeColor.txt
			printf " T=$clock\tPart=" >>informeBN.txt
			local count=0
			for (( i=0; i<$n_particiones; i++ )); do
			count=`expr $i + 1`
				if [ $count -eq "$n_particiones" ]; then
					printf "%d" "${part_cap[$i]}"
					printf "%d" "${part_cap[$i]}" >> informeColor.txt
					printf "%d" "${part_cap[$i]}" >>informeBN.txt
				else
					printf "%d-" "${part_cap[$i]}" 
					printf "%d-" "${part_cap[$i]}" >> informeColor.txt
					printf "%d-" "${part_cap[$i]}" >>informeBN.txt
				fi
			done
			printf "\tRango de pri=(%d,%d)" "$pri_minima" "$pri_maxima"
			printf "\tRango de pri=(%d,%d)" "$pri_minima" "$pri_maxima" >> informeColor.txt
			printf "\tRango de pri=(%d,%d)" "$pri_minima" "$pri_maxima" >>informeBN.txt
			
			State
			echo "--------------------------------------------------------------------" 
			printf " Tiempo medio de espera=$medEspera\tTiempo medio de retorno=$medRetorno\n"
			echo "--------------------------------------------------------------------" 
			printf " Tiempo medio de espera=$medEspera\tTiempo medio de retorno=$medRetorno\n" >> informeColor.txt
			printf " Tiempo medio de espera=$medEspera\tTiempo medio de retorno=$medRetorno\n" >>informeBN.txt
			longitud=$(tput cols)
			#let longitud=longitud-1
			je1=0
			carac1=5
			wr1=1
			je2=0
			carac2=5
			wr2=1
			je3=0
			carac3=5
			wr3=0
			terminar=0
			while [[ $terminar -eq 0 ]];do
				ImprimeLineaProcesos
				printf "\n"
				printf "\n" >> informeColor.txt
 				ImprimeMemoria
				printf "\n"
				printf "\n" >> informeColor.txt
				ImprimeLineaFinal
				printf "\n"
				printf "\n" >> informeColor.txt
				carac1=5
				carac2=5
				carac3=5
			done
			je1=0
			carac1=5
			wr1=1
			je2=0
			carac2=5
			wr2=1
			je3=0
			carac3=5
			wr3=0
			terminar=0
			while [[ $terminar -eq 0 ]];do
				ImprimeLineaProcesosBW
				printf "\n" >>informeBN.txt
 				ImprimeMemoriaBW
				printf "\n" >>informeBN.txt
				ImprimeLineaFinalBW
				printf "\n" >>informeBN.txt
				carac1=5
				carac2=5
				carac3=5
			done
			je1=0
			carac1=5
			wr1=0
			je2=0
			carac2=2
			wr2=0
			je3=0
			carac3=5
			wr3=0
			terminar=0
			imprimir_status=-1
			while [[ $terminar -eq 0 ]];do
				ImprimeLineaParticiones
				printf "\n"
				ImprimeProcesos
				printf "\n"
				printf "\n" >> informeColor.txt
				ImprimeGrafica
				printf "\n"
				printf "\n" >> informeColor.txt
				ImprimeLineaTemporal
				printf "\n"
				printf "\n" >> informeColor.txt
				carac1=5
				carac2=5
				carac3=5
			done
			je1=0
			carac1=5
			wr1=0
			je2=0
			carac2=2
			wr2=0
			je3=0
			carac3=5
			wr3=0
			terminar=0
			imprimir_status=-1
			while [[ $terminar -eq 0 ]];do
				ImprimeProcesosBW
				printf "\n" >>informeBN.txt
				ImprimeGraficaBW
				printf "\n" >>informeBN.txt
				ImprimeLineaTemporalBW
				printf "\n" >>informeBN.txt
				carac1=5
				carac2=5
				carac3=5
			done
			printf "\n" >> informeColor.txt
			printf "\n" >>informeBN.txt
		fi 

		evento=0
		if [ -n "$proc_exe" ];then
			let tiempo[$proc_exe]--
			let retornov[$proc_exe]++
			if [ ${tiempo[$proc_exe]} -eq 0 ];then
				proc_status[$proc_exe]=4
				evento=1
				resta
				OcupaLineaTemporal $clock
				let intervalo=clock-ini_ejec
				let intervalo=intervalo+1
				DesocupaMemoria ${proc_partition[$proc_exe]} ${proc_partition_end[$proc_exe]}
				DesocupaProceso ${proc_partition[$proc_exe]} ${proc_partition_end[$proc_exe]}
				DesocupaProcesoBW ${proc_partition[$proc_exe]} ${proc_partition_end[$proc_exe]}
				t=${partition_pos[$proc_exe]}
    			partition[$t]=0
				partition_free[$t]=0
				enEjecucion=0
				let procEjecutados++
				proc_exe=""
				flag_siguienteProceso=1
			fi
		fi

		for ((i=0;i<$num_proc;i++));do
			if [[ ${proc_status[$i]} -eq 2 || ${proc_status[$i]} -eq 1 ]];then
				let esperav[$i]++
				let retornov[$i]++
			fi
		done
		
		let clock++
		clear

		if [ $procEjecutados -eq ${#memori[@]} ];then
			finbucle=1
		fi
	done
}
function GestionDeMemoriaFinal {
	declare partition[${#part_init[@]}]
	declare partition_free[${#part_init[@]}]
	declare partition_pos[${#memori[@]}]
	declare proc_partition[${#memori[@]}]
	declare proc_partition_end[${#memori[@]}]
	declare proc_status[${#memori[@]}]
	mapa > /dev/null 2>&1 #Dibuja los cuadrados en $map
	mapaBW > /dev/null 2>&1
	mapaprocesos > /dev/null 2>&1
	mapaprocesosBW > /dev/null 2>&1
	mapafinal > /dev/null 2>&1
	mapagrafica > /dev/null 2>&1
	mapagraficaBW > /dev/null 2>&1
	mapatemporal > /dev/null 2>&1
	mapaprocesosdos > /dev/null 2>&1 
	mapaprocesosdosBW > /dev/null 2>&1
	mapatiempos > /dev/null 2>&1
	finbucle=0 > /dev/null 2>&1
	clock=0 > /dev/null 2>&1
	evento=0 > /dev/null 2>&1
	enEjecucion=0 > /dev/null 2>&1
	procEjecutados=0 > /dev/null 2>&1
	estadosiniciales > /dev/null 2>&1
 

	while [ $finbucle -eq 0 ];do
	flag_stop=0
		for (( i=0;i<num_proc;i++ ));do
			if [[ ${templl[$i]} -le $clock && ${proc_status[$i]} -ne 4 ]];then
				AsignaMemoriaPrimerAjuste $i
			fi
		done
		clear

		if [[ $clock -eq 0 ]];then
			ocupamapatiempos $clock > /dev/null 2>&1
		fi

		if [[ $enEjecucion -eq 0 ]];then
			priorit=$dato_primax
			momintro=-1
			for (( j=0;j<num_proc;j++ ));do
				if [[ ${templl[$j]} -le $clock && ${proc_status[$j]} -eq 2 ]];then
					if [[ ${dato_prioridad[$j]} -lt $priorit ]];then
		    			proc_exe=$j
		    			priorit=${dato_prioridad[$j]}
						momintro=${tiempintro[$j]}		
		    		elif [[ ${dato_prioridad[$j]} -eq $priorit ]];then
						if [[ $momintro -ne -1 ]];then
							if [[ ${tiempintro[$j]} -lt $momintro ]];then
								proc_exe=$j
		    					priorit=${dato_prioridad[$j]}
								momintro=${tiempintro[$j]}
							fi
						fi
					fi
				fi
			done	
			if [ -n "$proc_exe" ];then
				evento=1
				enEjecucion=1	
				proc_status[$proc_exe]=3
				OcupaProcesoDos $clock
				OcupaProcesoDosBW $clock
				flag_siguienteProceso=0				
				ocupamapatiempos $clock
			fi
		fi

		for (( i=0;i<num_proc;i++ ));do
		case ${proc_status[$i]} in
			0)
			estado[i]="Fuera del sistema"
			;;
			1)
			estado[i]="En espera        "
			;;
			2)
			estado[i]="En memoria  "
			;;
			3)
			estado[i]="En ejecución"
			;;
			4)
			estado[i]="Terminado        "
		esac
		done

		if [[ $enEjecucion -eq 1 ]];then
			let momento_ejec=$clock+1
			OcupaTiempo $momento_ejec
		fi

		if [[ $flag_siguienteProceso -eq 1 ]];then
			#let momento_ejec=$clock+1
			ocupamapatiempos $clock
			flag_siguienteProceso=0
		fi
		
		contador_division=0
		sumaEspera=0
		sumaRetorno=0
		for (( cont_numprocm=0;cont_numprocm<num_proc;cont_numprocm++ ));do
			if [[ ${proc_status[$cont_numprocm]} -ge 1 ]];then
				let sumaEspera=sumaEspera+esperav[$cont_numprocm]
				let sumaRetorno=sumaRetorno+retornov[$cont_numprocm]
				let contador_division++
			fi
		done
		if [[ $contador_division -gt 0 ]];then
			#medEspera=$(printf "%3.2f\n" $(echo "scale=2; $sumaEspera/$contador_division" | bc))
			medEspera=$(echo "$sumaEspera $contador_division" | awk '{printf "%f", $1 / $2}')
			medRetorno=$(echo "$sumaRetorno $contador_division" | awk '{printf "%f", $1 / $2}')

		else
			medEspera=0.00
			medRetorno=0.00
		fi
		#Impresión de datos en caso de que haya ocurrido algo
		if [[ $evento -eq 1 || $clock -eq 0 ]];then
			printf " PriMenor-FNI-Primer\n" > /dev/null 2>&1
			printf " PriMenor-FNI-Primer\n" >> informeColor.txt
			printf " PriMenor-FNI-Primer\n" >>informeBN.txt
			printf " T=$clock\tPart=" > /dev/null 2>&1
			printf " T=$clock\tPart=" >> informeColor.txt
			printf " T=$clock\tPart=" >>informeBN.txt
			local count=0
			for (( i=0; i<$n_particiones; i++ )); do
			count=`expr $i + 1`
				if [ $count -eq "$n_particiones" ]; then
					printf "%d" "${part_cap[$i]}" > /dev/null 2>&1
					printf "%d" "${part_cap[$i]}" >> informeColor.txt
					printf "%d" "${part_cap[$i]}" >>informeBN.txt
				else
					printf "%d-" "${part_cap[$i]}" > /dev/null 2>&1
					printf "%d-" "${part_cap[$i]}" >> informeColor.txt
					printf "%d-" "${part_cap[$i]}" >>informeBN.txt
				fi
			done
			printf "\tRango de pri=(%d,%d)" "$pri_minima" "$pri_maxima" > /dev/null 2>&1
			printf "\tRango de pri=(%d,%d)" "$pri_minima" "$pri_maxima" >> informeColor.txt
			printf "\tRango de pri=(%d,%d)" "$pri_minima" "$pri_maxima" >>informeBN.txt
						printf "Calculando, por favor, espere."
			State > /dev/null 2>&1
			printf " Tiempo medio de espera=$medEspera\tTiempo medio de retorno=$medRetorno\n" > /dev/null 2>&1
			printf " Tiempo medio de espera=$medEspera\tTiempo medio de retorno=$medRetorno\n" >> informeColor.txt
			printf " Tiempo medio de espera=$medEspera\tTiempo medio de retorno=$medRetorno\n" >>informeBN.txt
			longitud=$(tput cols)
			#let longitud=longitud-1
			je1=0
			carac1=5
			wr1=1
			je2=0
			carac2=5
			wr2=1
			je3=0
			carac3=5
			wr3=0
			terminar=0
			while [[ $terminar -eq 0 ]];do
				ImprimeLineaProcesos > /dev/null 2>&1
				printf "\n" > /dev/null 2>&1
				printf "\n" >> informeColor.txt
 				ImprimeMemoria > /dev/null 2>&1
				printf "\n" > /dev/null 2>&1
				printf "\n" >> informeColor.txt
				ImprimeLineaFinal > /dev/null 2>&1
				printf "\n" > /dev/null 2>&1
				printf "\n" >> informeColor.txt
				carac1=5
				carac2=5
				carac3=5
			done
			je1=0
			carac1=5
			wr1=1
			je2=0
			carac2=5
			wr2=1
			je3=0
			carac3=5
			wr3=0
			terminar=0
			while [[ $terminar -eq 0 ]];do
				ImprimeLineaProcesosBW > /dev/null 2>&1
				printf "\n" >>informeBN.txt
 				ImprimeMemoriaBW > /dev/null 2>&1
				printf "\n" >>informeBN.txt
				ImprimeLineaFinalBW > /dev/null 2>&1
				printf "\n" >>informeBN.txt
				carac1=5
				carac2=5
				carac3=5
			done
			je1=0
			carac1=5
			wr1=0
			je2=0
			carac2=2
			wr2=0
			je3=0
			carac3=5
			wr3=0
			terminar=0
			imprimir_status=-1
			while [[ $terminar -eq 0 ]];do
				ImprimeProcesos > /dev/null 2>&1
				printf "\n" > /dev/null 2>&1
				printf "\n" >> informeColor.txt
				ImprimeGrafica > /dev/null 2>&1
				printf "\n" > /dev/null 2>&1
				printf "\n" >> informeColor.txt
				ImprimeLineaTemporal > /dev/null 2>&1
				printf "\n" > /dev/null 2>&1
				printf "\n" >> informeColor.txt
				carac1=5
				carac2=5
				carac3=5
			done
			je1=0
			carac1=5
			wr1=0
			je2=0
			carac2=2
			wr2=0
			je3=0
			carac3=5
			wr3=0
			terminar=0
			imprimir_status=-1
			while [[ $terminar -eq 0 ]];do
				ImprimeProcesosBW
				printf "\n" >>informeBN.txt
				ImprimeGraficaBW
				printf "\n" >>informeBN.txt
				ImprimeLineaTemporalBW
				printf "\n" >>informeBN.txt
				carac1=5
				carac2=5
				carac3=5
			done
			printf "\n" >> informeColor.txt
			printf "\n" >>informeBN.txt

		fi 

		evento=0
		if [ -n "$proc_exe" ];then
			let tiempo[$proc_exe]--
			let retornov[$proc_exe]++
			if [ ${tiempo[$proc_exe]} -eq 0 ];then
				proc_status[$proc_exe]=4
				evento=1
				resta
				OcupaLineaTemporal $clock
				let intervalo=clock-ini_ejec
				let intervalo=intervalo+1
				DesocupaMemoria ${proc_partition[$proc_exe]} ${proc_partition_end[$proc_exe]}
				DesocupaProceso ${proc_partition[$proc_exe]} ${proc_partition_end[$proc_exe]}
				DesocupaProcesoBW ${proc_partition[$proc_exe]} ${proc_partition_end[$proc_exe]}
				t=${partition_pos[$proc_exe]}
    			partition[$t]=0
				partition_free[$t]=0
				enEjecucion=0
				let procEjecutados++
				proc_exe=""
				flag_siguienteProceso=1
			fi
		fi

		for ((i=0;i<$num_proc;i++));do
			if [[ ${proc_status[$i]} -eq 2 || ${proc_status[$i]} -eq 1 ]];then
				let esperav[$i]++
				let retornov[$i]++
			fi
		done
		
		let clock++
		clear

		if [ $procEjecutados -eq ${#memori[@]} ];then
			finbucle=1
		fi
	done
}



#Función encargada de ordenar los procesos
function Ordenar {
#inicio del algoritmo de ordenación
	for ((i=0;i<${#prioridad[@]};i++));do   # esto me indica ${#prioridad[@]} el tamaño de mi vector
 		for ((j=i+1;j<${#prioridad[@]};j++));do
			a=${templl[$i]};	#Asignamos a la variable a el indice de i correspondiente al vector tiempo
    	 	b=${templl[$j]};    #Asignamos a la variable b el indice de j correspondiente al vector tiempo
    	 	c=${tiempofijo[$i]};	#Asignamos a la variables c el indice de i correspondiente al vector llegada
    	 	d=${tiempofijo[$j]};	#Asignamos a la variables d el indice de j correspondiente al vector llegada
			e=${tiempintro[$i]};
			f=${tiempintro[$j]};
      		if [[ $a -gt $b || ($a -eq $b && $c -gt $d) || ($a -eq $b && $c -eq $d && $e -gt $f) ]];then #si a es mayor que b
            	aux=${prioridad[$i]};			 #utilizamos una variable auxiliar para almacenar el contenido del vector tiempo en la posición i
              	prioridad[$i]=${prioridad[$j]};	 #cambiamos el contenido del vector tiempo en la posicion i por el contenido de la posición j
             	prioridad[$j]=$aux;			 #cambiamos el contenido del vector tiempo en la posicion j por el contenido de la variable auxiliar
		     	auxx=${tiempofijo[$i]};		 #utilizamos una variable auxiliar para almacenar el contenido del vector llegada en la posición i
              	tiempofijo[$i]=${tiempofijo[$j]}; #cambiamos el contenido del vector llegada en la posicion i por el contenido de la posición j 
             	tiempofijo[$j]=$auxx;			 #cambiamos el contenido del vector llegada en la posicion j por el contenido de la variable auxiliar
	    	    aux2=${proceso[$i]};		 #utilizamos una variable auxiliar para almacenar el contenido del vector proceso en la posición i
            	proceso[$i]=${proceso[$j]}; 	#cambiamos el contenido del vector proceso llegada en la posicion i por el contenido de la posición j 
            	proceso[$j]=$aux2;			 #cambiamos el contenido del vector proceso llegada en la posicion j por el contenido de la variable auxiliar
         		aux2sc=${procesosc[$i]};		 #utilizamos una variable auxiliar para almacenar el contenido del vector proceso en la posición i
            	procesosc[$i]=${procesosc[$j]}; 	#cambiamos el contenido del vector proceso llegada en la posicion i por el contenido de la posición j 
            	procesosc[$j]=$aux2sc;	
         		aux3=${memori[$i]};
         		memori[$i]=${memori[$j]};
         		memori[$j]=$aux3;
         		aux4=${templl[$i]};
         		templl[$i]=${templl[$j]};
         		templl[$j]=$aux4;
				aux5=${tiempo[$i]}
			 	tiempo[$i]=${tiempo[$j]};  	
				tiempo[$j]=$aux5;	
				aux6=${esperav[$i]}
				esperav[$i]=${esperav[$j]}
				esperav[$j]=$aux6
				aux7=${retornov[$i]}
				retornov[$i]=${retornov[$j]}
				retorno[$j]=$aux7
				aux8=${estado[$i]}
				estado[$i]=${estado[$i]}
				estado[$j]=$aux8
				aux9=${colores[$i]}
				colores[$i]=${colores[$j]}
				colores[$j]=$aux9
				aux10=${tiempintro[$i]}
				tiempintro[$i]=${tiempintro[$j]}
				tiempintro[$j]=$aux10
				aux11=${dato_prioridad[$i]}
				dato_prioridad[$i]=${dato_prioridad[$j]}
				dato_prioridad[$j]=$aux11
			fi
		done
  	done	
}

# Nos permite saber si el parámetro pasado es entero positivo.
es_entero() {
	[ "$1" -eq "$1" -a "$1" -ge "-20" ] > /dev/null 2>&1  # En caso de error, sentencia falsa (Compara variables como enteros)
	return $?                           				# Retorna si la sentencia anterior fue verdadera
}

#función que comprueba que un nombre no tenga más de dos palabras separadas por espacios
function ComprobarPalabras {
	palabra=`echo $1 $2 | wc -w` #cuento el número de palabras
	if [ $palabra -ne 1 ];then  #si es distinto de 1
	    echo -e "${rojoR}ERROR: ${rojo} Has introducido más de una palabra ${NC}"
	    exit
    fi
}

#Función que comprueba que la prioridad introducida a cada proceso no esté fuera del rango de prioridades.
function ComprobarPrioridad {
	if [[ $dato_priorid -lt $dato_primin ]];then
		echo -e "${rojoR}ERROR: ${rojo} Has introducido una prioridad más baja que $pri_minima en el proceso $nombre.${NC}"
		exit
	fi
	if [[ $dato_priorid -gt $dato_primax ]];then
		echo -e "${rojoR}ERROR: ${rojo} Has introducido una prioridad más alta que $pri_maxima en el proceso $nombre. ${NC}"
		exit
	fi	
}

function CrearFicheroRangos {
		cantidadMinParticion=■
		cantidadMaxParticion=■
		tamanoMinParticion=■
		tamanoMaxParticion=■
		prioMin=■
		prioMax=■
		cantidadMinProcesos=■
		cantidadMaxProcesos=■
		tiempoMinLlegada=■
		tiempoMaxLlegada=■
		tiempoMinEjecucion=■
		tiempoMaxEjecucion=■
		tamanoMinProceso=■
		tamanoMaxProceso=■
		
		clear
		tablaRangos

		echo "Introduce el minimo del rango del numero de particiones"
		read cantidadMinParticion
		echo "Introduce el maximo del rango del numero de particiones"
		read cantidadMaxParticion
		clear

		tablaRangos

		echo "Introduce el minimo del rango del tamaño de las particiones"
		read tamanoMinParticion
		echo "Introduce el maximo del rango del tamaño de las particiones"
		read tamanoMaxParticion
		clear

		tablaRangos

		cantPart="$(seq $cantidadMinParticion $cantidadMaxParticion | shuf -n 1)"


    	val1="$(seq $tamanoMinParticion $tamanoMaxParticion | shuf -n 1)"

		contadorsinmas=0; while [[ $contadorsinmas -lt $cantPart ]];do

		val1=$((val1-2))
		echo -n "$val1;" >> $ENTRADA2

        contadorsinmas=$((contadorsinmas+1));
    	done

		printf "\n" >> $ENTRADA2

		echo "Introduce el minimo de la prioridad de los procesos"
		read prioMin
		echo "Introduce el maximo de la prioridad de los procesos"
		read prioMax
		clear

		prioMed=$((prioMax/2));
		
		valPrio1="$(seq $prioMin $prioMed | shuf -n 1)"
		valPrio2="$(seq $prioMed $prioMax | shuf -n 1)"

		echo -n "$valPrio1;" >> $ENTRADA2
		echo -n "$valPrio2;" >> $ENTRADA2
		
		tablaRangos

		echo "Introduce el minimo del rango del numero de procesos"
		read cantidadMinProcesos
		echo "Introduce el maximo del rango del numero de procesos"
		read cantidadMaxProcesos
		numProcesos="$(seq $cantidadMinProcesos $cantidadMaxProcesos | shuf -n 1)"
		clear

		tablaRangos

		echo "Introduce el minimo del rango del tiempo de llegada"
		read tiempoMinLlegada
		echo "Introduce el maximo del rango del tiempo de llegada"
		read tiempoMaxLlegada
		clear

		tablaRangos

		echo "Introduce el minimo del rango del tiempo de ejecucion"
		read tiempoMinEjecucion
		echo "Introduce el maximo del rango del tiempo de ejecucion"
		read tiempoMaxEjecucion
		clear

		tablaRangos

		echo "Introduce el minimo del rango de memoria de proceso"
		read tamanoMinProceso
		echo "Introduce el maximo del rango de memoria de proceso"
		read tamanoMaxProceso
		clear

		printf "\n" >> $ENTRADA2

		numproc=0; while [[ $numproc -lt $numProcesos ]]; do 
		echo "prioridad minima $valPrio1"
		echo "prioridad minima $valPrio2"
		prioproc="$(seq $valPrio1 $valPrio2 | shuf -n 1)"
		echo $prioproc
    	echo "$(seq $tiempoMinLlegada $tiempoMaxLlegada | shuf -n 1);$(seq $tiempoMinEjecucion $tiempoMaxEjecucion | shuf -n 1);$(seq $tamanoMinProceso $tamanoMaxProceso | shuf -n 1);$prioproc;" >> $ENTRADA2
		
    	numproc=$((numproc+1));
		echo "">>$ENTRADA2
		done

}
function tablaRangos {
		echo "Resumen de los datos introducidos"
		echo "------------------------------------------------------------------------"
		echo "Rango del numero de particiones $cantidadMinParticion - $cantidadMaxParticion"
		echo "Rango del tamaño de las particiones $tamanoMinParticion - $tamanoMaxParticion"
		echo "Rango prioridad de los procesos $prioMin - $prioMax"
		echo "Rango del numero de procesos $cantidadMinProcesos - $cantidadMaxProcesos"
		echo "Rango del tiempo de llegada $tiempoMinLlegada - $tiempoMaxLlegada"
		echo "Rango del rango del tiempo de ejecucion $tiempoMinEjecucion - $tiempoMaxEjecucion"
		echo "Rango de memoria de proceso $tamanoMinProceso - $tamanoMaxProceso"
		echo "-------------------------------------------------------------------------"
		echo ""

		echo -e "" >> informeColor.txt
		echo "Resumen de los datos introducidos">> informeColor.txt
		echo "------------------------------------------------------------------------">> informeColor.txt
		echo "Rango del numero de particiones $cantidadMinParticion - $cantidadMaxParticion">> informeColor.txt
		echo "Rango del tamaño de las particiones $tamanoMinParticion - $tamanoMaxParticion">> informeColor.txt
		echo "Rango prioridad de los procesos $prioMin - $prioMax">> informeColor.txt
		echo "Rango del numero de procesos $cantidadMinProcesos - $cantidadMaxProcesos">> informeColor.txt
		echo "Rango del tiempo de llegada $tiempoMinLlegada - $tiempoMaxLlegada">> informeColor.txt
		echo "Rango del rango del tiempo de ejecucion $tiempoMinEjecucion - $tiempoMaxEjecucion">> informeColor.txt
		echo "Rango de memoria de proceso $tamanoMinProceso - $tamanoMaxProceso">> informeColor.txt
		echo "-------------------------------------------------------------------------">> informeColor.txt
		echo -e "" >> informeColor.txt

		echo -e "" >> informeBN.txt
		echo "Resumen de los datos introducidos">> informeBN.txt
		echo "------------------------------------------------------------------------">> informeBN.txt
		echo "Rango del numero de particiones $cantidadMinParticion - $cantidadMaxParticion">> informeBN.txt
		echo "Rango del tamaño de las particiones $tamanoMinParticion - $tamanoMaxParticion">> informeBN.txt
		echo "Rango prioridad de los procesos $prioMin - $prioMax">> informeBN.txt
		echo "Rango del numero de procesos $cantidadMinProcesos - $cantidadMaxProcesos">> informeBN.txt
		echo "Rango del tiempo de llegada $tiempoMinLlegada - $tiempoMaxLlegada">> informeBN.txt
		echo "Rango del rango del tiempo de ejecucion $tiempoMinEjecucion - $tiempoMaxEjecucion">> informeBN.txt
		echo "Rango de memoria de proceso $tamanoMinProceso - $tamanoMaxProceso">> informeBN.txt
		echo "-------------------------------------------------------------------------">> informeBN.txt
		echo -e "" >> informeBN.txt
}
function guardarRangos {

		echo "$cantidadMinParticion;$cantidadMaxParticion;" >> $ENTRADA3
		echo "$tamanoMinParticion;$tamanoMaxParticion;" >> $ENTRADA3
		echo "$prioMin;$prioMax;" >> $ENTRADA3
		echo "$cantidadMinProcesos;$cantidadMaxProcesos;" >> $ENTRADA3
		echo "$tiempoMinLlegada;$tiempoMaxLlegada;" >> $ENTRADA3
		echo "$tiempoMinEjecucion;$tiempoMaxEjecucion;" >> $ENTRADA3
		echo "$tamanoMinProceso;$tamanoMaxProceso;" >> $ENTRADA3
}



#Comienzo del programa

#Comienzo del programa

echo -e "############################################################" 
echo -e "#                    Creative Commons                      #" 
echo -e "#                                                          #" 
echo -e "#                   BY - Atribución (BY)                   #" 
echo -e "#                 NC - No uso Comercial (NC)               #" 
echo -e "#                 SA - Compartir Igual (SA)                #" 
echo -e "############################################################" 
echo ""

echo -e "############################################################" > informeColor.txt
echo -e "#                    Creative Commons                      #" >> informeColor.txt
echo -e "#                                                          #" >> informeColor.txt
echo -e "#                   BY - Atribución (BY)                   #" >> informeColor.txt
echo -e "#                 NC - No uso Comercial (NC)               #" >> informeColor.txt
echo -e "#                 SA - Compartir Igual (SA)                #" >> informeColor.txt
echo -e "############################################################" >> informeColor.txt
echo -e "" >> informeColor.txt

echo -e "############################################################" > informeBN.txt
echo -e "#                    Creative Commons                      #" >> informeBN.txt
echo -e "#                                                          #" >> informeBN.txt
echo -e "#                   BY - Atribución (BY)                   #" >> informeBN.txt
echo -e "#                 NC - No uso Comercial (NC)               #" >> informeBN.txt
echo -e "#                 SA - Compartir Igual (SA)                #" >> informeBN.txt
echo -e "############################################################" >> informeBN.txt
echo -e "" >> informeBN.txt

echo -e "############################################################"
echo -e "#                                                          #"
echo -e "#                  INFORME DE PRÁCTICA                     #"
echo -e "#                   GESTIÓN DE MEMORIA                     #"
echo -e "#            -----------------------------                 #"
echo -e "#     ALGORITMO DE GESTIÓN DE MEMORIA: PRIORIDAD MENOR     #"
echo -e "#      PARTICIONES FIJAS Y NO IGUALES - PRIMER AJUSTE      #"
echo -e "#                                                          #"
echo -e "#                                                          #"
echo -e "#  ANTIGUOS ALUMNOS:                                       #"
echo -e "#  Gonzalo Murillo Montes y Gonzalo Cuesta Marín (2017)    #"
echo -e "#  Álvaro Manjón Vara (2020)                               #"
echo -e "#  NUEVOS ALUMNOS:                                         #"
echo -e "#  Adrián Núñez Martínez (2022)                            #"
echo -e "############################################################"
echo ""

echo -e "############################################################" >> informeColor.txt 
echo -e "#                                                          #" >> informeColor.txt
echo -e "#                  INFORME DE PRÁCTICA                     #" >> informeColor.txt 
echo -e "#                   GESTIÓN DE MEMORIA                     #" >> informeColor.txt 
echo -e "#            -----------------------------                 #" >> informeColor.txt 
echo -e "#     ALGORITMO DE GESTIÓN DE MEMORIA: PRIORIDAD MENOR     #" >> informeColor.txt 
echo -e "#      PARTICIONES FIJAS Y NO IGUALES - PRIMER AJUSTE      #" >> informeColor.txt 
echo -e "#                                                          #" >> informeColor.txt 
echo -e "#                                                          #" >> informeColor.txt 
echo -e "#  ANTIGUOS ALUMNOS:                                       #" >> informeColor.txt 
echo -e "#  Gonzalo Murillo Montes y Gonzalo Cuesta Marín (2017)    #" >> informeColor.txt 
echo -e "#  Álvaro Manjón Vara (2020)                               #" >> informeColor.txt 
echo -e "#  NUEVOS ALUMNOS:                                         #" >> informeColor.txt 
echo -e "#  Adrián Núñez Martínez (2022)                            #" >> informeColor.txt 
echo -e "############################################################" >> informeColor.txt 
echo -e "" >> informeColor.txt

echo -e "############################################################" >> informeBN.txt 
echo -e "#                                                          #" >> informeBN.txt 
echo -e "#                  INFORME DE PRÁCTICA                     #" >> informeBN.txt 
echo -e "#                   GESTIÓN DE MEMORIA                     #" >> informeBN.txt 
echo -e "#            -----------------------------                 #" >> informeBN.txt 
echo -e "#     ALGORITMO DE GESTIÓN DE MEMORIA: PRIORIDAD MENOR     #" >> informeBN.txt 
echo -e "#      PARTICIONES FIJAS Y NO IGUALES - PRIMER AJUSTE      #" >> informeBN.txt 
echo -e "#                                                          #" >> informeBN.txt 
echo -e "#                                                          #" >> informeBN.txt 
echo -e "#  ANTIGUOS ALUMNOS:                                       #" >> informeBN.txt 
echo -e "#  Gonzalo Murillo Montes y Gonzalo Cuesta Marín (2017)    #" >> informeBN.txt 
echo -e "#  Álvaro Manjón Vara (2020)                               #" >> informeBN.txt 
echo -e "#  NUEVOS ALUMNOS:                                         #" >> informeBN.txt 
echo -e "#  Adrián Núñez Martínez (2022)                            #" >> informeBN.txt 
echo -e "############################################################" >> informeBN.txt 
echo -e "" >> informeBN.txt


p=0;	#contador para los procesos introducidos de forma manual
pp=1;	#contador encargado del índice del nombre de los procesos y del tiempo de ejecución
ppp=1;
suma_espera=0;
suma_respuesta=0;	

espera=0;
respuesta=0;
ti=0;
tiempintro={}
secs=0

#Comienzo de la lectura de datos de un fichero o por teclado

if [ $p = 0	 ];then #condición para preguntar la forma a leer los datos
	echo ""
	echo -e "############################################################"		
	echo -e "1 - Introducir los datos de forma manual"
	echo -e "2 - Fichero de datos de ultima ejecucion (datos.txt)"
	echo -e "3 - Otro fichero de datos"
	echo -e "4 - Introduccion de rangos manualmente"
	echo -e "5 - Fichero de rangos de ultima ejecucion (datosrangos.txt)"
	echo -e "6 - Otro fichero de rangos"
	echo -e "############################################################"
	echo ""

	echo -e "">> informeColor.txt 
	echo -e "############################################################"	>> informeColor.txt 	
	echo -e "1 - Introducir los datos de forma manual">> informeColor.txt 
	echo -e "2 - Fichero de datos de ultima ejecucion (datos.txt)">> informeColor.txt 
	echo -e "3 - Otro fichero de datos">> informeColor.txt 
	echo -e "4 - Introduccion de rangos manualmente">> informeColor.txt 
	echo -e "5 - Fichero de rangos de ultima ejecucion (datosrangos.txt)">> informeColor.txt 
	echo -e "6 - Otro fichero de rangos">> informeColor.txt 
	echo -e "############################################################">> informeColor.txt 
	echo -e "">> informeColor.txt 

	echo -e "">> informeBN.txt 
	echo -e "############################################################">> informeBN.txt 
	echo -e "1 - Introducir los datos de forma manual">> informeBN.txt 
	echo -e "2 - Fichero de datos de ultima ejecucion (datos.txt)">> informeBN.txt 
	echo -e "3 - Otro fichero de datos">> informeBN.txt 
	echo -e "4 - Introduccion de rangos manualmente">> informeBN.txt 
	echo -e "5 - Fichero de rangos de ultima ejecucion (datosrangos.txt)">> informeBN.txt 
	echo -e "6 - Otro fichero de rangos">> informeBN.txt 
	echo -e "############################################################">> informeBN.txt 
	echo -e "">> informeBN.txt 

	read opcion	#variable que almacena la opción leída
	ComprobarPalabras $opcion
	while [ $opcion != "1" -a $opcion != "2" -a $opcion != "3" -a $opcion != "4" -a $opcion != "5" -a $opcion != "6" ];do
		echo -e "${rojoR}ERROR: ${rojo} No has introducido una opción válida ${NC}"
		echo -e "${azulR}Vuelve a introducir una opción${NC}"
		read opcion
	done

	echo -e "$opcion">> informeBN.txt 
	echo -e "$opcion">> informeColor.txt 

	if [ $opcion = 1 ];then
		echo -e "############################################################"
		echo "Elige el fichero donde quieres guardar los datos:"
		echo "1 - Fichero de datos de ultima ejecucion (datos.txt)"
		echo "2 - Otro fichero de datos"
		echo -e "############################################################"

		echo -e "############################################################">> informeColor.txt 
		echo "Elige el fichero donde quieres guardar los datos:">> informeColor.txt 
		echo "1 - Fichero de datos de ultima ejecucion (datos.txt)">> informeColor.txt 
		echo "2 - Otro fichero de datos">> informeColor.txt 
		echo -e "############################################################">> informeColor.txt 

		echo -e "############################################################">> informeBN.txt 
		echo "Elige el fichero donde quieres guardar los datos:">> informeBN.txt 
		echo "1 - Fichero de datos de ultima ejecucion (datos.txt)">> informeBN.txt 
		echo "2 - Otro fichero de datos">> informeBN.txt 
		echo -e "############################################################">> informeBN.txt 

		read lekt

		echo -e "$lekt">> informeBN.txt 
		echo -e "$lekt">> informeColor.txt 

		if [ $lekt = 1 ];then
			ENTRADA=FicherosDatos/datos.txt
			rm FicherosDatos/datos.txt > /dev/null 2>&1
		else
				rutaFich=0
				echo "En que fichero quieres guardar los datos? Si no existe, se creará.">> informeColor.txt 
				echo "En que fichero quieres guardar los datos? Si no existe, se creará.">> informeBN.txt 
				echo -e "" >> informeColor.txt
				echo -e "" >> informeBN.txt
				cd FicherosDatos
				echo "En que fichero quieres guardar los datos? Si no existe, se creará."
				echo ""
				ls *.txt 2>/dev/null
				echo ""
				read rutaFich
				ENTRADA=FicherosDatos/$rutaFich
				cd ..
				rm FicherosDatos/$rutaFich > /dev/null 2>&1
				echo -e "$rutaFich" >> informeColor.txt
				echo -e "$rutaFich" >> informeBN.txt
		fi
	fi

	if [ $opcion = 3 ];then
		mkdir -p FicherosDatos
		echo ""
		rutaFich=0
		echo "Introduce el nombre o ruta del fichero a leer :">> informeColor.txt 
		echo "Introduce el nombre o ruta del fichero a leer :">> informeBN.txt 
		echo -e "" >> informeColor.txt
		echo -e "" >> informeBN.txt
		cd FicherosDatos
		echo "Introduce el nombre o ruta del fichero a leer :"
		echo ""
		ls *.txt 2>/dev/null
		echo ""
		read rutaFich
		rutaFich=FicherosDatos/$rutaFich
		echo "$rutaFich"
		cd ..
		echo -e "$rutaFich" >> informeColor.txt
		echo -e "$rutaFich" >> informeBN.txt
	fi


	if [ $opcion = 4 ];then
		echo -e "############################################################"
		echo "Elige el fichero donde quieres guardar los rangos:"
		echo "1 - Fichero de rangos de ultima ejecucion (datosrangos.txt)"
		echo "2 - Otro fichero de rangos"
		echo -e "############################################################"
		echo ""

		echo -e "############################################################" >> informeColor.txt
		echo "Elige el fichero donde quieres guardar los datos:" >> informeColor.txt
		echo "1 - Fichero de rangos de ultima ejecucion (datosrangos.txt)" >> informeColor.txt
		echo "2 - Otro fichero de rangos" >> informeColor.txt
		echo -e "############################################################" >> informeColor.txt

		echo -e "############################################################" >> informeBN.txt 
		echo "Elige el fichero donde quieres guardar los datos:" >> informeBN.txt 
		echo "1 - Fichero de rangos de ultima ejecucion (datosrangos.txt)" >> informeBN.txt 
		echo "2 - Otro fichero de rangos" >> informeBN.txt 
		echo -e "############################################################" >> informeBN.txt 

		read lekt

		echo -e "$lekt">> informeBN.txt 
		echo -e "$lekt">> informeColor.txt 

		if [ $lekt = 1 ];then
			ENTRADA3=FicherosRangos/datosrangos.txt
			rm FicherosRangos/datosrangos.txt > /dev/null 2>&1
		else
				rutaFich=0
								echo "En que fichero quieres guardar los datos? Si no existe, se creará.">> informeColor.txt 
				echo "En que fichero quieres guardar los datos? Si no existe, se creará.">> informeBN.txt 
				
				echo -e "" >> informeBN.txt 
				echo -e "" >> informeColor.txt 
				cd FicherosRangos
				echo "En que fichero quieres guardar los datos? Si no existe, se creará."


				ls *.txt 2>/dev/null
				echo ""

				read rutaFich
				ENTRADA3=FicherosRangos/$rutaFich
				cd ..
				rm FicherosRangos/$rutaFich > /dev/null 2>&1
				echo -e "$rutaFich" >> informeColor.txt
				echo -e "$rutaFich" >> informeBN.txt
		fi

		echo ""
		echo -e "############################################################"
		echo "Elige el fichero donde quieres guardar los datos:"
		echo "1 - Fichero de datos de ultima ejecucion (datos.txt)"
		echo "2 - Otro fichero de datos"
		echo -e "############################################################"
		echo ""

		echo -e "############################################################">> informeColor.txt 
		echo "Elige el fichero donde quieres guardar los datos:">> informeColor.txt 
		echo "1 - Fichero de datos de ultima ejecucion (datos.txt)">> informeColor.txt 
		echo "2 - Otro fichero de datos">> informeColor.txt 
		echo -e "############################################################">> informeColor.txt 

		echo -e "############################################################">> informeBN.txt 
		echo "Elige el fichero donde quieres guardar los datos:">> informeBN.txt 
		echo "1 - Fichero de datos de ultima ejecucion (datos.txt)">> informeBN.txt 
		echo "2 - Otro fichero de datos">> informeBN.txt 
		echo -e "############################################################">> informeBN.txt 

		read lekt

		echo -e "$lekt">> informeBN.txt 
		echo -e "$lekt">> informeColor.txt 

		if [ $lekt = 1 ];then
			ENTRADA2=FicherosDatos/datos.txt
			rm FicherosDatos/datos.txt > /dev/null 2>&1
		else
				rutaFich=0
				echo "En que fichero quieres guardar los datos? Si no existe, se creará.">> informeColor.txt 
				echo "En que fichero quieres guardar los datos? Si no existe, se creará.">> informeBN.txt 
				echo -e "" >> informeColor.txt
				echo -e "" >> informeBN.txt
				cd FicherosDatos
				echo "En que fichero quieres guardar los datos? Si no existe, se creará."

				echo ""
				ls *.txt 2>/dev/null
				echo ""
				read rutaFich
				ENTRADA2=FicherosDatos/$rutaFich
				cd ..
				rm FicherosDatos/$rutaFich > /dev/null 2>&1
				echo -e "$rutaFich" >> informeColor.txt
				echo -e "$rutaFich" >> informeBN.txt
		fi

	fi

	if [ $opcion = 6 ];then
		mkdir -p FicherosRangos
		echo ""
		rutaFich=0
		echo "Introduce el nombre o ruta del fichero a leer :" >>informeColor.txt
		echo "Introduce el nombre o ruta del fichero a leer :" >> informeBN.txt 
		echo -e "" >> informeColor.txt
		echo -e "" >> informeBN.txt
		cd FicherosRangos
		echo "Introduce el nombre o ruta del fichero a leer :"	
		echo ""
		ls *.txt 2>/dev/null
		echo ""
		read rutaFich
		rutaFich=FicherosRangos/$rutaFich
		echo "$rutaFich"
		cd ..
		echo -e "$rutaFich" >> informeColor.txt
		echo -e "$rutaFich" >> informeBN.txt
	fi


fi

if [ $p2 = 0 ];then #condición para preguntar la forma a leer los datos	
	echo ""
	echo -e "############################################################"
	echo -e "1 - Por eventos (presionando enter)."
	echo -e "2 - Eventos automáticos (introduciendo segundos de espera)."
	echo -e "3 - Completa (sin tiempos de espera)."
	echo -e "4 - Resumen final."
	echo -e "############################################################"
	echo ""

	echo -e "">>informeColor.txt
	echo -e "############################################################">>informeColor.txt
	echo -e "1 - Por eventos (presionando enter).">>informeColor.txt
	echo -e "2 - Eventos automáticos (introduciendo segundos de espera).">>informeColor.txt
	echo -e "3 - Completa (sin tiempos de espera).">>informeColor.txt
	echo -e "4 - Resumen final.">>informeColor.txt
	echo -e "############################################################">>informeColor.txt
	echo -e "">>informeColor.txt

	echo -e "" >> informeBN.txt
	echo -e "############################################################">> informeBN.txt
	echo -e "1 - Por eventos (presionando enter).">> informeBN.txt
	echo -e "2 - Eventos automáticos (introduciendo segundos de espera).">> informeBN.txt
	echo -e "3 - Completa (sin tiempos de espera).">> informeBN.txt
	echo -e "4 - Resumen final.">> informeBN.txt
	echo -e "############################################################">> informeBN.txt
	echo -e "" >> informeBN.txt

	read opcion2	#variable que almacena la opción leída
	ComprobarPalabras $opcion2
	while [ $opcion2 != "1" -a $opcion2 != "2" -a $opcion2 != "3"  -a $opcion2 != "4" ];do
		echo -e "${rojoR}ERROR: ${rojo} No has introducido una opción válida ${NC}"
		echo -e "${azulR}Vuelve a introducir una opción${NC}"
		read opcion2
	done
	echo -e "$opcion2" >> informeColor.txt
	echo -e "$opcion2" >> informeBN.txt
fi


if [ $opcion = 1 ];then	#si el usuario desea introducir los datos de forma manual	
	mkdir -p FicherosDatos

	esunsi=1
	
	mas=0;
	while [ $mas -ne 1 ];do
		if [ $p = 0 ];then
			crea_particiones
			crea_prioridad
		fi
		echo ""
		echo ""
		if [ $ppp -lt 10 ];then
                nombre="P0$ppp"
        else
                nombre="P$ppp"
        fi

		tiempintro[$p]=$p
		proceso[$p]="${colores[$p]}$nombre"; #añado a el vector ese nombre
		procesosc[$p]="$nombre"
		#proceso[$p]=$nombre; #añado a el vector ese nombre
		clear
		printf "Ref Tll Tej Mem Pri\n"
		for ((i=0;i<=$p;i++));do
			if [ $i -lt $p ]; then
				printf "${colores[$i]}%s${NC} " ${procesosc[$i]}
				printf "${colores[$i]}%3d${NC} " ${templl[$i]}
				printf "${colores[$i]}%3d${NC} " ${tiempofijo[$i]}
				printf "${colores[$i]}%3d${NC} " ${memori[$i]}
				printf "${colores[$i]}%3d${NC} " ${prioridad[$i]}
				echo ""
			else
				printf "${colores[$i]}%s${NC} " ${procesosc[$i]}
				echo ""
			fi
		done
		echo ""
		echo -e "Tiempo de llegada del proceso $ppp:"
		read temp
		ComprobarPalabras $temp
		until [ $temp -ge 0 ];do
			echo -e "${rojoR}ERROR: ${rojo}No se pueden introducir tiempos de llegada negativos${NC}"
			echo -e "${NC}Introduce un nuevo tiempo de llegada:"
			read temp
		done
	
		echo -e "Tiempo de llegada del proceso $ppp: $temp " >> informeColor.txt
		echo -e "Tiempo de llegada del proceso $ppp: $temp " >> informeBN.txt
		templl[$p]=$temp;   #añado al vector ese numero
		clear
		printf "Ref Tll Tej Mem Pri\n"
		for ((i=0;i<=$p;i++));do
			if [ $i -lt $p ]; then
				printf "${colores[$i]}%s${NC} " ${procesosc[$i]}
				printf "${colores[$i]}%3d${NC} " ${templl[$i]}
				printf "${colores[$i]}%3d${NC} " ${tiempofijo[$i]}
				printf "${colores[$i]}%3d${NC} " ${memori[$i]}
				printf "${colores[$i]}%3d${NC} " ${prioridad[$i]}
				echo ""
			else
				printf "${colores[$i]}%s${NC} " ${procesosc[$i]}
				printf "${colores[$i]}%3d${NC} " ${templl[$i]}
				echo ""
			fi
		done
		echo ""
		echo -e "Tiempo de ejecución del proceso $ppp:"
		read tiemp
		ComprobarPalabras $tiemp
		until [ $tiemp -ge 0 ];do
			echo -e "${rojoR}ERROR: ${rojo}No se pueden introducir tiempos de llegada negativos${NC}"
			echo -e "${NC}Introduce un nuevo tiempo de ejecución:"
			read tiemp
		done
		echo -e "Tiempo de ejecución del proceso $ppp: $tiemp" >> informeColor.txt
		echo -e "Tiempo de ejecución del proceso $ppp: $tiemp"	>> informeBN.txt
		tiempo[$p]=$tiemp;   #añado al vector ese numero
		tiempofijo[$p]=$tiemp;
		clear
		printf "Ref Tll Tej Mem Pri\n"
		for ((i=0;i<=$p;i++));do
			if [ $i -lt $p ]; then
				printf "${colores[$i]}%s${NC} " ${procesosc[$i]}
				printf "${colores[$i]}%3d${NC} " ${templl[$i]}
				printf "${colores[$i]}%3d${NC} " ${tiempofijo[$i]}
				printf "${colores[$i]}%3d${NC} " ${memori[$i]}
				printf "${colores[$i]}%3d${NC} " ${prioridad[$i]}
				echo ""
			else
				printf "${colores[$i]}%s${NC} " ${procesosc[$i]}
				printf "${colores[$i]}%3d${NC} " ${templl[$i]}
				printf "${colores[$i]}%3d${NC} " ${tiempofijo[$i]}
				echo ""
			fi
		done
		echo ""
		echo -e "Memoria que ocupa el proceso $ppp:"
		read memor
		ComprobarPalabras $memor
		until [ $memor -ge 1 ] && [ $memor -le $cap_maxima ];do
			echo -e "${rojoR}ERROR: ${rojo}El valor ha de ser mayor que 0 y menor o igual que $cap_maxima ${NC}"
			echo -e "${NC}Introduce de nuevo la memoria que ocupa:"
			read memor
		done
		echo -e "Memoria que ocupa el proceso $ppp: $memor" >> informeColor.txt
		echo -e "Memoria que ocupa el proceso $ppp: $memor" 	>> informeBN.txt
		memori[$p]=$memor;
		clear
		printf "Ref Tll Tej Mem Pri\n"
		for ((i=0;i<=$p;i++));do
			if [ $i -lt $p ]; then
				printf "${colores[$i]}%s${NC} " ${procesosc[$i]}
				printf "${colores[$i]}%3d${NC} " ${templl[$i]}
				printf "${colores[$i]}%3d${NC} " ${tiempofijo[$i]}
				printf "${colores[$i]}%3d${NC} " ${memori[$i]}
				printf "${colores[$i]}%3d${NC} " ${prioridad[$i]}
				echo ""
			else
				printf "${colores[$i]}%s${NC} " ${procesosc[$i]}
				printf "${colores[$i]}%3d${NC} " ${templl[$i]}
				printf "${colores[$i]}%3d${NC} " ${tiempofijo[$i]}
				printf "${colores[$i]}%3d${NC} " ${memori[$i]}
				echo ""
			fi
		done
		echo ""
		echo -e "Prioridad del proceso $ppp:"
		read priorida
		ComprobarPalabras $priorida
		dato_priorid=$(calculoSegunTipoPrioridad $tipo_prioridad $priorida)
		dato_correcto=0
		while [ $dato_correcto -eq 0 ];do
			if [[ $dato_priorid -lt $dato_primin || $dato_priorid -gt $dato_primax ]];then
				echo -e "${rojoR}ERROR: ${rojo}No se pueden poner prioridades menores que $pri_minima, ni mayores que $pri_maxima${NC}"
				echo -e "${NC}Introduce una nueva prioridad para el proceso:"
				read priorida
				ComprobarPalabras $priorida
				dato_priorid=$(calculoSegunTipoPrioridad $tipo_prioridad $priorida)
			else
				dato_correcto=1
			fi
		done
		echo -e "Prioridad del proceso $ppp: $priorida" >> informeColor.txt
		echo -e "Prioridad del proceso $ppp: $priorida" >> informeBN.txt
		prioridad[$p]=$priorida;   #añado al vector ese numero
		dato_prioridad[$p]=$dato_priorid
		clear
		printf "Ref Tll Tej Mem Pri\n"
		for ((i=0;i<=$p;i++));do
			printf "${colores[$i]}%s${NC} " ${procesosc[$i]}
			printf "${colores[$i]}%3d${NC} " ${templl[$i]}
			printf "${colores[$i]}%3d${NC} " ${tiempofijo[$i]}
			printf "${colores[$i]}%3d${NC} " ${memori[$i]}
			printf "${colores[$i]}%3d${NC} " ${prioridad[$i]}
			echo ""
		done

		echo -e "$temp;$tiemp;$memor;$priorida;" >> $ENTRADA			
		p=`expr $p + 1` #incremento el contador
		pp=`expr $pp + 1` #incremento el contador
		ppp=`expr $ppp + 1` #incremento el contador
		num_proc=`expr $num_proc + 1`
		let ti=ti+1
		pl=0
		Ordenar
		clear
		printf "Ref Tll Tej Mem Pri\n"
		for ((i=0;i<${#tiempo[@]};i++));do
			printf "${colores[$i]}%s${NC} " ${procesosc[$i]}
			printf "${colores[$i]}%3d${NC} " ${templl[$i]}
			printf "${colores[$i]}%3d${NC} " ${tiempofijo[$i]}
			printf "${colores[$i]}%3d${NC} "	${memori[$i]}
			printf "${colores[$i]}%3d${NC} " ${prioridad[$i]}
			echo ""
		done
		echo "" >> informeColor.txt
		printf "Ref Tll Tej Mem Pri\n" >> informeColor.txt
		for ((i=0;i<${#tiempo[@]};i++));do
			printf "${colores[$i]}%s${NC} " ${procesosc[$i]}>> informeColor.txt
			printf "${colores[$i]}%3d${NC} " ${templl[$i]} >> informeColor.txt
			printf "${colores[$i]}%3d${NC} " ${tiempofijo[$i]} >> informeColor.txt
			printf "${colores[$i]}%3d${NC} "	${memori[$i]} >> informeColor.txt
			printf "${colores[$i]}%3d${NC} " ${prioridad[$i]} >> informeColor.txt
			echo "" >> informeColor.txt
		done
		echo "" >> informeBN.txt
		printf "Ref Tll Tej Mem Pri\n" >> informeBN.txt
		for ((i=0;i<${#tiempo[@]};i++));do
			printf "%s " ${procesosc[$i]} >> informeBN.txt
			printf "%3d " ${templl[$i]} >> informeBN.txt
			printf "%3d " ${tiempofijo[$i]} >> informeBN.txt
			printf "%3d "	${memori[$i]} >> informeBN.txt
			printf "%3d " ${prioridad[$i]} >> informeBN.txt
			echo "" >> informeBN.txt
		done
		let "i2++"
		while [ $pl -eq 0 ];do
			echo ""
			echo -e "¿Desea introducir otro proceso? (s/n)"
			read opp
			if [ $opp = "S" -o $opp = "s" -o $opp = "n" -o $opp = "N" ];then
				let pl=1;
			fi
		done
		case $opp in
			"No") mas=1;;
			"no") mas=1;;
			"N") mas=1;;
			"n") mas=1;;
			*);;
		esac
		echo "" >> informeColor.txt
		echo -e "¿Desea introducir otro proceso? (s/n) $opp" >> informeColor.txt
		echo "" >> informeColor.txt
		echo "" >> informeBN.txt
		echo -e "¿Desea introducir otro proceso? (s/n) $opp" >> informeBN.txt
		echo "" >> informeBN.txt
	done
fi

if [ $opcion = 2 ];then #leer fichero de datos
	mkdir -p FicherosDatos

	esunsi=0
	sed "/^ *$/d" FicherosDatos/datos.txt > datos.txt
	mv datos.txt FicherosDatos/datos.txt
	num_proc=`expr $(cat FicherosDatos/datos.txt | wc -l) - 2`
	if [ $p = 0 ];then
		pri_minima=`cat FicherosDatos/datos.txt| cut -f 1 -d";" | sed -n 2p`
		pri_maxima=`cat FicherosDatos/datos.txt | cut -f 2 -d";" | sed -n 2p`
		n_particiones=`cat FicherosDatos/datos.txt | sed -n 1p | grep -o ";" | wc -l`

		calcularTipoPrioridad $pri_minima $pri_maxima

		for (( jka=0; jka<n_particiones; jka++ ));do
			part_cap[$jka]=$(cat FicherosDatos/datos.txt | cut -f$(expr $jka + 1) -d";" | sed -n 1p)
			let cap_memoria=cap_memoria+part_cap[$jka]
			if [ $jka -eq 0 ];then
				part_init[$jka]=0
			else
				part_init[$jka]=$(expr ${part_fin[$(expr $jka - 1)]} + 1)
			fi
			let part_fin[$jka]=part_init[$jka]+part_cap[$jka]
			let part_fin[$jka]=part_fin[$jka]-1
		done
		echo -e ""
		echo -e "${verdeR}Todas las particiones estan creadas${NC}"
		echo -e "Las particiones empiezan en	${part_init[@]}"
		echo -e "Las particiones acaban en	${part_fin[@]}"
		echo -e "Tamaño completo de la memoria	$cap_memoria"
		echo -e "" >> informeColor.txt
		echo -e "${verdeR}Todas las particiones estan creadas${NC}" >> informeColor.txt
		echo -e "Las particiones empiezan en	${part_init[@]}" >> informeColor.txt
		echo -e "Las particiones acaban en	${part_fin[@]}" >> informeColor.txt
		echo -e "Tamaño completo de la memoria	$cap_memoria" >> informeColor.txt
		echo -e "" >> informeBN.txt
		echo -e "Todas las particiones estan creadas" >> informeBN.txt
		echo -e "Las particiones empiezan en	${part_init[@]}" >> informeBN.txt
		echo -e "Las particiones acaban en	${part_fin[@]}" >> informeBN.txt
		echo -e "Tamaño completo de la memoria	$cap_memoria" >> informeBN.txt
		
		echo ""
		printf "La prioridad mínima es\t%2d\n" "$pri_minima"
		printf "La prioridad máxima es\t%2d\n" "$pri_maxima"
		echo ""
		echo "" >> informeColor.txt
		printf "La prioridad mínima es\t%2d\n" "$pri_minima" >> informeColor.txt
		printf "La prioridad máxima es\t%2d\n" "$pri_maxima" >> informeColor.txt
		echo "" >> informeColor.txt
		echo "" >> informeBN.txt
		echo -e "La prioridad mínima es	$pri_minima" >> informeBN.txt
		echo -e "La prioridad máxima es	$pri_maxima" >> informeBN.txt
		echo "" >> informeBN.txt
	fi
	
	for ((p=0;p<$num_proc;p++));do
		if [ $ppp -lt 10 ]; then
			nombre=P0$ppp
		else 
			nombre=P$ppp
		fi
		#ComprobarPalabras $nombre #comprobamos que la entrada leída de nombre es correcta
		proceso[$p]="${colores[$p]}$nombre${NC}"; 		#añadimos al vector de los procesos en la posición del índice el nombre de ese proceso
		tiempintro[$p]=$p
		procesosc[$p]="$nombre"
		let contar_lineas=p+3
		contar_lineas_p=$contar_lineas'p'
		pp=1
		temp=`cat FicherosDatos/datos.txt| cut -d ";" -f $pp | sed -n $contar_lineas_p`
		templl[$p]=$temp
		let pp++		
		tiemp=`cat FicherosDatos/datos.txt| cut -d ";" -f $pp | sed -n $contar_lineas_p`
		tiempo[$p]="$tiemp"
		tiempofijo[$p]="$tiemp"
		let pp++			
		memor=`cat FicherosDatos/datos.txt | cut -d ";" -f $pp | sed -n $contar_lineas_p`
		memori[$p]=$memor
		let pp++
		priorida=`cat FicherosDatos/datos.txt | cut -d ";" -f $pp | sed -n $contar_lineas_p`
		dato_priorid=$(calculoSegunTipoPrioridad $tipo_prioridad $priorida)
		ComprobarPrioridad
		prioridad[$p]=$priorida
		dato_prioridad[$p]=$dato_priorid
		let pp++
		echo -e "${verdeR}Proceso: ${verde}$nombre ${verdeR}Tiempo de llegada: ${verde}$temp ${verdeR}Tiempo de ejecución: ${verde}$tiemp ${verdeR}Prioridad de Proceso: ${verde}$priorida ${verdeR}Memoria que ocupa: ${verde}$memor"  >> informeColor.txt
		echo "Proceso: $nombre Tiempo de llegada: $temp Tiempo de ejecución: $tiemp Prioridad de Proceso: $priorida Memoria que ocupa: $memor"  >> informeBN.txt	
		let ppp++
		Ordenar
	done
	Ordenar

	printf "Ref Tll Tej Mem Pri\n"
	for ((i=0;i<${#tiempo[@]};i++));do
			printf "${colores[$i]}%s${NC} " ${procesosc[$i]}
			printf "${colores[$i]}%3d${NC} " ${templl[$i]}
			printf "${colores[$i]}%3d${NC} " ${tiempofijo[$i]}
			printf "${colores[$i]}%3d${NC} "	${memori[$i]}
			printf "${colores[$i]}%3d${NC} " ${prioridad[$i]}
			echo ""
	done
	printf "Ref Tll Tej Mem Pri\n" >> informeColor.txt
	for ((i=0;i<${#tiempo[@]};i++));do
			printf "${colores[$i]}%s${NC} " ${procesosc[$i]} >> informeColor.txt
			printf "${colores[$i]}%3d${NC} " ${templl[$i]} >> informeColor.txt
			printf "${colores[$i]}%3d${NC} " ${tiempofijo[$i]} >> informeColor.txt
			printf "${colores[$i]}%3d${NC} "	${memori[$i]} >> informeColor.txt
			printf "${colores[$i]}%3d${NC} " ${prioridad[$i]} >> informeColor.txt
			echo "" >> informeColor.txt
	done
	printf "Ref Tll Tej Mem Pri\n" >> informeBN.txt
	for ((i=0;i<${#tiempo[@]};i++));do
			printf "%s " ${procesosc[$i]} >> informeBN.txt
			printf "%3d " ${templl[$i]} >> informeBN.txt
			printf "%3d " ${tiempofijo[$i]} >> informeBN.txt
			printf "%3d "	${memori[$i]} >> informeBN.txt
			printf "%3d " ${prioridad[$i]} >> informeBN.txt
			echo "" >> informeBN.txt
	done
fi

if [ $opcion = 3 ];then #leer fichero intrudocido a mano
	esunsi=0
	sed "/^ *$/d" $rutaFich > datos.txt
	mv datos.txt $rutaFich
	num_proc=`expr $(cat $rutaFich | wc -l) - 2`
	if [ $p = 0 ];then
		pri_minima=`cat $rutaFich | cut -f 1 -d";" | sed -n 2p`
		pri_maxima=`cat $rutaFich | cut -f 2 -d";" | sed -n 2p`
		n_particiones=`cat $rutaFich | sed -n 1p | grep -o ";" | wc -l`

		calcularTipoPrioridad $pri_minima $pri_maxima

		for (( jka=0; jka<n_particiones; jka++ ));do
			part_cap[$jka]=$(cat $rutaFich | cut -f$(expr $jka + 1) -d";" | sed -n 1p)
			let cap_memoria=cap_memoria+part_cap[$jka]
			if [ $jka -eq 0 ];then
				part_init[$jka]=0
			else
				part_init[$jka]=$(expr ${part_fin[$(expr $jka - 1)]} + 1)
			fi
			let part_fin[$jka]=part_init[$jka]+part_cap[$jka]
			let part_fin[$jka]=part_fin[$jka]-1
		done
		echo -e ""
		echo -e "${verdeR}Todas las particiones estan creadas${NC}"
		echo -e "Las particiones empiezan en	${part_init[@]}"
		echo -e "Las particiones acaban en	${part_fin[@]}"
		echo -e "Tamaño completo de la memoria	$cap_memoria"
		echo -e "" >> informeColor.txt
		echo -e "${verdeR}Todas las particiones estan creadas${NC}" >> informeColor.txt
		echo -e "Las particiones empiezan en	${part_init[@]}" >> informeColor.txt
		echo -e "Las particiones acaban en	${part_fin[@]}" >> informeColor.txt
		echo -e "Tamaño completo de la memoria	$cap_memoria" >> informeColor.txt
		echo -e "" >> informeBN.txt
		echo -e "Todas las particiones estan creadas" >> informeBN.txt
		echo -e "Las particiones empiezan en	${part_init[@]}" >> informeBN.txt
		echo -e "Las particiones acaban en	${part_fin[@]}" >> informeBN.txt
		echo -e "Tamaño completo de la memoria	$cap_memoria" >> informeBN.txt
		
		echo ""
		printf "La prioridad mínima es\t%2d\n" "$pri_minima"
		printf "La prioridad máxima es\t%2d\n" "$pri_maxima"
		echo ""
		echo "" >> informeColor.txt
		printf "La prioridad mínima es\t%2d\n" "$pri_minima" >> informeColor.txt
		printf "La prioridad máxima es\t%2d\n" "$pri_maxima" >> informeColor.txt
		echo "" >> informeColor.txt
		echo "" >> informeBN.txt
		echo -e "La prioridad mínima es	$pri_minima" >> informeBN.txt
		echo -e "La prioridad máxima es	$pri_maxima" >> informeBN.txt
		echo "" >> informeBN.txt
	fi
	for ((p=0;p<$num_proc;p++));do
		if [ $ppp -lt 10 ]; then
			nombre=P0$ppp
		else 
			nombre=P$ppp
		fi
		#ComprobarPalabras $nombre #comprobamos que la entrada leída de nombre es correcta
		proceso[$p]="${colores[$p]}$nombre${NC}"; 		#añadimos al vector de los procesos en la posición del índice el nombre de ese proceso
		tiempintro[$p]=$p
		procesosc[$p]="$nombre"
		let contar_lineas=p+3
		contar_lineas_p=$contar_lineas'p'
		pp=1
		temp=`cat $rutaFich | cut -d ";" -f $pp | sed -n $contar_lineas_p`
		templl[$p]=$temp
		let pp++		
		tiemp=`cat $rutaFich | cut -d ";" -f $pp | sed -n $contar_lineas_p`
		tiempo[$p]="$tiemp"
		tiempofijo[$p]="$tiemp"
		let pp++			
		memor=`cat $rutaFich | cut -d ";" -f $pp | sed -n $contar_lineas_p`
		memori[$p]=$memor
		let pp++
		priorida=`cat $rutaFich | cut -d ";" -f $pp | sed -n $contar_lineas_p`
		dato_priorid=$(calculoSegunTipoPrioridad $tipo_prioridad $priorida)
		ComprobarPrioridad
		prioridad[$p]=$priorida
		dato_prioridad[$p]=$dato_priorid
		#let pp++
		#echo -e "${verdeR}Proceso: ${verde}$nombre ${verdeR}Tiempo de llegada: ${verde}$temp ${verdeR}Tiempo de ejecución: ${verde}$tiemp ${verdeR}Prioridad de Proceso: ${verde}$priorida ${verdeR}Memoria que ocupa: ${verde}$memor"  >> informeColor.txt
		#echo "Proceso: $nombre Tiempo de llegada: $temp Tiempo de ejecución: $tiemp Prioridad de Proceso: $priorida Memoria que ocupa: $memor"  >> informeBN.txt	
		let ppp++
		#Ordenar
	done
	Ordenar

	printf "Ref Tll Tej Mem Pri\n"
	for ((i=0;i<${#tiempo[@]};i++));do
			printf "${colores[$i]}%s${NC} " ${procesosc[$i]}
			printf "${colores[$i]}%3d${NC} " ${templl[$i]}
			printf "${colores[$i]}%3d${NC} " ${tiempofijo[$i]}
			printf "${colores[$i]}%3d${NC} "	${memori[$i]}
			printf "${colores[$i]}%3d${NC} " ${prioridad[$i]}
			echo ""
	done
	printf "Ref Tll Tej Mem Pri\n" >> informeColor.txt
	for ((i=0;i<${#tiempo[@]};i++));do
			printf "${colores[$i]}%s${NC} " ${procesosc[$i]} >> informeColor.txt
			printf "${colores[$i]}%3d${NC} " ${templl[$i]} >> informeColor.txt
			printf "${colores[$i]}%3d${NC} " ${tiempofijo[$i]} >> informeColor.txt
			printf "${colores[$i]}%3d${NC} "	${memori[$i]} >> informeColor.txt
			printf "${colores[$i]}%3d${NC} " ${prioridad[$i]} >> informeColor.txt
			echo "" >> informeColor.txt
	done
	printf "Ref Tll Tej Mem Pri\n" >> informeBN.txt
	for ((i=0;i<${#tiempo[@]};i++));do
			printf "%s " ${procesosc[$i]} >> informeBN.txt
			printf "%3d " ${templl[$i]} >> informeBN.txt
			printf "%3d " ${tiempofijo[$i]} >> informeBN.txt
			printf "%3d "	${memori[$i]} >> informeBN.txt
			printf "%3d " ${prioridad[$i]} >> informeBN.txt
			echo "" >> informeBN.txt
	done
fi

if [ $opcion = 4 ];then #crea un fichero de rangos de forma automatica y lo lee
	CrearFicheroRangos
	guardarRangos

	esunsi=0
	sed "/^ *$/d" $ENTRADA2 > datos.txt
	mv datos.txt $ENTRADA2
	num_proc=`expr $(cat $ENTRADA2 | wc -l) - 2`
	if [ $p = 0 ];then
		pri_minima=`cat $ENTRADA2 | cut -f 1 -d";" | sed -n 2p`
		pri_maxima=`cat $ENTRADA2 | cut -f 2 -d";" | sed -n 2p`
		n_particiones=`cat $ENTRADA2 | sed -n 1p | grep -o ";" | wc -l`

		calcularTipoPrioridad $pri_minima $pri_maxima

		for (( jka=0; jka<n_particiones; jka++ ));do
			part_cap[$jka]=$(cat $ENTRADA2 | cut -f$(expr $jka + 1) -d";" | sed -n 1p)
			let cap_memoria=cap_memoria+part_cap[$jka]
			if [ $jka -eq 0 ];then
				part_init[$jka]=0
			else
				part_init[$jka]=$(expr ${part_fin[$(expr $jka - 1)]} + 1)
			fi
			let part_fin[$jka]=part_init[$jka]+part_cap[$jka]
			let part_fin[$jka]=part_fin[$jka]-1
		done
		echo -e ""
		echo -e "${verdeR}Todas las particiones estan creadas${NC}"
		echo -e "Las particiones empiezan en	${part_init[@]}"
		echo -e "Las particiones acaban en	${part_fin[@]}"
		echo -e "Tamaño completo de la memoria	$cap_memoria"
		echo -e "" >> informeColor.txt
		echo -e "${verdeR}Todas las particiones estan creadas${NC}" >> informeColor.txt
		echo -e "Las particiones empiezan en	${part_init[@]}" >> informeColor.txt
		echo -e "Las particiones acaban en	${part_fin[@]}" >> informeColor.txt
		echo -e "Tamaño completo de la memoria	$cap_memoria" >> informeColor.txt
		echo -e "" >> informeBN.txt
		echo -e "Todas las particiones estan creadas" >> informeBN.txt
		echo -e "Las particiones empiezan en	${part_init[@]}" >> informeBN.txt
		echo -e "Las particiones acaban en	${part_fin[@]}" >> informeBN.txt
		echo -e "Tamaño completo de la memoria	$cap_memoria" >> informeBN.txt
		
		echo ""
		printf "La prioridad mínima es\t%2d\n" "$pri_minima"
		printf "La prioridad máxima es\t%2d\n" "$pri_maxima"
		echo ""
		echo "" >> informeColor.txt
		printf "La prioridad mínima es\t%2d\n" "$pri_minima" >> informeColor.txt
		printf "La prioridad máxima es\t%2d\n" "$pri_maxima" >> informeColor.txt
		echo "" >> informeColor.txt
		echo "" >> informeBN.txt
		echo -e "La prioridad mínima es	$pri_minima" >> informeBN.txt
		echo -e "La prioridad máxima es	$pri_maxima" >> informeBN.txt
		echo "" >> informeBN.txt
	fi
	for ((p=0;p<$num_proc;p++));do
		if [ $ppp -lt 10 ]; then
			nombre=P0$ppp
		else 
			nombre=P$ppp
		fi
		#ComprobarPalabras $nombre #comprobamos que la entrada leída de nombre es correcta
		proceso[$p]="${colores[$p]}$nombre${NC}"; 		#añadimos al vector de los procesos en la posición del índice el nombre de ese proceso
		tiempintro[$p]=$p
		procesosc[$p]="$nombre"
		let contar_lineas=p+3
		contar_lineas_p=$contar_lineas'p'
		pp=1
		temp=`cat $ENTRADA2 | cut -d ";" -f $pp | sed -n $contar_lineas_p`
		templl[$p]=$temp
		let pp++		
		tiemp=`cat $ENTRADA2 | cut -d ";" -f $pp | sed -n $contar_lineas_p`
		tiempo[$p]="$tiemp"
		tiempofijo[$p]="$tiemp"
		let pp++			
		memor=`cat $ENTRADA2 | cut -d ";" -f $pp | sed -n $contar_lineas_p`
		memori[$p]=$memor
		let pp++
		priorida=`cat $ENTRADA2 | cut -d ";" -f $pp | sed -n $contar_lineas_p`
		dato_priorid=$(calculoSegunTipoPrioridad $tipo_prioridad $priorida)
		ComprobarPrioridad
		prioridad[$p]=$priorida
		dato_prioridad[$p]=$dato_priorid
		#let pp++
		#echo -e "${verdeR}Proceso: ${verde}$nombre ${verdeR}Tiempo de llegada: ${verde}$temp ${verdeR}Tiempo de ejecución: ${verde}$tiemp ${verdeR}Prioridad de Proceso: ${verde}$priorida ${verdeR}Memoria que ocupa: ${verde}$memor"  >> informeColor.txt
		#echo "Proceso: $nombre Tiempo de llegada: $temp Tiempo de ejecución: $tiemp Prioridad de Proceso: $priorida Memoria que ocupa: $memor"  >> informeBN.txt	
		let ppp++
		#Ordenar
	done
	Ordenar

	printf "Ref Tll Tej Mem Pri\n"
	for ((i=0;i<${#tiempo[@]};i++));do
			printf "${colores[$i]}%s${NC} " ${procesosc[$i]}
			printf "${colores[$i]}%3d${NC} " ${templl[$i]}
			printf "${colores[$i]}%3d${NC} " ${tiempofijo[$i]}
			printf "${colores[$i]}%3d${NC} "	${memori[$i]}
			printf "${colores[$i]}%3d${NC} " ${prioridad[$i]}
			echo ""
	done
	printf "Ref Tll Tej Mem Pri\n" >> informeColor.txt
	for ((i=0;i<${#tiempo[@]};i++));do
			printf "${colores[$i]}%s${NC} " ${procesosc[$i]} >> informeColor.txt
			printf "${colores[$i]}%3d${NC} " ${templl[$i]} >> informeColor.txt
			printf "${colores[$i]}%3d${NC} " ${tiempofijo[$i]} >> informeColor.txt
			printf "${colores[$i]}%3d${NC} "	${memori[$i]} >> informeColor.txt
			printf "${colores[$i]}%3d${NC} " ${prioridad[$i]} >> informeColor.txt
			echo "" >> informeColor.txt
	done
	printf "Ref Tll Tej Mem Pri\n" >> informeBN.txt
	for ((i=0;i<${#tiempo[@]};i++));do
			printf "%s " ${procesosc[$i]} >> informeBN.txt
			printf "%3d " ${templl[$i]} >> informeBN.txt
			printf "%3d " ${tiempofijo[$i]} >> informeBN.txt
			printf "%3d "	${memori[$i]} >> informeBN.txt
			printf "%3d " ${prioridad[$i]} >> informeBN.txt
			echo "" >> informeBN.txt
	done
fi

if [ $opcion = 5 ];then #leer ultima ejecucion del fichero de rangos automatico
	mkdir -p FicherosRangos

	esunsi=0
	sed "/^ *$/d" FicherosRangos/datosrangos.txt > datos.txt
	mv datos.txt FicherosRangos/datosrangos.txt
	num_proc=`expr $(cat FicherosRangos/datosrangos.txt | wc -l) - 2`
	if [ $p = 0 ];then
		pri_minima=`cat FicherosRangos/datosrangos.txt| cut -f 1 -d";" | sed -n 2p`
		pri_maxima=`cat FicherosRangos/datosrangos.txt | cut -f 2 -d";" | sed -n 2p`
		n_particiones=`cat FicherosRangos/datosrangos.txt | sed -n 1p | grep -o ";" | wc -l`

		calcularTipoPrioridad $pri_minima $pri_maxima

		for (( jka=0; jka<n_particiones; jka++ ));do
			part_cap[$jka]=$(cat FicherosRangos/datosrangos.txt | cut -f$(expr $jka + 1) -d";" | sed -n 1p)
			let cap_memoria=cap_memoria+part_cap[$jka]
			if [ $jka -eq 0 ];then
				part_init[$jka]=0
			else
				part_init[$jka]=$(expr ${part_fin[$(expr $jka - 1)]} + 1)
			fi
			let part_fin[$jka]=part_init[$jka]+part_cap[$jka]
			let part_fin[$jka]=part_fin[$jka]-1
		done
		echo -e ""
		echo -e "${verdeR}Todas las particiones estan creadas${NC}"
		echo -e "Las particiones empiezan en	${part_init[@]}"
		echo -e "Las particiones acaban en	${part_fin[@]}"
		echo -e "Tamaño completo de la memoria	$cap_memoria"
		echo -e "" >> informeColor.txt
		echo -e "${verdeR}Todas las particiones estan creadas${NC}" >> informeColor.txt
		echo -e "Las particiones empiezan en	${part_init[@]}" >> informeColor.txt
		echo -e "Las particiones acaban en	${part_fin[@]}" >> informeColor.txt
		echo -e "Tamaño completo de la memoria	$cap_memoria" >> informeColor.txt
		echo -e "" >> informeBN.txt
		echo -e "Todas las particiones estan creadas" >> informeBN.txt
		echo -e "Las particiones empiezan en	${part_init[@]}" >> informeBN.txt
		echo -e "Las particiones acaban en	${part_fin[@]}" >> informeBN.txt
		echo -e "Tamaño completo de la memoria	$cap_memoria" >> informeBN.txt
		
		echo ""
		printf "La prioridad mínima es\t%2d\n" "$pri_minima"
		printf "La prioridad máxima es\t%2d\n" "$pri_maxima"
		echo ""
		echo "" >> informeColor.txt
		printf "La prioridad mínima es\t%2d\n" "$pri_minima" >> informeColor.txt
		printf "La prioridad máxima es\t%2d\n" "$pri_maxima" >> informeColor.txt
		echo "" >> informeColor.txt
		echo "" >> informeBN.txt
		echo -e "La prioridad mínima es	$pri_minima" >> informeBN.txt
		echo -e "La prioridad máxima es	$pri_maxima" >> informeBN.txt
		echo "" >> informeBN.txt
	fi
	
	for ((p=0;p<$num_proc;p++));do
		if [ $ppp -lt 10 ]; then
			nombre=P0$ppp
		else 
			nombre=P$ppp
		fi
		#ComprobarPalabras $nombre #comprobamos que la entrada leída de nombre es correcta
		proceso[$p]="${colores[$p]}$nombre${NC}"; 		#añadimos al vector de los procesos en la posición del índice el nombre de ese proceso
		tiempintro[$p]=$p
		procesosc[$p]="$nombre"
		let contar_lineas=p+3
		contar_lineas_p=$contar_lineas'p'
		pp=1
		temp=`cat FicherosRangos/datosrangos.txt | cut -d ";" -f $pp | sed -n $contar_lineas_p`
		templl[$p]=$temp
		let pp++		
		tiemp=`cat FicherosRangos/datosrangos.txt | cut -d ";" -f $pp | sed -n $contar_lineas_p`
		tiempo[$p]="$tiemp"
		tiempofijo[$p]="$tiemp"
		let pp++			
		memor=`cat FicherosRangos/datosrangos.txt | cut -d ";" -f $pp | sed -n $contar_lineas_p`
		memori[$p]=$memor
		let pp++
		priorida=`cat FicherosRangos/datosrangos.txt | cut -d ";" -f $pp | sed -n $contar_lineas_p`
		dato_priorid=$(calculoSegunTipoPrioridad $tipo_prioridad $priorida)
		ComprobarPrioridad
		prioridad[$p]=$priorida
		dato_prioridad[$p]=$dato_priorid
		let pp++
		echo -e "${verdeR}Proceso: ${verde}$nombre ${verdeR}Tiempo de llegada: ${verde}$temp ${verdeR}Tiempo de ejecución: ${verde}$tiemp ${verdeR}Prioridad de Proceso: ${verde}$priorida ${verdeR}Memoria que ocupa: ${verde}$memor"  >> informeColor.txt
		echo "Proceso: $nombre Tiempo de llegada: $temp Tiempo de ejecución: $tiemp Prioridad de Proceso: $priorida Memoria que ocupa: $memor"  >> informeBN.txt	
		let ppp++
		Ordenar
	done
	Ordenar

	printf "Ref Tll Tej Mem Pri\n"
	for ((i=0;i<${#tiempo[@]};i++));do
			printf "${colores[$i]}%s${NC} " ${procesosc[$i]}
			printf "${colores[$i]}%3d${NC} " ${templl[$i]}
			printf "${colores[$i]}%3d${NC} " ${tiempofijo[$i]}
			printf "${colores[$i]}%3d${NC} "	${memori[$i]}
			printf "${colores[$i]}%3d${NC} " ${prioridad[$i]}
			echo ""
	done
	printf "Ref Tll Tej Mem Pri\n" >> informeColor.txt
	for ((i=0;i<${#tiempo[@]};i++));do
			printf "${colores[$i]}%s${NC} " ${procesosc[$i]} >> informeColor.txt
			printf "${colores[$i]}%3d${NC} " ${templl[$i]} >> informeColor.txt
			printf "${colores[$i]}%3d${NC} " ${tiempofijo[$i]} >> informeColor.txt
			printf "${colores[$i]}%3d${NC} "	${memori[$i]} >> informeColor.txt
			printf "${colores[$i]}%3d${NC} " ${prioridad[$i]} >> informeColor.txt
			echo "" >> informeColor.txt
	done
	printf "Ref Tll Tej Mem Pri\n" >> informeBN.txt
	for ((i=0;i<${#tiempo[@]};i++));do
			printf "%s " ${procesosc[$i]} >> informeBN.txt
			printf "%3d " ${templl[$i]} >> informeBN.txt
			printf "%3d " ${tiempofijo[$i]} >> informeBN.txt
			printf "%3d "	${memori[$i]} >> informeBN.txt
			printf "%3d " ${prioridad[$i]} >> informeBN.txt
			echo "" >> informeBN.txt
	done
fi

if [ $opcion = 6 ];then #leer fichero intrudocido a mano
	

	esunsi=0
	sed "/^ *$/d" $rutaFich > datos.txt
	mv datos.txt $rutaFich
	num_proc=`expr $(cat $rutaFich | wc -l) - 2`
	if [ $p = 0 ];then
		pri_minima=`cat $rutaFich | cut -f 1 -d";" | sed -n 2p`
		pri_maxima=`cat $rutaFich | cut -f 2 -d";" | sed -n 2p`
		n_particiones=`cat $rutaFich | sed -n 1p | grep -o ";" | wc -l`

		calcularTipoPrioridad $pri_minima $pri_maxima

		for (( jka=0; jka<n_particiones; jka++ ));do
			part_cap[$jka]=$(cat $rutaFich | cut -f$(expr $jka + 1) -d";" | sed -n 1p)
			let cap_memoria=cap_memoria+part_cap[$jka]
			if [ $jka -eq 0 ];then
				part_init[$jka]=0
			else
				part_init[$jka]=$(expr ${part_fin[$(expr $jka - 1)]} + 1)
			fi
			let part_fin[$jka]=part_init[$jka]+part_cap[$jka]
			let part_fin[$jka]=part_fin[$jka]-1
		done
		echo -e ""
		echo -e "${verdeR}Todas las particiones estan creadas${NC}"
		echo -e "Las particiones empiezan en	${part_init[@]}"
		echo -e "Las particiones acaban en	${part_fin[@]}"
		echo -e "Tamaño completo de la memoria	$cap_memoria"
		echo -e "" >> informeColor.txt
		echo -e "${verdeR}Todas las particiones estan creadas${NC}" >> informeColor.txt
		echo -e "Las particiones empiezan en	${part_init[@]}" >> informeColor.txt
		echo -e "Las particiones acaban en	${part_fin[@]}" >> informeColor.txt
		echo -e "Tamaño completo de la memoria	$cap_memoria" >> informeColor.txt
		echo -e "" >> informeBN.txt
		echo -e "Todas las particiones estan creadas" >> informeBN.txt
		echo -e "Las particiones empiezan en	${part_init[@]}" >> informeBN.txt
		echo -e "Las particiones acaban en	${part_fin[@]}" >> informeBN.txt
		echo -e "Tamaño completo de la memoria	$cap_memoria" >> informeBN.txt
		
		echo ""
		printf "La prioridad mínima es\t%2d\n" "$pri_minima"
		printf "La prioridad máxima es\t%2d\n" "$pri_maxima"
		echo ""
		echo "" >> informeColor.txt
		printf "La prioridad mínima es\t%2d\n" "$pri_minima" >> informeColor.txt
		printf "La prioridad máxima es\t%2d\n" "$pri_maxima" >> informeColor.txt
		echo "" >> informeColor.txt
		echo "" >> informeBN.txt
		echo -e "La prioridad mínima es	$pri_minima" >> informeBN.txt
		echo -e "La prioridad máxima es	$pri_maxima" >> informeBN.txt
		echo "" >> informeBN.txt
	fi
	for ((p=0;p<$num_proc;p++));do
		if [ $ppp -lt 10 ]; then
			nombre=P0$ppp
		else 
			nombre=P$ppp
		fi
		#ComprobarPalabras $nombre #comprobamos que la entrada leída de nombre es correcta
		proceso[$p]="${colores[$p]}$nombre${NC}"; 		#añadimos al vector de los procesos en la posición del índice el nombre de ese proceso
		tiempintro[$p]=$p
		procesosc[$p]="$nombre"
		let contar_lineas=p+3
		contar_lineas_p=$contar_lineas'p'
		pp=1
		temp=`cat $rutaFich | cut -d ";" -f $pp | sed -n $contar_lineas_p`
		templl[$p]=$temp
		let pp++		
		tiemp=`cat $rutaFich | cut -d ";" -f $pp | sed -n $contar_lineas_p`
		tiempo[$p]="$tiemp"
		tiempofijo[$p]="$tiemp"
		let pp++			
		memor=`cat $rutaFich | cut -d ";" -f $pp | sed -n $contar_lineas_p`
		memori[$p]=$memor
		let pp++
		priorida=`cat $rutaFich | cut -d ";" -f $pp | sed -n $contar_lineas_p`
		dato_priorid=$(calculoSegunTipoPrioridad $tipo_prioridad $priorida)
		ComprobarPrioridad
		prioridad[$p]=$priorida
		dato_prioridad[$p]=$dato_priorid
		#let pp++
		#echo -e "${verdeR}Proceso: ${verde}$nombre ${verdeR}Tiempo de llegada: ${verde}$temp ${verdeR}Tiempo de ejecución: ${verde}$tiemp ${verdeR}Prioridad de Proceso: ${verde}$priorida ${verdeR}Memoria que ocupa: ${verde}$memor"  >> informeColor.txt
		#echo "Proceso: $nombre Tiempo de llegada: $temp Tiempo de ejecución: $tiemp Prioridad de Proceso: $priorida Memoria que ocupa: $memor"  >> informeBN.txt	
		let ppp++
		#Ordenar
	done
	Ordenar

	printf "Ref Tll Tej Mem Pri\n"
	for ((i=0;i<${#tiempo[@]};i++));do
			printf "${colores[$i]}%s${NC} " ${procesosc[$i]}
			printf "${colores[$i]}%3d${NC} " ${templl[$i]}
			printf "${colores[$i]}%3d${NC} " ${tiempofijo[$i]}
			printf "${colores[$i]}%3d${NC} "	${memori[$i]}
			printf "${colores[$i]}%3d${NC} " ${prioridad[$i]}
			echo ""
	done
	printf "Ref Tll Tej Mem Pri\n" >> informeColor.txt
	for ((i=0;i<${#tiempo[@]};i++));do
			printf "${colores[$i]}%s${NC} " ${procesosc[$i]} >> informeColor.txt
			printf "${colores[$i]}%3d${NC} " ${templl[$i]} >> informeColor.txt
			printf "${colores[$i]}%3d${NC} " ${tiempofijo[$i]} >> informeColor.txt
			printf "${colores[$i]}%3d${NC} "	${memori[$i]} >> informeColor.txt
			printf "${colores[$i]}%3d${NC} " ${prioridad[$i]} >> informeColor.txt
			echo "" >> informeColor.txt
	done
	printf "Ref Tll Tej Mem Pri\n" >> informeBN.txt
	for ((i=0;i<${#tiempo[@]};i++));do
			printf "%s " ${procesosc[$i]} >> informeBN.txt
			printf "%3d " ${templl[$i]} >> informeBN.txt
			printf "%3d " ${tiempofijo[$i]} >> informeBN.txt
			printf "%3d "	${memori[$i]} >> informeBN.txt
			printf "%3d " ${prioridad[$i]} >> informeBN.txt
			echo "" >> informeBN.txt
	done
fi


echo "" >> informeColor.txt
echo -e "COMIENZO DE EJECUCIÓN" >> informeColor.txt
echo "" >> informeColor.txt
echo "" >>informeBN.txt
echo -e "COMIENZO DE EJECUCIÓN" >>informeBN.txt
echo "" >>informeBN.txt


for ((i=0;i<$num_proc;i++));do
	esperav[$i]=0
	retornov[$i]=0
done
#Elaboro los datos de salida para crear el fichero correspondiente a los datos introducidos.
#Guardamos los datos introducidos de forma manual al archivo datosEntradaPred para poder volver a repetir la sesión de forma no manual (MAyor comodidad).	
te=0;	
while [ $te -lt $ti ];do
	let te=te+1
done

flag=0;
#final de ejecución del algoritmo de ordenación del PRIORIDADES
#A través de este bucle conseguimos los tiempos de espera y de retorno de cada uno de los procesos. Además, calculamos sus medias.
espera=0
ier=0
for ((i=0;i<${#tiempo[@]};i++));do
	if [ ${tiempo[$i]} -eq 0 ];then    #si la posición 0 = 0 
	    espera=0;                 #valores de inicio
	    respuesta=${tiempo[0]}; 
	else 
		if [ $i -gt "0" ];then
			espera=`expr $espera + ${tiempo[$(($i-1))]}`
		fi                     #variable que almacena el tiempo de espera de ese proceso, es decir, el tiempo de respuesta anterior
		respuesta=`expr $espera + ${tiempo[$i]}`  #variabl quee que almacena la suma del tiempo de espera, mas el contenido del vector tiempo en esa posición
		suma_espera=`expr $suma_espera + $espera`            #suma para sacar su promedio de espera
		promedio_espera=`expr $suma_espera / ${#tiempo[@]}`  #promedio del tiempo de espera
		suma_respuesta=`expr $suma_respuesta + $respuesta`   #suma para sacar su promedio de respuesta
		promedio_respuesta=`expr $suma_respuesta / ${#tiempo[@]}`  #promedio del tiempo de retorno medio
    fi
	ier=`expr $ier + 1`
done

if [ $opcion2 = 1 ];then
GestionDeMemoria
fi
if [ $opcion2 = 2 ];then
printf  "\n"
echo -e "############################################################" 
echo "Introduce el tiempo de espera."
printf  "\n"
read secs
GestionDeMemoriaAutomatico
fi
if [ $opcion2 = 3 ];then
GestionDeMemoriaCompleta
fi
if [ $opcion2 = 4 ];then
GestionDeMemoriaFinal
fi



#Gráfica que indica la ejecución de cada uno de los procesos respecto al tiempo.
echo -e "RESUMEN DE LA EJECUCIÓN"
echo -e "RESUMEN DE LA EJECUCIÓN" >> informeColor.txt
echo -e "RESUMEN DE LA EJECUCIÓN" >>informeBN.txt
printf "\n"
printf "\n" >> informeColor.txt
printf "\n" >>informeBN.txt
je1=0
carac1=5
wr1=0
je2=0
carac2=2
wr2=0
je3=0
carac3=5
wr3=0
terminar=0
imprimir_status=-1
while [[ $terminar -eq 0 ]];do
	ImprimeProcesos
	printf "\n"
	printf "\n" >> informeColor.txt
	ImprimeGrafica
	printf "\n"
	printf "\n" >> informeColor.txt
	ImprimeLineaTemporal
	printf "\n"
	printf "\n" >> informeColor.txt
	carac1=5
	carac2=5
	carac3=5
done
je1=0
carac1=5
wr1=0
je2=0
carac2=2
wr2=0
je3=0
carac3=5
wr3=0
terminar=0
imprimir_status=-1
while [[ $terminar -eq 0 ]];do
	ImprimeProcesosBW
	printf "\n" >>informeBN.txt
	ImprimeGraficaBW
	printf "\n" >>informeBN.txt
	ImprimeLineaTemporalBW
	echo "" >>informeBN.txt
	carac1=5
	carac2=5
	carac3=5
done
	
#promedios e imprimimos
echo ""
printf "Tiempo medio de espera=$medEspera\t" 
printf " Tiempo medio de retorno=$medRetorno"
echo ""
echo "" >> informeColor.txt
printf "Tiempo medio de espera=$medEspera\t" >> informeColor.txt
printf " Tiempo medio de retorno=$medRetorno" >> informeColor.txt
echo "" >> informeColor.txt
echo "" >>informeBN.txt
printf "Tiempo medio de espera=$medEspera\t" >>informeBN.txt
printf " Tiempo medio de retorno=$medRetorno" >>informeBN.txt
echo "" >>informeBN.txt

#apertura del informe final
echo ""
printf "¿Quieres ver el informe a continuación? (s/n): " 
read datos
if [ -z "${datos}" ];then
	datos="s"
fi
while [ "${datos}" != "s" -a "${datos}" != "n" -a "${datos}" != "S" -a "${datos}" != "N" ];do
	printf "${rojoR}ERROR: ${rojo}Entrada no válida, vuelve a intentarlo. ¿Quieres abrir el informe? (s/n): " 
	read datos
	if [ -z "${datos}" ];then
		datos="s"
	fi
done
if [ $datos = "s" ] || [ $datos = "S" ];then
	cat informeColor.txt
else
	printf "¿Quieres abrir el informe (.txt)? (s/n): "
	read datosdos
	if [ -z "${datosdos}" ];then
		datos="s"
	fi
	while [ "${datosdos}" != "s" -a "${datosdos}" != "n" -a "${datosdos}" != "S" -a "${datosdos}" != "N" ];do
		printf "${rojoR}ERROR: ${rojo}Entrada no válida, vuelve a intentarlo. ${azulR}¿Quieres abrir el informe (.txt)? (${verdeR}s${azulR}/${rojoR}n${azulR}):${azul} " 
		read datos
		if [ -z "${datosdos}" ];then
			datos="s"
		fi
	done
	if [ $datosdos = "s" ] || [ $datosdos = "S" ];then
		gediinformeBN.txt
	fi
fi
echo -ne "\x1B]111\a"

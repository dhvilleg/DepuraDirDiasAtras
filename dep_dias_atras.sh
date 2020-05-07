#!/bin/bash
# ===========================================================================================================
#  Script %name:        dep_dias_atras.sh %
#  %version:            1 %
#  Description:         Depura (Elimina), los archivos contenidos en el archivo de configuracion
#                       $HOME/directorios.dat el formato del archivo de configuracion es el siguiente
#                       path_directorio:*.extencion por ejemplo 
#		        		/RYG/CHURN/msgreceived/err:*.err
# ===========================================================================================================
#  %created_by:         Diego Villegas (FDM) %
#  %date_created:       Fri Feb 24 13:13:39 SAT 2012 %
# ===========================================================================================================
# change log
# ===========================================================================================================
# Mod.ID         Who                            When                                    Description
# ===========================================================================================================
# 1.1		Diego Villegas (FDM)	Wed Mar 28 15:17:49 SAT 2012	Se agrega control de existencia del
#		                                                                archivo de configuracion.
#
# 	                                                                    Se agrega envio de reporte por correo
#		                                                                solo en caso de errores.
# ===========================================================================================================
#definiciones que se pueden cambiar

#Directorio donde se debe cargar el archivo de configuración, y se escribira los logs.
HOME=/home/NAAN1U01
#Direcciones de Correos a donde se enviara las notificaciones en caso de errores
MAILADD='servicio_n1_unix@FDM.com.ec,operador.sistemas@FDM.com.ec'
#Parametro de dias a mantener antes de la depuracion
DIAS=15
#Formato de Fecha de ejecucion del SOP
FECHA=`date`

#cabecera de descripcion de proceso
echo '-------------------------------------------------------------------------'>>$HOME/cabecera.txt
echo "|SOP  MANTENIMIENTO DE SERVIDOR ICARO  FILESYSTEM /RYG  Y /home/usergana |"  >>$HOME/cabecera.txt
echo '-------------------------------------------------------------------------'>>$HOME/cabecera.txt
echo 'Fecha e ejecucion: $FECHA'>>$HOME/cabecera.txt
				
#Inicio del proceso
if [ -f $HOME/directorios.dat ]; then
	for i in `cat $HOME/directorios.dat`
	do
	DIRECTORIO=`echo $i | awk -F: '{ print $1 }'`
	EXT=`echo $i | awk -F: '{ print $2 }'`
	if [ -d $DIRECTORIO ]; then
		find $DIRECTORIO -name "$EXT" -mtime +$DIAS>$HOME/lista.tmp
		for e in `cat $HOME/lista.tmp`;
		do
			if [ -f $e ]; then
				rm -f $e 2>>$HOME/dep_dias_atras.err
			else
				cat $HOME/cabecera.txt>>$HOME/dep_dias_atras.err
				echo 'Fecha e ejecucion: $FECHA'>>$HOME/dep_dias_atras.err
				echo "|$e No es un archivo regular directorio: $DIRECTORIO "  >>$HOME/dep_dias_atras.err
				echo '|Favor validar '  >>$HOME/dep_dias_atras.err
				echo '-------------------------------------------------------------------------'>>$HOME/dep_dias_atras.err
			fi
		done
		>$HOME/lista.tmp
	else
		cat $HOME/cabecera.txt>>$HOME/dep_dias_atras.err
		echo "|El siguiente no es un directorio valido: $DIRECTORIO"  >>$HOME/dep_dias_atras.err
		echo "|Favor revisar el archivo de configuracion $HOME/directorios.dat ">>$HOME/dep_dias_atras.err
		echo '-------------------------------------------------------------------------'>>$HOME/dep_dias_atras.err
	fi
	done
	if [ -f $HOME/dep_dias_atras.err ]; then
		mailx -s "La depuracion finaliza con errores: " $MAILADD <$HOME/dep_dias_atras.err
		rm -f $HOME/dep_dias_atras.err
		rm -f $HOME/cabecera.tx
	fi
else
	cat $HOME/cabecera.txt>>$HOME/alert.msj
	echo '-------------------------------------------------------------------------'>>$HOME/alert.msj
	echo '|No existe el fichero de configuracion, favor validar'>>$HOME/alert.msj
	echo '-------------------------------------------------------------------------'>>$HOME/alert.msj
	mailx -s "La depuracion finaliza con errores: " $MAILADD <$HOME/alert.msj
	rm -f $HOME/alert.msj
	rm -f $HOME/cabecera.txt
fi

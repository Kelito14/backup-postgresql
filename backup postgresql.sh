!/bin/bash
 ######## Bash script para hacer mantenimiento y backup de bases de datos especificas ########
 
 dbcxn="-h localhost -p 5432 -U postgres";    # Datos de conexion
 
 rtdir="/home/kelito/Escritorio/backup/";        # Directorio de backups
 
 dblst=( pcmca_pcs );                         #Nombre de la db q se quiere exportar
 
 # Directorio de backup
 dirdt=`eval date +%Y%m%d`;             # Fecha para el directorio
 bkdir=$rtdir"/backup-"$dirdt;            # Direccion absoluta directorio
 if [ ! -d $bkdir ]; then
   echo "Creando directorio: "$bkdir" ";
   /bin/mkdir $bkdir
 fi
 
 # Boocle para vacum, reparacion, y backup
 dbsc=0;
 dbst=${#dblst[@]};
 while [ "$dbsc" -lt "$dbst" ]; do
   dbsp=${dblst[$dbsc]};
   dbspf=""$bkdir"/"$dbsp"";            # Prefijo (dir+nom+fecha) nombre de archivo
   echo "";
   echo "######################################################";
   echo "Procesando base de datos '"$dbsp"'";
 
   echo "  * Realizando reindexado de: '"$dbsp"'";
   ridt=`eval date +%Y%m%d_%H%M%S`;
   /usr/bin/reindexdb $dbcxn -d $dbsp -e > $dbspf"-"$ridt"-reindexdb.log" 2>&1
 
   echo "  * Realizando vacuum de: '"$dbsp"'";
   vadt=`eval date +%Y%m%d_%H%M%S`;
   /usr/bin/vacuumdb $dbcxn -f -v -d $dbsp > $dbspf"-"$vadt"-vacuumdb.log" 2>&1
 
   echo "  * Realizando copia de seguridad de: '"$dbsp"'";
   bkdt=`eval date +%Y%m%d_%H%M%S`;
   /usr/bin/pg_dump -i $dbcxn -F c -b -v -f $dbspf"-"$bkdt".backup" $dbsp > $dbspf"-"$bkdt"-backup.log" 2>&1
 
   echo "######################################################";
   echo "";
 
   dbsc=`expr $dbsc + 1`;
 done
 exit 0;
 
== ==
#OBS: para evitar que el postgresql pida contraseña debe modificarde se esta manera el /<path>/pg_hba.conf
# local   all         all                               ident
 # IPv4 local connections:
 #host    all         all         127.0.0.1/32          trust
 
== ==
 
#Para evitar desactivar la solicitud de contraseña se puede usar un "export" que almacene la cotnraseña de la siguiente forma:  
 
#export PGPASSWORD='MI_PASSWD'
 
#Este puede ubicarse para mejor organización después de la línea rtdir 

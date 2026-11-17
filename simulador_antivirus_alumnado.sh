#!/bin/bash

# ==========================================================
# UT4 - MALWARE Y ANTIMALWARE
# TAREA 2 - CREA TU PROPIO ANTIVIRUS
# ==========================================================
#
# OBJETIVO:
# Analizar archivos .txt ficticios de un laboratorio, buscar
# una firma, crear un informe y preguntar antes de eliminarlos.
#
# INSTRUCCIONES:
# - Sustituye cada ... por el código Bash correspondiente.
# - Conserva los bucles, los condicionales y las comprobaciones
#   de seguridad que ya están preparadas.
# - No utilices sudo. Trabaja solo con archivos de prueba.
# - Este archivo NO está terminado: no lo ejecutes hasta
#   haber reemplazado todos los ...
# ==========================================================


# ----------------------------------------------------------
# 1. PREPARACIÓN DEL LABORATORIO
# ----------------------------------------------------------
# Estas variables ya están preparadas. No necesitas cambiarlas.
LAB="$HOME/laboratorio_malware"
DOCS="$LAB/documentos"
INFORME="$LAB/informe_antivirus.txt"
FIRMA="INFECTADO_SMR_2026"

# Comprobar que el laboratorio existe y que sus rutas principales
# no son enlaces simbólicos. Así evitamos acceder por error
# a elementos situados fuera del laboratorio.
if [ ! -d "$DOCS" ] || [ -L "$LAB" ] || [ -L "$DOCS" ] || [ -L "$INFORME" ]; then
    echo "ERROR: laboratorio no válido. Comprueba las carpetas."
    exit 1
fi

# Entrar en la carpeta donde están los archivos de prueba.
cd "$DOCS" || exit 1


# ----------------------------------------------------------
# 2. CONTADORES
# ----------------------------------------------------------
# Crea cuatro variables con valor inicial 0:
# - analizados: número total de archivos examinados.
# - sospechosos: archivos que contienen la firma.
# - limpios: archivos que no contienen la firma.
# - eliminados: archivos borrados tras la confirmación.
analizados=0
sospechosos=0
limpios=0
eliminados=0


echo "=== ANTIVIRUS SMR ==="
echo "Analizando archivos..."
echo


# ----------------------------------------------------------
# 3. PREPARAR EL INFORME
# ----------------------------------------------------------
# Estas líneas crean el informe y guardan la fecha actual.
# Recuerda: > sobrescribe el archivo; >> añade contenido.
echo "INFORME DEL ANTIVIRUS SMR" > "$INFORME"
echo "Fecha del análisis: $(date)" >> "$INFORME"
echo "Archivos sospechosos detectados:" >> "$INFORME"


# ----------------------------------------------------------
# 4. ANALIZAR LOS ARCHIVOS .txt
# ----------------------------------------------------------
# El bucle recorre los archivos .txt de la carpeta actual.
for archivo in *.txt
do
    # Analizar solo archivos normales, NO enlaces simbólicos.
    if [ -f "$archivo" ] && [ ! -L "$archivo" ]; then

        # Incrementa el contador de archivos analizados.
        analizados=$((analizados + 1))

        # Comprueba si el archivo contiene la firma.
        # PISTA: grep -Fq busca un texto literal en un archivo
        # y permite usar su resultado dentro de un if.
        if grep -Fq "$FIRMA" "$archivo"; then

            # Si contiene la firma:
            # 1) muestra [ALERTA] y el nombre del archivo;
            # 2) aumenta el contador de sospechosos;
            # 3) añade el nombre al informe.
            echo "[ALERTA] $archivo"
            sospechosos=$((sospechosos+1))
            "$archivo" >> "$INFORME"

        else

            # Si NO contiene la firma:
            # 1) muestra [LIMPIO] y el nombre del archivo;
            # 2) aumenta el contador de limpios.
            echo "[LIMPIO] $archivo"
            limpios=$((limpios + 1))

        fi
    fi
done


# ----------------------------------------------------------
# 5. MOSTRAR Y GUARDAR EL RESUMEN
# ----------------------------------------------------------
# Muestra el número de archivos analizados, sospechosos y limpios.
# Después, escribe esos mismos datos al final del informe.
echo "Análisis finalizado."
echo 
echo "Resultados:"
echo "$analizados Analizados"
echo "$sospechosos Sospechosos"
echo "$limpios Limpios"

echo "Resultados:" >> $INFORME
echo "$analizados Analizados" >> $INFORME
echo "$sospechosos Sospechosos" >> $INFORME
echo "$limpios Limpios" >> $INFORME


# ----------------------------------------------------------
# 6. PEDIR PERMISO PARA ELIMINAR
# ----------------------------------------------------------
# Solo preguntamos si hay al menos un archivo sospechoso.
if [ "$sospechosos" -gt 0 ]; then

    # Muestra cuántos archivos sospechosos se han encontrado.
    echo "Se han encontrado $sospechosos archivos sospechosos"

    # Pregunta al usuario si desea eliminarlos (s/n).
    # PISTA: read permite guardar lo que escribe el usuario.
    read -p "Desea eliminarlos? (s/n)" "$respuesta"

    if [ "$respuesta" = "s" ]; then

        echo "Eliminando archivos sospechosos..."

        # Recorre de nuevo SOLO los .txt del laboratorio.
        for archivo in *.txt
        do
            if [ -f "$archivo" ] && [ ! -L "$archivo" ]; then

                # Comprueba OTRA VEZ si contiene la firma.
                # Nunca elimines un archivo solo por su extensión.
                if grep -Fq "$FIRMA" "$archivo"; then

                    # Intenta eliminar SOLO este archivo.
                    # PISTA: rm -- "$archivo" elimina el archivo
                    # indicado; el if permite comprobar si funcionó.
                    if rm -- "$archivo" ; then

                        # Indica cuál se ha eliminado.
                        # Suma 1 al contador de eliminados.
                        # Registra la eliminación en el informe.
                        echo "$archivo ha sido eliminado"
                        eliminados=$((eliminados + 1))
                        ...

                    else
                        # Si falla el borrado, informa del error.
                        echo "Fallo al borrar"
                    fi

                fi
            fi
        done

        # Muestra y registra cuántos archivos se eliminaron.
        echo "Se han eliminado $eliminados archivos"
        echo "Se han eliminado $eliminados archivos" >> $INFORME

    elif [ "$respuesta" = "n" ]; then

        # El usuario ha rechazado la eliminación:
        # no borres nada y deja constancia en el informe.
        echo "El usuario ha rechazado la eliminación"
        echo "El usuario ha rechazado la eliminación" >> $INFORME

    else

        # Si escribe otra cosa, no borres ningún archivo.
        echo "Opcion invalida"
        echo 
        continue

    fi

else

    # No se han encontrado sospechosos: no hay que preguntar.
    echo "No se han encontrado archivos sospechosos"
    echo "No se han encontrado archivos sospechosos" >> $INFORME

fi

# FIN DE LA PLANTILLA

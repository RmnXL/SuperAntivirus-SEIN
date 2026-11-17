#!/bin/bash

# ==========================================================
# UT4 - MALWARE Y ANTIMALWARE
# TAREA 2 - CREA TU PROPIO ANTIVIRUS
# ==========================================================
# Analiza los archivos .txt de laboratorio_malware/documentos,
# busca una firma, genera un informe y pregunta antes de
# eliminar los archivos sospechosos.
# No usar sudo. Trabajar solo con archivos de prueba.
# ==========================================================

# ----------------------------------------------------------
# 1. PREPARACIÓN DEL LABORATORIO
# ----------------------------------------------------------
LAB="$HOME/laboratorio_malware"
DOCS="$LAB/documentos"
INFORME="$LAB/informe_antivirus.txt"
FIRMA="INFECTADO_SMR_2026"

# Comprobar que el laboratorio existe y que sus rutas principales
# no son enlaces simbólicos.
if [ ! -d "$DOCS" ] || [ -L "$LAB" ] || [ -L "$DOCS" ] || [ -L "$INFORME" ]; then
    echo "ERROR: laboratorio no válido. Comprueba las carpetas."
    exit 1
fi

# Entrar en la carpeta donde están los archivos de prueba.
cd "$DOCS" || exit 1

# ----------------------------------------------------------
# 2. CONTADORES
# ----------------------------------------------------------
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
# > sobrescribe el informe anterior; >> añade contenido.
echo "INFORME DEL ANTIVIRUS SMR" > "$INFORME"
echo "Fecha del análisis: $(date)" >> "$INFORME"
echo "Archivos sospechosos detectados:" >> "$INFORME"

# ----------------------------------------------------------
# 4. ANALIZAR LOS ARCHIVOS .txt
# ----------------------------------------------------------
for archivo in *.txt
do
    # Solo archivos normales, NO enlaces simbólicos.
    if [ -f "$archivo" ] && [ ! -L "$archivo" ]; then

        analizados=$((analizados + 1))

        # grep -F: texto literal | -q: sin salida, solo código de retorno
        if grep -Fq "$FIRMA" "$archivo"; then
            echo "[ALERTA] $archivo"
            sospechosos=$((sospechosos + 1))
            echo "$archivo" >> "$INFORME"
        else
            echo "[LIMPIO] $archivo"
            limpios=$((limpios + 1))
        fi
    fi
done

# ----------------------------------------------------------
# 5. MOSTRAR Y GUARDAR EL RESUMEN
# ----------------------------------------------------------
echo
echo "Análisis finalizado."
echo "Archivos analizados: $analizados"
echo "Archivos sospechosos: $sospechosos"
echo "Archivos limpios: $limpios"

echo >> "$INFORME"
echo "Resultados:" >> "$INFORME"
echo "Archivos analizados: $analizados" >> "$INFORME"
echo "Archivos sospechosos: $sospechosos" >> "$INFORME"
echo "Archivos limpios: $limpios" >> "$INFORME"

# ----------------------------------------------------------
# 6. PEDIR PERMISO PARA ELIMINAR
# ----------------------------------------------------------
if [ "$sospechosos" -gt 0 ]; then

    echo
    echo "Se han detectado $sospechosos archivos sospechosos."

    # OJO: read lleva el NOMBRE de la variable, sin $
    read -r -p "¿Deseas eliminar los archivos infectados? (s/n): " respuesta

    if [ "$respuesta" = "s" ]; then

        echo >> "$INFORME"
        echo "Archivos eliminados:" >> "$INFORME"

        for archivo in *.txt
        do
            if [ -f "$archivo" ] && [ ! -L "$archivo" ]; then

                # Comprobar OTRA VEZ la firma antes de borrar.
                if grep -Fq "$FIRMA" "$archivo"; then

                    if rm -- "$archivo"; then
                        echo "[ELIMINADO] $archivo"
                        eliminados=$((eliminados + 1))
                        echo "$archivo" >> "$INFORME"
                    else
                        echo "[ERROR] No se pudo eliminar $archivo"
                        echo "[ERROR] No se pudo eliminar $archivo" >> "$INFORME"
                    fi
                fi
            fi
        done

        echo "Eliminación finalizada."
        echo "Archivos eliminados: $eliminados"
        echo "Archivos eliminados: $eliminados" >> "$INFORME"

    elif [ "$respuesta" = "n" ]; then
        echo "Eliminación cancelada. No se ha borrado ningún archivo."
        echo >> "$INFORME"
        echo "El usuario ha cancelado la eliminación. No se ha borrado ningún archivo." >> "$INFORME"

    else
        echo "Respuesta no válida. No se ha borrado ningún archivo."
        echo >> "$INFORME"
        echo "Respuesta no válida. No se ha borrado ningún archivo." >> "$INFORME"
    fi

else
    echo
    echo "No se han encontrado archivos sospechosos."
    echo >> "$INFORME"
    echo "No se han encontrado archivos sospechosos." >> "$INFORME"
fi

# FIN DEL PROGRAMA
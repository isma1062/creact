#!/bin/bash
# INSTALADOR DEL ECOSISTEMA 'CREACT' + 'ARQON' (VERSIÓN 15.0 - EDICIÓN OPTIMIZADA)
# Usa un spinner de 600 frames pre-calculado en memoria para máxima fluidez y un instalador robusto.

# --- Colores y Estilos ---
GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BLUE='\033[0;34m'; PURPLE='\033[0;35m'; NC='\033[0m'
BOLD='\033[1m'

#------------------------------------------------------------------#
#  DEFINICIÓN DEL COMANDO 'CREACT' (Interfaz de Usuario)
#------------------------------------------------------------------#
CREACT_SCRIPT=$(cat <<'EOF'
#!/bin/bash
# Interfaz principal para la creación de proyectos.

# --- Colores ---
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; PURPLE='\033[0;35m'
CYAN='\033[0;36m'; BLUE='\033[0;34m'; RED='\033[0;31m'; NC='\033[0m'
BOLD='\033[1m'

# --- LÓGICA DEL SPINNER DINÁMICO OPTIMIZADO ---
# Arrays para guardar las posiciones calculadas
declare -a PX PY OW

# Calcula las 600 posiciones una sola vez y las guarda en los arrays
precalculate_frames() {
    local total_frames=600
    local PI=$(echo "scale=10; 4*a(1)" | bc -l)
    
    tput civis # Oculta el cursor durante el cálculo
    echo -e "${PURPLE}Optimizando animación por primera vez...${NC}"

    for i in $(seq 0 $((total_frames - 1))); do
        local angle=$(echo "scale=10; $i * (2 * $PI / $total_frames)" | bc -l)
        PX[$i]=$(printf "%.0f" "$(echo "10 * c($angle)" | bc -l)")
        PY[$i]=$(printf "%.0f" "$(echo "4 * s($angle)" | bc -l)")
        OW[$i]=$(printf "%.0f" "$(echo "a(8 * c($angle * 2))" | bc -l | sed 's/-//')")
    done
    tput cnorm # Muestra el cursor de nuevo
}

# Dibuja un fotograma usando los datos pre-calculados
draw_frame() {
    local frame_num=$1; local start_row=$2; local start_col=$3
    local pole_x=${PX[$frame_num]}; local pole_y=${PY[$frame_num]}; local oval_width=${OW[$frame_num]}
    local char1="/"; local char2="\\"; if (( oval_width < 4 )); then char1="|"; char2="|"; fi

    tput cup $((start_row + 4 - pole_y)) $((start_col + 10 - pole_x)); echo -e "${CYAN}(@)${NC}"
    tput cup $((start_row + 2)) $((start_col + 10 - oval_width)); echo -e "${CYAN}${char1}${NC}"
    tput cup $((start_row + 3)) $((start_col + 10 - oval_width)); echo -e "${CYAN}${char1}${NC}"
    tput cup $((start_row + 5)) $((start_col + 10 - oval_width)); echo -e "${CYAN}${char2}${NC}"
    tput cup $((start_row + 6)) $((start_col + 10 - oval_width)); echo -e "${CYAN}${char2}${NC}"
    tput cup $((start_row + 4)) $((start_col + 10)); echo -e "${PURPLE}O${NC}"
    tput cup $((start_row + 2)) $((start_col + 10 + oval_width)); echo -e "${CYAN}${char2}${NC}"
    tput cup $((start_row + 3)) $((start_col + 10 + oval_width)); echo -e "${CYAN}${char2}${NC}"
    tput cup $((start_row + 5)) $((start_col + 10 + oval_width)); echo -e "${CYAN}${char1}${NC}"
    tput cup $((start_row + 6)) $((start_col + 10 + oval_width)); echo -e "${CYAN}${char1}${NC}"
    tput cup $((start_row + 4 + pole_y)) $((start_col + 10 + pole_x)); echo -e "${CYAN}(@)${NC}"
}

# Orquesta la animación mientras un comando se ejecuta en segundo plano
run_with_giant_spinner() {
    local cmd_to_run=$1; local status_message=$2; local frame_index=0
    
    # Si los frames no han sido calculados, los calcula ahora.
    if [ ${#PX[@]} -eq 0 ]; then
        precalculate_frames
    fi
    
    eval "$cmd_to_run" &> /dev/null &
    local pid=$!; tput civis; tput clear
    
    while kill -0 $pid 2>/dev/null; do
        local height=$(tput lines); local width=$(tput cols)
        local start_row=$(( (height - 9) / 2 )); local start_col=$(( (width - 21) / 2 ))
        
        tput cup 0 0
        draw_frame $frame_index $start_row $start_col
        
        tput cup $((height - 2)) 0
        printf "%*s" $(( (width + ${#status_message}) / 2 )) "${YELLOW}${status_message}${NC}"
        
        frame_index=$(( (frame_index + 1) % 600 )); sleep 0.016
    done
    tput cnorm; tput clear
}

# --- Configuración del Menú (Simple y Robusto) ---
declare -A MENU_INFO
MENU_OPTIONS=( "React - Arqon" "Vue - Arqon" "Svelte - Arqon" "SolidJS - Arqon" "Preact - Arqon" "Lit - Arqon" "Vanilla TS - Arqon" "Salir" )
MENU_INFO["React - Arqon"]="${YELLOW}Framework:${NC} React\n${YELLOW}Ideal para:${NC} SPAs complejas."
MENU_INFO["Vue - Arqon"]="${YELLOW}Framework:${NC} Vue.js\n${YELLOW}Ideal para:${NC} Proyectos versátiles."
MENU_INFO["Svelte - Arqon"]="${YELLOW}Framework:${NC} Svelte\n${YELLOW}Ideal para:${NC} Interfaces sin sobrecarga."
MENU_INFO["SolidJS - Arqon"]="${YELLOW}Framework:${NC} SolidJS\n${YELLOW}Ideal para:${NC} Máximo rendimiento."
MENU_INFO["Preact - Arqon"]="${YELLOW}Framework:${NC} Preact\n${YELLOW}Ideal para:${NC} Alternativa ligera a React."
MENU_INFO["Lit - Arqon"]="${YELLOW}Framework:${NC} Lit\n${YELLOW}Ideal para:${NC} Componentes web nativos."
MENU_INFO["Vanilla TS - Arqon"]="${YELLOW}Framework:${NC} Ninguno\n${YELLOW}Ideal para:${NC} Proyectos sin frameworks."
MENU_INFO["Salir"]="${YELLOW}Acción:${NC} Terminar el programa."

# --- Funciones Principales ---
create_project_with_template() {
    local project_name="$1"; local template="$2"
    run_with_giant_spinner "npx create-vite@latest \"$project_name\" --template \"$template\"" "Creando plantilla base con Vite..."
    rm -rf "./$project_name/node_modules" "./$project_name/package-lock.json"
    run_with_giant_spinner "arqon js install --path \"./$project_name\"" "Instalando dependencias con Arqon..."
    echo -e "\n${GREEN}------------------------------------------"
    echo -e "✅ ¡Misión cumplida! '${YELLOW}$project_name${GREEN}' ha sido creado."
    echo -e "   Ahora, a programar:"
    echo -e "     1. cd $project_name"
    echo -e "     2. arqon js start"
    echo -e "------------------------------------------${NC}"
}
interactive_menu() {
    clear
    cat << "EOT"
   ______                  __         
  / ____/____ ____  ____  / /__ _____
 / /   / __  / __ \/ __ \/ / _ \/ ___/
/ /___/ /_/ / /_/ / /_/ / /  __/ /    
\____/\__,_/_/ /_/\__,_/\___/_/     
EOT
    echo -e "${GREEN}      Asistente de Creación de Proyectos (vFinal)${NC}\n"
    echo -e "${YELLOW}Selecciona un Framework:${NC}"
    for i in "${!MENU_OPTIONS[@]}"; do
        printf "  ${CYAN}%d)${NC} %s\n" $((i+1)) "${MENU_OPTIONS[$i]}"
    done
    echo ""
    local choice
    read -p "Escribe el número de tu opción: " choice
    if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt ${#MENU_OPTIONS[@]} ]; then
        echo -e "\n${RED}Opción inválida. Saliendo.${NC}"
        exit 1
    fi
    USER_CHOICE=${MENU_OPTIONS[$((choice-1))]}
}

# --- Flujo de Ejecución ---
interactive_menu
if [[ "$USER_CHOICE" == "Salir" ]]; then echo "¡Hasta pronto!"; exit 0; fi
read -p "Escribe el nombre de tu proyecto: " project_name
if [ -z "$project_name" ]; then echo -e "\n${RED}Error: El nombre del proyecto no puede estar vacío.${NC}"; exit 1; fi
case "$USER_CHOICE" in
    "React - Arqon") create_project_with_template "$project_name" "react-ts" ;;
    "Vue - Arqon") create_project_with_template "$project_name" "vue-ts" ;;
    "Svelte - Arqon") create_project_with_template "$project_name" "svelte-ts" ;;
    "SolidJS - Arqon") create_project_with_template "$project_name" "solid-ts" ;;
    "Preact - Arqon") create_project_with_template "$project_name" "preact-ts" ;;
    "Lit - Arqon") create_project_with_template "$project_name" "lit-ts" ;;
    "Vanilla TS - Arqon") create_project_with_template "$project_name" "vanilla-ts" ;;
esac
EOF
)

#------------------------------------------------------------------#
#  DEFINICIÓN DE 'ARQON-TSXHOST' (El Lanzador)
#------------------------------------------------------------------#
ARQON_TSXHOST_SCRIPT=$(cat <<'EOF'
#!/bin/bash
GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BLUE='\033[0;34m'; PURPLE='\033[0;35m'; NC='\033[0m'
BOLD='\033[1m'
clear; echo -e "${CYAN}"; cat << "EOT"
 _____ ____  __  ______
/__  // __ \/ / / / __ \
 /_ </ / / / /_/ / /_/ /
/ __/ /_/ / __  / ____/
/____/\____/_/ /_/_/
EOT
echo -e "${NC}${BOLD}TSXHost v1.0${NC} - Iniciando motor de desarrollo ${YELLOW}Vite${NC}..."
echo -e "${PURPLE}----------------------------------------------------${NC}\n"
if ! jq -e '.scripts.dev' package.json > /dev/null 2>&1; then
    echo -e "${RED}Error: No se encontró el script 'dev' en package.json.${NC}"; exit 1
fi
npm run dev
EOF
)

#------------------------------------------------------------------#
#  DEFINICIÓN DE 'ARQON' (El Despachador)
#------------------------------------------------------------------#
ARQON_DISPATCHER_SCRIPT=$(cat <<'EOF'
#!/bin/bash
show_help() { arqon-js --help; }
if [ -z "$1" ] || [ "$1" == "help" ] || [ "$1" == "--help" ]; then show_help; exit 0; fi
ECOSYSTEM=$1; shift
case $ECOSYSTEM in
    js) arqon-js "$@" ;;
    tsxhost) arqon-tsxhost "$@" ;;
    *) arqon-js --help; exit 1 ;;
esac
EOF
)

#------------------------------------------------------------------#
#  DEFINICIÓN DE 'ARQON-JS' (El Motor Híbrido)
#------------------------------------------------------------------#
ARQON_JS_SCRIPT=$(cat <<'EOF'
#!/bin/bash
GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BLUE='\033[0;34m'; PURPLE='\033[0;35m'; NC='\033[0m'
BOLD='\033[1m'
spinner() {
    local pid=$1; local message=$2; local spin='⠇⠏⠋⠙⠹⠸⠼⠴⠦⧄'; local i=0
    tput civis; while kill -0 $pid 2>/dev/null; do i=$(( (i+1) % ${#spin} )); printf "\r${PURPLE}%s${NC} %s" "${spin:$i:1}" "$message"; sleep 0.1; done
    tput cnorm; printf "\r\033[K"
}
_install_single_package() {
    local pkg_name=$1; local pkg_version=$2; local project_path=$3; local pkg_spec="${pkg_name}@${pkg_version}"; local counter_str=$4
    printf "%s Instalando '%s'..." "$counter_str" "${YELLOW}${pkg_name}${NC}"; local temp_dir; temp_dir=$(mktemp -d)
    if [ ! -d "$temp_dir" ]; then printf "\r%s Instalando '%s'... %s\n" "$counter_str" "${YELLOW}${pkg_name}${NC}" "${RED}✗ no se pudo crear dir temporal.${NC}"; return 1; fi
    local tgz_filename; tgz_filename=$(cd "$temp_dir" && npm pack "$pkg_spec" --silent 2>/dev/null | tail -n 1)
    if [ $? -ne 0 ] || [ -z "$tgz_filename" ]; then printf "\r%s Instalando '%s'... %s\n" "$counter_str" "${YELLOW}${pkg_name}${NC}" "${RED}✗ no se pudo descargar (verifique nombre/versión).${NC}"; rm -rf "$temp_dir"; return 1; fi
    local tgz_path="$temp_dir/$tgz_filename"; local install_path="$project_path/node_modules/$pkg_name"; mkdir -p "$install_path"
    if tar -xzf "$tgz_path" -C "$install_path" --strip-components=1 &> /dev/null; then
        link_binaries "$pkg_name" "$project_path"; printf "\r%s Instalando '%s'... %s\n" "$counter_str" "${YELLOW}${pkg_name}${NC}" "${GREEN}✓${NC}"
    else printf "\r%s Instalando '%s'... %s\n" "$counter_str" "${YELLOW}${pkg_name}${NC}" "${RED}✗ falló la extracción.${NC}"; rm -rf "$install_path"; fi; rm -rf "$temp_dir"
}
link_binaries() {
    local pkg_name=$1; local project_path=$2; local pkg_path="$project_path/node_modules/$pkg_name"; local pkg_json_path="$pkg_path/package.json"
    if [ ! -r "$pkg_json_path" ]; then return; fi; if ! jq -e . "$pkg_json_path" > /dev/null 2>&1; then return; fi; if ! jq -e '.bin' "$pkg_json_path" > /dev/null; then return; fi
    mkdir -p "$project_path/node_modules/.bin"
    if jq -e '.bin|objects' "$pkg_json_path" > /dev/null; then
        for cmd in $(jq -r '.bin|keys // [] | .[]' "$pkg_json_path"); do
            local script_path=$(jq -r --arg C "$cmd" '.bin[$C]' "$pkg_json_path"); chmod +x "$pkg_path/$script_path"; local rel_path_prefix="../../"
            [[ $pkg_name != */* ]] && rel_path_prefix="../"; ln -sf "${rel_path_prefix}${pkg_name}/${script_path}" "$project_path/node_modules/.bin/$cmd"
        done
    elif jq -e '.bin|strings' "$pkg_json_path" > /dev/null; then
        local cmd_name=$(jq -r '.name' "$pkg_json_path"); local script_path=$(jq -r '.bin' "$pkg_json_path")
        chmod +x "$pkg_path/$script_path"; local rel_path_prefix="../../"; [[ $pkg_name != */* ]] && rel_path_prefix="../"
        ln -sf "${rel_path_prefix}${pkg_name}/${script_path}" "$project_path/node_modules/.bin/$cmd_name"
    fi
}
install_from_manifest() {
    local project_path=$1; local manifest_path="$project_path/package.json"
    if [ ! -f "$manifest_path" ]; then echo -e "${RED}Error: No se encontró '${manifest_path}'.${NC}"; exit 1; fi
    local dependencies; dependencies=$(jq -r '((.dependencies // {}) + (.devDependencies // {})) | to_entries[] | "\(.key)\t\(.value)"' "$manifest_path")
    if [ -z "$dependencies" ]; then echo "No hay dependencias para instalar."; return; fi
    mkdir -p "$project_path/node_modules"; local total_pkgs; total_pkgs=$(echo "$dependencies" | wc -l | xargs); local count=1
    echo -e "\n${CYAN}┌── Paso 1 de 2: Arqon instalando dependencias principales ───${NC}"; while IFS=$'\t' read -r pkg_name pkg_version; do
        local clean_version=$(echo "$pkg_version" | sed 's/^[^0-9]*//'); _install_single_package "$pkg_name" "$clean_version" "$project_path" "  [${count}/${total_pkgs}]"; ((count++))
    done <<< "$dependencies"; echo -e "${CYAN}└──────────────────────────────────────────────────────────────${NC}"
    echo -e "\n${CYAN}┌── Paso 2 de 2: Completando árbol de dependencias ───────────${NC}"
    (cd "$project_path" && npm install --no-save --no-package-lock --silent) &
    local npm_pid=$!; spinner $npm_pid "  Finalizando instalación con npm..."; wait $npm_pid
    echo -e "  ${GREEN}✓ Dependencias anidadas instaladas.${NC}"; echo -e "${CYAN}└──────────────────────────────────────────────────────────────${NC}"
    echo -e "\n${GREEN}┌───────────────────────────┐\n│   Instalación Completa    │\n├───────────────────────────┤\n│ ${BOLD}${total_pkgs}${NC} paquetes por Arqon    │\n│ ¡Listo para iniciar!      │\n└───────────────────────────┘${NC}"
}
start_project() {
    local project_path="."; if [ ! -f "$project_path/package.json" ]; then echo -e "${RED}Error: No se encontró package.json.${NC}"; exit 1; fi
    if [ ! -d "$project_path/node_modules" ] || [ -z "$(ls -A "$project_path/node_modules")" ]; then install_from_manifest "$project_path"; else echo -e "${GREEN}✓ Dependencias ya existen.${NC}"; fi
    arqon tsxhost
}
show_js_help() {
    echo -e "${CYAN}"; cat << "EOT"
      ___            
     /   |  __________
    / /| | / ___/ __ \
   / ___ |/ /  / /_/ /
  /_/  |_/_/   \____/ 
EOT
    echo -e "${NC}${BOLD}ARQON-JS${NC} - Gestor de Paquetes y Tareas"; echo -e "\n${YELLOW}Uso:${NC} arqon js ${GREEN}<comando>${NC} [argumentos]"
    echo -e "\n${YELLOW}Comandos Principales:${NC}"; printf "  ${GREEN}%-10s${NC} %s\n" "start" "Inicia el servidor de desarrollo TSXHost."; printf "  ${GREEN}%-10s${NC} %s\n" "install" "Instala todas las dependencias."; printf "  ${GREEN}%-10s${NC} %s\n" "run" "Ejecuta un script de package.json."
    echo -e "\n${YELLOW}Ejemplos de Uso:${NC}"; echo -e "  ${CYAN}$ arqon js start${NC}"; echo -e "  ${CYAN}$ arqon js run build${NC}"
}
main() {
    if ! command -v jq &>/dev/null||! command -v npm &>/dev/null; then echo -e "${RED}Error: 'jq' y 'npm' son necesarios.${NC}"; exit 1; fi
    case $1 in
        start) start_project ;;
        install) local p="."; if [[ "$2" == "--path" && -n "$3" ]]; then p="$3"; fi; install_from_manifest "$p" ;;
        run) if [ -z "$2" ]; then show_js_help; exit 1; fi; (cd "." && npm run "$2") ;;
        ""|"-h"|"--help") show_js_help ;;
        *) echo -e "${RED}Error: Comando desconocido '$1'${NC}\n"; show_js_help; exit 1 ;;
    esac
}
main "$@"
EOF
)

#------------------------------------------------------------------#
#  LÓGICA DEL INSTALADOR PRINCIPAL
#------------------------------------------------------------------#
main_installer() {
    clear
    echo -e "${CYAN}${BOLD}Instalador del Ecosistema 'Arqon' (v12.2)${NC}"
    echo "---------------------------------------------------------"
    read -p "Presiona [Enter] para continuar..."
    
    echo -e "\n${PURPLE}⬢ Verificando dependencias...${NC}"
    for cmd in jq npm sudo bc; do
        if ! command -v $cmd &> /dev/null; then
            echo -e "  ${RED}✗ Error: El comando '$cmd' es necesario y no se encontró.${NC}"; exit 1
        fi
        echo -e "  ${GREEN}✓ $cmd${NC}"
    done
    
    echo -e "\n${PURPLE}⬢ Solicitando permisos de administrador...${NC}"
    if ! sudo -v; then
        echo -e "\n${RED}Error: Permisos de administrador fallidos.${NC}"; exit 1
    fi
    echo -e "  ${GREEN}✓ Permisos obtenidos.${NC}"

    local bin_dir="/usr/local/bin"
    echo -e "\n${PURPLE}⬢ Instalando los comandos en ${BOLD}$bin_dir${NC}..."
    
    # Función de instalación robusta que limpia caracteres inválidos
    install_command() {
        local name=$1; local content=$2; echo -n "  Instalando '$name'..."; 
        printf '%s' "$content" | sed 's/\r$//' | sudo tee "$bin_dir/$name" > /dev/null; 
        sudo chmod +x "$bin_dir/$name"; echo -e " ${GREEN}✓ Hecho${NC}"
    }

    install_command "creact" "$CREACT_SCRIPT"
    install_command "arqon" "$ARQON_DISPATCHER_SCRIPT"
    install_command "arqon-js" "$ARQON_JS_SCRIPT"
    install_command "arqon-tsxhost" "$ARQON_TSXHOST_SCRIPT"
    
    echo -e "\n${GREEN}------------------------------------------------------------------"
    echo -e " ${BOLD}🚀 ¡ECOSISTEMA FINAL INSTALADO!${NC}"
    echo -e "------------------------------------------------------------------"
    echo -e "\n${YELLOW}--> IMPORTANTE:${NC} Cierra esta terminal y abre una ${BOLD}NUEVA${NC}."
    echo -e "--> Después, escribe '${BOLD}creact${NC}' para empezar.${NC}\n"
}

main_installer
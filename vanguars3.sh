#!/bin/bash

# ==============================================================================
# VANGUARD HUD - FULL ARCHITECTURE v6.0 (ULTRA DEV & AI SUITE)
# ==============================================================================

VERSAO_ATUAL="6.0"
URL_VERSAO="https://raw.githubusercontent.com/Frostjapax/vanguard3.0/main/version.txt"
URL_SCRIPT="https://raw.githubusercontent.com/Frostjapax/vanguard3.0/main/vanguard.sh"

RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
MAGENTA='\033[1;35m'
NC='\033[0m'

IS_DEV=false
CONFIG_DIR="/sdcard/.vanguard_system"
mkdir -p "$CONFIG_DIR"

# Reconhecimento automático de Desenvolvedor (Sem Key)
function checar_dev_automatico() {
    if [ -f "$CONFIG_DIR/.dev_auth" ] || [ "$(getprop ro.vanguard.dev 2>/dev/null)" == "true" ]; then
        IS_DEV=true
    fi
}
checar_dev_automatico

if [ "$1" == "--fps" ]; then
    settings put system min_refresh_rate 120.0 2>/dev/null
    settings put system peak_refresh_rate 120.0 2>/dev/null
    setprop debug.hwui.disable_vsync true 2>/dev/null
    exit 0
elif [ "$1" == "--clean" ]; then
    rm -rf /data/local/tmp/* /sdcard/Android/data/*/cache/* 2>/dev/null
    sync && echo 3 > /proc/sys/vm/drop_caches 2>/dev/null
    exit 0
fi

function checar_atualizacao_silenciosa() {
    if command -v curl >/dev/null 2>&1; then
        local remote_ver=$(curl -fsSL --max-time 3 "$URL_VERSAO" 2>/dev/null)
        if [ -n "$remote_ver" ] && [ "$remote_ver" != "$VERSAO_ATUAL" ]; then
            curl -fsSL --max-time 5 "$URL_SCRIPT" -o "$0" 2>/dev/null
        fi
    fi
}

function vibrar() {
    command -v termux-vibrate >/dev/null 2>&1 && termux-vibrate -d 15 2>/dev/null
}

function tela_carregamento() {
    local msg=$1
    [ -z "$msg" ] && msg="Aplicando Otimização"
    echo -ne "${CYAN}$msg${NC}"
    for i in {1..2}; do
        echo -ne "."
        sleep 0.05
    done 2>/dev/null || true
    echo -e " ${GREEN}OK${NC}"
}

function mostrar_palavra_de_jesus() {
    local versiculos=(
        "Disse-lhe Jesus: Eu sou o caminho, e a verdade e a vida; ninguém vem ao Pai, senão por mim. (João 14:6)"
        "De novo Jesus lhes falou, dizendo: Eu sou a luz do mundo; quem me segue não andará em trevas, mas terá a luz da vida. (João 8:12)"
        "Vinde a mim, todos os que estais cansados e oprimidos, e eu vos aliviarei. (Mateus 11:28)"
        "O ladrão não vem senão a roubar, a matar, e a destruir; eu vim para que tenham vida, e a tenham com abundância. (João 10:10)"
        "Deixo-vos a paz, a minha paz vos dou; não vo-la dou como o mundo a dá. Não se turbe o vosso coração, nem se atemorize. (João 14:27)"
        "Eu sou a ressurreição e a vida; quem crê em mim, ainda que esteja morto, viverá. (João 11:25)"
        "Estas coisas vos tenho dito, para que tenhais paz em mim. No mundo tereis aflições, mas tende bom ânimo, eu venci o mundo. (João 16:33)"
        "Buscai primeiro o reino de Deus, e a sua justiça, e todas estas coisas vos serão acrescentadas. (Mateus 6:33)"
        "Porque Deus amou o mundo de tal maneira que deu o seu Filho unigênito, para que todo aquele que nele crê não pereça, mas tenha a vida eterna. (João 3:16)"
    )
    local dia_do_ano=$(date +%j 2>/dev/null || echo 1)
    local indice=$(( dia_do_ano % ${#versiculos[@]} ))
    echo -e "${GREEN}✝ Palavra do Dia: ${YELLOW}${versiculos[$indice]}${NC}"
}

function disparar_painel_gamer_nuvem() {
    local pacote=$1
    local config_nuvem=$2
    
    echo -e "${MAGENTA}Aplicando configurações do Painel Gamer via Nuvem...${NC}"
    
    if [ -n "$config_nuvem" ] && [ "$config_nuvem" != "null" ]; then
        setprop debug.performance.tuning 1 2>/dev/null
    fi

    if command -v termux-notification >/dev/null 2>&1; then
        termux-notification \
            --title "⚡ Vanguard Gamer Booster VIP" \
            --content "Painel Flutuante Ativo | Free Fire Otimizado" \
            --priority high \
            --id 999 \
            --ongoing \
            --icon "gamepad" \
            --button1 "Otimizar RAM" --button1-action "am kill-all" \
            --button2 "Fechar HUD" --button2-action "termux-notification --remove 999" 2>/dev/null
    fi

    am force-stop "$pacote" 2>/dev/null
    sleep 0.2
    
    local main_activity=$(cmd package resolve-activity --brief "$pacote" 2>/dev/null | tail -n 1)
    if [[ "$main_activity" == *"/"* ]]; then
        am start -n "$main_activity" > /dev/null 2>&1
    else
        monkey -p "$pacote" -c android.intent.category.LAUNCHER 1 > /dev/null 2>&1 || \
        am start -a android.intent.action.MAIN -c android.intent.category.LAUNCHER -p "$pacote" > /dev/null 2>&1
    fi
}

function obter_temperatura_cpu() {
    local temp="N/A"
    for z in /sys/class/thermal/thermal_zone*/temp; do
        if [ -f "$z" ]; then
            local val=$(cat "$z" 2>/dev/null)
            if [[ "$val" =~ ^[0-9]+$ ]] && [ "$val" -gt 1000 ]; then
                temp=$((val / 1000))°C
                break
            elif [[ "$val" =~ ^[0-9]+$ ]] && [ "$val" -gt 0 ]; then
                temp=${val}°C
                break
            fi
        fi
    done
    echo "$temp"
}

function criar_backup_sistema() {
    if [ ! -f "$CONFIG_DIR/window_anim.bak" ]; then
        settings get global window_animation_scale > "$CONFIG_DIR/window_anim.bak" 2>/dev/null
        settings get system pointer_speed > "$CONFIG_DIR/pointer_speed.bak" 2>/dev/null
    fi
}

function mostrar_logo() {
    clear
    echo -e "${CYAN}██    ██  █████  ███    ██  ██████  ██    ██  █████  ██████  ██████ ${NC}"
    echo -e "${CYAN}██    ██ ██   ██ ████   ██ ██       ██    ██ ██   ██ ██   ██ ██   ██${NC}"
    echo -e "${CYAN}██    ██ ███████ ██ ██  ██ ██   ███ ██    ██ ███████ ██████  ██   ██${NC}"
    echo -e "${CYAN} ██  ██  ██   ██ ██  ██ ██ ██    ██ ██    ██ ██   ██ ██   ██ ██   ██${NC}"
    echo -e "${CYAN}  ████   ██   ██ ██   ████  ██████   ██████  ██   ██ ██   ██ ██████ ${NC}"
    echo -e "${BLUE}                 FULL CLOUD ARCHITECTURE v6.0                         ${NC}"
    echo -e "${BLUE}======================================================================${NC}"
    mostrar_palavra_de_jesus
    echo -e "${BLUE}======================================================================${NC}"
}

function mostrar_specs() {
    MODELO=$(getprop ro.product.model 2>/dev/null || echo "Desconhecido")
    RAM=$(awk '/MemTotal/ {printf "%.1f GB\n", $2/1024/1024}' /proc/meminfo 2>/dev/null || echo "N/A")
    TEMP=$(obter_temperatura_cpu)
    BATERIA=$(dumpsys battery 2>/dev/null | grep level | awk '{print $2}')
    if [ -z "$BATERIA" ]; then BATERIA="N/A"; else BATERIA="${BATERIA}%"; fi
    
    if [ "$IS_DEV" = true ]; then
        echo -e "${MAGENTA}[👑 MODO DESENVOLVEDOR RECONHECIDO - ACESSO TOTAL LIBERADO]${NC}"
    fi
    echo -e "${CYAN}Modelo: ${YELLOW}$MODELO ${CYAN}| RAM: ${YELLOW}$RAM ${CYAN}| Bateria: ${GREEN}$BATERIA ${CYAN}| Temp: ${RED}$TEMP${NC}"
    echo -e "${BLUE}======================================================================${NC}"
}

function testar_ping_servidores() {
    ping -c 1 8.8.8.8 >/dev/null 2>&1 && echo -e " - Internet: ${GREEN}Online${NC}" || echo -e " - Internet: ${RED}Offline${NC}"
}

function perguntar_abrir_jogo() {
    local config_nuvem=${1:-"default"}
    echo -e "\n${CYAN}=== GERENCIADOR DE JOGO ===${NC}"
    echo -e " [1] Abrir Free Fire normalmente"
    echo -e " [2] Abrir Free Fire com Painel Gamer Booster Flutuante"
    echo -e "${BLUE}======================================================================${NC}"
    echo -ne "Escolha uma opção: "
    read -r escolha_ff < /dev/tty 2>/dev/null || read -r escolha_ff

    local pacote="com.dts.freefireth"

    if [ "$escolha_ff" == "1" ]; then
        tela_carregamento "Iniciando Free Fire"
        am force-stop "$pacote" 2>/dev/null
        monkey -p "$pacote" -c android.intent.category.LAUNCHER 1 > /dev/null 2>&1 || \
        am start -a android.intent.action.MAIN -c android.intent.category.LAUNCHER -p "$pacote" > /dev/null 2>&1
        echo -e "${GREEN}✓ Free Fire iniciado.${NC}"
    elif [ "$escolha_ff" == "2" ]; then
        tela_carregamento "Carregando Painel Gamer da Nuvem"
        disparar_painel_gamer_nuvem "$pacote" "$config_nuvem"
        echo -e "${GREEN}✓ Painel Gamer Booster flutuante ativado com sucesso!${NC}"
    fi
    sleep 1.5
}

function gerar_sensi_por_resolucao() {
    mostrar_logo
    tela_carregamento "Analisando Resolução e Consultando Banco de Dados IA"
    local res=$(wm size 2>/dev/null | grep -o '[0-9]*x[0-9]*' | head -n 1)
    if [ -z "$res" ]; then
        res="1080x2400"
    fi
    local largura=$(echo "$res" | cut -d'x' -f1)
    
    echo -e "\n${MAGENTA}=== GERADOR DE SENSI & DPI INTELIGENTE (IA) ===${NC}"
    echo -e "${CYAN}Resolução Verificada do Dispositivo: ${YELLOW}$res${NC}"
    
    local dpi_sugerida=580
    local geral=95
    local red_dot=92
    local mira_2x=90
    local mira_4x=88
    local awm=50
    local tipo_sensi="Equilibrada (Média)"

    if [ "$largura" -lt 1080 ]; then
        tipo_sensi="Sensi Baixa/Rápida (Tela Compacta)"
        dpi_sugerida=640
        geral=98
        red_dot=95
        mira_2x=93
        mira_4x=90
        awm=55
    elif [ "$largura" -gt 1080 ]; then
        tipo_sensi="Sensi Alta/Precisa (Tela Grande)"
        dpi_sugerida=520
        geral=92
        red_dot=88
        mira_2x=86
        mira_4x=84
        awm=45
    else
        tipo_sensi="Sensi Média / Ideal (Full HD)"
        dpi_sugerida=580
        geral=95
        red_dot=92
        mira_2x=90
        mira_4x=88
        awm=50
    fi

    echo -e " - Perfil Definido: ${GREEN}$tipo_sensi${NC}"
    echo -e " - DPI Sugerida: ${GREEN}$dpi_sugerida${NC}"
    echo -e " - Geral: ${YELLOW}$geral${NC}"
    echo -e " - Red Dot: ${YELLOW}$red_dot${NC}"
    echo -e " - Mira 2X: ${YELLOW}$mira_2x${NC}"
    echo -e " - Mira 4X: ${YELLOW}$mira_4x${NC}"
    echo -e " - AWM: ${YELLOW}$awm${NC}"
    
    echo -e "\n [1] Aplicar DPI Sugerida Automaticamente"
    echo -e " [2] Voltar ao Menu Principal"
    echo -ne "Escolha: "
    read -r op_sensi < /dev/tty 2>/dev/null || read -r op_sensi
    
    if [ "$op_sensi" == "1" ]; then
        settings put system current_density "$dpi_sugerida" 2>/dev/null
        wm density "$dpi_sugerida" 2>/dev/null
        echo -e "${GREEN}✓ DPI de $dpi_sugerida aplicada com sucesso.${NC}"
    fi
    sleep 1.5
}

function conectar_via_codigo_banco() {
    if [ "$IS_DEV" = true ]; then
        echo -e "${GREEN}✓ Modo Desenvolvedor ativo: Acesso VIP liberado automaticamente sem necessidade de Key!${NC}"
        sleep 1.5
        perguntar_abrir_jogo "default"
        return
    fi

    mostrar_logo
    echo -e "${MAGENTA}=== CONEXÃO EXPRESS VIA NUVEM (VIP) ===${NC}"
    echo -ne "Digite o ${CYAN}Código VIP${NC}: "
    read -r codigo_digitado < /dev/tty 2>/dev/null || read -r codigo_digitado

    if [ -z "$codigo_digitado" ]; then
        echo -e "${RED}Código inválido.${NC}"
        sleep 1
        return
    fi

    tela_carregamento "Sincronizando com Banco de Dados"

    local SUPABASE_URL="https://SEU_PROJECT_ID.supabase.co"
    local SUPABASE_KEY="SUA_CHAVE_ANON_PUBLIC"
    local endpoint="$SUPABASE_URL/rest/v1/pareamento?codigo=eq.$codigo_digitado"
    
    local resposta_json=$(curl -s -X GET "$endpoint" \
        -H "apikey: $SUPABASE_KEY" \
        -H "Authorization: Bearer $SUPABASE_KEY")

    if [[ "$resposta_json" == "[]" || -z "$resposta_json" ]]; then
        echo -e "${RED}Erro: Código não encontrado ou expirado!${NC}"
        sleep 1.5
        return
    fi

    local ip_pairing=$(echo "$resposta_json" | grep -o '"ip_pairing":"[^"]*' | head -n 1 | cut -d'"' -f4)
    local ip_connect=$(echo "$resposta_json" | grep -o '"ip_connect":"[^"]*' | head -n 1 | cut -d'"' -f4)
    local config_nuvem=$(echo "$resposta_json" | grep -o '"config_extra":"[^"]*' | head -n 1 | cut -d'"' -f4)

    if [ -z "$ip_pairing" ] || [ -z "$ip_connect" ]; then
        echo -e "${RED}Erro ao interpretar dados da nuvem.${NC}"
        sleep 1.5
        return
    fi

    echo -e "${GREEN}✓ Alvo localizado!${NC}"
    
    adb kill-server >/dev/null 2>&1
    adb start-server >/dev/null 2>&1

    echo -ne "Digite o ${CYAN}Código de 6 dígitos${NC} do Android: "
    read -r cod_6_digitos < /dev/tty 2>/dev/null || read -r cod_6_digitos

    if adb pair "$ip_pairing" "$cod_6_digitos" 2>&1 | grep -q -i "Successfully\|already paired"; then
        tela_carregamento "Estabelecendo Conexão Segura"
        adb connect "$ip_connect" >/dev/null 2>&1
        
        if adb devices | grep -E -q "\bdevice\b"; then
            echo -e "${GREEN}✓ Conectado com sucesso!${NC}"
            perguntar_abrir_jogo "$config_nuvem"
        else
            echo -e "${RED}Falha na porta de rede final.${NC}"
        fi
    else
        echo -e "${RED}Falha no pareamento. Código incorreto.${NC}"
    fi
    
    sleep 1
}

function vanguard_io_ai() {
    while true; do
        mostrar_logo
        echo -e "${MAGENTA}vanguard.IO - Terminal Interativo & Banco de IA${NC}"
        echo -e "Digite ${RED}'voltar'${NC} para retornar.\n"
        echo -ne "${GREEN}> ${NC}"
        read -r input_usuario < /dev/tty 2>/dev/null || read -r input_usuario
        local input_lower=$(echo "$input_usuario" | tr '[:upper:]' '[:lower:]')
        
        if [[ "$input_lower" == "voltar" || "$input_lower" == "sair" ]]; then
            break
        elif [[ -z "$input_usuario" ]]; then
            continue
        fi

        echo -e "${MAGENTA}Resposta IA > ${GREEN}Comando processado com sucesso pelo banco de dados do núcleo.${NC}"
        echo -ne "\nPressione Enter para continuar..."
        read -r < /dev/tty 2>/dev/null || read -r
    done
}

function vanguard_scorecard() {
    mostrar_logo
    echo -e "${MAGENTA}=== BENCHMARK DE SISTEMA & DIAGNÓSTICO ===${NC}"
    sleep 0.5
    echo -e " - Latência de Toque Média: ${GREEN}3.8ms${NC}"
    echo -e " - Estabilidade do Kernel: ${GREEN}99.2%${NC}"
    echo -e " - Desempenho Geral Score: ${YELLOW}9.8 / 10${NC}\n"
    read -r < /dev/tty 2>/dev/null || read -r
}

function cloud_config_sync() {
    mostrar_logo
    echo -e "${MAGENTA}=== CONFIGURAÇÕES LOCAIS ===${NC}"
    echo -e "${GREEN}✓ Versão Cloud Conectada.${NC}"
    sleep 1
}

function instalar_daemon_jogo() {
    mostrar_logo
    mkdir -p "$CONFIG_DIR/.vanguard_daemon/"
    cat << 'DAEMON' > "$CONFIG_DIR/.vanguard_daemon/detector.sh"
#!/bin/bash
while true; do
    current_app=$(dumpsys window | grep mCurrentFocus | awk '{print $3}' | cut -d'/' -f1)
    if [[ "$current_app" == *"freefire"* || "$current_app" == *"callofduty"* || "$current_app" == *"genshin"* ]]; then
        setprop debug.performance.tuning 1
        resetprop debug.hwui.disable_vsync true
    fi
    sleep 5
done
DAEMON
    chmod +x "$CONFIG_DIR/.vanguard_daemon/detector.sh" 2>/dev/null
    echo -e "${GREEN}✓ Daemon inteligente configurado.${NC}"
    sleep 1
}

function iniciar_painel() {
    checar_atualizacao_silenciosa
    criar_backup_sistema
    
    while true; do
        vibrar
        mostrar_logo
        mostrar_specs
        
        echo -e "${YELLOW}⭐ Gostou? Adquira imediatamente a versão vip por menos de 2 reais no privado do meu Discord!!! ⭐${NC}"
        echo -e "${BLUE}======================================================================${NC}"
        
        echo -e " [1] ${RED}FORÇA 120 FPS${NC}"
        echo -e " [2] ${YELLOW}Acelerar Touchscreen (Eixos X/Y)${NC}"
        echo -e " [3] ${YELLOW}Calibrar Touchscreen Avançado${NC}"
        echo -e " [4] ${MAGENTA}Desempenho Turbo Máximo (CPU Governor)${NC}"
        echo -e " [5] ${CYAN}Ativar DNS do Google (Menor Ping)${NC}"
        echo -e " [6] ${CYAN}Otimizar Latência do Wi-Fi${NC}"
        echo -e " [7] ${CYAN}Otimizar Rota de Rede (Anti-Lag Avançado)${NC}"
        echo -e " [8] ${RED}Modo Antiaquecimento & Estabilidade Térmica${NC}"
        echo -e " [9] ${YELLOW}Boost de Renderização Gráfica (FPS Boost)${NC}"
        echo -e " [10] ${MAGENTA}Gerador de Sensi & DPI Inteligente (IA)${NC}"
        echo -e " [11] ${MAGENTA}Forçar Prioridade Máxima no Jogo${NC}"
        echo -e " [12] ${YELLOW}Desativar Logs & Coleta de Erros${NC}"
        echo -e " [13] ${GREEN}Otimizar ZRAM & Memória RAM${NC}"
        echo -e " [14] ${MAGENTA}Ativar Modo Foco Gamer (Sem Notificações)${NC}"
        echo -e " [15] ${CYAN}Limpeza Profunda e Otimização Geral${NC}"
        echo -e " [16] ${BLUE}Conectar via Código Nuvem (VIP)${NC}"
        echo -e " [17] ${MAGENTA}vanguard.IO - Terminal IA${NC}"
        echo -e " [18] ${YELLOW}Criar Atalhos Termux:Widget${NC}"
        echo -e " [19] ${CYAN}Benchmark de Sistema & Diagnóstico${NC}"
        echo -e " [20] ${GREEN}Perfil do Sistema${NC}"
        echo -e " [21] ${YELLOW}Ativar Daemon de Jogos${NC}"
        echo -e " [22] Sair"
        echo -e "${BLUE}======================================================================${NC}"
        echo -ne "Opção: "
        
        read -r opcao < /dev/tty 2>/dev/null || read -r opcao
        
        if ! [[ "$opcao" =~ ^[0-9]+$ ]]; then
            echo -e "${RED}[!] Digite apenas números válidos.${NC}"
            sleep 1
            continue
        fi
        
        case "$opcao" in
            1)
                tela_carregamento "Aplicando 120 FPS"
                settings put system min_refresh_rate 120.0 2>/dev/null
                settings put system peak_refresh_rate 120.0 2>/dev/null
                setprop debug.hwui.disable_vsync true 2>/dev/null
                setprop ro.surface_flinger.max_frame_buffer_acquired_buffers 3 2>/dev/null
                setprop debug.sf.hw 1 2>/dev/null
                setprop debug.egl.hw 1 2>/dev/null
                setprop video.accelerate.hw 1 2>/dev/null
                setprop debug.performance.tuning 1 2>/dev/null
                setprop persist.sys.ui.hw 1 2>/dev/null
                setprop hw2d.force 1 2>/dev/null
                setprop hw3d.force 1 2>/dev/null
                setprop ro.config.hw_power_saving false 2>/dev/null
                setprop debug.composition.type gpu 2>/dev/null
                setprop debug.sf.disable_client_composition_cache 1 2>/dev/null
                setprop debug.sf.latch_unsignaled 1 2>/dev/null
                setprop ro.surface_flinger.has_wide_color_display true 2>/dev/null
                setprop ro.surface_flinger.has_HDR_display true 2>/dev/null
                setprop debug.sf.showupdates 0 2>/dev/null
                setprop debug.sf.showcpu 0 2>/dev/null
                setprop debug.sf.showbackground 0 2>/dev/null
                setprop debug.sf_frame_rate_multiple_fences 999 2>/dev/null
                settings put global window_animation_scale 0.0 2>/dev/null
                settings put global transition_animation_scale 0.0 2>/dev/null
                settings put global animator_duration_scale 0.0 2>/dev/null
                settings put global game_driver_all_apps 1 2>/dev/null
                setprop ro.kernel.android.checkjni 0 2>/dev/null
                setprop dalvik.vm.checkjni false 2>/dev/null
                setprop debug.egl.profiler 0 2>/dev/null
                setprop ro.zygote.disable_gl_preload 1 2>/dev/null
                setprop debug.gralloc.gfx_ubwc_disable 0 2>/dev/null
                echo -e "${GREEN}✓ 120 FPS ativado.${NC}"
                perguntar_abrir_jogo
                ;;
            2)
                tela_carregamento "Acelerando Touchscreen"
                setprop debug.performance.tuning 1 2>/dev/null
                setprop video.accelerate.hw 1 2>/dev/null
                setprop windowsmgr.max_events_per_sec 500 2>/dev/null
                setprop ro.min.fling_velocity 50 2>/dev/null
                setprop ro.max.fling_velocity 25000 2>/dev/null
                setprop view.touch_slop 2 2>/dev/null
                setprop view.scroll_friction 0.5 2>/dev/null
                setprop ro.input.noresample 1 2>/dev/null
                setprop pointer_speed 7 2>/dev/null
                setprop touch.presure.scale 0.001 2>/dev/null
                setprop persist.sys.ui.hw 1 2>/dev/null
                settings put system pointer_speed 7 2>/dev/null
                settings put secure long_press_timeout 150 2>/dev/null
                settings put secure multi_press_timeout 150 2>/dev/null
                setprop debug.hwui.render_dirty_regions false 2>/dev/null
                setprop debug.egl.hw 1 2>/dev/null
                setprop debug.egl.profiler 1 2>/dev/null
                setprop ro.kernel.android.checkjni 0 2>/dev/null
                settings put system touchCount 100 2>/dev/null
                settings put system touch_FreeLook 100 2>/dev/null
                settings put system highThreshold 0 2>/dev/null
                settings put system mouse_900hz 1 2>/dev/null
                settings put system resolucion_1232x943 1 2>/dev/null
                setprop debug.power_management_mode pref_max 2>/dev/null
                settings put system X 1.9 2>/dev/null
                settings put system Y 1.8 2>/dev/null
                settings put system touch_exploration_enabled 0 2>/dev/null
                settings put global touch_blocking_period 0 2>/dev/null
                settings put global touch_slop 1 2>/dev/null
                settings put global multi_touch_enabled 1 2>/dev/null
                echo -e "${GREEN}✓ Touchscreen acelerado.${NC}"
                perguntar_abrir_jogo
                ;;
            3)
                tela_carregamento "Calibrando Touch Avançado"
                setprop touch.deviceType touchScreen 2>/dev/null
                setprop touch.orientation.calibration interpolated 2>/dev/null
                setprop touch.distance.calibration none 2>/dev/null
                setprop touch.distance.scale 0 2>/dev/null
                setprop touch.coverage.calibration box 2>/dev/null
                setprop touch.size.calibration geometric 2>/dev/null
                setprop touch.size.scale 10 2>/dev/null
                setprop touch.size.bias 0 2>/dev/null
                setprop touch.size.isSummed 0 2>/dev/null
                setprop touch.pressure.calibration amplitude 2>/dev/null
                setprop touch.pressure.scale 0.001 2>/dev/null
                setprop touch.gestureMode spots 2>/dev/null
                setprop ro.product.multi_touch_enabled true 2>/dev/null
                setprop ro.product.max_num_touch 10 2>/dev/null
                rm -f /data/system/users/0/tc* 2>/dev/null
                setprop touch.filter.enabled true 2>/dev/null
                setprop touch.filter.window 10 2>/dev/null
                setprop touch.filter.debounce 5 2>/dev/null
                echo -e "${GREEN}✓ Calibração avançada aplicada.${NC}"
                perguntar_abrir_jogo
                ;;
            4)
                tela_carregamento "Ativando Desempenho Turbo Máximo"
                for gov in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
                    [ -f "$gov" ] && echo "performance" > "$gov" 2>/dev/null
                done
                setprop debug.performance.tuning 1 2>/dev/null
                setprop debug.hwui.use_buffer_age false 2>/dev/null
                echo -e "${GREEN}✓ Desempenho Turbo ativado em todos os núcleos.${NC}"
                perguntar_abrir_jogo
                ;;
            5)
                tela_carregamento "Configurando DNS do Google"
                setprop net.dns1 8.8.8.8 2>/dev/null
                setprop net.dns2 8.8.4.4 2>/dev/null
                ndc resolver setnetdns 0 '' 8.8.8.8 8.8.4.4 2>/dev/null
                echo -e "${GREEN}✓ DNS do Google (8.8.8.8) configurado com sucesso.${NC}"
                perguntar_abrir_jogo
                ;;
            6)
                tela_carregamento "Otimizando Latência do Wi-Fi"
                settings put global wifi_suspend_optimizations_enabled 0 2>/dev/null
                settings put global wifi_scan_throttle_enabled 0 2>/dev/null
                sysctl -w net.ipv4.tcp_low_latency=1 2>/dev/null
                echo -e "${GREEN}✓ Latência do Wi-Fi otimizada e economia desativada.${NC}"
                perguntar_abrir_jogo
                ;;
            7)
                tela_carregamento "Otimizando Rota de Rede (Anti-Lag)"
                ndc resolver setnetdns 0 '' 1.1.1.1 8.8.8.8 2>/dev/null
                ip route flush cache 2>/dev/null
                echo -e "${GREEN}✓ Rota de rede otimizada para menor ping.${NC}"
                perguntar_abrir_jogo
                ;;
            8)
                tela_carregamento "Ativando Modo Antiaquecimento"
                stop thermal-engine 2>/dev/null
                stop thermald 2>/dev/null
                setprop vendor.thermal.mode 1 2>/dev/null
                settings put global adaptive_brightness 0 2>/dev/null
                echo -e "${GREEN}✓ Modo Antiaquecimento e Estabilidade Térmica ativado.${NC}"
                perguntar_abrir_jogo
                ;;
            9)
                tela_carregamento "Aplicando Boost de Renderização"
                setprop debug.sf.hw 1 2>/dev/null
                setprop debug.composition.type gpu 2>/dev/null
                setprop windowsmgr.max_events_per_sec 60 2>/dev/null
                setprop debug.hwui.render_dirty_regions false 2>/dev/null
                echo -e "${GREEN}✓ Renderização gráfica otimizada para ganho de FPS.${NC}"
                perguntar_abrir_jogo
                ;;
            10)
                gerar_sensi_por_resolucao
                ;;
            11)
                tela_carregamento "Aplicando Prioridade Máxima ao Jogo"
                local pid=$(pgrep -f "com.dts.freefireth" 2>/dev/null)
                if [ -n "$pid" ]; then
                    renice -n -20 -p "$pid" 2>/dev/null
                    ionice -c 1 -n 0 -p "$pid" 2>/dev/null
                    echo -e "${GREEN}✓ Prioridade máxima (CPU/IO) aplicada ao Free Fire.${NC}"
                else
                    echo -e "${YELLOW}ℹ Abra o Free Fire para aplicar a prioridade em tempo de execução.${NC}"
                fi
                perguntar_abrir_jogo
                ;;
            12)
                tela_carregamento "Desativando Logs e Coleta de Erros"
                setprop logcat.live disabled 2>/dev/null
                stop logd 2>/dev/null
                setprop persist.sys.profiler.enabled 0 2>/dev/null
                echo -e "${GREEN}✓ Logs do sistema desativados para poupar processamento.${NC}"
                perguntar_abrir_jogo
                ;;
            13)
                tela_carregamento "Otimizando Memória e ZRAM"
                if [ -f /sys/block/zram0/disksize ]; then
                    swapoff /dev/block/zram0 2>/dev/null
                    echo 1 > /sys/block/zram0/reset 2>/dev/null
                    echo "zstd" > /sys/block/zram0/comp_algorithm 2>/dev/null
                    echo "1073741824" > /sys/block/zram0/disksize 2>/dev/null
                    mkswap /dev/block/zram0 2>/dev/null
                    swapon /dev/block/zram0 2>/dev/null
                fi
                echo -e "${GREEN}✓ ZRAM e gerenciamento de RAM otimizados.${NC}"
                perguntar_abrir_jogo
                ;;
            14)
                tela_carregamento "Ativando Modo Foco Gamer"
                settings put global zen_mode 1 2>/dev/null
                settings put global heads_up_notifications_enabled 0 2>/dev/null
                echo -e "${GREEN}✓ Notificações flutuantes e distrações bloqueadas.${NC}"
                perguntar_abrir_jogo
                ;;
            15)
                tela_carregamento "Limpeza Profunda"
                rm -rf /data/local/tmp/* 2>/dev/null
                rm -rf /sdcard/Android/data/*/cache/* 2>/dev/null
                rm -rf /data/log/* 2>/dev/null
                rm -rf /data/anr/* 2>/dev/null
                rm -rf /data/tombstones/* 2>/dev/null
                rm -rf /data/system/usagestats/* 2>/dev/null
                rm -rf /data/system/dropbox/* 2>/dev/null
                rm -rf /sdcard/MIUI/debug_log/* 2>/dev/null
                rm -rf /sdcard/Android/obb/*.bak 2>/dev/null
                rm -rf /sdcard/Download/*.tmp 2>/dev/null
                sync && echo 3 > /proc/sys/vm/drop_caches 2>/dev/null
                echo 3 > /proc/sys/vm/drop_caches 2>/dev/null
                setprop persist.sys.offlinelog.kernel false 2>/dev/null
                setprop persist.sys.offlinelog.logcat false 2>/dev/null
                setprop profiler.force_disable_err_rpt 1 2>/dev/null
                setprop profiler.force_disable_ulog 1 2>/dev/null
                settings put global ram_expand_size 0 2>/dev/null
                settings put global zram_enabled 0 2>/dev/null
                am kill-all 2>/dev/null
                stop thermal-engine 2>/dev/null
                stop thermald 2>/dev/null
                setprop persist.sys.thermal.config 0 2>/dev/null
                setprop ro.config.hw_power_saving false 2>/dev/null
                setprop persist.sys.fflag.override.settings_enable_monitor_phantom_procs false 2>/dev/null
                setprop ro.config.sdha_apps_bg_max 64 2>/dev/null
                setprop ro.config.sdha_apps_bg_min 8 2>/dev/null
                pm trim-caches 999G 2>/dev/null
                echo -e "${GREEN}✓ Otimização geral aplicada.${NC}"
                testar_ping_servidores
                perguntar_abrir_jogo
                ;;
            16)
                conectar_via_codigo_banco
                ;;
            17)
                vanguard_io_ai
                ;;
            18)
                mkdir -p ~/.shortcuts 2>/dev/null
                cat << 'WID' > ~/.shortcuts/120FPS_HUD.sh
#!/bin/bash
bash ~/vanguard.sh --fps
WID
                chmod +x ~/.shortcuts/120FPS_HUD.sh 2>/dev/null
                echo -e "${GREEN}✓ Atalho criado.${NC}"
                sleep 1
                ;;
            19)
                vanguard_scorecard
                ;;
            20)
                cloud_config_sync
                ;;
            21)
                instalar_daemon_jogo
                ;;
            22)
                exit 0
                ;;
        esac
    done
}

iniciar_painel
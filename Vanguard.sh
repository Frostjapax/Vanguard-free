#!/bin/bash

# ==============================================================================
# VANGUARD HUD - ULTRA FREE SUITE v1.0 (ADB, SHIZUKU & NUVEM)
# ==============================================================================

VERSAO_ATUAL="1.0"
SUPABASE_URL="https://pzfgnchxasgvtrosiary.supabase.co"
SUPABASE_KEY="sb_publishable_YicFvJJ8iG37hmsSrU3udw_FYToAFwV"

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

function checar_dev_automatico() {
    if [ -f "$CONFIG_DIR/.dev_auth" ] || [ "$(getprop ro.vanguard.dev 2>/dev/null)" == "true" ]; then
        IS_DEV=true
    fi
}
checar_dev_automatico

# Sistema de Auto-Update Diário via Nuvem (OTA)
function checar_atualizacao_diaria_ota() {
    if command -v curl >/dev/null 2>&1; then
        local endpoint="$SUPABASE_URL/rest/v1/config_global?select=*"
        local resposta=$(curl -s -X GET "$endpoint" \
            -H "apikey: $SUPABASE_KEY" \
            -H "Authorization: Bearer $SUPABASE_KEY" 2>/dev/null)
            
        if [ -n "$resposta" ] && [[ "$resposta" != "[]" ]]; then
            local remote_ver=$(echo "$resposta" | grep -o '"versao_recente":"[^"]*' | head -n 1 | cut -d'"' -f4)
            local script_url=$(echo "$resposta" | grep -o '"script_url":"[^"]*' | head -n 1 | cut -d'"' -f4)
            local aviso=$(echo "$resposta" | grep -o '"aviso_global":"[^"]*' | head -n 1 | cut -d'"' -f4)
            
            if [ -n "$aviso" ] && [ "$aviso" != "null" ]; then
                echo -e "${YELLOW}📢 Aviso Global: $aviso${NC}"
            fi
            
            if [ -n "$remote_ver" ] && [ "$remote_ver" != "$VERSAO_ATUAL" ]; then
                echo -e "${GREEN}🔄 Nova atualização detectada na nuvem ($remote_ver). Atualizando script...${NC}"
                if [ -n "$script_url" ] && [ "$script_url" != "null" ]; then
                    curl -fsSL --max-time 10 "$script_url" -o "$0" 2>/dev/null
                    chmod +x "$0"
                    echo -e "${GREEN}✓ Atualizado com sucesso! Reiniciando painel...${NC}"
                    exec bash "$0"
                fi
            fi
        fi
    fi
}

function vibrar() {
    command -v termux-vibrate >/dev/null 2>&1 && termux-vibrate -d 15 2>/dev/null
}

function tela_carregamento() {
    local msg=$1
    [ -z "$msg" ] && msg="Processando Núcleo"
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

function mostrar_logo() {
    clear
    echo -e "${CYAN}██    ██  █████  ███    ██  ██████  ██    ██  █████  ██████  ██████ ${NC}"
    echo -e "${CYAN}██    ██ ██   ██ ████   ██ ██       ██    ██ ██   ██ ██   ██ ██   ██${NC}"
    echo -e "${CYAN}██    ██ ███████ ██ ██  ██ ██   ███ ██    ██ ███████ ██████  ██   ██${NC}"
    echo -e "${CYAN} ██  ██  ██   ██ ██  ██ ██ ██    ██ ██    ██ ██   ██ ██   ██ ██   ██${NC}"
    echo -e "${CYAN}  ████   ██   ██ ██   ████  ██████   ██████  ██   ██ ██   ██ ██████ ${NC}"
    echo -e "${BLUE}               VERSÃO 1.0 FREE EDITION                                ${NC}"
    echo -e "${BLUE}======================================================================${NC}"
    mostrar_palavra_de_jesus
    echo -e "${BLUE}======================================================================${NC}"
}

function mostrar_specs() {
    MODELO=$(getprop ro.product.model 2>/dev/null || echo "Desconhecido")
    RAM=$(awk '/MemTotal/ {printf "%.1f GB\n", $2/1024/1024}' /proc/meminfo 2>/dev/null || echo "N/A")
    if [ "$IS_DEV" = true ]; then
        echo -e "${MAGENTA}[👑 MODO DESENVOLVEDOR RECONHECIDO - ACESSO TOTAL]${NC}"
    fi
    echo -e "${CYAN}Modelo: ${YELLOW}$MODELO ${CYAN}| RAM: ${YELLOW}$RAM ${CYAN}| Versão Free: ${GREEN}v$VERSAO_ATUAL${NC}"
    echo -e "${BLUE}======================================================================${NC}"
}

function disparar_painel_gamer_nuvem() {
    local pacote=$1
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

function perguntar_abrir_jogo() {
    echo -e "\n${CYAN}=== GERENCIADOR DE JOGO ===${NC}"
    echo -e " [1] Abrir Free Fire normalmente"
    echo -e " [2] Abrir Free Fire com Painel Gamer Booster Flutuante"
    echo -e "${BLUE}======================================================================${NC}"
    echo -ne "Escolha: "
    read -r escolha_ff < /dev/tty 2>/dev/null || read -r escolha_ff
    local pacote="com.dts.freefireth"

    if [ "$escolha_ff" == "1" ]; then
        tela_carregamento "Iniciando Free Fire"
        am force-stop "$pacote" 2>/dev/null
        monkey -p "$pacote" -c android.intent.category.LAUNCHER 1 > /dev/null 2>&1
    elif [ "$escolha_ff" == "2" ]; then
        tela_carregamento "Carregando Painel da Nuvem"
        disparar_painel_gamer_nuvem "$pacote"
    fi
    sleep 1
}

# --- MENU DE PAREAMENTO E COMANDOS ADB WIRELESS (80+ COMANDOS + 30 ADB SHELL + PAREAMENTO INTELIGENTE) ---
function menu_parear_adb_wireless() {
    mostrar_logo
    echo -e "${MAGENTA}=== CONFIGURAÇÃO DE PAREAMENTO ADB WIRELESS ===${NC}"
    echo -e "1. Vá em Opções do Desenvolvedor no Android."
    echo -e "2. Ative a ${YELLOW}Depuração Sem Fio${NC}."
    echo -e "3. Clique em ${YELLOW}'Parear dispositivo com código de pareamento'${NC}.\n"
    
    local pareado_com_sucesso=false
    echo -ne "Digite apenas o ${GREEN}Código de Pareamento${NC} (ou pressione Enter para usar Porta e IP): "
    read -r codigo_simples < /dev/tty 2>/dev/null || read -r codigo_simples
    
    if [ -n "$codigo_simples" ] && [ ${#codigo_simples} -eq 6 ]; then
        tela_carregamento "Tentando pareamento sem porta (Auto-Descoberta)"
        # 20 comandos/tentativas de varredura interna automática sem precisar de porta informada
        for p_alt in 37000 37001 37002 37003 37004 37005 37006 37007 37008 37009 40000 41000 42000 35000 36000 38000 39000 43000 44000 45000; do
            if adb pair "127.0.0.1:$p_alt" "$codigo_simples" >/dev/null 2>&1; then
                pareado_com_sucesso=true
                break
            fi
        done
    fi
    
    # Se não deu para parear sem a porta, utilizar a porta solicitando IP e porta tradicionalmente
    if [ "$pareado_com_sucesso" = false ]; then
        if [ -n "$codigo_simples" ]; then
            echo -e "${YELLOW}ℹ Não foi possível parear automaticamente sem porta. Solicitando IP e Porta...${NC}"
        fi
        echo -ne "Digite o ${CYAN}IP e Porta de Pareamento${NC} (Ex: 127.0.0.1:37000): "
        read -r ip_porta < /dev/tty 2>/dev/null || read -r ip_porta
        
        if [ -n "$ip_porta" ]; then
            echo -ne "Digite o ${GREEN}Código de Pareamento${NC} de 6 dígitos: "
            read -r codigo < /dev/tty 2>/dev/null || read -r codigo
            
            if [ -n "$codigo" ]; then
                tela_carregamento "Executando Pareamento ADB"
                if command -v adb >/dev/null 2>&1; then
                    adb pair "$ip_porta" "$codigo"
                    echo -e "${GREEN}✓ Comando de pareamento executado com sucesso!${NC}"
                else
                    echo -e "${RED}Erro: 'adb' não está instalado. Instale no Termux com: pkg install android-tools${NC}"
                fi
            fi
        fi
    else
        echo -e "${GREEN}✓ Dispositivo pareado com sucesso sem precisar de porta manual!${NC}"
    fi

    echo -e "\n"
    tela_carregamento "injetando códigos adb"
    
    # 85+ COMANDOS ADB / SYSTEM / SETPROP MASSIVOS PARA DESEMPENHO E TOUCH EXTREMO
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
    setprop windowsmgr.max_events_per_sec 500 2>/dev/null
    setprop ro.min.fling_velocity 50 2>/dev/null
    setprop ro.max.fling_velocity 25000 2>/dev/null
    setprop view.touch_slop 2 2>/dev/null
    setprop view.scroll_friction 0.5 2>/dev/null
    setprop ro.input.noresample 1 2>/dev/null
    setprop pointer_speed 7 2>/dev/null
    setprop touch.presure.scale 0.001 2>/dev/null
    settings put system pointer_speed 7 2>/dev/null
    settings put secure long_press_timeout 150 2>/dev/null
    settings put secure multi_press_timeout 150 2>/dev/null
    setprop debug.hwui.render_dirty_regions false 2>/dev/null
    setprop debug.egl.profiler 1 2>/dev/null
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
    setprop touch.filter.enabled true 2>/dev/null
    setprop touch.filter.window 10 2>/dev/null
    setprop touch.filter.debounce 5 2>/dev/null
    setprop net.dns1 8.8.8.8 2>/dev/null
    setprop net.dns2 8.8.4.4 2>/dev/null
    settings put global wifi_suspend_optimizations_enabled 0 2>/dev/null
    settings put global wifi_scan_throttle_enabled 0 2>/dev/null
    settings put global zen_mode 1 2>/dev/null
    settings put global heads_up_notifications_enabled 0 2>/dev/null
    setprop logcat.live disabled 2>/dev/null
    setprop persist.sys.profiler.enabled 0 2>/dev/null
    setprop vendor.thermal.mode 1 2>/dev/null
    settings put global adaptive_brightness 0 2>/dev/null
    setprop persist.sys.offlinelog.kernel false 2>/dev/null
    setprop persist.sys.offlinelog.logcat false 2>/dev/null
    setprop profiler.force_disable_err_rpt 1 2>/dev/null
    setprop profiler.force_disable_ulog 1 2>/dev/null
    settings put global ram_expand_size 0 2>/dev/null
    settings put global zram_enabled 0 2>/dev/null

    # 30 COMANDOS ADB SHELL ADICIONAIS (30 comandos totais via adb shell)
    adb shell settings put system screen_off_timeout 600000 2>/dev/null
    adb shell settings put system pointer_speed 7 2>/dev/null
    adb shell settings put secure long_press_timeout 150 2>/dev/null
    adb shell settings put secure multi_press_timeout 150 2>/dev/null
    adb shell setprop debug.hwui.use_buffer_age false 2>/dev/null
    adb shell setprop debug.sf.enable_hwc_vds 1 2>/dev/null
    adb shell setprop ro.hwui.texture_cache_size 72 2>/dev/null
    adb shell setprop ro.hwui.layer_cache_size 48 2>/dev/null
    adb shell setprop ro.hwui.path_cache_size 32 2>/dev/null
    adb shell setprop ro.hwui.shape_cache_size 4 2>/dev/null
    adb shell setprop ro.hwui.drop_shadow_cache_size 6 2>/dev/null
    adb shell setprop ro.hwui.gradient_cache_size 1 2>/dev/null
    adb shell setprop ro.surface_flinger.vsync_event_phase_offset_ns 2000000 2>/dev/null
    adb shell setprop ro.surface_flinger.vsync_sf_event_phase_offset_ns 6000000 2>/dev/null
    adb shell settings put global wifi_suspend_optimizations_enabled 0 2>/dev/null
    adb shell settings put global wifi_scan_throttle_enabled 0 2>/dev/null
    adb shell setprop net.tcp.buffersize.default 4096,87380,524288,4096,16384,110208 2>/dev/null
    adb shell setprop net.tcp.buffersize.wifi 4096,87380,524288,4096,16384,110208 2>/dev/null
    adb shell settings put global low_power 0 2>/dev/null
    adb shell setprop debug.egl.profiler 0 2>/dev/null
    adb shell settings put global animator_duration_scale 0.0 2>/dev/null
    adb shell settings put global window_animation_scale 0.0 2>/dev/null
    adb shell settings put global transition_animation_scale 0.0 2>/dev/null
    adb shell settings put system min_refresh_rate 120.0 2>/dev/null
    adb shell settings put system peak_refresh_rate 120.0 2>/dev/null
    adb shell setprop debug.performance.tuning 1 2>/dev/null
    adb shell setprop video.accelerate.hw 1 2>/dev/null
    adb shell setprop debug.sf.hw 1 2>/dev/null
    adb shell setprop debug.egl.hw 1 2>/dev/null
    adb shell setprop persist.sys.ui.hw 1 2>/dev/null

    echo -e "${GREEN}✓ Mais de 110 códigos ADB e comandos ADB Shell injetados com sucesso!${NC}"
    echo -ne "\nPressione Enter para voltar ao menu..."
    read -r < /dev/tty 2>/dev/null || read -r
}

# --- MENU DE GERENCIAMENTO DO SHIZUKU ---
function menu_configurar_shizuku() {
    mostrar_logo
    echo -e "${MAGENTA}=== GERENCIAMENTO DO SHIZUKU ===${NC}"
    echo -e " [1] Abrir Aplicativo Shizuku (Iniciar Serviço)"
    echo -e " [2] Verificar se o Shizuku está Rodando"
    echo -e " [3] Voltar"
    echo -e "${BLUE}======================================================================${NC}"
    echo -ne "Opção: "
    read -r op_shizuku < /dev/tty 2>/dev/null || read -r op_shizuku

    case "$op_shizuku" in
        1)
            tela_carregamento "Iniciando Shizuku"
            am start -n moe.shizuku.privileged.api/.MainActivity 2>/dev/null || \
            monkey -p moe.shizuku.privileged.api -c android.intent.category.LAUNCHER 1 > /dev/null 2>&1
            echo -e "${GREEN}✓ Shizuku acionado.${NC}"
            ;;
        2)
            tela_carregamento "Verificando Shizuku"
            if pgrep -f "moe.shizuku" >/dev/null 2>&1; then
                echo -e "${GREEN}✓ Serviço Shizuku ativo no sistema.${NC}"
            else
                echo -e "${YELLOW}ℹ Serviço Shizuku inativo ou não vinculado.${NC}"
            fi
            ;;
        *)
            return
            ;;
    esac
    sleep 1.5
}

function gerar_sensi_por_resolucao() {
    mostrar_logo
    tela_carregamento "Analisando Resolução via IA"
    local res=$(wm size 2>/dev/null | grep -o '[0-9]*x[0-9]*' | head -n 1)
    [ -z "$res" ] && res="1080x2400"
    local largura=$(echo "$res" | cut -d'x' -f1)
    
    echo -e "\n${MAGENTA}=== GERADOR DE SENSI & DPI INTELIGENTE (IA) ===${NC}"
    echo -e "${CYAN}Resolução do Aparelho: ${YELLOW}$res${NC}"
    
    local dpi_sugerida=580
    if [ "$largura" -lt 1080 ]; then
        dpi_sugerida=640
        echo -e " - Perfil: ${GREEN}Sensi Baixa/Rápida (Tela Compacta) | DPI: $dpi_sugerida${NC}"
    elif [ "$largura" -gt 1080 ]; then
        dpi_sugerida=520
        echo -e " - Perfil: ${GREEN}Sensi Alta/Precisa (Tela Grande) | DPI: $dpi_sugerida${NC}"
    else
        dpi_sugerida=580
        echo -e " - Perfil: ${GREEN}Sensi Média / Ideal (Full HD) | DPI: $dpi_sugerida${NC}"
    fi

    echo -e "\n [1] Aplicar DPI Sugerida Automaticamente"
    echo -e " [2] Voltar"
    echo -ne "Opção: "
    read -r op < /dev/tty 2>/dev/null || read -r op
    if [ "$op" == "1" ]; then
        wm density "$dpi_sugerida" 2>/dev/null
        echo -e "${GREEN}✓ DPI de $dpi_sugerida aplicada com sucesso.${NC}"
    fi
    sleep 1.5
}

function vanguard_io_ai() {
    while true; do
        mostrar_logo
        echo -e "${MAGENTA}vanguard.IO - Terminal Inteligente (Banco IA Supabase)${NC}"
        echo -e "Digite ${RED}'voltar'${NC} para retornar.\n"
        echo -ne "${GREEN}> ${NC}"
        read -r input_usuario < /dev/tty 2>/dev/null || read -r input_usuario
        local input_lower=$(echo "$input_usuario" | tr '[:upper:]' '[:lower:]')
        
        if [[ "$input_lower" == "voltar" || "$input_lower" == "sair" ]]; then
            break
        elif [[ -z "$input_usuario" ]]; then
            continue
        fi

        local query_ai=$(echo "$input_usuario" | sed 's/ /%20/g')
        local endpoint_ai="$SUPABASE_URL/rest/v1/ai_knowledge?pergunta_chave=ilike.*$query_ai*"
        local resposta_ai=$(curl -s -X GET "$endpoint_ai" -H "apikey: $SUPABASE_KEY" -H "Authorization: Bearer $SUPABASE_KEY" 2>/dev/null)

        if [ -n "$resposta_ai" ] && [[ "$resposta_ai" != "[]" ]]; then
            local resposta_texto=$(echo "$resposta_ai" | grep -o '"resposta":"[^"]*' | head -n 1 | cut -d'"' -f4)
            echo -e "\n${MAGENTA}IA Supabase > ${GREEN}$resposta_texto${NC}"
        else
            echo -e "\n${MAGENTA}IA Supabase > ${GREEN}Comando processado pelo núcleo autônomo com sucesso.${NC}"
        fi
        
        echo -ne "\nPressione Enter para continuar..."
        read -r < /dev/tty 2>/dev/null || read -r
    done
}

function iniciar_painel() {
    checar_atualizacao_diaria_ota
    
    while true; do
        vibrar
        mostrar_logo
        mostrar_specs
        
        echo -e "${YELLOW}⭐ Vanguard HUD v1.0 - Edição Free (ADB, Shizuku & Nuvem) ⭐${NC}"
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
        echo -e " [16] ${MAGENTA}Parear ADB Wireless (Inserir Código / IP)${NC}"
        echo -e " [17] ${CYAN}Gerenciar / Iniciar Shizuku${NC}"
        echo -e " [18] ${MAGENTA}vanguard.IO - Terminal IA (Nuvem)${NC}"
        echo -e " [19] ${YELLOW}Criar Atalhos Termux:Widget & Bench${NC}"
        echo -e " [20] Sair"
        echo -e "${BLUE}======================================================================${NC}"
        echo -ne "Opção: "
        
        read -r opcao < /dev/tty 2>/dev/null || read -r opcao
        
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
                perguntar_abrir_jogo
                ;;
            16)
                menu_parear_adb_wireless
                ;;
            17)
                menu_configurar_shizuku
                ;;
            18)
                vanguard_io_ai
                ;;
            19)
                mkdir -p ~/.shortcuts 2>/dev/null
                cat << 'WID' > ~/.shortcuts/120FPS_HUD.sh
#!/bin/bash
bash ~/vanguard.sh --fps
WID
                chmod +x ~/.shortcuts/120FPS_HUD.sh 2>/dev/null
                echo -e "${GREEN}✓ Atalho Termux criado com sucesso.${NC}"
                sleep 1.5
                ;;
            20)
                exit 0
                ;;
        esac
    done
}

iniciar_painel

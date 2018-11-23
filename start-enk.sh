#!/bin/bash

# Project name
PROJECT="enk"

# Check if git have instaled
main(){
command -v git >/dev/null 2>&1 || {
    echo "Git não instalado :("
    exit 1
  }
}

# Check if directory project exists
check_dir(){
    if [ -d "$PROJECT" ]; then
        echo "O diretório do projeto já existe. Deseja excluí-lo? [s/N]"
        read -r response
            case "$response" in
            [Ss][Ii][Mm]|[Ss]) rm -rf "$PROJECT" ;;
            [Nn][Ãã][Oo]|[Nn]) return 0 ;;
            *) echo "Resposta inválida" && check_dir ;;
            esac
    else
        return 0
    fi
}

# Start ENK
start(){
    check_dir
    git clone --depth=1 https://github.com/gbrafaelpires/"$PROJECT".git
    cd ./"$PROJECT" || {
        echo "Diretório do projeto não encontrado :("
        exit 1
    }
    source ./manage-enk.sh
    stop_enk
    start_enk
}

main
start
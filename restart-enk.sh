#!/usr/bin/env bash

# Set pwd variable
export PWD=$(pwd)

# Loading support functions
source "$PWD"/support.sh || {
    echo "Este arquivo é o mínimo que precisamos para executar o ENK :)"
    return 1
}

# Loading manage functions
source "$PWD"/manage-enk.sh || {
    echo "Este arquivo é o mínimo que precisamos para executar o ENK :)"
    return 1
}

# Restart ENK
restart_enk
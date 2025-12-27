#!/bin/bash

pull_image() {
    podman pull mcr.microsoft.com/mssql/server:latest-ubuntu
}

sql() {
    local container="$1"
    local user="$2"
    local query="$3"
    local password="$4"

    # Pass query as-is to sqlcmd
    podman exec -i "$container" /opt/mssql-tools/bin/sqlcmd \
        -S localhost -U "$user" -P "$password" -b -Q "$query"
}

configure() {
    local container="$1"
    local user="$2"
    local password="$3"

    # Create login
    sql "$container" "sa" \
        "CREATE LOGIN [$user] WITH PASSWORD = '$password'" "$password"

    # Grant sysadmin
    sql "$container" "sa" \
        "ALTER SERVER ROLE sysadmin ADD MEMBER [$user]" "$password"

    # Disable the SA account
    sql "$container" "sa" \
        "ALTER LOGIN [sa] DISABLE" "$password"
}

create() {
    local container="$1"
    local user="$2"
    local password="$3"

    if [ -z "$1" ]; then
        echo "Error: Provide name for sql container" >&2
        return 1
    fi

    podman run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=$password" \
        -p 1433:1433 --name "$container" --hostname "$container" \
        -d \
        mcr.microsoft.com/mssql/server:latest-ubuntu

    sleep 5

    configure "$container" "$user" "$password"
}

start() {
    local container="$1"
    podman start "$container"
}

stop() {
    local container="$1"
    podman stop "$container"
}

connect() {
    local container="$1"
    local user="$2"
    local password="$3"

    if [ -z "$1" ]; then
        echo "Error: Provide container name you'd like to connect to" >&2
        return 1
    fi

    podman exec -it "$container" bash -c "
        /opt/mssql-tools/bin/sqlcmd -S localhost -U '$user' -P '$password'
    "
}

shell() {
    local container="$1"
    local user="$2"
    local password="$3"

    if [ -z "$1" ]; then
        echo "Error: Provide container name you'd like to connect to" >&2
        return 1
    fi

    podman exec -it "$container" bash
}

delete() {
    local container="$1"

    if [ -z "$1" ]; then
        echo "Error: Provide container name you'd like to delete >&2"
        return 1
    fi

    podman stop "$container"
    podman rm "$container"
}

help() {
    echo "Usage $0 {pull_image|create|start|stop|connect|shell|delete}"
}

case "$1" in
    pull_image)
        pull_image
    ;;
    create)
        create "$2" "$3" "$4"
    ;;
    connect)
        connect "$2" "$3" "$4"
    ;;
    shell)
        shell "$2" "$3" "$4"
    ;;
    start)
        start "$2"
    ;;
    stop)
        stop "$2"
    ;;
    delete)
        delete "$2"
    ;;
    *)
        help
    ;;
esac

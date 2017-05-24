#!/bin/bash
set -e

prj_path=$(cd $(dirname $0); pwd -P)

devops_prj_path="$prj_path/devops"

nginx_image=nginx:1.11-alpine
hexo_image=hexo:7.9.0-alpine

app_basic_name="blog"
developer_name="huazhou"
app_nginx_http_port=4000

function _ensure_dir_and_files() {
    ensure_dir "$app_storage_path"
    ensure_dir "$app_log_path"
}

function _init_field() {
    app="$developer_name-$app_basic_name"

    nginx_container="$app-nginx"
    hexo_container="$app-hexo"

    app_storage_path="/opt/data/$app"
    app_log_path="$app_storage_path/logs"
}

function _load_config() {
    if [ ! -d "$app_storage_path" ]; then
        echo 'please sh manager.sh init first'
        exit 1
    fi
}

function init() {
    _ensure_dir_and_files
}

# init  
. $devops_prj_path/base/base.sh
# action

function build_hexo_image() {
    build_image "$hexo_image" "$devops_prj_path/docker/hexo"
}

function build() {
    build_hexo_image
}

function restart_hexo() {
    restart_container "$hexo_container"
}

function stop_hexo() {
    stop_container "$hexo_container"
}

function run_hexo() {
    local container_root="/hexo"
    local node_modules_cache="/tmp/$app/node_modules"

    local args="-d --restart always"
    args="$args -v $prj_path/hexo:$container_root"
    args="$args -v $prj_path/blog:$container_root/source"
    args="$args -v $prj_path/themes:$container_root/themes"
    args="$args -w $container_root"
    args="$args --name $hexo_container"

    run_cmd "docker run $docker_run_fg_mode $args $hexo_image"
    _wait_hexo_ready
}

function _wait_hexo_ready() {
    run_cmd "docker exec $docker_run_fg_mode $hexo_container \
        sh -c 'while ! curl --output /dev/null --silent --head --fail http://localhost:4000; do sleep 1 && echo -n .; done; echo ;'"
}

function to_hexo() {
    to_container "$hexo_container"
}

function hexo() {
    if [ $# -lt 2 ]; then
        echo 'pleace sh manager.sh hexo {hexo cmd}'
        exit 1
    fi

    local hexo_cmd=${*:2}
    run_cmd "docker exec $hexo_container sh -c 'hexo $hexo_cmd'"
}

function run_nginx() {
    local args="-d --restart=always"
    args="$args -w /var/log/nginx"
    args="$args -p $app_nginx_http_port:80"
    args="$args -v $devops_prj_path/nginx-data:/etc/nginx"
    args="$args -v $app_log_path:/var/log/nginx"
    args="$args --link $hexo_container:hexo"
    args="$args --name $nginx_container"

    run_cmd "docker run $docker_run_fg_mode $args $nginx_image"
}

function stop_nginx() {
    stop_container "$nginx_container"
}

function restart_nginx() {
    restart_container "$nginx_container"
}

function to_nginx() {
    run_cmd "docker exec -it $nginx_container sh"
}

function run() {
    run_hexo
    run_nginx
}

function stop() {
    stop_hexo
    stop_nginx
}

function restart() {
    restart_hexo
    restart_nginx
}

function log_hexo() {
    log_container "$hexo_container"
}

function log_nginx() {
     log_container "$nginx_container"
}

function clean() {
    stop
    run_cmd "docker run --rm $docker_run_fg_mode -v /opt/data:/opt/data $nginx_image rm -rf $app_storage_path"
    run_cmd "docker run --rm $docker_run_fg_mode -v $prj_path/hexo:/hexo -w /hexo $nginx_image rm -rf public source themes node_modules"
}

function help() {
    cat <<-EOF

    Usage: sh manager.sh [options]
    
        Valid options are:
            help                show this help message and exit 

            build               build hexo image  
            init                initialize project, like directories
            run                 run project 
            stop                stop project
            restart             restart project
            clean               clean project

            to_hexo             enter hexo container
            hexo                execute hexo command, usage sh manager.sh hexo {hexo cmd}
            to_nginx            enter nginx project
        
            log_hexo            log hexo docker
            log_nginx           log nginx docker
            
EOF
}

ALL_COMMANDS="help"
ALL_COMMANDS="$ALL_COMMANDS build init run stop restart clean"
ALL_COMMANDS="$ALL_COMMANDS to_hexo hexo"
ALL_COMMANDS="$ALL_COMMANDS log_hexo log_nginx to_nginx"

action=${1:-help}
list_contains ALL_COMMANDS "$action" || action=help

_init_field

if [ $action != 'init' ]; then
    _load_config
fi

$action "$@"

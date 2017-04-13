#!/bin/bash
set -e

prj_path=$(cd $(dirname $0); pwd -P)

devops_prj_path="$prj_path/devops"

nginx_image=nginx:1.11-alpine
hexo_image=hexo

app_basic_name="blog"
developer_name="huazhou"
app_nginx_http_port=80
app_nginx_https_port=443

function _ensure_dir_and_files() {
    ensure_dir "$app_storage_path"
    ensure_dir "$app_log_path"
    ensure_dir "$app_nginx_path"

    run_cmd "cp -r $prj_path/hexo $app_hexo_path"
    run_cmd "cp -r $prj_path/blog $app_hexo_path/source"
    run_cmd "cp -r $devops_prj_path/nginx-data $app_nginx_path/confs"
}

function _init_field() {
    app="$developer_name-$app_basic_name"

    nginx_container="$app-nginx"
    hexo_container="$app-hexo"

    app_storage_path="/opt/data/$app"
    app_log_path="$app_storage_path/logs"
    app_hexo_path="$app_storage_path/hexo"
    app_nginx_path="$app_storage_path/nginx"
}

function init() {
    _ensure_dir_and_files
}

function _load_config() {
    if [ ! -d "$app_storage_path" ]; then
        echo 'please sh manager.sh init first'
        exit 1
    fi
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
    args="$args -v $app_hexo_path:$container_root"
    args="$args -v $node_modules_cache:$container_root/node_modules"
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

function hexo_g() {
    run_cmd "docker exec $hexo_container sh -c 'hexo clean && hexo generate'"
}

function run_nginx() {
    local args="-d --restart=always"
    args="$args -p $app_nginx_http_port:80"
    args="$args -p $app_nginx_https_port:443"
    args="$args -v $app_nginx_path/confs:/etc/nginx"
    args="$args -v $app_nginx_path/logs:/var/log/nginx"
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
}

function help() {
    cat <<-EOF

    Usage: sh manager.sh [options]
    
        Valid options are:
            help 

            build 
            init
            run 
            stop
            restart
            clean

            to_hexo
            hexo_g   invoke hexo clean and hexo generate
        
            log_hexo
            log_nginx
            
EOF
}

ALL_COMMANDS="help"
ALL_COMMANDS="$ALL_COMMANDS build init run stop restart clean"
ALL_COMMANDS="$ALL_COMMANDS to_hexo hexo_g"
ALL_COMMANDS="$ALL_COMMANDS log_hexo log_nginx"

action=${1:-help}
list_contains ALL_COMMANDS "$action" || action=help

_init_field

if [ $action != 'init' ]; then
    _load_config
fi

$action "$@"

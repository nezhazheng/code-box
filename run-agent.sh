#!/bin/bash
# run-agent.sh v2.0 - Agent Sandbox 智能启动器
# 支持持久化、资源限制、健康检查

set -e

# ==========================================
# 配置区
# ==========================================
IMAGE_NAME="agent-box-image"

# 根据当前目录名生成唯一容器名
PROJECT_NAME=$(basename "$PWD" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9._-]//g')
CONTAINER_NAME="agent_box_${PROJECT_NAME}"

# 端口配置 (可通过参数覆盖)
VNC_PORT=${1:-6080}

# 资源限制
MEMORY_LIMIT="4g"
CPU_LIMIT="2"
SHM_SIZE="2gb"

# ==========================================
# 颜色输出
# ==========================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warn() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }

# ==========================================
# 前置检查
# ==========================================
check_prerequisites() {
    # 检查 Docker 是否运行
    if ! docker info > /dev/null 2>&1; then
        log_error "Docker is not running. Please start Docker first."
        exit 1
    fi

    # 检查镜像是否存在
    if ! docker image inspect $IMAGE_NAME > /dev/null 2>&1; then
        log_error "Image '$IMAGE_NAME' not found."
        log_info "Please build the image first: docker build -t $IMAGE_NAME ."
        exit 1
    fi

    # 检查端口是否被占用
    if lsof -i:$VNC_PORT > /dev/null 2>&1; then
        # 检查是否是本容器占用的端口
        CONTAINER_USING_PORT=$(docker ps --filter "publish=$VNC_PORT" --format "{{.Names}}" 2>/dev/null)
        if [ "$CONTAINER_USING_PORT" != "$CONTAINER_NAME" ]; then
            log_error "Port $VNC_PORT is already in use."
            log_info "Try a different port: $0 <port>"
            exit 1
        fi
    fi
}

# ==========================================
# 主逻辑
# ==========================================
main() {
    echo ""
    echo "=========================================="
    echo "🛡️  Agent Sandbox Launcher"
    echo "=========================================="
    log_info "Project: $PROJECT_NAME"
    log_info "Container: $CONTAINER_NAME"
    echo ""

    check_prerequisites

    # 检查容器是否已存在
    if [ "$(docker ps -a -q -f name=^/${CONTAINER_NAME}$)" ]; then
        log_info "Found existing container, checking status..."

        # 检查容器是否在运行
        if [ "$(docker ps -q -f name=^/${CONTAINER_NAME}$)" ]; then
            log_success "Container is already running."
        else
            log_info "Container is stopped, starting..."
            docker start $CONTAINER_NAME
            log_success "Container started."
        fi

        # 等待健康检查通过
        log_info "Waiting for services to be ready..."
        for i in {1..30}; do
            HEALTH=$(docker inspect --format='{{.State.Health.Status}}' $CONTAINER_NAME 2>/dev/null || echo "unknown")
            if [ "$HEALTH" = "healthy" ]; then
                log_success "All services are healthy!"
                break
            fi
            sleep 1
        done
    else
        log_info "Creating new sandbox environment..."

        # 创建新容器
        docker run -d \
            --name $CONTAINER_NAME \
            -p ${VNC_PORT}:6080 \
            --shm-size=$SHM_SIZE \
            --memory=$MEMORY_LIMIT \
            --cpus=$CPU_LIMIT \
            -v "$(pwd)":/workspace \
            -v "${HOME}/.claude_config_docker:/home/developer/.claude" \
            -e ANTHROPIC_API_KEY="${ANTHROPIC_API_KEY:-}" \
            --restart unless-stopped \
            $IMAGE_NAME

        log_success "Container created successfully."

        # 等待服务就绪
        log_info "Waiting for services to start..."
        sleep 5

        for i in {1..30}; do
            HEALTH=$(docker inspect --format='{{.State.Health.Status}}' $CONTAINER_NAME 2>/dev/null || echo "starting")
            if [ "$HEALTH" = "healthy" ]; then
                log_success "All services are healthy!"
                break
            elif [ "$HEALTH" = "unhealthy" ]; then
                log_warn "Health check failed, but continuing..."
                break
            fi
            sleep 1
        done
    fi

    # 输出访问信息
    echo ""
    echo "=========================================="
    echo "🎉 Sandbox Ready!"
    echo "=========================================="
    echo -e "📺 ${GREEN}Browser View:${NC} http://localhost:${VNC_PORT}"
    echo -e "📂 ${GREEN}Workspace:${NC}    $(pwd)"
    echo -e "💾 ${GREEN}Memory:${NC}       $MEMORY_LIMIT"
    echo -e "🔧 ${GREEN}CPUs:${NC}         $CPU_LIMIT"
    echo "=========================================="
    echo ""
    log_info "Entering sandbox terminal..."
    echo ""

    # 进入容器交互式终端
    docker exec -it $CONTAINER_NAME bash -c "cd /workspace && exec bash"
}

# ==========================================
# 帮助信息
# ==========================================
show_help() {
    echo "Usage: $0 [OPTIONS] [VNC_PORT]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -s, --stop     Stop the container"
    echo "  -r, --remove   Stop and remove the container"
    echo "  -l, --logs     Show container logs"
    echo ""
    echo "Arguments:"
    echo "  VNC_PORT       Port for noVNC web interface (default: 6080)"
    echo ""
    echo "Examples:"
    echo "  $0              # Start with default port 6080"
    echo "  $0 8080         # Start with port 8080"
    echo "  $0 --stop       # Stop the container"
    echo "  $0 --logs       # View logs"
}

# ==========================================
# 命令处理
# ==========================================
case "${1:-}" in
    -h|--help)
        show_help
        exit 0
        ;;
    -s|--stop)
        log_info "Stopping container: $CONTAINER_NAME"
        docker stop $CONTAINER_NAME 2>/dev/null || log_warn "Container not running"
        log_success "Container stopped."
        exit 0
        ;;
    -r|--remove)
        log_info "Removing container: $CONTAINER_NAME"
        docker rm -f $CONTAINER_NAME 2>/dev/null || log_warn "Container not found"
        log_success "Container removed."
        exit 0
        ;;
    -l|--logs)
        docker logs -f $CONTAINER_NAME
        exit 0
        ;;
    *)
        main
        ;;
esac

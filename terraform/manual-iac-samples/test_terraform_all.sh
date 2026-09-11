#!/bin/bash

# Terraformテストスクリプト - 01から08のフォルダでplan & applyを実行

set -e  # エラーが発生したら即座に停止

# ベースディレクトリ
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"

# カラー出力の定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# .envファイルが存在する場合は読み込む
if [ -f "${BASE_DIR}/.env" ]; then
    set -a  # 自動的にexportする
    source "${BASE_DIR}/.env"
    set +a
    echo "Loaded environment variables from .env"
elif [ -f .env ]; then
    set -a  # 自動的にexportする
    source .env
    set +a
    echo "Loaded environment variables from .env"
fi

# 環境変数が設定されているか確認と警告表示の関数定義
check_env_vars() {
    if [ -z "${SAKURA_ACCESS_TOKEN}" ] || [ -z "${SAKURA_ACCESS_TOKEN_SECRET}" ]; then
        echo -e "${YELLOW}⚠ SAKURA_ACCESS_TOKEN or SAKURA_ACCESS_TOKEN_SECRET is not set${NC}"
        echo -e "${YELLOW}⚠ Please set these environment variables or create a .env file${NC}"
        echo -e "${YELLOW}⚠ Example: cp .env.example .env && edit .env${NC}"
        exit 1
    fi
}

# ログファイル
LOG_DIR="${BASE_DIR}/terraform_test_logs"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="${LOG_DIR}/test_${TIMESTAMP}.log"

# ログディレクトリの作成
mkdir -p "${LOG_DIR}"

# ログ記録関数
log() {
    echo -e "$1" | tee -a "${LOG_FILE}"
}

# 成功メッセージ
success() {
    log "${GREEN}✓ $1${NC}"
}

# エラーメッセージ
error() {
    log "${RED}✗ $1${NC}"
}

# 警告メッセージ
warning() {
    log "${YELLOW}⚠ $1${NC}"
}

# テスト対象のフォルダ（04は存在しないので除外）
FOLDERS=("01" "02" "03" "04" "05")

# テスト結果を記録する配列
declare -A RESULTS

# メイン処理
main() {
    log "=========================================="
    log "Terraform Test Script Started at $(date)"
    log "=========================================="

    # 環境変数のチェック
    check_env_vars

    # 各フォルダをテスト
    for folder in "${FOLDERS[@]}"; do
        log "\n------------------------------------------"
        log "Testing folder: ${folder}"
        log "------------------------------------------"

        if [ ! -d "${BASE_DIR}/${folder}" ]; then
            error "Directory ${folder} does not exist. Skipping..."
            RESULTS[${folder}]="SKIPPED - Directory not found"
            continue
        fi
        
        cd "${BASE_DIR}/${folder}"

        # terraform.tfvarsの確認
        if [ ! -f "terraform.tfvars" ]; then
            if [ -f "terraform.tfvars.example" ]; then
                warning "terraform.tfvars not found. Using terraform.tfvars.example as reference"
                cp terraform.tfvars.example terraform.tfvars
                warning "Created terraform.tfvars from example. Please edit with actual values before running apply."
            else
                error "Neither terraform.tfvars nor terraform.tfvars.example found"
                RESULTS[${folder}]="FAILED - No tfvars file"
                cd "${BASE_DIR}"
                continue
            fi
        fi

        # Terraform初期化
        log "Running terraform init..."
        INIT_OUTPUT="${LOG_DIR}/${folder}_init_${TIMESTAMP}.txt"
        if terraform init -upgrade > "${INIT_OUTPUT}" 2>&1; then
            success "terraform init completed"
        else
            error "terraform init failed - check ${INIT_OUTPUT} for details"
            # エラーの最初の数行を表示
            head -5 "${INIT_OUTPUT}" | while IFS= read -r line; do
                log "  ${line}"
            done
            RESULTS[${folder}]="FAILED - Init error"
            cd "${BASE_DIR}"
            continue
        fi

        # Terraform validate
        log "Running terraform validate..."
        VALIDATE_OUTPUT="${LOG_DIR}/${folder}_validate_${TIMESTAMP}.txt"
        if terraform validate > "${VALIDATE_OUTPUT}" 2>&1; then
            success "terraform validate completed"
        else
            error "terraform validate failed - check ${VALIDATE_OUTPUT} for details"
            # エラーの最初の数行を表示
            head -5 "${VALIDATE_OUTPUT}" | while IFS= read -r line; do
                log "  ${line}"
            done
            RESULTS[${folder}]="FAILED - Validation error"
            cd "${BASE_DIR}"
            continue
        fi

        # Terraform plan
        log "Running terraform plan..."
        PLAN_OUTPUT="${LOG_DIR}/${folder}_plan_${TIMESTAMP}.txt"
        if terraform plan -out=${folder}.tfplan > "${PLAN_OUTPUT}" 2>&1; then
            success "terraform plan completed successfully"
            log "Plan output saved to ${PLAN_OUTPUT}"
            
            # Apply実行の確認（非対話モードオプション）
            if [ "${AUTO_APPROVE:-}" = "true" ]; then
                REPLY="y"
            elif [ "${AUTO_REJECT:-}" = "true" ]; then
                REPLY="n"
            else
                read -p "Do you want to apply the changes for ${folder}? (y/N): " -n 1 -r
                echo
            fi
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                log "Running terraform apply..."
                APPLY_OUTPUT="${LOG_DIR}/${folder}_apply_${TIMESTAMP}.txt"
                if terraform apply ${folder}.tfplan > "${APPLY_OUTPUT}" 2>&1; then
                    success "terraform apply completed successfully"
                    log "Apply output saved to ${APPLY_OUTPUT}"
                    RESULTS[${folder}]="SUCCESS - Applied"
                else
                    error "terraform apply failed - check ${APPLY_OUTPUT} for details"
                    # エラーの最初の数行を表示
                    tail -10 "${APPLY_OUTPUT}" | while IFS= read -r line; do
                        log "  ${line}"
                    done
                    RESULTS[${folder}]="FAILED - Apply error"
                fi
                
                # tfplanファイルの削除
                rm -f ${folder}.tfplan
            else
                warning "Skipping terraform apply for ${folder}"
                RESULTS[${folder}]="SUCCESS - Plan only"
                rm -f ${folder}.tfplan
            fi
        else
            error "terraform plan failed"
            RESULTS[${folder}]="FAILED - Plan error"
        fi

        cd "${BASE_DIR}"
    done

    # 結果サマリーの表示
    log "\n=========================================="
    log "Test Results Summary"
    log "=========================================="

    for folder in "${FOLDERS[@]}"; do
        result="${RESULTS[${folder}]:-NOT TESTED}"
        if [[ $result == SUCCESS* ]]; then
            success "Folder ${folder}: ${result}"
        elif [[ $result == FAILED* ]]; then
            error "Folder ${folder}: ${result}"
        elif [[ $result == SKIPPED* ]]; then
            warning "Folder ${folder}: ${result}"
        else
            log "Folder ${folder}: ${result}"
        fi
    done

    log "\n=========================================="
    log "Test completed at $(date)"
    log "Log file: ${LOG_FILE}"
    log "=========================================="
}

# Destroy オプション
destroy_all() {
    log "=========================================="
    log "Terraform Destroy Started at $(date)"
    log "=========================================="

    for folder in "${FOLDERS[@]}"; do
        if [ ! -d "${BASE_DIR}/${folder}" ]; then
            continue
        fi
    
        log "\nDestroying resources in ${folder}..."
        cd "${BASE_DIR}/${folder}"

        if [ -f "terraform.tfstate" ]; then
            if [ "${AUTO_APPROVE:-}" = "true" ]; then
                REPLY="y"
            elif [ "${AUTO_REJECT:-}" = "true" ]; then
                REPLY="n"
            else
                read -p "Are you sure you want to destroy resources in ${folder}? (y/N): " -n 1 -r
                echo
            fi
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                DESTROY_OUTPUT="${LOG_DIR}/${folder}_destroy_${TIMESTAMP}.txt"
                if terraform destroy -auto-approve > "${DESTROY_OUTPUT}" 2>&1; then
                    success "Resources destroyed in ${folder}"
                    log "Destroy output saved to ${DESTROY_OUTPUT}"
                else
                    error "Failed to destroy resources in ${folder} - check ${DESTROY_OUTPUT} for details"
                    # エラーの最後の数行を表示
                    tail -10 "${DESTROY_OUTPUT}" | while IFS= read -r line; do
                        log "  ${line}"
                    done
                fi
            else
                warning "Skipped destroying resources in ${folder}"
            fi
        else
            log "No state file found in ${folder}, skipping..."
        fi

        cd "${BASE_DIR}"
    done
}

# コマンドライン引数の処理
case "${1:-}" in
    destroy)
        destroy_all
        ;;
    *)
        main
        ;;
esac
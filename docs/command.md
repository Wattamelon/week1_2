# 환경변수(.env) 설정

```env
# env 파일 설정
# =========================================
# Agent Base Path
# =========================================

AGENT_HOME=/Users/seongon10104692/Desktop/week2

# =========================================
# Network
# =========================================

AGENT_PORT=15034

# =========================================
# Directories
# =========================================

AGENT_UPLOAD_DIR=$AGENT_HOME/upload_files

AGENT_KEY_PATH=$AGENT_HOME/api_keys

AGENT_LOG_DIR=$AGENT_HOME/logs

# =========================================
# OOM / CPU / Deadlock Settings
# =========================================

MEMORY_LIMIT=256

CPU_MAX_OCCUPY=80

MULTI_THREAD_ENABLE=true
```

---

# 현재 작업 디렉토리 확인

```bash
pwd
```

출력:

```bash
/Users/seongon10104692/Desktop/week2
```

---

# .env 환경변수 적용

```bash
set -a
source .env
set +a
```

설명:

- `set -a`
  - source 되는 변수들을 자동 export 처리

- `source .env`
  - .env 파일 내용 적용

- `set +a`
  - 자동 export 모드 종료

---

# 디렉토리 생성

```bash
mkdir -p $AGENT_UPLOAD_DIR
mkdir -p $AGENT_KEY_PATH
mkdir -p $AGENT_LOG_DIR
```

실제 생성되는 디렉토리:

```text
/Users/seongon10104692/Desktop/week2/upload_files

/Users/seongon10104692/Desktop/week2/api_keys

/Users/seongon10104692/Desktop/week2/logs
```

---

# secret.key 생성

```bash
echo "agent_api_key_test" > $AGENT_KEY_PATH/secret.key
```

실제 생성 파일:

```text
/Users/seongon10104692/Desktop/week2/api_keys/secret.key
```

파일 내용:

```text
agent_api_key_test
```



# Docker 환경 세팅 

# Dockerfile 작성

현재 프로젝트 루트에 `Dockerfile` 작성.

```dockerfile
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y \
    bash \
    procps \
    htop \
    tree \
    vim \
    nano \
    curl \
    wget \
    net-tools \
    iproute2 \
    lsof \
    psmisc \
    grep \
    coreutils \
    findutils \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash agentuser

WORKDIR /app

USER agentuser

EXPOSE 15034

CMD ["/bin/bash"]
```

---

# Dockerfile 구성 목적

이번 미션에서 필요한 Linux 관제 및 시스템 분석 환경을 구성하기 위함.

포함 내용:

- Ubuntu Linux 환경 구성
- 리눅스 관제 명령어 설치
- 일반 사용자(agentuser) 생성
- `/app` 작업 디렉토리 설정
- 15034 포트 사용
- bash 기본 실행 환경 구성

---

# 설치된 주요 패키지

| 패키지 | 목적 |
|---|---|
| procps | ps, top 사용 |
| htop | CPU/MEM 실시간 관찰 |
| tree | 디렉토리 구조 출력 |
| vim / nano | 텍스트 편집 |
| net-tools | netstat 사용 |
| iproute2 | ss 사용 |
| lsof | 포트 사용 프로세스 확인 |
| psmisc | pstree 사용 |
| grep | 로그 검색 |

---

# Docker Container 실행

```bash
docker run -it \
  --name week2-agent \
  -v $(pwd):/app \
  -p 15034:15034 \
  wee1_2
```

옵션 설명:

| 옵션 | 의미 |
|---|---|
| -it | 인터랙티브 터미널 |
| --name | 컨테이너 이름 지정 |
| -v | bind mount |
| -p | 포트 연결 |

---

# Bind Mount 구조

현재 구조:

```text
로컬 week2 폴더
↕
Docker 컨테이너 /app
```

즉:

```bash
-v $(pwd):/app
```

를 통해 로컬 프로젝트 폴더를 컨테이너 내부 `/app`에 연결하였다.

---

# Container 내부 확인

현재 사용자 확인:

```bash
whoami
```

출력:

```bash
agentuser
```

현재 작업 디렉토리 확인:

```bash
pwd
```

출력:

```bash
/app
```

---

# Bind Mount 정상 동작 확인

```bash
ls
```

출력:

```bash
Dockerfile
api_keys
docs
logs
reports
screenshots
upload_files
미션.pdf
```

즉:

```text
로컬 파일
=
컨테이너 내부 /app 파일
```

공유 성공 확인.

---

# Docker 기준 .env 수정

Docker 환경에서는 로컬 Mac 절대경로 대신 `/app` 기준으로 환경변수를 설정하였다.

```env
AGENT_HOME=/app

AGENT_PORT=15034

AGENT_UPLOAD_DIR=$AGENT_HOME/upload_files

AGENT_KEY_PATH=$AGENT_HOME/api_keys

AGENT_LOG_DIR=$AGENT_HOME/logs

MEMORY_LIMIT=256

CPU_MAX_OCCUPY=80

MULTI_THREAD_ENABLE=true
```

---

# .env 적용

컨테이너 내부에서:

```bash
set -a
source .env
set +a
```

실행.

---

# 환경변수 확인

```bash
echo $AGENT_HOME
echo $AGENT_UPLOAD_DIR
echo $AGENT_KEY_PATH
echo $AGENT_LOG_DIR
```

출력:

```bash
/app

/app/upload_files

/app/api_keys

/app/logs
```

---

# Linux 명령어 정상 동작 확인

---

## top

```bash
top -v
```

출력:

```bash
procps-ng 3.3.17
```

---

## htop

```bash
htop --version
```

출력:

```bash
htop 3.0.5
```

---

## tree

```bash
tree --version
```

출력:

```bash
tree v2.0.2
```

---

## ss

```bash
ss --version
```

출력:

```bash
ss utility, iproute2-5.15.0
```

---

## lsof

```bash
lsof -v
```

정상 동작 확인 완료.

---

## pstree

```bash
pstree --version
```

출력:

```bash
pstree (PSmisc) 23.4
```

---

# 미션 진행 청사진

# 전체 목표

이번 미션의 목표는 `agent-leak-app`을 실행하면서 발생하는 3가지 장애를 분석하고, GitHub Issue 형태의 기술 리포트로 정리하는 것이다.

분석해야 할 장애는 다음 3가지다.

- OOM Crash
- CPU Latency
- Deadlock

각 장애마다 반드시 다음 흐름으로 정리한다.

현상 관찰
↓
증거 수집
↓
원인 분석
↓
환경변수 조정
↓
Before & After 비교
↓
GitHub Issue 작성

---

# 최종 제출물 구조

GitHub Repository 기준으로 정리하면 다음 구조를 추천한다.

```text
linux-os-troubleshooting/
├── README.md
├── study.md
├── reports/
│   ├── oom-crash.md
│   ├── cpu-latency.md
│   └── deadlock.md
├── logs/
│   ├── oom/
│   ├── cpu/
│   └── deadlock/
├── screenshots/
│   ├── oom/
│   ├── cpu/
│   └── deadlock/
└── scripts/
    └── command-record.md
```

---

# 진행 순서

# 준비 단계

먼저 실행 환경을 구성한다.

확인해야 할 것:

- root가 아닌 일반 사용자로 실행
- AGENT_HOME 환경변수 설정
- AGENT_PORT는 15034
- upload_files 디렉터리 존재
- api_keys 디렉터리 존재
- secret.key 파일 존재
- 로그 디렉터리 존재 및 쓰기 권한 확인
- MEMORY_LIMIT 설정
- CPU_MAX_OCCUPY 설정
- MULTI_THREAD_ENABLE 설정
- 15034 포트 사용 가능 여부 확인

예시 명령어:

```bash
whoami
pwd
echo $AGENT_HOME
echo $MEMORY_LIMIT
echo $CPU_MAX_OCCUPY
echo $MULTI_THREAD_ENABLE
ls -l
ss -tunlp | grep 15034
```

---

# 기본 디렉터리 구성

예시:

```bash
mkdir -p reports
mkdir -p logs/oom logs/cpu logs/deadlock
mkdir -p screenshots/oom screenshots/cpu screenshots/deadlock
mkdir -p scripts
touch study.md
touch reports/oom-crash.md
touch reports/cpu-latency.md
touch reports/deadlock.md
touch scripts/command-record.md
```

---

# 환경변수 설정

미션 조건에 맞게 환경변수를 설정한다.

예시:

```bash
export AGENT_HOME=$HOME/agent
export AGENT_PORT=15034
export AGENT_UPLOAD_DIR=$AGENT_HOME/upload_files
export AGENT_KEY_PATH=$AGENT_HOME/api_keys
export AGENT_LOG_DIR=$AGENT_HOME/logs
export MEMORY_LIMIT=256
export CPU_MAX_OCCUPY=80
export MULTI_THREAD_ENABLE=true
```

필요 디렉터리 생성:

```bash
mkdir -p $AGENT_UPLOAD_DIR
mkdir -p $AGENT_KEY_PATH
mkdir -p $AGENT_LOG_DIR
```

secret.key 생성:

```bash
echo "agent_api_key_test" > $AGENT_KEY_PATH/secret.key
```

---

# 실행 전 점검

실행 전에 아래를 확인한다.

```bash
ls -ld $AGENT_HOME
ls -ld $AGENT_UPLOAD_DIR
ls -ld $AGENT_KEY_PATH
ls -ld $AGENT_LOG_DIR
cat $AGENT_KEY_PATH/secret.key
echo $MEMORY_LIMIT
echo $CPU_MAX_OCCUPY
echo $MULTI_THREAD_ENABLE
```

확인 포인트:

- 디렉터리가 실제로 존재하는가?
- 로그 디렉터리에 쓰기 권한이 있는가?
- secret.key 내용이 정확한가?
- 환경변수가 정상 출력되는가?

---

# 공통 관제 명령어 정리

미션 중 자주 사용할 명령어:

```bash
ps -ef | grep agent
```

프로세스 존재 확인

```bash
top
```

실시간 CPU/MEM 확인

```bash
top -H
```

스레드 단위 확인

```bash
ps -L -p PID
```

특정 프로세스의 스레드 확인

```bash
tail -f 로그파일경로
```

실시간 로그 확인

```bash
grep -E "ERROR|WARN|CRITICAL|Memory|WATCHDOG|WAITING|BLOCKED" 로그파일경로
```

핵심 로그 검색

```bash
kill PID
```

프로세스 정상 종료 요청

```bash
kill -9 PID
```

프로세스 강제 종료

---

# 1단계: OOM Crash 분석

# 목표

메모리 사용량이 시간에 따라 증가하고, MEMORY_LIMIT에 도달했을 때 MemoryGuard에 의해 프로세스가 종료되는지 확인한다.

OOM 케이스에서는 최소한 다음 증거가 필요하다.

- monitor.sh 결과
- 메모리 상승 수치
- 종료 직전/직후 실행 로그
- Memory limit exceeded 로그
- SELF-TERMINATED 로그
- MEMORY_LIMIT 변경 전후 비교

---

# OOM 실험 흐름

# Before 실험

낮은 MEMORY_LIMIT 값으로 실행한다.

예시:

```bash
export MEMORY_LIMIT=256
export CPU_MAX_OCCUPY=80
export MULTI_THREAD_ENABLE=false
```

프로그램 실행:

```bash
./agent-leak-app
```

다른 터미널에서 관제:

```bash
./monitor.sh
```

또는:

```bash
top
ps -ef | grep agent
```

로그 확인:

```bash
tail -f $AGENT_LOG_DIR/*.log
```

수집할 것:

- 시작 시각
- 종료 시각
- 종료 직전 메모리 사용량
- MemoryGuard 로그
- SELF-TERMINATED 로그
- monitor.sh 출력

---

# After 실험

MEMORY_LIMIT 값을 높여서 다시 실행한다.

예시:

```bash
export MEMORY_LIMIT=512
```

다시 실행:

```bash
./agent-leak-app
```

관제:

```bash
./monitor.sh
```

비교할 것:

```text
Before:
MEMORY_LIMIT=256
약 N분 후 종료

After:
MEMORY_LIMIT=512
약 M분 이상 생존
```

---

# OOM 리포트에 쓸 핵심 분석

분석 방향:

```text
monitor.sh 결과 메모리 사용량이 시간에 따라 지속적으로 증가했다.
CPU 사용률은 상대적으로 안정적이었다.
종료 직전 로그에서 Memory limit exceeded 메시지가 확인되었다.
따라서 agent-leak-app 내부에서 Heap 메모리에 데이터가 지속적으로 누적되는 Memory Leak 가능성이 있다.
MEMORY_LIMIT 값을 높이자 프로세스 생존 시간이 증가했다.
하지만 이는 임시 조치이며, 근본 해결은 누수되는 데이터 구조를 해제하거나 누적 로직을 수정하는 것이다.
```

---

# 2단계: CPU Latency 분석

# 목표

특정 프로세스가 CPU를 과점유하고, Watchdog 보호 정책에 의해 종료되는지 확인한다.

CPU 케이스에서는 최소한 다음 증거가 필요하다.

- CPU 사용률 급상승 구간
- top / ps / monitor.sh 캡처
- WATCHDOG 또는 SIGTERM 종료 로그
- CPU_MAX_OCCUPY 변경 전후 비교

---

# CPU 실험 흐름

# Before 실험

CPU 제한값을 낮게 설정한다.

예시:

```bash
export MEMORY_LIMIT=512
export CPU_MAX_OCCUPY=50
export MULTI_THREAD_ENABLE=false
```

프로그램 실행:

```bash
./agent-leak-app
```

관제:

```bash
top
```

또는:

```bash
ps -eo pid,ppid,cmd,%cpu,%mem --sort=-%cpu
```

로그 확인:

```bash
tail -f $AGENT_LOG_DIR/*.log
```

수집할 것:

- CPU 사용률 급상승 시점
- agent-leak-app의 CPU 점유율
- Watchdog 로그
- SIGTERM 로그
- 종료 여부

---

# After 실험

CPU_MAX_OCCUPY 값을 높인다.

예시:

```bash
export CPU_MAX_OCCUPY=90
```

다시 실행:

```bash
./agent-leak-app
```

비교할 것:

```text
Before:
CPU_MAX_OCCUPY=50
CPU 사용률 초과 후 Watchdog 종료

After:
CPU_MAX_OCCUPY=90
종료 시점 지연 또는 생존 시간 증가
```

---

# CPU 리포트에 쓸 핵심 분석

분석 방향:

```text
관제 결과 시스템 전체 문제가 아니라 agent-leak-app 프로세스의 CPU 사용률이 급격히 상승했다.
top 또는 ps 출력에서도 해당 프로세스가 높은 CPU 점유율을 보였다.
프로그램 로그에서 WATCHDOG 관련 메시지와 SIGTERM 종료 로그가 확인되었다.
따라서 이는 단순 오류 종료가 아니라 CPU 과점유를 막기 위한 Watchdog 보호 조치로 판단된다.
CPU_MAX_OCCUPY 값을 높이자 종료 시점 또는 생존 시간이 변화했다.
다만 근본 해결은 CPU를 과도하게 사용하는 루프, 연산, 스레드 동작을 개선하는 것이다.
```

---

# 3단계: Deadlock 분석

# 목표

프로세스는 살아 있지만 CPU/MEM 변화가 없고 로그가 멈춘 상태를 확인한다.

Deadlock 케이스에서는 최소한 다음 증거가 필요하다.

- PID 존재 증거
- CPU/MEM 변화 정체 증거
- top -H 또는 ps -L 결과
- 마지막 로그 지점
- WAITING 또는 BLOCKED 로그
- 스레드/락 대기 추론 근거
- MULTI_THREAD_ENABLE 변경 전후 비교

---

# Deadlock 실험 흐름

# Before 실험

멀티스레드를 활성화한다.

예시:

```bash
export MEMORY_LIMIT=512
export CPU_MAX_OCCUPY=90
export MULTI_THREAD_ENABLE=true
```

프로그램 실행:

```bash
./agent-leak-app
```

관제:

```bash
ps -ef | grep agent
```

PID 확인 후:

```bash
ps -L -p PID
```

```bash
top -H
```

로그 확인:

```bash
tail -f $AGENT_LOG_DIR/*.log
```

수집할 것:

- PID가 살아 있는 증거
- CPU 사용률이 거의 변하지 않는 증거
- 메모리 사용량 변화가 없는 증거
- 로그가 멈춘 마지막 지점
- WAITING / BLOCKED / lock 관련 로그

---

# After 실험

멀티스레드를 비활성화한다.

```bash
export MULTI_THREAD_ENABLE=false
```

다시 실행:

```bash
./agent-leak-app
```

비교할 것:

```text
Before:
MULTI_THREAD_ENABLE=true
PID는 살아 있지만 로그 정지, CPU/MEM 변화 없음

After:
MULTI_THREAD_ENABLE=false
Deadlock 미발생 또는 정상 진행
```

---

# Deadlock 리포트에 쓸 핵심 분석

분석 방향:

```text
프로세스 PID는 유지되고 있으므로 프로세스가 종료된 상태는 아니다.
하지만 CPU 사용률과 메모리 사용량이 거의 변하지 않았고, 로그 출력도 특정 지점 이후 멈췄다.
마지막 로그에서 WAITING 또는 BLOCKED 상태가 확인되었다.
이는 여러 스레드가 서로의 자원을 기다리는 교착상태로 추정된다.
MULTI_THREAD_ENABLE=false로 변경하자 동일한 무응답 상태가 재현되지 않았다.
따라서 멀티스레드 환경에서 락 획득 순서 또는 공유 자원 경쟁으로 인해 Deadlock이 발생한 것으로 분석할 수 있다.
```

---

# 4단계: 보너스 과제 진행 여부 결정

보너스 과제는 스케줄링 알고리즘 추론이다.

여유가 있으면 진행한다.

목표:

```text
로그의 타임스탬프와 스레드 실행 순서를 분석해서
Round Robin, FCFS, Priority 중 어떤 방식에 가까운지 추론한다.
```

분석 포인트:

```text
Thread-A가 끝나기 전에 Thread-B가 실행되는가?
특정 스레드만 계속 실행되는가?
A → B → C → A처럼 번갈아 실행되는가?
우선순위가 높은 작업이 먼저 처리되는 흔적이 있는가?
```

결론 예시:

```text
Thread-A가 완료되기 전에 Thread-B, Thread-C가 번갈아 실행되었고,
특정 스레드가 독점하지 않았으므로 Round Robin 방식에 가깝다고 추론된다.
```

---

# 리포트 작성 템플릿

각 리포트는 아래 형식으로 작성한다.

```markdown
# [Bug] 장애 유형 - 한 줄 요약

## Description

어떤 현상이 발생했는지 작성한다.

- 언제 발생했는가?
- 어떤 조건에서 발생했는가?
- 프로그램은 종료되었는가, 멈췄는가?
- 사용자 입장에서 어떤 문제가 보였는가?

## Evidence & Logs

수집한 증거를 작성한다.

- monitor.sh 결과
- top / ps 결과
- 로그 핵심 구간
- 스크린샷 경로
- 실행 조건

## Root Cause Analysis

증거를 바탕으로 원인을 분석한다.

- 메모리 누수인가?
- CPU 과점유인가?
- Deadlock인가?
- 관련 OS 개념은 무엇인가?

## Workaround & Verification

조치와 검증 결과를 작성한다.

- 어떤 환경변수를 바꿨는가?
- Before 상태는 어땠는가?
- After 상태는 어땠는가?
- 근본 해결책은 무엇인가?
```

---

# 증거 수집 체크리스트

# OOM

- monitor.sh 메모리 증가 수치
- 종료 직전 로그
- Memory limit exceeded
- SELF-TERMINATED
- MEMORY_LIMIT 변경 전후 비교

# CPU

- CPU 급상승 수치
- top 또는 ps 출력
- Watchdog 로그
- SIGTERM 로그
- CPU_MAX_OCCUPY 변경 전후 비교

# Deadlock

- PID 존재
- CPU/MEM 변화 없음
- top -H 또는 ps -L 출력
- 마지막 로그
- WAITING / BLOCKED
- MULTI_THREAD_ENABLE 변경 전후 비교

---

# 스크린샷 추천 목록

최소한 아래 화면은 캡처해두는 것이 좋다.

# OOM

- monitor.sh에서 메모리 증가하는 화면
- MemoryGuard 종료 로그
- MEMORY_LIMIT 변경 전후 실행 결과

# CPU

- top에서 CPU 사용률 높은 화면
- Watchdog 종료 로그
- CPU_MAX_OCCUPY 변경 전후 실행 결과

# Deadlock

- ps -ef로 PID 살아 있는 화면
- top -H 또는 ps -L 결과
- 로그가 멈춘 마지막 화면
- MULTI_THREAD_ENABLE 변경 전후 결과

---

# 작업 순서 추천

가장 추천하는 순서:

```text
1. 실행 환경 구성
2. 정상 실행 확인
3. OOM 실험
4. OOM 리포트 작성
5. CPU 실험
6. CPU 리포트 작성
7. Deadlock 실험
8. Deadlock 리포트 작성
9. README.md 작성
10. study.md 정리
11. GitHub push
```

한 번에 3개를 다 실험하고 나중에 쓰려고 하면 헷갈릴 가능성이 높다.

따라서:

```text
실험 하나 끝냄
↓
바로 리포트 작성
↓
다음 실험 진행
```

이 방식이 좋다.

---

# Git 커밋 전략

커밋은 단계별로 나눈다.

예시:

```bash
git add study.md
git commit -m "docs: add os and linux study notes"
```

```bash
git add reports/oom-crash.md logs/oom screenshots/oom
git commit -m "docs: add oom crash analysis report"
```

```bash
git add reports/cpu-latency.md logs/cpu screenshots/cpu
git commit -m "docs: add cpu latency analysis report"
```

```bash
git add reports/deadlock.md logs/deadlock screenshots/deadlock
git commit -m "docs: add deadlock analysis report"
```

마지막:

```bash
git add README.md
git commit -m "docs: add project overview"
git push origin main
```

---

# README.md에 넣을 내용

README에는 전체 프로젝트 요약을 넣는다.

추천 구조:

```markdown
# Linux Process and System Resource Troubleshooting

## Mission Overview

이 프로젝트는 Linux 환경에서 발생하는 OOM Crash, CPU Latency, Deadlock 장애를 관찰하고 분석한 결과를 정리한 저장소입니다.

## Objectives

- Memory Leak과 OOM Crash 분석
- CPU Spike와 Watchdog 종료 분석
- Deadlock 상태 진단
- Linux 관제 명령어 활용
- GitHub Issue 형태의 장애 리포트 작성

## Reports

- OOM Crash Report
- CPU Latency Report
- Deadlock Report

## Tools

- monitor.sh
- ps
- top
- htop
- pstree
- kill
- grep
- tail

## Directory Structure

저장소 구조 설명
```

---

# 최종 점검

제출 전 확인:

- 리포트 3개가 모두 있는가?
- 각 리포트에 Description이 있는가?
- Evidence & Logs가 있는가?
- Root Cause Analysis가 있는가?
- Workaround & Verification이 있는가?
- Before & After 비교가 있는가?
- 로그 또는 스크린샷 증거가 있는가?
- README.md가 있는가?
- study.md가 있는가?
- GitHub에 push했는가?

---

# 핵심 전략

이번 미션은 코드를 잘 짜는 것보다, 장애를 잘 관찰하고 논리적으로 설명하는 것이 중요하다.

따라서 항상 아래 순서를 지킨다.

```text
감으로 판단하지 않기
↓
수치 확인하기
↓
로그 확인하기
↓
명령어 출력 저장하기
↓
환경변수 하나씩만 바꾸기
↓
Before & After 비교하기
↓
리포트로 정리하기
```
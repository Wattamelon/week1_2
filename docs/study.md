# 리눅스 프로세스 및 시스템 리소스 트러블슈팅 정리

# 프로세스(Process)

프로세스(Process)는 실행 중인 프로그램이다.

예를 들어:
- 크롬 실행
- 파이썬 실행
- Node.js 서버 실행

모두 프로세스로 동작한다.

운영체제는 각 프로세스에:
- PID(Process ID)
- 메모리
- CPU 시간
- 파일 접근 권한

등을 할당한다.

관련 명령어:

```bash
ps -ef
```

현재 실행 중인 프로세스 확인

```bash
ps -ef | grep python
```

특정 프로세스 검색

```bash
top
```

실시간 프로세스 상태 확인

---

# 스레드(Thread)

스레드는 프로세스 내부의 작업 실행 단위다.

프로세스:
- 하나의 실행 공간

스레드:
- 그 안에서 실제 작업 수행

예시:
- 게임 프로세스
  - 렌더링 스레드
  - 입력 처리 스레드
  - 사운드 스레드

멀티스레드:
- 여러 작업을 동시에 수행 가능
- 하지만 동기화 문제가 발생할 수 있음

관련 명령어:

```bash
top -H
```

스레드 단위 확인

```bash
ps -L
```

프로세스 내부 스레드 확인

---

# PID(Process ID)

PID는 프로세스 고유 번호다.

예시:

```bash
ps -ef
```

출력:

```bash
user   12345  ...
```

여기서:
- 12345 = PID

프로세스를 종료할 때 사용:

```bash
kill 12345
```

강제 종료:

```bash
kill -9 12345
```

---

# 시그널(Signal)

시그널은 운영체제가 프로세스에게 보내는 메시지다.

대표 시그널:

| 시그널 | 의미 |
|---|---|
| SIGTERM | 정상 종료 요청 |
| SIGKILL | 강제 종료 |
| SIGINT | Ctrl + C |
| SIGHUP | 설정 재로드 |

예시:

```bash
kill -15 PID
```

SIGTERM

```bash
kill -9 PID
```

SIGKILL

---

# 메모리 구조

프로세스 메모리는 크게:

- Code 영역
- Data 영역
- Heap 영역
- Stack 영역

으로 구성된다.

## Stack

함수 호출 시 사용된다.

특징:
- 자동 관리
- 함수 종료 시 자동 반환

## Heap

동적 메모리 영역

특징:
- 직접 해제 필요
- 해제 안 하면 메모리 누수 발생

Python도 내부적으로 Heap을 사용한다.

---

# Memory Leak

메모리 누수(Memory Leak)는:

사용하지 않는 메모리를 해제하지 않는 현상

이다.

결과:
- 메모리 사용량 계속 증가
- 시스템 느려짐
- OOM 발생 가능

미션에서:
- monitor.sh 로 메모리 증가 관찰
- MEMORY_LIMIT 도달 시 종료

---

# OOM(Out Of Memory)

시스템 메모리가 부족한 상태

결과:
- 프로세스 종료
- 시스템 불안정

Linux에서는:
- OOM Killer
- MemoryGuard

같은 보호 정책이 동작할 수 있다.

---

# CPU 사용률(CPU Usage)

CPU 사용률은:
프로세스가 CPU를 얼마나 사용하는지 나타낸다.

문제 상황:
- 특정 프로세스가 CPU 독점
- 시스템 전체 느려짐

관련 명령어:

```bash
top
```

```bash
htop
```

```bash
ps -eo pid,cmd,%cpu --sort=-%cpu
```

CPU 사용률 높은 순 정렬

---

# CPU Spike

CPU Spike:
짧은 시간 동안 CPU 사용률이 급격히 증가하는 현상

원인:
- 무한루프
- 과도한 연산
- 멀티스레드 경쟁
- 잘못된 로직

결과:
- 응답 지연
- Watchdog 종료

---

# Watchdog

Watchdog은:
시스템 보호용 감시 기능

특정 조건:
- CPU 과점유
- 무응답
- 메모리 초과

등이 발생하면 프로세스를 종료한다.

실무에서도:
- 서버 감시
- 임베디드 시스템
- 컨테이너 관리

등에서 자주 사용된다.

---

# Deadlock(교착상태)

Deadlock:
서로 자원을 기다리며 무한 대기하는 상태

특징:
- 프로세스 안 죽음
- CPU 거의 안 씀
- 로그 멈춤
- 응답 없음

---

# Deadlock 4대 조건

## Mutual Exclusion(상호 배제)

한 번에 하나만 자원 사용 가능

## Hold and Wait(점유 대기)

자원 가진 상태로 다른 자원 기다림

## No Preemption(비선점)

강제로 자원 회수 불가능

## Circular Wait(순환 대기)

서로 상대 자원 기다림

4개 모두 만족 시 Deadlock 발생 가능

---

# Dining Philosophers Problem

Deadlock 대표 예제

철학자들이:
- 왼쪽 포크
- 오른쪽 포크

를 서로 기다리며 멈추는 문제

운영체제 동기화 문제 설명에 자주 사용됨

---

# 락(Lock)

멀티스레드 환경에서:
공유 자원을 동시에 수정하지 못하도록 막는 장치

문제:
- 락 순서 꼬임
- 락 해제 누락

→ Deadlock 발생 가능

---

# 환경변수(Environment Variable)

프로그램 실행 환경 설정 값

예시:

```bash
export MEMORY_LIMIT=256
```

```bash
export CPU_MAX_OCCUPY=80
```

```bash
export MULTI_THREAD_ENABLE=true
```

환경변수 확인:

```bash
echo $MEMORY_LIMIT
```

---

# 로그(Log)

프로그램 동작 기록

분석 시 중요:
- 에러 메시지
- 종료 시점
- 마지막 실행 위치
- 경고 메시지

관련 명령어:

```bash
cat app.log
```

```bash
tail -f app.log
```

```bash
grep ERROR app.log
```

---

# 관제(Monitoring)

시스템 상태를 지속적으로 관찰하는 것

관찰 대상:
- CPU
- Memory
- Disk
- Network
- Process

미션에서는:
- monitor.sh 사용

---

# top 명령어

실시간 시스템 상태 확인

확인 가능:
- CPU
- 메모리
- 프로세스 상태

실행:

```bash
top
```

종료:
- q

---

# htop

top 개선 버전

장점:
- UI 보기 편함
- 마우스 사용 가능
- 색상 지원

설치:

```bash
sudo apt install htop
```

실행:

```bash
htop
```

---

# ps 명령어

프로세스 목록 출력

```bash
ps -ef
```

전체 프로세스 출력

```bash
ps -ef | grep agent
```

특정 프로세스 검색

---

# grep

문자열 검색 명령어

예시:

```bash
grep ERROR app.log
```

ERROR 포함 줄 검색

---

# tail

파일 마지막 출력

```bash
tail app.log
```

실시간 로그 추적:

```bash
tail -f app.log
```

---

# pstree

프로세스 트리 구조 출력

```bash
pstree
```

부모-자식 프로세스 관계 확인 가능

---

# kill

프로세스 종료

```bash
kill PID
```

정상 종료 요청

```bash
kill -9 PID
```

강제 종료

---

# Before & After 분석

조치 전/후 비교 분석

예시:
- MEMORY_LIMIT 변경 전
- MEMORY_LIMIT 변경 후

비교 대상:
- 생존 시간
- CPU 사용률
- 메모리 사용량
- 종료 여부

---

# Root Cause Analysis(RCA)

근본 원인 분석

단순히:
- "프로그램 죽음"

이 아니라:

- 왜 죽었는가
- 어떤 조건에서 발생했는가
- 어떤 정책이 동작했는가

를 분석해야 한다.

---

# GitHub Issue 형태 보고서

실무 장애 보고서 스타일

구조:

## Description
현상 설명

## Evidence & Logs
증거 자료

## Root Cause Analysis
원인 분석

## Workaround & Verification
조치 및 검증

---

# 스케줄링(Scheduling)

운영체제가:
어떤 프로세스에게 CPU를 줄지 결정하는 것

대표 알고리즘:
- FCFS
- Round Robin
- Priority Scheduling

---

# FCFS(First Come First Served)

먼저 온 작업부터 처리

장점:
- 단순함

단점:
- 긴 작업이 CPU 독점 가능

---

# Round Robin

각 프로세스에게 일정 시간씩 CPU 분배

특징:
- 공평함
- 멀티태스킹에 적합

현대 운영체제에서 많이 사용

---

# Priority Scheduling

우선순위 높은 작업 먼저 처리

문제:
- 낮은 우선순위 작업 기아 현상 가능

---

# 리눅스 파일 권한

권한:
- 읽기(r)
- 쓰기(w)
- 실행(x)

확인:

```bash
ls -l
```

권한 변경:

```bash
chmod +x monitor.sh
```

---

# 포트(Port)

네트워크 통신 창구

예시:
- 80 → HTTP
- 443 → HTTPS
- 15034 → agent 앱 사용 포트

포트 사용 확인:

```bash
lsof -i :15034
```

---

# Docker와의 연관성

Docker 컨테이너 내부에서도:
- 프로세스
- 메모리
- CPU
- PID

개념 동일

Docker에서도:
- 메모리 제한
- CPU 제한
- 프로세스 모니터링

중요하게 사용됨

---

# 실무 관점 핵심 흐름

실무 장애 분석 흐름:

1. 현상 확인
2. 로그 수집
3. 관제 데이터 확인
4. 원인 추론
5. 환경 조정
6. 재실행
7. Before & After 비교
8. 기술 리포트 작성

---

# 이 미션의 핵심 학습 목표

- 운영체제 이론을 실무와 연결
- 리눅스 관제 능력 향상
- 장애 분석 능력 습득
- 로그 기반 문제 해결
- 프로세스/스레드 이해
- 메모리/CPU 문제 분석
- Deadlock 이해
- GitHub Issue 문서화 능력 향상
좋음. **지금 올린 Jenkins 배포 행동강령 + Tomcat/Jenkins/React 실행 확인 문서**를 하나로 합쳐서, 시험장에서 **진짜 위에서 아래로만 따라가면 되게** 재정렬해놨음.

# AWS EC2 + Jenkins + Tomcat + React 배포 시험 최종 행동강령

> 전제
> EC2 / JDK / Maven / Tomcat / Jenkins가 이미 설치되어 있음
> Spring Boot는 WAR → Tomcat 배포
> React는 Vite 기반
> 시험 중 AI 사용 불가 / 오픈북 가능

---

# 0. 제일 먼저 알아둘 포트

```text
22
= SSH

5173
= React

7070
= Jenkins

8080
= Spring Boot / Tomcat
```

구조:

```text
내 브라우저
│
├─ http://EC2_IP:5173
│      ↓
│    React
│
├─ http://EC2_IP:7070
│      ↓
│    Jenkins
│
└─ http://EC2_IP:8080
       ↓
     Tomcat
       ↓
     Spring Boot
```

---

# 1. 시험 시작하자마자 적어놓을 것

시험 문제를 보고 아래부터 채운다.

```text
EC2 공인 IP = __________________________

키 파일 위치 = _________________________

GitHub 백엔드 Repository URL = _________________________

GitHub 프론트 Repository URL = _________________________

배포 Branch = main / ___________________

백엔드 프로젝트 폴더 = semprj / ___________________

pom.xml 위치 = semprj/pom.xml / ___________________

WAR 파일명 = semiprj-1.0.0.war / ___________________

실제 확인할 API 주소 = /api/test / ___________________

React 프로젝트 위치 = _______________________________
```

문서 기준 백엔드 예시:

```text
Repository
https://github.com/hiphop5782/kh17-semi-be.git

Branch
main

Root POM
semprj/pom.xml

WAR
semprj/target/semiprj-1.0.0.war
```

**시험 프로젝트 이름이 다르면 semprj 같은 이름을 무지성 복붙하지 않는다.**

---

# 2. EC2 접속

## 프로그램

Windows PowerShell 또는 터미널

```bash
ssh -i [키파일경로] ubuntu@[EC2공인IP]
```

예:

```bash
ssh -i D:\webserver-cicd-key.pem ubuntu@15.164.234.38
```

접속 확인:

```bash
whoami
```

정상:

```text
ubuntu
```

---

# 3. 시험 시작 시 Tomcat / Jenkins부터 살린다

## Tomcat 시작

```bash
sudo systemctl start tomcat
```

상태:

```bash
sudo systemctl status tomcat
```

정상:

```text
active (running)
```

상태 화면 종료:

```text
q
```

---

## Jenkins 시작

```bash
sudo systemctl start jenkins
```

상태:

```bash
sudo systemctl status jenkins
```

정상:

```text
active (running)
```

---

# 4. Tomcat / Jenkins 포트 확인

```bash
sudo ss -lntp | grep -E ':7070|:8080'
```

정상적으로:

```text
7070
8080
```

이 LISTEN 상태로 보여야 한다.

개별 확인:

```bash
sudo ss -lntp | grep 7070
```

```bash
sudo ss -lntp | grep 8080
```

---

# 5. Tomcat 명령어 모음

## 시작

```bash
sudo systemctl start tomcat
```

## 종료

```bash
sudo systemctl stop tomcat
```

## 재시작

```bash
sudo systemctl restart tomcat
```

## 상태

```bash
sudo systemctl status tomcat
```

## 부팅 시 자동 실행

```bash
sudo systemctl enable tomcat
```

## 자동 실행 여부

```bash
sudo systemctl is-enabled tomcat
```

## 로그 최근 100줄

```bash
sudo tail -n 100 /opt/tomcat/logs/catalina.out
```

## 실시간 로그

```bash
sudo tail -f /opt/tomcat/logs/catalina.out
```

종료:

```text
Ctrl + C
```

---

# 6. Jenkins 명령어 모음

## 시작

```bash
sudo systemctl start jenkins
```

## 종료

```bash
sudo systemctl stop jenkins
```

## 재시작

```bash
sudo systemctl restart jenkins
```

## 상태

```bash
sudo systemctl status jenkins
```

## 부팅 시 자동 실행

```bash
sudo systemctl enable jenkins
```

## 포트

```bash
sudo ss -lntp | grep 7070
```

## 로그

```bash
sudo journalctl -u jenkins -n 100 --no-pager
```

## 실시간 로그

```bash
sudo journalctl -u jenkins -f
```

종료:

```text
Ctrl + C
```

설정파일 수정 후:

```bash
sudo systemctl daemon-reload
sudo systemctl restart jenkins
```

---

# 7. Jenkins 웹 접속

## 프로그램

웹 브라우저

```text
http://EC2공인IP:7070
```

예:

```text
http://15.164.234.38:7070
```

Jenkins 로그인.

---

# 8. Jenkins 프로젝트 생성

Jenkins 메인:

```text
새 Item
```

이름 예:

```text
semiprj-deploy
```

선택:

```text
Freestyle project
```

클릭:

```text
OK
```

---

# 9. GitHub 백엔드 Repository 연결

Jenkins:

```text
프로젝트
→ 구성
→ 소스 코드 관리
→ Git
```

Repository URL:

```text
시험에서 주어진 GitHub 백엔드 Repository URL
```

예:

```text
https://github.com/hiphop5782/kh17-semi-be.git
```

Branch Specifier:

```text
*/main
```

develop이면:

```text
*/develop
```

**push하는 브랜치와 반드시 일치시킨다.**

---

# 10. pom.xml 위치 확인

문서 프로젝트:

```text
kh17-semi-be/
 └─ semprj/
     └─ pom.xml
```

따라서:

```text
Root POM
semprj/pom.xml
```

Repository 최상단에 pom.xml이 있다면 구조가 다르므로 실제 구조를 따른다.

---

# 11. application.properties 문제 확인

GitHub에 `application.properties`가 없으면 Jenkins는 DB 설정을 모를 수 있다.

대표 오류:

```text
Failed to configure a DataSource

'url' attribute is not specified

Failed to determine a suitable driver class
```

이 경우 Spring Boot가 시작되지 않는다.

Tomcat만 실행되고:

```text
404
```

가 뜰 수도 있다.

---

# 12. Jenkins용 application.properties 만들기

## 위치

EC2 SSH

```bash
sudo mkdir -p /var/lib/jenkins/config/semprj
```

편집:

```bash
sudo nano /var/lib/jenkins/config/semprj/application.properties
```

---

# 13. application.properties 작성

예:

```properties
spring.datasource.driver-class-name=oracle.jdbc.OracleDriver
spring.datasource.url=jdbc:oracle:thin:@DB_HOST:1521:xe
spring.datasource.username=DB_USERNAME
spring.datasource.password=DB_PASSWORD

server.servlet.session.timeout=30m

spring.mvc.view.prefix=/WEB-INF/views/
spring.mvc.view.suffix=.jsp

spring.servlet.multipart.enabled=true
spring.servlet.multipart.max-file-size=1MB
spring.servlet.multipart.max-request-size=10MB

custom.email.host=smtp.gmail.com
custom.email.port=587
custom.email.username=MAIL_USERNAME
custom.email.password=MAIL_APP_PASSWORD
```

**시험에서 제공한 실제 DB 정보로 수정한다.**

nano 저장:

```text
Ctrl + O
Enter
Ctrl + X
```

---

# 14. application.properties 권한 설정

```bash
sudo chown -R jenkins:jenkins /var/lib/jenkins/config
```

```bash
sudo chmod 700 /var/lib/jenkins/config/semprj
```

```bash
sudo chmod 600 /var/lib/jenkins/config/semprj/application.properties
```

Jenkins가 읽을 수 있는지:

```bash
sudo -u jenkins test -r /var/lib/jenkins/config/semprj/application.properties
```

확인:

```bash
sudo -u jenkins ls -l /var/lib/jenkins/config/semprj/application.properties
```

주의:

비밀번호가 들어 있으므로 Jenkins Console에:

```bash
cat application.properties
```

이딴 짓은 하지 않는다.

---

# 15. Jenkins Build Step 1

목표:

```text
서버에 보관한 application.properties
↓
Jenkins Workspace
↓
Spring 프로젝트 resources
```

Jenkins:

```text
프로젝트
→ 구성
→ Build Steps
→ Add build step
→ Execute shell
```

입력:

```bash
#!/bin/bash
set -euo pipefail

CONFIG_FILE="/var/lib/jenkins/config/semprj/application.properties"
TARGET_FILE="${WORKSPACE}/semprj/src/main/resources/application.properties"

echo "1. 외부 설정 파일 확인"
test -r "$CONFIG_FILE"

echo "2. 프로젝트 리소스 폴더 확인"
mkdir -p "$(dirname "$TARGET_FILE")"

echo "3. application.properties 복사"
install -m 600 "$CONFIG_FILE" "$TARGET_FILE"

echo "4. 복사 결과 확인"
test -f "$TARGET_FILE"
```

중요:

```text
${WORKSPACE}
```

는 Jenkins가 GitHub 코드를 내려받은 작업공간.

프로젝트 이름이 semprj가 아니면:

```text
${WORKSPACE}/semprj/...
```

부분을 실제 프로젝트명으로 바꾼다.

---

# 16. Jenkins Build Step 2 - Maven Build

Jenkins:

```text
Build Steps
→ Add build step
→ Invoke top-level Maven targets
```

Advanced 열기.

Root POM:

```text
semprj/pom.xml
```

Goals:

```text
clean package -DskipTests
```

의미:

```text
clean
→ 기존 빌드 결과 삭제

package
→ Maven 빌드 + WAR 생성

-DskipTests
→ 테스트 실행 생략
```

---

# 17. WAR 위치 확인

문서 기준:

```text
${WORKSPACE}/semprj/target/semiprj-1.0.0.war
```

WAR 내부에 properties가 있는지:

```bash
jar tf semprj/target/semiprj-1.0.0.war | grep 'WEB-INF/classes/application.properties'
```

정상:

```text
WEB-INF/classes/application.properties
```

안 나오면 배포하지 말고 설정파일 복사 단계부터 확인.

---

# 18. Jenkins Build Step 3 - Tomcat 배포

Jenkins:

```text
프로젝트
→ 구성
→ Build Steps
→ Add build step
→ Execute shell
```

**반드시 Maven Build 아래에 둔다.**

최종 Build Step 순서:

```text
1. Execute shell
   → application.properties 복사

2. Invoke top-level Maven targets
   → Maven build

3. Execute shell
   → Tomcat 배포
```

---

# 19. Tomcat 배포 스크립트

```bash
#!/bin/bash
set -euo pipefail

WAR_FILE="${WORKSPACE}/semprj/target/semiprj-1.0.0.war"
TOMCAT_HOME="/opt/tomcat"
TOMCAT_PATTERN="org.apache.catalina.startup.Bootstrap"

echo "1. WAR 파일 확인"
test -f "$WAR_FILE"
ls -lh "$WAR_FILE"

echo "2. WAR 내부 필수 파일 확인"
jar tf "$WAR_FILE" | grep -q 'WEB-INF/classes/application.properties'
jar tf "$WAR_FILE" | grep -q 'Controller.class'

echo "3. Tomcat 중지"
sudo systemctl stop tomcat

echo "4. Tomcat 프로세스 종료 대기"
for i in {1..20}; do
    if ! pgrep -f "$TOMCAT_PATTERN" > /dev/null; then
        echo "Tomcat 프로세스 종료 확인"
        break
    fi

    echo "Tomcat 종료 대기: ${i}/20"
    sleep 1
done

echo "5. 잔여 Tomcat 프로세스 처리"
if pgrep -f "$TOMCAT_PATTERN" > /dev/null; then
    sudo pkill -f "$TOMCAT_PATTERN"
    sleep 3
fi

echo "6. 포트 반환 확인"
if sudo ss -lntp | grep -Eq ':8080|:8005'; then
    echo "8080 또는 8005 포트가 아직 사용 중"
    sudo ss -lntp | grep -E ':8080|:8005'
    exit 1
fi

echo "7. 기존 ROOT 제거"
sudo rm -rf "$TOMCAT_HOME/webapps/ROOT"
sudo rm -f "$TOMCAT_HOME/webapps/ROOT.war"
sudo rm -rf "$TOMCAT_HOME/work/Catalina/localhost/ROOT"
sudo rm -rf "$TOMCAT_HOME/temp/"*

echo "8. 작업 디렉터리 생성 및 권한 복구"
sudo mkdir -p "$TOMCAT_HOME/work/Catalina/localhost"
sudo chown -R tomcat:tomcat "$TOMCAT_HOME/work"
sudo chown -R tomcat:tomcat "$TOMCAT_HOME/temp"

echo "9. 새 WAR 배포"
sudo install \
    -o tomcat \
    -g tomcat \
    -m 640 \
    "$WAR_FILE" \
    "$TOMCAT_HOME/webapps/ROOT.war"

echo "10. Tomcat 시작"
sudo systemctl start tomcat

echo "11. 애플리케이션 기동 대기"
for i in {1..30}; do
    if curl -fsS http://localhost:8080/ > /dev/null; then
        echo "HTTP 응답 확인"
        break
    fi

    echo "기동 대기: ${i}/30"
    sleep 1
done

echo "12. 최종 서비스 상태 확인"
sudo systemctl is-active --quiet tomcat

echo "13. 포트 확인"
sudo ss -lntp | grep -E ':8080|:8005'

echo "14. 최근 로그 확인"
sudo tail -n 100 "$TOMCAT_HOME/logs/catalina.out"

echo "15. 배포 완료"
```

---

# 20. 배포 확인 주소 수정

프로젝트 `/`가 404인 경우:

```bash
curl -fsS http://localhost:8080/
```

로 검사하면 실패할 수 있다.

실제 존재하는 GET API로 수정.

예:

```java
@GetMapping("/api/test")
```

가 있다면:

```bash
curl -fsS http://localhost:8080/api/test
```

---

# 21. Jenkins 저장

Jenkins:

```text
프로젝트
→ 구성
```

Build Step 순서를 다시 본다.

```text
1. properties 복사
2. Maven
3. Tomcat 배포
```

그리고:

```text
저장
```

---

# 22. 첫 백엔드 배포

Jenkins 프로젝트:

```text
Build Now
```

Build History:

```text
#1
```

클릭.

```text
Console Output
```

확인.

정상 흐름:

```text
application.properties 확인
↓
application.properties 복사
↓
Maven BUILD SUCCESS
↓
WAR 확인
↓
Tomcat 중지
↓
기존 ROOT 삭제
↓
새 WAR 배포
↓
Tomcat 시작
↓
HTTP 응답 확인
↓
배포 완료
```

최종:

```text
Finished: SUCCESS
```

---

# 23. 백엔드 배포 성공 확인

## EC2 SSH

Tomcat:

```bash
sudo systemctl status tomcat
```

WAR:

```bash
sudo ls -lh /opt/tomcat/webapps/ROOT.war
```

ROOT:

```bash
sudo find /opt/tomcat/webapps/ROOT -maxdepth 2 -type d | head
```

프로세스:

```bash
pgrep -af 'org.apache.catalina.startup.Bootstrap'
```

포트:

```bash
sudo ss -lntp | grep -E ':8080|:8005'
```

API:

```bash
curl -i http://localhost:8080/실제_API
```

예:

```bash
curl -i http://localhost:8080/api/test
```

---

# 24. 내 PC 브라우저에서 백엔드 확인

```text
http://EC2_PUBLIC_IP:8080/실제_API
```

예:

```text
http://15.164.234.38:8080/api/test
```

---

# =========================

# React 프론트엔드 배포

# =========================

# 25. React 배포 전에 제일 먼저 할 것

React가 백엔드 API를 어디로 호출하는지 확인한다.

로컬 개발에서는 보통:

```javascript
baseURL: "http://localhost:8080/api"
```

로 되어 있을 수 있다.

EC2 배포 상태에서 사용자 브라우저가 이것을 호출하면:

```text
localhost
```

는 **EC2가 아니라 사용자 PC 자신**이다.

따라서 배포용 주소는:

```javascript
baseURL: "http://EC2공인IP:8080/api"
```

예:

```javascript
baseURL: "http://15.164.234.38:8080/api"
```

형태가 되어야 한다.

환경변수를 쓰는 프로젝트라면 그 프로젝트 방식에 맞춘다.

---

# 26. Spring CORS 확인

React:

```text
http://EC2_IP:5173
```

Spring:

```text
http://EC2_IP:8080
```

으로 서로 포트가 다르므로 Origin이 다르다.

Spring Security CORS 설정이 기존에:

```text
http://localhost:5173
```

만 허용되어 있다면 배포 주소도 허용해야 한다.

예:

```text
http://15.164.234.38:5173
```

시험에서 사용하는 실제 EC2 IP로 설정한다.

CORS 수정 후에는 백엔드를 다시 빌드/배포해야 한다.

---

# 27. AWS 보안그룹에서 React 포트 확인

AWS 콘솔:

```text
EC2
→ 인스턴스
→ 해당 인스턴스
→ Security
→ Security groups
→ Inbound rules
```

시험용 React 접근을 위해:

```text
5173 TCP
```

접근 가능해야 한다.

백엔드:

```text
8080
```

Jenkins:

```text
7070
```

도 필요한 범위에 맞게 설정되어 있어야 한다.

---

# 28. Node / npm 설치 여부 확인

## EC2 SSH

```bash
node -v
```

```bash
npm -v
```

버전이 나오면 설치된 상태.

만약:

```text
command not found
```

이면 Node/npm이 설치되어 있지 않은 것.

---

# 29. React 프로젝트 EC2에 가져오기

프론트 Repository를 EC2에서 clone하는 방식이라면 예:

```bash
cd /home/ubuntu
```

```bash
git clone [프론트 GitHub Repository URL] frontend
```

예:

```bash
git clone https://github.com/사용자/프로젝트-fe.git frontend
```

프로젝트 이동:

```bash
cd /home/ubuntu/frontend
```

이미 clone 되어 있으면 clone 다시 하지 않는다.

---

# 30. 이미 React 프로젝트가 있으면 최신 코드 받기

```bash
cd /home/ubuntu/frontend
```

```bash
git pull
```

필요한 브랜치라면:

```bash
git checkout main
```

그리고:

```bash
git pull
```

---

# 31. React 패키지 설치

```bash
cd /home/ubuntu/frontend
```

```bash
npm install
```

`package.json`을 보고 필요한 라이브러리를 설치한다.

---

# 32. React 빌드

```bash
npm run build
```

정상적으로 끝나면 Vite 기준 보통:

```text
dist/
```

폴더가 만들어진다.

확인:

```bash
ls -al
```

또는:

```bash
ls -al dist
```

---

# 33. React 실행

현재 시험용 방식은 Vite Preview를 5173에 띄우는 방식.

```bash
nohup npm run preview -- --host 0.0.0.0 --port 5173 --strictPort > /home/ubuntu/react-preview.log 2>&1 &
```

의미:

```text
nohup
→ SSH 연결이 끊겨도 프로세스를 계속 실행

npm run preview
→ 빌드한 React 화면 실행

--host 0.0.0.0
→ EC2 외부에서도 접근 가능

--port 5173
→ 5173 포트 사용

--strictPort
→ 5173을 못 쓰면 멋대로 다른 포트로 넘어가지 않고 실패

> react-preview.log
→ 실행 로그 파일 저장

2>&1
→ 에러 로그도 같은 파일에 저장

&
→ 백그라운드 실행
```

---

# 34. React 실행 확인

포트:

```bash
sudo ss -lntp | grep 5173
```

HTTP:

```bash
curl -I http://localhost:5173
```

프로세스:

```bash
ps -ef | grep vite
```

로그:

```bash
tail -n 100 /home/ubuntu/react-preview.log
```

실시간 로그:

```bash
tail -f /home/ubuntu/react-preview.log
```

종료:

```text
Ctrl + C
```

---

# 35. React 브라우저 확인

내 PC 브라우저:

```text
http://EC2_PUBLIC_IP:5173
```

예:

```text
http://15.164.234.38:5173
```

React 화면이 나오면 성공.

---

# 36. React 화면은 나오는데 API가 안 될 때

브라우저 개발자 도구:

```text
F12
→ Network
```

API 요청 주소 확인.

만약:

```text
http://localhost:8080/...
```

로 호출되고 있으면 배포 설정이 잘못된 것.

배포에서는:

```text
http://EC2_IP:8080/...
```

이어야 한다.

---

# 37. React에서 CORS 오류가 뜰 때

브라우저 Console에:

```text
CORS
Access-Control-Allow-Origin
blocked by CORS policy
```

같은 내용이 나오면 Spring의 CORS 허용 주소 확인.

React 주소:

```text
http://EC2_IP:5173
```

를 Spring이 허용해야 한다.

Spring 수정:

```text
↓
Git push
↓
Jenkins Build
↓
Tomcat 재배포
```

순서로 반영한다.

---

# 38. React 끄기

```bash
pkill -f 'vite.*preview'
```

확인:

```bash
sudo ss -lntp | grep 5173
```

아무것도 안 나오면 종료.

---

# 39. React 다시 켜기

```bash
cd /home/ubuntu/frontend
```

```bash
nohup npm run preview -- --host 0.0.0.0 --port 5173 --strictPort > /home/ubuntu/react-preview.log 2>&1 &
```

확인:

```bash
sudo ss -lntp | grep 5173
```

---

# 40. 프론트 코드 수정 후 다시 배포

```bash
cd /home/ubuntu/frontend
```

최신 코드:

```bash
git pull
```

기존 React preview 종료:

```bash
pkill -f 'vite.*preview'
```

다시 빌드:

```bash
npm install
```

```bash
npm run build
```

다시 실행:

```bash
nohup npm run preview -- --host 0.0.0.0 --port 5173 --strictPort > /home/ubuntu/react-preview.log 2>&1 &
```

확인:

```bash
sudo ss -lntp | grep 5173
```

---

# =========================

# GitHub Webhook

# =========================

# 41. Webhook이 필요한 경우

Webhook:

```text
GitHub push
↓
GitHub가 Jenkins 호출
↓
Jenkins 자동 Build
↓
Maven
↓
WAR
↓
Tomcat 자동 재배포
```

즉 사람이 매번:

```text
Build Now
```

를 안 눌러도 된다.

---

# 42. Jenkins Webhook Trigger

Jenkins:

```text
프로젝트
→ 구성
→ Build Triggers
```

체크:

```text
GitHub hook trigger for GITScm polling
```

그리고:

```text
소스 코드 관리
→ Git
→ Branch Specifier
```

확인:

```text
*/main
```

push 브랜치와 일치해야 한다.

---

# 43. GitHub Webhook 추가

GitHub:

```text
Repository
→ Settings
→ Webhooks
→ Add webhook
```

Payload URL:

```text
http://EC2_PUBLIC_IP:7070/github-webhook/
```

Content type:

```text
application/json
```

현재 시험용 HTTP 환경이면 문서 기준:

```text
SSL verification
→ Disable
```

이벤트:

```text
Just the push event
```

Active:

```text
체크
```

저장.

---

# 44. Webhook 테스트

로컬 IDE:

```bash
git add .
```

```bash
git commit -m "deploy test"
```

```bash
git push
```

Jenkins:

```text
프로젝트
→ Build History
```

새 빌드가 자동 생성되는지 확인.

---

# 45. GitHub에서 Webhook 확인

GitHub:

```text
Repository
→ Settings
→ Webhooks
→ 등록한 Webhook
→ Recent Deliveries
```

정상:

```text
200
```

---

# =========================

# 오류 해결

# =========================

# 46. Jenkins BUILD FAILURE

Jenkins:

```text
프로젝트
→ Build History
→ 실패한 빌드
→ Console Output
```

맨 마지막 줄만 보지 말고 **조금 위쪽 최초 오류**를 찾는다.

---

# 47. there is no POM

```text
there is no POM in this directory
```

원인:

```text
pom.xml 경로 잘못 지정
```

Jenkins:

```text
프로젝트
→ 구성
→ Maven Build Step
→ Root POM
```

확인.

예:

```text
semprj/pom.xml
```

---

# 48. DataSource 오류

```text
Failed to configure a DataSource
'url' attribute is not specified
```

확인:

```bash
sudo -u jenkins test -r /var/lib/jenkins/config/semprj/application.properties
```

Jenkins Workspace:

```bash
test -f "${WORKSPACE}/semprj/src/main/resources/application.properties"
```

WAR:

```bash
jar tf "${WORKSPACE}/semprj/target/semiprj-1.0.0.war" \
  | grep 'WEB-INF/classes/application.properties'
```

---

# 49. 백엔드 404

순서대로:

```bash
sudo systemctl status tomcat
```

```bash
sudo ss -lntp | grep 8080
```

```bash
sudo tail -n 100 /opt/tomcat/logs/catalina.out
```

```bash
sudo ls -lh /opt/tomcat/webapps/ROOT.war
```

실제 API:

```bash
curl -i http://localhost:8080/실제_API
```

**`/`가 없는 프로젝트에서 `localhost:8080/`가 404인 건 정상일 수도 있다.**

---

# 50. Address already in use

```text
java.net.BindException:
Address already in use
```

기존 Tomcat이 안 죽었을 가능성.

```bash
sudo systemctl stop tomcat
```

```bash
pgrep -af 'org.apache.catalina.startup.Bootstrap'
```

```bash
sudo ss -lntp | grep -E ':8080|:8005' || true
```

남아 있으면:

```bash
sudo pkill -f 'org.apache.catalina.startup.Bootstrap' || true
```

```bash
sleep 3
```

다시:

```bash
pgrep -af 'org.apache.catalina.startup.Bootstrap' || true
```

```bash
sudo ss -lntp | grep -E ':8080|:8005' || true
```

깨끗해지면:

```bash
sudo systemctl start tomcat
```

---

# 51. NoSuchFileException

예:

```text
NoSuchFileException:
/opt/tomcat/webapps/ROOT/WEB-INF/lib/...
```

정리:

```bash
sudo systemctl stop tomcat
```

Tomcat 완전 종료 확인 후:

```bash
sudo rm -rf /opt/tomcat/work/Catalina/localhost/ROOT
```

```bash
sudo rm -rf /opt/tomcat/temp/*
```

```bash
sudo mkdir -p /opt/tomcat/work/Catalina/localhost
```

```bash
sudo chown -R tomcat:tomcat /opt/tomcat/work
```

```bash
sudo chown -R tomcat:tomcat /opt/tomcat/temp
```

그 후 다시 Jenkins 배포.

---

# 52. Jenkins가 안 켜질 때

```bash
sudo systemctl status jenkins
```

```bash
sudo journalctl -u jenkins -n 100 --no-pager
```

필요 시:

```bash
sudo systemctl daemon-reload
sudo systemctl restart jenkins
```

---

# 53. Tomcat이 안 켜질 때

```bash
sudo systemctl status tomcat
```

```bash
sudo tail -n 100 /opt/tomcat/logs/catalina.out
```

```bash
sudo ss -lntp | grep -E ':8080|:8005'
```

```bash
pgrep -af 'org.apache.catalina.startup.Bootstrap'
```

---

# 54. React가 안 켜질 때

포트:

```bash
sudo ss -lntp | grep 5173
```

로그:

```bash
tail -n 100 /home/ubuntu/react-preview.log
```

프로세스:

```bash
ps -ef | grep vite
```

다시:

```bash
cd /home/ubuntu/frontend
```

```bash
npm run build
```

```bash
nohup npm run preview -- --host 0.0.0.0 --port 5173 --strictPort > /home/ubuntu/react-preview.log 2>&1 &
```

---

# 55. React Connection refused

확인:

```bash
sudo ss -lntp | grep 5173
```

안 나오면 React가 안 켜져 있음.

나오는데 외부에서 안 되면:

```text
AWS Security Group
→ 5173 확인
```

---

# 56. React 화면은 뜨는데 데이터가 안 나옴

이 순서:

```text
F12
↓
Network
↓
실패한 API 클릭
↓
Request URL 확인
```

`localhost:8080`이면 API 주소 수정.

`EC2_IP:8080`인데 CORS면 Spring CORS 수정.

500이면 Spring 로그:

```bash
sudo tail -n 100 /opt/tomcat/logs/catalina.out
```

401/403이면:

```text
Spring Security / JWT / 권한 문제
```

404이면:

```text
API 주소 / Controller Mapping 확인
```

---

# =========================

# 시험 시작 / 종료용 초단축

# =========================

# 57. 시험 시작 시 진짜 이것부터

EC2 접속:

```bash
ssh -i [키파일경로] ubuntu@[EC2_IP]
```

Tomcat:

```bash
sudo systemctl start tomcat
```

Jenkins:

```bash
sudo systemctl start jenkins
```

상태:

```bash
sudo systemctl status tomcat
```

```bash
sudo systemctl status jenkins
```

포트:

```bash
sudo ss -lntp | grep -E ':7070|:8080'
```

브라우저:

```text
http://EC2_IP:7070
```

---

# 58. 백엔드 배포 최소 순서

```text
Jenkins 접속
↓
Freestyle Project
↓
Git Repository 설정
↓
Branch 설정
↓
Build Step 1
properties 복사
↓
Build Step 2
Maven
clean package -DskipTests
↓
Build Step 3
WAR → Tomcat
↓
저장
↓
Build Now
↓
Console Output
↓
Finished: SUCCESS
```

그다음:

```bash
curl -i http://localhost:8080/실제_API
```

브라우저:

```text
http://EC2_IP:8080/실제_API
```

---

# 59. 프론트 배포 최소 순서

```bash
cd /home/ubuntu/frontend
```

최신 코드:

```bash
git pull
```

설치:

```bash
npm install
```

빌드:

```bash
npm run build
```

기존 React 있으면 종료:

```bash
pkill -f 'vite.*preview' || true
```

실행:

```bash
nohup npm run preview -- --host 0.0.0.0 --port 5173 --strictPort > /home/ubuntu/react-preview.log 2>&1 &
```

확인:

```bash
sudo ss -lntp | grep 5173
```

```bash
curl -I http://localhost:5173
```

브라우저:

```text
http://EC2_IP:5173
```

---

# 60. 마지막 전체 확인

```bash
sudo systemctl status tomcat
```

```bash
sudo systemctl status jenkins
```

```bash
sudo ss -lntp | grep -E ':5173|:7070|:8080'
```

백엔드:

```bash
curl -i http://localhost:8080/실제_API
```

프론트:

```bash
curl -I http://localhost:5173
```

내 PC:

```text
React
http://EC2_IP:5173

Jenkins
http://EC2_IP:7070

Spring
http://EC2_IP:8080/실제_API
```

---

# 61. 시험장에서 문제 터졌을 때 어디로 가는지만 기억

```text
Jenkins 빌드 실패
→ Jenkins Console Output

Maven 오류
→ Jenkins Console Output
→ pom.xml / Root POM

Spring 안 뜸
→ catalina.out

Tomcat 안 뜸
→ systemctl status tomcat

Jenkins 안 뜸
→ systemctl status jenkins
→ journalctl

포트 문제
→ ss

Tomcat 중복 프로세스
→ pgrep

백엔드 HTTP 확인
→ curl :8080

React 실행 문제
→ react-preview.log

React API 연결 문제
→ 브라우저 F12 Network

CORS
→ Spring Security CORS 설정

Webhook
→ GitHub Recent Deliveries
→ Jenkins Trigger

외부 접속 자체 안 됨
→ AWS Security Group
```

---

# 62. 에러별 초단기 판단

```text
there is no POM
→ Root POM 틀림

BUILD FAILURE
→ Maven 오류 위쪽 확인

Failed to configure a DataSource
→ application.properties / DB 설정

404
→ 실제 API 주소 확인
→ Spring 기동 확인

500
→ Spring 서버 내부 오류
→ catalina.out

401
→ 인증 문제

403
→ 권한 문제

Address already in use
→ 기존 Tomcat 프로세스

NoSuchFileException
→ 실행 중 ROOT 삭제 가능성

Connection refused :8080
→ Tomcat 안 켜짐

Connection refused :5173
→ React 안 켜짐

CORS
→ React Origin 허용 안 됨

React 화면은 뜨는데 API 실패
→ F12 Network에서 Request URL부터 확인

Webhook 안 됨
→ GitHub Recent Deliveries
→ 7070
→ Jenkins Trigger
→ Branch
```

---

# 63. 시험 직전 최종 암기

## 백엔드

```text
GitHub
↓
Jenkins
↓
properties 주입
↓
Maven
↓
WAR
↓
Tomcat
↓
8080
```

## 프론트

```text
GitHub
↓
EC2
↓
npm install
↓
npm run build
↓
npm run preview
↓
5173
↓
React
```

## 둘 연결

```text
브라우저
↓
React :5173
↓
Axios / API 요청
↓
Spring :8080
↓
DB
```

---

# 64. 진짜 마지막 10줄

시험장에서 머리 하얘지면 이것만 본다.

```bash
sudo systemctl start tomcat
sudo systemctl start jenkins

sudo ss -lntp | grep -E ':7070|:8080'

# Jenkins 웹 :7070에서 Build Now

curl -i http://localhost:8080/실제_API

cd /home/ubuntu/frontend
npm install
npm run build

pkill -f 'vite.*preview' || true

nohup npm run preview -- --host 0.0.0.0 --port 5173 --strictPort > /home/ubuntu/react-preview.log 2>&1 &

sudo ss -lntp | grep -E ':5173|:7070|:8080'
```

최종 브라우저:

```text
React   → http://EC2_IP:5173
Jenkins → http://EC2_IP:7070
Spring  → http://EC2_IP:8080/실제_API
```

**끝.**

기존 Jenkins 문서의 핵심 설정값도 그대로 살렸다. 예를 들어 Repository/Branch/Root POM/WAR 위치를 먼저 특정하고,  Jenkins에서 **Git 연결 → properties 복사 → Maven → Tomcat 배포** 순서를 유지했다.  

그리고 시험에서 제일 중요한 건 이거임. **백엔드는 Jenkins가 담당하고, React는 현재 문서 기준 별도 프로세스로 띄우는 거다.** 기존 문서도 원래 `Spring Boot WAR → Tomcat 8080`, React는 별개라고 명시돼 있었음. 

이 버전 하나만 복붙해놓는 게 낫다. 앞에서 만든 두 개 따로 들고 있으면 시험 때 오히려 **“이거 어디 문서에 있었지 시발”** 하다가 꼬임.

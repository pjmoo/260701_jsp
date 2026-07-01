# JSTL(JSP Standard Tag Library) 코어 태그의 이해와 적용

이 가이드는 [pom.xml](file:///Users/morgan/Documents/workspace/jsp/pom.xml), [JSTLServlet.java](file:///Users/morgan/Documents/workspace/jsp/src/main/java/com/example/jsp/step4/JSTLServlet.java), [JSTLServlet2.java](file:///Users/morgan/Documents/workspace/jsp/src/main/java/com/example/jsp/step4/JSTLServlet2.java), [jstl.jsp](file:///Users/morgan/Documents/workspace/jsp/src/main/webapp/WEB-INF/step04/jstl.jsp), 그리고 [jstl2.jsp](file:///Users/morgan/Documents/workspace/jsp/src/main/webapp/WEB-INF/step04/jstl2.jsp) 코드를 바탕으로 JSTL의 조건문, 반복문, 보안 제어, URL 경로 자동 빌드 방식을 설명합니다.

---

## 1. 초심자를 위한 비유 🏷️

### 💻 스크립틀릿(자바 지옥) vs JSTL(깔끔한 태그 통역사)
JSP에서 조건문이나 반복문을 돌리기 위해 자바 코드 `<% if (...) { %>`를 사용하는 것은 HTML 태그 사이에 외계어가 섞여 있는 것처럼 지저분하고 괄호(`}`)가 하나만 빠져도 전체 페이지가 깨지는 오류를 발생시킵니다.
*   **스크립틀릿**: `<% if (flag) { %> <p>참입니다</p> <% } %>`
*   **JSTL**: `<c:if test="${flag}"> <p>참입니다</p> </c:if>`
    JSTL은 복잡한 자바 코드 구문을 친숙한 **HTML 커스텀 태그**로 번역해주는 **"코드 통역사"** 역할을 합니다.

---

### 🛡️ XSS 방어벽과 안전 확성기 (`<c:out>`)
*   **일반 출력 `${text}` (무방비 확성기)**: 마이크를 쥐어주고 하고 싶은 말을 그대로 확성기로 내보내는 것과 같습니다. 악성 사용자(해커)가 대본에 악성 자바스크립트 코드(`<script>...</script>`)를 적어 넣으면 웹 페이지가 이 코드를 그대로 실행하여 개인 정보 해킹(XSS 공격)이 발생할 수 있습니다.
*   **JSTL `<c:out>` (정제 필터링)**: 사용자가 위험한 코드(`<script>`)를 입력하더라도, 이를 그대로 칠판에 받아쓰기하여 작동 불가능한 글자 덩어리(`&lt;script&gt;`)로 안전하게 변환(HTML Escaping)시킨 뒤 보여주는 보안 필터입니다.

---

### 🚦 조건 제어문 종류
*   **`<c:if>` (단일 조건식)**: "예/아니오"만 판별하는 외길 통로 조건문입니다. (else가 없음)
*   **`<c:choose>` (다중 선택 뷔페)**: 자바의 `switch`나 `if-else if-else`처럼 동작합니다. 여러 조건 중에서 첫 번째 조건이 성립하는 길(`<c:when>`)로 가고, 일치하는 게 없으면 기본 통로(`<c:otherwise>`)로 나옵니다.

---

### 🔄 반복 구동기 (`<c:forEach>`)
*   **리스트 반복**: 과일 박스(`items="${list}"`)에서 하나씩 내용물을 꺼내(`var="item"`) 진열대에 놓는 자동화 기계입니다. 이때 현재 상태 판독기(`varStatus="status"`)를 붙이면, 지금 꺼낸 게 몇 번째 과일인지(`index`, `count`), 첫 번째인지(`first`), 마지막인지(`last`)를 알아서 측정해 알려줍니다.
*   **구간 반복**: `begin="1" end="10" step="3"`과 같이 셋팅하여 1부터 10까지 3씩 건너뛰며 반복하도록 구간을 설정하는 기계입니다.

---

### 🔗 경로 자동 매핑 내비게이터 (`<c:url>` & `<c:param>`)
웹 서버의 최상단 경로(Context Path)가 `/`가 아닌 `/myapp` 등으로 바뀌면 기존에 작성해 둔 `<a href="/jstl">` 경로는 길을 잃고 헤매게 됩니다.
*   **수동 주소**: `/jstl` (서버 설정 변경 시 깨지기 쉬움)
*   **`<c:url>`**: 서블릿 컨테이너가 현재 돌아가고 있는 웹 애플리케이션의 진짜 기준점(Context Path)을 알아서 앞에 붙여 안전한 전체 주소로 만들어 줍니다.
*   **`<c:param>`**: 주소 뒤에 붙는 정보(`?id=123&name=kim`)에 한글이나 띄어쓰기가 들어있을 때, 깨지지 않도록 특수 문자를 기계어 포맷으로 알아서 변환(URL 인코딩)해 줍니다.

---

## 2. 능숙자를 위한 절차 설명 ⚙️

JSTL 라이브러리를 프로젝트에 빌드하고 서블릿 컨트롤러와 상호작용하도록 적용하는 절차입니다.

### Step 1: 의존성 라이브러리 추가
Jakarta EE 10 규격(Tomcat 10.1 이상) 기준의 JSTL 3.0 스펙을 활성화하기 위해 [pom.xml](file:///Users/morgan/Documents/workspace/jsp/pom.xml)의 `<dependencies>`에 다음 2개의 의존성을 선언합니다.

```xml
<!-- JSTL 3.0 API 선언 -->
<dependency>
    <groupId>jakarta.servlet.jsp.jstl</groupId>
    <artifactId>jakarta.servlet.jsp.jstl-api</artifactId>
    <version>3.0.2</version>
    <scope>compile</scope>
</dependency>
<!-- Glassfish의 JSTL 3.0 런타임 구현체 주입 -->
<dependency>
    <groupId>org.glassfish.web</groupId>
    <artifactId>jakarta.servlet.jsp.jstl</artifactId>
    <version>3.0.1</version>
    <scope>runtime</scope>
</dependency>
```

### Step 2: JSP 페이지 상단 Taglib 지시자 로드
JSTL 코어 태그 라이브러리를 사용하기 위해 JSP 파일 최상단에 지시자를 기입합니다.
```jsp
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
```

### Step 3: 조건 분기 및 다중 조건 처리
*   **단일 조건 분기 (`<c:if>`)**: `test` 속성 내부에 EL 조건식을 할당하여 동작합니다.
```jsp
<c:if test="${flag}">
    <p>집에 가고 싶다 체크 완료</p>
</c:if>
```
*   **다중 조건 분기 (`<c:choose>`)**: 자바의 다중 조건문(if-else)에 대응합니다.
```jsp
<c:choose>
    <c:when test="${text.length() >= 5}">5글자 이상</c:when>
    <c:when test="${text.equals('딸기')}">딸기 감지</c:when>
    <c:otherwise>나머지 처리</c:otherwise>
</c:choose>
```

### Step 4: 루프 구조 활용
*   **컬렉션 탐색 (`<c:forEach>`)**:
```jsp
<c:forEach var="item" items="${list}" varStatus="status">
    <li>${item} (순번: ${status.count}, 인덱스: ${status.index})</li>
</c:forEach>
```
*   **구간 제어 루프**:
```jsp
<c:forEach var="i" begin="1" end="10" step="3">
    <span>${i} </span> <!-- 1, 4, 7, 10 출력 -->
</c:forEach>
```

### Step 5: XSS 대응 출력 처리 (`<c:out>`)
사용자 입력 값이나 제어 불가능한 외부 파라미터를 그대로 출력해야 할 때는 XSS 방지를 위해 `<c:out>` 태그를 이용해 특수문자를 엔티티 코드로 치환합니다.
```jsp
<c:out value="${text}"/>
```

### Step 6: 안전한 URL 생성 및 파라미터 인코딩 (`<c:url>`)
애플리케이션 컨텍스트 경로를 자동으로 덧붙이고, 쿼리 스트링 값을 안전하게 URL 인코딩하여 하이퍼링크 주소를 생성합니다.
```jsp
<a href="<c:url value="/jstl">
             <c:param name="id" value="123456" />
             <c:param name="name" value="kim윌리엄" />
         </c:url>">안정적인 이동 경로</a>
```

---

## 3. 취업 대비를 위한 면접 예상 문항 💬

### Q1. JSTL(JSP Standard Tag Library)이란 무엇이며, JSP 페이지 개발 시 자바 스크립틀릿 표현식(`<%= %>`) 대신 JSTL의 사용을 적극 권장하는 이유는 무엇인가요?
> **답변 방향**: 코드 가독성, MVC 패턴의 관심사 분리(SoC), 개발과 디자인의 협업성 관점에서 설명합니다.

*   **답변**: JSTL은 JSP 개발 시 자주 쓰이는 조건 제어, 루프 처리, 포맷팅, 로컬라이징 등의 자바 구문을 XML/HTML 규격과 유사한 커스텀 태그로 정형화해 놓은 표준 라이브러리입니다.
*   **권장 이유**:
    1.  **가독성 및 유지보수**: HTML 마크업 코드와 구조가 동일하여 자바 스크립틀릿을 사용할 때 빈번히 발생하는 중괄호(`{ }`) 매칭 에러 등을 원천 차단하고 구조 분석이 쉽습니다.
    2.  **화면과 비즈니스 로직의 명확한 분리**: JSP 페이지 내부에서 데이터 조작 및 비즈니스 연산을 배제하고 순수 프레젠테이션 역할에만 집중하게 함으로써 MVC 디자인 패턴을 안정적으로 구현할 수 있게 돕습니다.
    3.  **협업 강화**: HTML 마크업만 파악하는 웹 디자이너나 프론트엔드 개발자들도 오류 없이 쉽게 페이지 구조를 해석하고 함께 유지보수할 수 있습니다.

---

### Q2. JSP EL의 일반적인 데이터 출력 구문 `${text}`와 JSTL의 `<c:out value="${text}" />` 태그는 보안상 어떤 치명적인 차이를 가질까요? 이와 연계하여 XSS(Cross-Site Scripting) 방어 원리를 설명하세요.
> **답변 방향**: HTML Escaping의 적용 여부와 특수 기호 변환 테이블을 구체적으로 답변에 담아야 가점을 받습니다.

*   **답변**: 핵심적 차이는 **HTML 이스케이프(HTML Escaping)의 자동 적용 여부**입니다.
*   `${text}`는 문자열 안에 HTML 태그나 자바스크립트 코드(`<script>`)가 섞여 있을 때 브라우저가 이를 파싱하고 그대로 실행하도록 전송합니다. 만약 해커가 악성 스크립트를 주입(XSS 공격)하면 사용자 쿠키 탈취 등의 심각한 보안 이슈가 발생할 수 있습니다.
*   반면, JSTL의 `<c:out>` 태그는 `escapeXml` 속성의 기본값이 `true`로 설정되어 있어, 데이터를 렌더링하기 전 HTML 특수문자인 `<`는 `&lt;`, `>`는 `&gt;`, `&`는 `&amp;` 등으로 자동 변환하여 클라이언트에 출력합니다. 이로 인해 브라우저는 코드를 스크립트로 실행하지 않고 문자열 그대로 안전하게 화면에 띄우게 되므로 XSS 취약점을 차단할 수 있습니다.

---

### Q3. JSTL `<c:forEach>` 반복 태그 내에서 사용할 수 있는 `varStatus` 속성이 가리키는 객체의 역할은 무엇이며, 이 객체에서 유용하게 쓰이는 4가지 프로퍼티 값을 설명해 주세요.
> **답변 방향**: LoopTagStatus 인터페이스 및 properties의 실제 반환 데이터 형식과 의미(index, count, first, last)를 명쾌하게 나열합니다.

*   **답변**: `varStatus`는 루프 실행 중 현재 반복 상태 데이터를 담고 있는 `LoopTagStatus` 인스턴스를 바인딩할 임시 변수명을 정의하는 속성입니다.
*   주요 프로퍼티 4가지는 다음과 같습니다:
    1.  `index`: 0부터 시작하는 현재 반복의 0-based 인덱스 번호를 반환합니다.
    2.  `count`: 1부터 시작하는 현재 반복의 1-based 차수(횟수)를 반환합니다.
    3.  `first`: 현재 가리키는 원소가 해당 컬렉션의 첫 번째 데이터인지의 판별값(`boolean`)을 반환합니다. (첫 요소에만 스타일을 먹일 때 유용)
    4.  `last`: 현재 가리키는 원소가 해당 컬렉션의 마지막 데이터인지의 판별값(`boolean`)을 반환합니다. (중간 쉼표 처리 등 특수 마감 작업 시 유용)

---

### Q4. JSP 페이지 상에서 하이퍼링크 주소를 설정할 때, 일반적인 `<a href="/path">` 대신 JSTL의 `<c:url>` 및 `<c:param>` 태그를 사용하는 것이 유리한 이유가 무엇인가요?
> **답변 방향**: Context Path 자동 해결 기능 및 URL 인코딩 처리를 핵심 개념으로 기술합니다.

*   **답변**:
    1.  **컨텍스트 경로(Context Path) 자동 매핑**: WAS 상에서 애플리케이션의 배포 경로가 변경되어 최상단 웹 경로(예: `/` -> `/myapp`)가 달라질 때, `<c:url>`은 런타임에 현재 Context Path를 자동으로 탐색하여 경로 앞에 붙여 주므로 링크 깨짐 현상을 방지합니다.
    2.  **안전한 특수문자 및 한글 인코딩**: `<c:param>` 태그를 통해 파라미터를 넘겨주면, 파라미터 값 안에 포함된 공백이나 특수문자, 한글 등을 브라우저 표준에 맞는 URL 인코딩 방식으로 변환하여 인자 전달 시의 깨짐이나 규격 오작동을 차단합니다.
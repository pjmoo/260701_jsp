# JSP Include 지시자(<%@ include %>)와 Action Tag(<jsp:include>)를 통한 페이지 모듈화

이 가이드는 [IncludeServlet.java](file:///Users/morgan/Documents/workspace/jsp/src/main/java/com/example/jsp/step2/IncludeServlet.java), [include.jsp](file:///Users/morgan/Documents/workspace/jsp/src/main/webapp/WEB-INF/step02/include.jsp), [header.jsp](file:///Users/morgan/Documents/workspace/jsp/src/main/webapp/WEB-INF/step02/header.jsp), [meta.jsp](file:///Users/morgan/Documents/workspace/jsp/src/main/webapp/WEB-INF/step02/meta.jsp), [detail.jsp](file:///Users/morgan/Documents/workspace/jsp/src/main/webapp/WEB-INF/step02/detail.jsp), [footer.jsp](file:///Users/morgan/Documents/workspace/jsp/src/main/webapp/WEB-INF/step02/footer.jsp) 코드를 바탕으로 JSP의 정적/동적 페이지 조립 및 데이터 연동 기법을 설명합니다.

---

## 1. 초심자를 위한 비유 🧱

### 🤯 100개의 페이지와 1개의 텍스트 수정
웹 사이트를 개발하다 보면 모든 페이지에 동일한 헤더(Header), 푸터(Footer), 공통 CSS/JS 파일 경로(Meta)가 들어갑니다. 만약 사이트가 100개의 페이지로 구성되어 있는데 상단 메뉴 중 하나인 "소개"를 "회사 소개"로 바꾸어야 한다면 어떻게 해야 할까요? 100개의 파일을 다 열어서 고치는 것은 무척 지루하고 실수하기 쉽습니다.

### 🧩 레고 블록 조립 (`<%@ include %>` 와 `<jsp:include>`)
JSP Include는 공통으로 들어가는 구성 요소를 하나의 레고 블록으로 분리해 놓는 기법입니다.
그리고 본문 페이지([include.jsp](file:///Users/morgan/Documents/workspace/jsp/src/main/webapp/WEB-INF/step02/include.jsp))에서는 블록이 들어갈 자리에 구멍을 뚫어 놓고 조립합니다.

이렇게 하면 메뉴바에 수정이 필요할 때 오직 [header.jsp](file:///Users/morgan/Documents/workspace/jsp/src/main/webapp/WEB-INF/step02/header.jsp) 파일 하나만 수정하면 이를 참조하고 있는 100개의 페이지 전체에 변경사항이 알아서 적용됩니다.

### 🤖 복사-붙여넣기 로봇 vs 주문 제작 서비스
JSP는 페이지를 포함할 때 두 가지 로봇을 사용할 수 있습니다.

1.  **정적 Include (`<%@ include file="..." %>`): 복사-붙여넣기 로봇**
    *   톰캣이 자바 서블릿 파일(`.java`)을 만들기 전에(번역 단계), [meta.jsp](file:///Users/morgan/Documents/workspace/jsp/src/main/webapp/WEB-INF/step02/meta.jsp)나 [header.jsp](file:///Users/morgan/Documents/workspace/jsp/src/main/webapp/WEB-INF/step02/header.jsp)의 내용(소스 코드)을 메인 파일에 그대로 복사-붙여넣기하여 하나의 커다란 자바 파일을 만듭니다.
    *   만약 변수명이 겹치면 싸움(컴파일 에러)이 날 수 있습니다.
2.  **동적 Include (`<jsp:include page="..." />`): 주문 제작 서비스**
    *   런타임(프로그램이 돌아가는 도중)에 동작합니다.
    *   메인 페이지를 실행하다가 동적 Include 태그를 만나면, 잠시 [detail.jsp](file:///Users/morgan/Documents/workspace/jsp/src/main/webapp/WEB-INF/step02/detail.jsp)나 [footer.jsp](file:///Users/morgan/Documents/workspace/jsp/src/main/webapp/WEB-INF/step02/footer.jsp)로 이동하여 화면을 따로 렌더링하고, 완성된 결과물(HTML)만 가지고 돌아와 합칩니다.
    *   이때 주문서(`<jsp:param>`)를 동봉하여 각각의 부품 페이지로 데이터를 다르게 전달해 맞춤 제작을 요청할 수 있습니다.

---

## 2. 능숙자를 위한 절차 설명 ⚙️

JSP의 정적 include 지시자와 동적 include 액션 태그를 결합하여 모듈화된 페이지 레이아웃을 작성하는 절차입니다.

### Step 1: 공통 요소 분리
*   **정적 결합 대상 (정적인 메타데이터 등)**: [meta.jsp](file:///Users/morgan/Documents/workspace/jsp/src/main/webapp/WEB-INF/step02/meta.jsp)
    *   Bootstrap 등 공통 스타일시트 링크나 스크립트를 정의합니다.
*   **동적 결합 대상 (파라미터에 따라 내용이 변하는 요소)**: [detail.jsp](file:///Users/morgan/Documents/workspace/jsp/src/main/webapp/WEB-INF/step02/detail.jsp), [footer.jsp](file:///Users/morgan/Documents/workspace/jsp/src/main/webapp/WEB-INF/step02/footer.jsp)
    *   외부 파라미터(`request.getParameter("title")` 등)에 의존하는 화면입니다.

### Step 2: 메인 JSP([include.jsp](file:///Users/morgan/Documents/workspace/jsp/src/main/webapp/WEB-INF/step02/include.jsp))에서 조립 구현
메인 페이지의 구성 방식에 따라 적절한 Include 방식을 혼용합니다.

```jsp
<%-- WEB-INF/step02/include.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <%-- 1. 정적 include: 공통 meta 태그 및 외부 스타일시트 결합 --%>
    <%@ include file="meta.jsp" %>
    
    <%-- 2. 동적 include: 파라미터를 넘겨주어 동적으로 타이틀 렌더링 --%>
    <jsp:include page="detail.jsp">
        <jsp:param name="title" value="동적으로 제어해야하는 내용(상위 페이지가)"/>
    </jsp:include>
</head>
<body class="p-4">
    <%-- 3. 정적 include: 공통 헤더 네비게이션바 조립 --%>
    <%@ include file="header.jsp" %>
    
    <h1>Include</h1>
    
    <%-- 4. 동적 include: 특정 메시지 파라미터 전달과 함께 푸터 조립 --%>
    <jsp:include page="footer.jsp">
        <jsp:param name="msg" value="반갑습니다 include 어렵죠?"/>
    </jsp:include>
</body>
</html>
```

### 정적 Include vs 동적 Include 핵심 동작 메커니즘
1.  **컴파일 단계의 정적 결합 (`<%@ include %>`)**:
    *   웹 컨테이너가 JSP를 자바 코드(`.java`)로 컴파일할 때, `file` 속성으로 지정된 파일의 텍스트가 메인 JSP 코드에 그대로 삽입됩니다.
    *   따라서 파일 간 변수 영역(Scope)이 합쳐져 변수를 서로 참조할 수 있지만, 동일한 변수 선언 시 충돌이 일어납니다.
2.  **런타임 단계의 동적 결합 (`<jsp:include>`)**:
    *   각 JSP가 개별 서블릿으로 실행됩니다. 런타임 시 메인 서블릿이 헬퍼 서블릿(`detail_jsp.class` 등)을 내부적으로 호출(`include()`)하고 출력 버퍼의 내용만 합칩니다.
    *   `<jsp:param>`을 사용하여 파라미터를 하위 JSP로 전송할 수 있습니다.

---

## 3. 취업 대비를 위한 면접 예상 문항 💬

### Q1. JSP의 정적 Include 지시자(`<%@ include file="..." %>`)와 동적 Include 액션 태그(`<jsp:include page="..." />`)의 내부적인 처리 차이를 설명해 주세요.
> **답변 방향**: 결합 시점, 생성되는 서블릿 파일 개수, 로컬 변수 접근 가능 여부의 3가지를 명확히 짚어주어야 합니다.

*   **정적 Include (`<%@ include %>`)**
    *   **처리 시점**: JSP 파일이 서블릿(.java)으로 변환(번역)되는 **컴파일 시점**에 코드가 물리적으로 병합됩니다.
    *   **클래스 파일**: 부모 JSP와 자식 JSP가 합쳐져 **단 하나의 서블릿 클래스**로 생성됩니다.
    *   **자원 공유**: 같은 자바 코드 내에 위치하게 되므로 자바 로컬 변수를 직접 공유할 수 있습니다.
*   **동적 Include (`<jsp:include>`)**
    *   **처리 시점**: 클라이언트의 요청이 도달하는 **런타임 시점**에 요청을 분기하여 처리 결과를 병합합니다.
    *   **클래스 파일**: 각각의 JSP 파일이 **개별적인 독립 서블릿 클래스**로 컴파일되고 관리됩니다.
    *   **자원 공유**: 서로 소스코드가 섞이지 않기 때문에 로컬 변수는 공유 불가능하며, 대신 `<jsp:param>`을 통해 파라미터를 넘겨받거나 `request.setAttribute` 등을 통해 데이터를 공유해야 합니다.

---

### Q2. 동적 include(`<jsp:include>`)에서 `<jsp:param>`을 사용해 데이터를 넘길 때, 전달받는 JSP(예: [footer.jsp](file:///Users/morgan/Documents/workspace/jsp/src/main/webapp/WEB-INF/step02/footer.jsp))에서는 이 데이터를 어떻게 꺼내 쓰나요?
> **답변 방향**: 데이터 전달이 HTTP 파라미터 방식을 따른다는 점과 서블릿 객체 모델을 언급합니다.

*   **답변**: `<jsp:param>` 태그로 넘긴 데이터는 HTTP 요청 파라미터(Request Parameter)의 형태로 서브 JSP에 전달됩니다.
*   따라서 값을 전달받는 JSP 파일에서는 서블릿 내장 객체인 `request` 객체의 `getParameter(String name)` 메서드를 사용하여 데이터를 꺼내 쓸 수 있습니다.
*   예시: `request.getParameter("msg")` 또는 EL(Expression Language) 표현식인 `${param.msg}` 형태로 접근이 가능합니다.

---

### Q3. 정적 include를 사용할 때 주의해야 할 에러 케이스는 무엇이 있나요?
> **답변 방향**: 물리적 소스 병합의 특성에 기인한 에러(변수명 충돌, JSP 설정 헤더 충돌)를 설명합니다.

*   **답변**:
    1.  **로컬 변수명 충돌**: 메인 JSP와 포함되는 조각 JSP 양쪽에서 동일한 이름의 로컬 변수를 선언하면 서블릿 컴파일 시 `Duplicate local variable` 컴파일 에러가 발생합니다.
    2.  **JSP 지시자 옵션 충돌**: 포함되는 JSP와 메인 JSP 간의 `contentType`, `pageEncoding` 등 환경 설정이 일치하지 않을 경우 컴파일 오류가 나거나 깨진 한글이 출력될 수 있습니다. 조각 JSP 파일도 인코딩 형식을 맞춰서 일관되게 작성해 주어야 합니다.
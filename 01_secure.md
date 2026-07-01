# Servlet과 JSP 포워딩(Forwarding) 및 WEB-INF 보안

이 가이드는 [SecureServlet.java](file:///Users/morgan/Documents/workspace/jsp/src/main/java/com/example/jsp/step1/SecureServlet.java), [01_secure.jsp](file:///Users/morgan/Documents/workspace/jsp/src/main/webapp/01_secure.jsp), 그리고 [01_secure2.jsp](file:///Users/morgan/Documents/workspace/jsp/src/main/webapp/WEB-INF/01_secure2.jsp) 코드를 바탕으로 서블릿의 요청 제어(Forwarding)와 `WEB-INF` 디렉토리를 활용한 보안 메커니즘을 설명합니다.

---

## 1. 초심자를 위한 비유 🏪

### 🔓 오픈된 가판대 (`01_secure.jsp`) vs 🔒 금고/창고 (`WEB-INF/01_secure2.jsp`)

*   **webapp 바로 아래의 `01_secure.jsp`**: 편의점 입구 가판대에 놓인 물건입니다. 지나가는 손님(클라이언트/브라우저)이 점원을 거치지 않고 직접 손을 뻗어 가져갈 수 있습니다. (URL로 직접 호출 가능: `http://localhost:8080/01_secure.jsp`)
*   **WEB-INF 폴더 안의 `01_secure2.jsp`**: 편의점 카운터 뒤쪽 창고나 금고에 보관된 물건입니다. 손님이 직접 들어가서 가져올 수 없으며, 접근하려고 하면 경고를 받거나 물건이 없다는 답변(404 Error)을 듣게 됩니다. (URL 직접 접근 불가능)

### 🤵 점원의 안내 (`RequestDispatcher` 와 `Forward`)

손님이 금고 안의 물건을 보고 싶다면, 반드시 카운터에 있는 **점원(서블릿, [SecureServlet.java](file:///Users/morgan/Documents/workspace/jsp/src/main/java/com/example/jsp/step1/SecureServlet.java))**에게 요청해야 합니다.

1.  손님이 점원에게 `/secure`라는 서비스(URL)를 요청합니다.
2.  점원은 손님의 요청을 확인하고, 뒤편의 안전한 창고(`WEB-INF/01_secure2.jsp`)로 들어가서 물건을 꺼내옵니다.
3.  점원이 물건을 꺼내 손님에게 보여줍니다(`forward()`).
4.  **중요한 점**: 손님은 여전히 카운터 앞(`/secure`)에 서 있습니다. 자신이 창고 안을 직접 들여다보거나 이동한 것이 아니기 때문에, 브라우저 주소창의 주소는 여전히 `/secure`로 유지됩니다.

### 🏷️ 쟁반 위에 올려둔 서비스 (`request.setAttribute`)

점원은 창고로 가기 전, 손님이 주문한 내용이나 서비스 품목(`isSecure = true`)을 쟁반(`request`)에 얹어둡니다. 창고 안에 있는 화면 템플릿(`01_secure2.jsp`)은 점원이 쟁반 위에 두고 간 정보(`request.getAttribute("isSecure")`)를 읽어와서 화면에 출력합니다.

---

## 2. 능숙자를 위한 절차 설명 ⚙️

서블릿 컨테이너(Tomcat 등)에서 클라이언트의 직접적인 JSP 접근을 막고 서블릿(Controller)의 통제를 거치도록 설계하는 절차는 다음과 같습니다.

### Step 1: 서블릿 생성 및 매핑
[SecureServlet.java](file:///Users/morgan/Documents/workspace/jsp/src/main/java/com/example/jsp/step1/SecureServlet.java)와 같이 `HttpServlet`을 상속받는 서블릿 클래스를 생성하고, `@WebServlet("/secure")` 어노테이션으로 가상 경로를 매핑합니다.

```java
@WebServlet("/secure")
public class SecureServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // ...
    }
}
```

### Step 2: Request Scope 데이터 바인딩
JSP(View)에 전달할 비즈니스 로직 결과 데이터를 `HttpServletRequest` 객체의 `setAttribute()` 메서드를 사용하여 저장합니다.
```java
req.setAttribute("isSecure", true);
```

### Step 3: WEB-INF 하위 뷰 경로 지정 및 포워드
브라우저의 직접 요청을 차단하기 위해 JSP 파일을 `webapp/WEB-INF/` 디렉토리 하위에 배치합니다. 서블릿 내에서 `RequestDispatcher`를 얻어올 때 해당 경로를 지정한 후 `forward()`를 호출합니다.

```java
// 서버 내부에서만 접근할 수 있는 WEB-INF 경로 지정
req.getRequestDispatcher("/WEB-INF/01_secure2.jsp")
   .forward(req, resp); // 제어권 전달
```

*   **작동 방식**:
    1.  클라이언트가 `/secure` 경로로 GET 요청을 보냄.
    2.  `SecureServlet`의 `doGet` 메소드가 실행되어 데이터를 셋팅함.
    3.  `forward()` 호출 시 서블릿 컨테이너는 HTTP 응답을 생성하지 않고 제어권을 바로 `/WEB-INF/01_secure2.jsp`로 넘김.
    4.  JSP가 실행되어 HTML을 생성하고, 최종 결과물만 클라이언트에 전송됨.
    5.  클라이언트 브라우저는 제어권이 내부적으로 이동했음을 알지 못하므로 주소창의 주소는 `/secure`로 유지됨.

---

## 3. 취업 대비를 위한 면접 예상 문항 💬

### Q1. Servlet에서 다른 리소스로 이동할 때 사용하는 `Forward` 방식과 `Redirect` 방식의 차이점을 설명해 주세요.
> **답변 방향**: 두 방식의 주체(서버 vs 클라이언트), URL 변화 여부, Request/Response 객체의 유지 여부 및 활용 사례를 대조하여 답변합니다.

*   **Forward (전달)**
    *   **이동 주체**: 서버 내부에서 서블릿 컨테이너가 다른 리소스(Servlet/JSP)로 제어권을 직접 넘깁니다.
    *   **URL 주소창**: 변화 없음 (클라이언트는 내부 이동을 인지하지 못함).
    *   **데이터 유지**: 최초 요청 시 생성된 `HttpServletRequest`와 `HttpServletResponse` 객체가 그대로 유지되므로, `request.setAttribute()`로 담은 데이터를 이동 대상 페이지에서 그대로 사용할 수 있습니다.
    *   **용도**: 주로 조회(Select)성 요청 처리 후 비즈니스 로직 결과를 뷰(JSP) 화면에 표현할 때 사용합니다.
*   **Redirect (재요청)**
    *   **이동 주체**: 서버가 클라이언트에게 302 상태 코드와 Location 헤더를 보내어 다른 URL로 재요청하도록 지시합니다. 클라이언트(브라우저)가 새로운 요청을 다시 보냅니다.
    *   **URL 주소창**: 재요청 대상 주소로 변경됨.
    *   **데이터 유지**: 완전히 새로운 HTTP 요청이 발생하므로 이전 `request` 객체와 저장된 데이터는 소멸됩니다. (데이터 유지 필요 시 세션 혹은 URL 쿼리 파라미터를 사용해야 함)
    *   **용도**: 등록, 수정, 삭제(CUD) 작업 수행 후 화면을 새로고침할 때 발생할 수 있는 중복 요청 방지(PRG 패턴: Post-Redirect-Get)에 사용합니다.

---

### Q2. JSP 파일들을 `WEB-INF` 폴더 아래에 두는 이유와 그로 인한 장점은 무엇인가요?
> **답변 방향**: 서블릿 규약에 따른 WEB-INF 디렉토리의 특성(직접 접근 불가)과 MVC 패턴 구현 시의 보안 관점을 엮어서 답변합니다.

*   **이유**: 서블릿 스펙상 `WEB-INF` 디렉토리 하위의 파일들은 외부 웹 브라우저에서 직접 URL 입력을 통해 접근할 수 없도록 보호됩니다.
*   **장점 (보안 및 아키텍처 제어)**:
    1.  **비즈니스 로직 흐름 강제**: 사용자가 컨트롤러(Servlet)를 거치지 않고 JSP 화면에 직접 접근하는 것을 차단합니다. 이를 통해 서블릿에서 수행되는 인증/인가 검증이나 데이터 바인딩 로직(`request.setAttribute`)의 누락 없이 항상 정상적인 흐름으로만 서비스에 접근하도록 보장합니다.
    2.  **데이터 노출 및 에러 예방**: 데이터가 비어 있는 상태에서 JSP가 직접 호출되어 발생할 수 있는 `NullPointerException`이나 기타 시스템 예외 화면이 사용자에게 노출되는 것을 방지합니다.

---

### Q3. `request.setAttribute()`를 통해 담은 데이터는 세션(`session`)에 담은 데이터와 어떤 차이가 있나요?
> **답변 방향**: 웹 애플리케이션의 Scope(범위) 개념과 생명주기를 설명하고 리소스 효율성 관점에서 답변합니다.

*   **Request Scope (`request.setAttribute`)**
    *   **유효 범위**: 하나의 HTTP 요청이 시작되어 응답이 클라이언트에 나갈 때까지 유효합니다.
    *   **생명 주기**: 포워드(`forward`)를 통해 이동하는 동안에는 유지되지만, 응답이 완료되는 즉시 소멸합니다.
    *   **활용**: 특정 요청에 따른 결과 데이터를 뷰에 일회성으로 전달할 때 사용하며, 메모리 관리에 효율적입니다.
*   **Session Scope (`session.setAttribute`)**
    *   **유효 범위**: 클라이언트(브라우저)별로 고유하게 생성되는 세션 영역 전체에서 유효합니다.
    *   **생명 주기**: 웹 브라우저가 종료되거나, 설정된 세션 타임아웃(기본 30분)이 지나거나, 명시적으로 세션을 무효화(`session.invalidate()`)할 때까지 유지됩니다.
    *   **활용**: 로그인 사용자 정보, 장바구니 설정과 같이 여러 페이지 요청에 걸쳐 지속적으로 유지되어야 하는 상태 값을 다룰 때 사용합니다. 세션 데이터를 남용하면 서버 메모리에 부하를 주기 때문에 신중하게 활용해야 합니다.
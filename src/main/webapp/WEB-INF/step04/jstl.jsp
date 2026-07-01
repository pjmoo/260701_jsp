<%-- WEB-INF/step04/jstl.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%-- c:*** 해서 JSTL 기능 중 core를 로드 --%>
<%-- JSTL을 사용하는 패키지 코드 --%>

<html>
<head>
  <title>JSTL</title>
</head>
<body>
<h1>JSTL</h1>
<form method="post">
  <div>
    <input type="checkbox" name="flag"> 집에 가고 싶다
  </div>
  <button type="submit">제출</button>
</form>
<section>
  <%
    if (request.getAttribute("flag") == null) {
  %>
  <p>응답해주세요</p>
  <%
  } else {
    boolean flag = (Boolean) request.getAttribute("flag");
    if (flag) {
  %>
  <p>저도 가고 싶어요</p>
  <% } else {

  %>
  <p>진짜 안가고 싶어요?</p>
  <%
      }
    }
  %>
</section>
<section>
  <%--    test -> el 태그를 작성 --%>
  <c:if test="${flag}">
    <p>그래도 집에 가면 안되죠</p>
  </c:if>
  <c:if test="${!flag}">
    <p>그래요 잘 생각했어요</p>
  </c:if>
  <%-- (test)  if (단일조건문) choose, when, otherwise 다중조건문 --%>
  <%-- forEach - var, items, varStatus, begin, end --%>
  <%-- url, out --%>
</section>
</body>
</html>
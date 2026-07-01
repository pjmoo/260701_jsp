<%-- WEB-INF/step04/jstl2.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<html>
<head>
  <title>JSTL2</title>
</head>
<body>
<h1>JSTL2</h1>

<%-- 반복 --%>
<ul>
  <c:forEach var="item" items="${list}" varStatus="status">
    <%-- var="item" --%>
    <li>${item}</li>
    <%--        <p>${status}</p>--%>
    <p>${status.index} (0부터 시작)</p>
    <p>${status.count} (1부터 시작)</p>
    <p>${status.first} (첫번째 요소인가?)</p>
    <p>${status.last} (마지막 요소인가?)</p>
  </c:forEach>
  <%--  begin end (시작점, 끝점 모두 포함) / step 증가시키는 것. --%>
  <c:forEach var="i" begin="1" end="10" step="3">
    <p>${i}</p>
  </c:forEach>
</ul>

<a href="/jstl">안정적이지 않다 (application context)</a>
<a href=
           "<c:url value="/jstl">
                <c:param name="id" value="123456" />
                <c:param name="name" value="kim윌리엄" />
            </c:url>"
<%-- 쿼리스트링으로 주입 가능 --%>
>안정적이다 (application context)</a>
<form method="post">
  <input name="text">
  <input type="submit">
</form>
<section>
  <p>
    ${text}
  </p>
  <p>
    <c:out value="${text}"/>
  </p>
  <%--  태그를 이스케이프 처리 (실행되지 않게 변경)  --%>
  <%-- XSS : 태그를 해석하는 경우에 스크립트 등을 넣어서 무언가 탈취 --%>
  <%--  thymeleaf는 기본적으로 이스케이프처리를 함. (jsp가 xss가 만연하기 전에 만들어져서 그럼)  --%>
  <%--  단순 조건 (if, test)  --%>
  <c:if test="${text.length() >= 5}">
    <%-- test 조건을 만족시에만 이 태그가 활성화 --%>
    5글자 이상입니다
  </c:if>
  <%-- 다중 조건문 (choose, when, otherwise) (if-else, else-if) --%>
  <c:choose>
    <c:when test="${text.length() >= 5}">
      5글자 이상이네요
    </c:when>
    <c:when test="${text.length() >= 3}">
      3글자 이상이네요
    </c:when>
    <%--   EL 태그에선 작은따옴표도 String으로 감지 (js처럼)     --%>
    <c:when test="${text.equals('딸기')}">
      딸기네요
    </c:when>
    <c:otherwise>
      도대체 뭘 입력하신 겁니까?
    </c:otherwise>
  </c:choose>

</section>
</body>
</html>
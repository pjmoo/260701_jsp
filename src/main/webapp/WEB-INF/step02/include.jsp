<%-- WEB-INF/step02/include.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <%-- 메타데이터 --%>
    <%@ include file="meta.jsp" %>
    <jsp:include page="detail.jsp">
        <jsp:param name="title" value="동적으로 제어해야하는 내용(상위 페이지가)"/>
    </jsp:include>
</head>
<body class="p-4">
<%-- 헤더 --%>
<%@ include file="header.jsp" %>
<h1>
    Include
</h1>
<div>
    <%-- 특정 기능을 하는 컴포넌트 등... --%>
</div>
<%-- 푸터 --%>
<%-- 정적 include --%>
<%-- 따로 논다 => 별개의 jsp인거지 유기적으로 작동 X --%>
<%@ include file="footer.jsp" %>
<jsp:include page="footer.jsp">
    <jsp:param name="msg" value="반갑습니다 include 어렵죠?"/>
</jsp:include>
</body>
</html>

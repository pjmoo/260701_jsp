
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
  <title>Secured</title>
</head>
<body>
<h1>
  Secured
</h1>
<%-- 스크립틀릿 중 출력문법 --%>
<h2>
  보안처리 되었나요? : <%= request.getAttribute("isSecure") %>
</h2>
</body>
</html>
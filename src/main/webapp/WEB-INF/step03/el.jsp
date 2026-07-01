<%-- WEB-INF/step03/el.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
  <title>El</title>
</head>
<body>
<h1>El</h1>
<%-- Expression Language (EL) 이전에는... --%>
<%--<%--%>
<%--    String name = "가브";--%>
<%--    // 실행 시점이 일반적인 html을 그리는 출력보다 위--%>
<%--//    response.getWriter().println("%s은 황천의 츠가이 캐릭터 중 하나로 에드를 닮았습니다".formatted(name));--%>
<%--%>--%>
<p>
  <%--    <%= name %>은 황천의 츠가이 캐릭터 중 하나로 에드를 닮았습니다--%>
  <%= request.getAttribute("name") %>은 황천의 츠가이 캐릭터 중 하나입니다
</p>
<p>
  <%--  el parser가 타입을 알아서 해석해줌 --%>
  <%-- servlet에서 req.setAttribute로 전달 받은 것 --%>
  ${name}은 황천의 츠가이 캐릭터 중 하나입니다
</p>
<p>
  ${data} <br>
  <%-- 알아서 get을 붙여서 getValue1로 호출함 --%>
  ${data.value1}
  ${data.value2}
  ${data.value3}
</p>
<p>
  ${data2} <br>
  ${data2.value1}
  ${data2.value2}
  ${data2.value3}
</p>
</body>
</html>
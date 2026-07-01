<%-- WEB-INF/step02/footer.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<footer>
    <%= request.getParameter("data") %>
    <p>
        <%= request.getParameter("msg") %>
    </p>
</footer>
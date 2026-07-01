package com.example.jsp.step4;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/jstl")
public class JSTLServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.getRequestDispatcher("/WEB-INF/step04/jstl.jsp")
                .forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        System.out.println("req.getParameter(\"flag\") = " + req.getParameter("flag"));
        // 속성으로 넘겨줘야함
        boolean flag = "on".equals(req.getParameter("flag")); // 텍스트로 넘어옴
        req.setAttribute("flag", flag);
        req.getRequestDispatcher("/WEB-INF/step04/jstl.jsp")
                .forward(req, resp);
    }
}
package com.example.jsp.step1;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/secure")
public class SecureServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setAttribute("isSecure", true);
        // /secure라는 가상경로를 요청 받았을 때 주소창 및 요청 객체의 변경 없이
        // 연동되는 jsp로 이동시킨다
        // webapp 안에 있는 경로를 인식함
//        req.getRequestDispatcher("01_secure.jsp") // webapp 경로 기준 jsp로 이동
        req.getRequestDispatcher("/WEB-INF/01_secure2.jsp") // 서버 내부에 코드로만 접근할 수 있는 경로
                .forward(req, resp); // 전달.
        // webapp 안에 있는 경로는 default servlet이 인식하여 외부에 노출
    }
}
package com.example.jsp.step3;

import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/el")
public class ElServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setAttribute("data", new Data(
                "문자열", 42, true
        ));
        req.setAttribute("data2", new Data2("공자왈맹자왈", 73, false));

        req.setAttribute("name", "요루");
        HttpSession session = req.getSession(); // 유저별로 데이터 공간이 주어진다
        session.setAttribute("name", "아사");
        ServletContext context = getServletContext();
        context.setAttribute("name", "에드워드");
        // 톰캣에서 실행 중인 전체 스레드가 공유하는 서버 웹앱의 데이터 공간
        req.getRequestDispatcher("/WEB-INF/step03/el.jsp")
                .forward(req, resp);
    }
}
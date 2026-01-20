
package com.example.webapp;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String username = req.getParameter("username");
        String password = req.getParameter("password");

        // Very simple demo check
        if ("admin".equals(username) && "password".equals(password)) {
            resp.sendRedirect("welcome.jsp");
        } else {
            resp.sendRedirect("login.jsp?error=1");
        }
    }
}

package com.financetracker.servlet;

import com.financetracker.util.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/TransactionServlet")
public class TransactionServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        int userId = 1; // Default user for demo (or retrieve from session: (Integer) session.getAttribute("userId"))

        if ("add".equals(action)) {
            String title = request.getParameter("title");
            double amount = Double.parseDouble(request.getParameter("amount"));
            String type = request.getParameter("type");
            String category = request.getParameter("category");
            String dateStr = request.getParameter("date");

            try (Connection conn = DBConnection.getConnection()) {
                String sql = "INSERT INTO transactions (user_id, title, amount, type, category, transaction_date) VALUES (?, ?, ?, ?, ?, ?)";
                PreparedStatement stmt = conn.prepareStatement(sql);
                stmt.setInt(1, userId);
                stmt.setString(2, title);
                stmt.setDouble(3, amount);
                stmt.setString(4, type);
                stmt.setString(5, category);
                stmt.setDate(6, Date.valueOf(dateStr));

                stmt.executeUpdate();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        } else if ("delete".equals(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
            try (Connection conn = DBConnection.getConnection()) {
                String sql = "DELETE FROM transactions WHERE id = ? AND user_id = ?";
                PreparedStatement stmt = conn.prepareStatement(sql);
                stmt.setInt(1, id);
                stmt.setInt(2, userId);
                stmt.executeUpdate();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }

        response.sendRedirect("dashboard.jsp");
    }
}
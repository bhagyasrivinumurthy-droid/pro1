 <%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.financetracker.util.DBConnection" %>
<%
    int userId = 1; // Demo User ID
    double totalIncome = 0.0;
    double totalExpense = 0.0;

    // Fetch Income & Expense Aggregates directly from MySQL
    try (Connection conn = DBConnection.getConnection()) {
        String query = "SELECT type, SUM(amount) as total FROM transactions WHERE user_id = ? GROUP BY type";
        PreparedStatement stmt = conn.prepareStatement(query);
        stmt.setInt(1, userId);
        ResultSet rs = stmt.executeQuery();

        while (rs.next()) {
            if ("INCOME".equalsIgnoreCase(rs.getString("type"))) {
                totalIncome = rs.getDouble("total");
            } else if ("EXPENSE".equalsIgnoreCase(rs.getString("type"))) {
                totalExpense = rs.getDouble("total");
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }

    double netBalance = totalIncome - totalExpense;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FinancePulse - Modern Dashboard</title>
    <!-- Tailwind CSS CDN -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- FontAwesome Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Chart.js -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body class="bg-slate-900 text-slate-100 font-sans min-h-screen">

    <!-- Navigation Bar -->
    <nav class="bg-slate-800 border-b border-slate-700 px-6 py-4 flex justify-between items-center shadow-lg">
        <div class="flex items-center space-x-3">
            <div class="bg-indigo-600 p-2 rounded-lg text-white">
                <i class="fa-solid fa-wallet text-xl"></i>
            </div>
            <span class="text-2xl font-bold bg-gradient-to-r from-indigo-400 to-cyan-400 bg-clip-text text-transparent">FinancePulse</span>
        </div>
        <div class="flex items-center space-x-4">
            <span class="text-slate-300"><i class="fa-solid fa-circle-user mr-2 text-indigo-400"></i>Madhuri</span>
        </div>
    </nav>

    <!-- Main Container -->
    <div class="container mx-auto px-6 py-8">

        <!-- Key Metrics Cards -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
            <!-- Balance Card -->
            <div class="bg-slate-800 p-6 rounded-2xl border border-slate-700 shadow-xl relative overflow-hidden">
                <div class="text-slate-400 text-sm font-medium mb-1">Net Balance</div>
                <div class="text-3xl font-bold text-white">$<%= String.format("%.2f", netBalance) %></div>
                <div class="mt-4 text-xs text-indigo-400 font-semibold flex items-center">
                    <i class="fa-solid fa-chart-line mr-1"></i> Updated in Real-Time
                </div>
            </div>

            <!-- Total Income -->
            <div class="bg-slate-800 p-6 rounded-2xl border border-emerald-500/20 shadow-xl">
                <div class="flex justify-between items-start">
                    <div>
                        <div class="text-slate-400 text-sm font-medium mb-1">Total Income</div>
                        <div class="text-3xl font-bold text-emerald-400">+$<%= String.format("%.2f", totalIncome) %></div>
                    </div>
                    <div class="bg-emerald-500/10 p-3 rounded-xl text-emerald-400">
                        <i class="fa-solid fa-arrow-down-left text-xl"></i>
                    </div>
                </div>
            </div>

            <!-- Total Expenses -->
            <div class="bg-slate-800 p-6 rounded-2xl border border-rose-500/20 shadow-xl">
                 <div class="flex justify-between items-start">
                    <div>
                        <div class="text-slate-400 text-sm font-medium mb-1">Total Expenses</div>
                        <div class="text-3xl font-bold text-rose-400">-$<%= String.format("%.2f", totalExpense) %></div>
                    </div>
                    <div class="bg-rose-500/10 p-3 rounded-xl text-rose-400">
                        <i class="fa-solid fa-arrow-up-right text-xl"></i>
                    </div>
                </div>
            </div>
        </div>

        <!-- Charts & Forms Section -->
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-8 mb-8">
            <!-- Dynamic Chart -->
            <div class="lg:col-span-2 bg-slate-800 p-6 rounded-2xl border border-slate-700 shadow-xl">
                <h3 class="text-lg font-bold text-slate-200 mb-4 flex items-center">
                    <i class="fa-solid fa-chart-pie mr-2 text-indigo-400"></i> Financial Breakdown
                </h3>
                <div class="h-64 flex justify-center items-center">
                    <canvas id="financeChart"></canvas>
                </div>
            </div>

            <!-- Add Transaction Form -->
            <div class="bg-slate-800 p-6 rounded-2xl border border-slate-700 shadow-xl">
                <h3 class="text-lg font-bold text-slate-200 mb-4 flex items-center">
                    <i class="fa-solid fa-plus-circle mr-2 text-indigo-400"></i> Quick Entry
                </h3>
                <form action="TransactionServlet" method="POST" class="space-y-4">
                    <input type="hidden" name="action" value="add">

                    <div>
                        <label class="block text-xs font-semibold text-slate-400 mb-1">Title</label>
                        <input type="text" name="title" required class="w-full bg-slate-900 border border-slate-700 rounded-lg px-3 py-2 text-white focus:outline-none focus:border-indigo-500">
                    </div>

                    <div class="grid grid-cols-2 gap-3">
                        <div>
                            <label class="block text-xs font-semibold text-slate-400 mb-1">Amount ($)</label>
                            <input type="number" step="0.01" name="amount" required class="w-full bg-slate-900 border border-slate-700 rounded-lg px-3 py-2 text-white focus:outline-none focus:border-indigo-500">
                        </div>
                        <div>
                            <label class="block text-xs font-semibold text-slate-400 mb-1">Type</label>
                            <select name="type" class="w-full bg-slate-900 border border-slate-700 rounded-lg px-3 py-2 text-white focus:outline-none focus:border-indigo-500">
                                <option value="INCOME">Income</option>
                                <option value="EXPENSE">Expense</option>
                            </select>
                        </div>
                    </div>

                    <div class="grid grid-cols-2 gap-3">
                        <div>
                            <label class="block text-xs font-semibold text-slate-400 mb-1">Category</label>
                            <input type="text" name="category" placeholder="e.g. Salary, Food" required class="w-full bg-slate-900 border border-slate-700 rounded-lg px-3 py-2 text-white focus:outline-none focus:border-indigo-500">
                        </div>
                        <div>
                            <label class="block text-xs font-semibold text-slate-400 mb-1">Date</label>
                            <input type="date" name="date" required class="w-full bg-slate-900 border border-slate-700 rounded-lg px-3 py-2 text-white focus:outline-none focus:border-indigo-500">
                        </div>
                    </div>
                    <button type="submit" class="w-full bg-gradient-to-r from-indigo-500 to-cyan-500 hover:from-indigo-600 hover:to-cyan-600 text-white font-semibold py-2.5 rounded-lg transition shadow-lg mt-2">
                        Record Transaction
                    </button>
                </form>
            </div>
        </div>

        <!-- Recent Transactions Table -->
        <div class="bg-slate-800 rounded-2xl border border-slate-700 shadow-xl overflow-hidden">
            <div class="p-6 border-b border-slate-700 flex justify-between items-center">
                <h3 class="text-lg font-bold text-slate-200"><i class="fa-solid fa-list-check mr-2 text-indigo-400"></i> Transaction Records</h3>
            </div>
            <div class="overflow-x-auto">
                <table class="w-full text-left border-collapse">
                    <thead>
                        <tr class="bg-slate-900/50 text-slate-400 text-xs uppercase tracking-wider">
                            <th class="p-4">Title</th>
                            <th class="p-4">Category</th>
                            <th class="p-4">Date</th>
                            <th class="p-4">Type</th>
                            <th class="p-4">Amount</th>
                            <th class="p-4 text-right">Action</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-700/50 text-sm">
                        <%
                            try (Connection conn = DBConnection.getConnection()) {
                                String sql = "SELECT * FROM transactions WHERE user_id = ? ORDER BY transaction_date DESC";
                                PreparedStatement stmt = conn.prepareStatement(sql);
                                stmt.setInt(1, userId);
                                ResultSet rs = stmt.executeQuery();

                                while(rs.next()) {
                                    boolean isIncome = "INCOME".equalsIgnoreCase(rs.getString("type"));
                        %>
                        <tr class="hover:bg-slate-700/30 transition">
                            <td class="p-4 font-medium text-white"><%= rs.getString("title") %></td>
                            <td class="p-4"><span class="bg-slate-700 px-2.5 py-1 rounded-full text-xs text-slate-300"><%= rs.getString("category") %></span></td>
                            <td class="p-4 text-slate-400"><%= rs.getDate("transaction_date") %></td>
                            <td class="p-4">
                                <span class="px-2.5 py-1 rounded-full text-xs font-semibold <%= isIncome ? "bg-emerald-500/10 text-emerald-400" : "bg-rose-500/10 text-rose-400" %>">
                                    <%= rs.getString("type") %>
                                </span>
                            </td>
                            <td class="p-4 font-bold <%= isIncome ? "text-emerald-400" : "text-rose-400" %>">
                                <%= isIncome ? "+" : "-" %>$<%= String.format("%.2f", rs.getDouble("amount")) %>
                            </td>
                            <td class="p-4 text-right">
                                <form action="TransactionServlet" method="POST" class="inline">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="id" value="<%= rs.getInt("id") %>">
                                    <button type="submit" class="text-slate-400 hover:text-rose-400 transition" onclick="return confirm('Delete record?')">
                                        <i class="fa-solid fa-trash-can"></i>
                                    </button>
                                </form>
                            </td>
                        </tr>
                        <%
                                }
                            } catch (Exception e) {
                                e.printStackTrace();
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </div>

    </div>

    <!-- Chart Integration Script -->
    <script>
        const ctx = document.getElementById('financeChart').getContext('2d');
        new Chart(ctx, {
            type: 'doughnut',
            data: {
                labels: ['Income', 'Expenses'],
                datasets: [{
                    data: [<%= totalIncome %>, <%= totalExpense %>],
                    backgroundColor: ['#10b981', '#f43f5e'],
                    borderWidth: 0
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: {
                        labels: { color: '#94a3b8' }
                    }
                }
            }
        });
    </script>
</body>
</html>
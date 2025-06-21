
# Day 1 – SQL Tutorial & Mini Project  
*Online Retail Sales Insights*

Welcome to Day 1 of my SQL learning journey!  
Today I focused on the absolute basics—writing simple `SELECT` statements and exploring data in a sample retail dataset.

---

## 📚 Tutorial Tasks

| Task | Description | SQL Snippet |
|------|-------------|-------------|
| **1** | Display *all* columns from the table | ```sql\nSELECT * FROM sample_dataset;\n``` |
| **2** | Show only `product` & `quantity` columns | ```sql\nSELECT product, quantity FROM sample_dataset;\n``` |
| **3** | List all orders where the product is **T‑shirt** | ```sql\nSELECT * FROM sample_dataset WHERE product = 'T-shirt';\n``` |
| **4** | Find orders with **quantity > 2** | ```sql\nSELECT * FROM sample_dataset WHERE quantity > 2;\n``` |
| **5** | Show the **most‑expensive** order | ```sql\nSELECT order_id, customer_name, product, price\nFROM sample_dataset\nWHERE price = (SELECT MAX(price) FROM sample_dataset);\n``` |

---

## 🛠️ Mini Project — *Online Retail Sales Insights*

> **Goal:** Use a handful of aggregate queries to get quick, business‑ready insights.

### 1. Total Number of Orders
```sql
SELECT COUNT(*) AS total_orders
FROM sample_dataset;
2. Total Revenue
sql
Copy
Edit
SELECT SUM(price * quantity) AS total_revenue
FROM sample_dataset;
3. Top 3 Best‑Selling Products
sql
Copy
Edit
SELECT
    product,
    SUM(quantity) AS total_sold
FROM sample_dataset
GROUP BY product
ORDER BY total_sold DESC
LIMIT 3;
🔑 Key Takeaways
Column selection (SELECT col1, col2) lets you focus on the data that matters.

Filtering with WHERE is essential for narrowing down rows.

Aggregation (COUNT, SUM, MAX) turns raw tables into usable KPIs.

Even the simplest queries already create real value—e.g., total revenue or best‑selling products.

🚀 What’s Next?
Day 2: Intro to JOINs—combining multiple tables.

Day 3: GROUP BY deep‑dive and basic window functions.

Long‑term: Turn these insights into a Power BI dashboard.

Follow my progress as I level up from SQL basics to full‑stack analytics!

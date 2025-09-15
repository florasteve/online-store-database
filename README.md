<p align="left">
  <img alt="Docker" src="https://img.shields.io/badge/Docker-ready-2496ED?logo=docker&logoColor=white">
  <img alt="SQL Server" src="https://img.shields.io/badge/SQL%20Server-2022-CC2927?logo=microsoft%20sql%20server&logoColor=white">
  <img alt="License" src="https://img.shields.io/badge/License-MIT-green">
</p>

> OnlineStoreDB — Dockerized SQL Server demo with normalized schema (Customers, Products, Orders, OrderDetails), computed `Subtotal`, timestamps, procs for safe inserts & lifecycle, analytics views, and seed data.
# Online Store Database

Relational database for **e-commerce operations and analytics**: customers, products, orders, and order line items.  
Built for **SQL Server** in **SSMS** with normalized tables, T-SQL procedures, computed subtotals, triggers (for UpdatedAt), and reporting views.

---

## ✨ Features
- Customer and product catalogs with basic indexing
- Orders with line items (computed `Subtotal = Quantity * UnitPrice`)
- Order total rollup and stock decrement on each added item
- Views for **order summaries** and **best-selling products (last 30 days)**
- Sample queries for last-month orders, revenue, top customers, and low stock

---

## 🧱 Schema (Core Tables)

- `Customers(CustomerID, Name, Email, Address, CreatedAt, UpdatedAt)`
- `Products(ProductID, Name, Price, StockQuantity, CreatedAt, UpdatedAt)`
- `Orders(OrderID, CustomerID, OrderDate, TotalAmount, CreatedAt, UpdatedAt)`
- `OrderDetails(OrderDetailID, OrderID, ProductID, Quantity, UnitPrice, Subtotal [PERSISTED], CreatedAt, UpdatedAt)`

**Relationships:**  
`Customers 1..* Orders` • `Orders 1..* OrderDetails` • `Products 1..* OrderDetails`

---

## 🗺️ ER Diagram (Mermaid)

```mermaid
erDiagram
  CUSTOMERS ||--o{ ORDERS : places
  ORDERS    ||--o{ ORDER_DETAILS : contains
  PRODUCTS  ||--o{ ORDER_DETAILS : sold_in

  CUSTOMERS {
    int CustomerID PK
    string Name
    string Email
    string Address
  }

  PRODUCTS {
    int ProductID PK
    string Name
    decimal Price
    int StockQuantity
  }

  ORDERS {
    int OrderID PK
    int CustomerID FK
    datetime OrderDate
    decimal TotalAmount
  }

  ORDER_DETAILS {
    int OrderDetailID PK
    int OrderID FK
    int ProductID FK
    int Quantity
    decimal UnitPrice
    decimal Subtotal
  }

---

## 🧪 Quickstart (Docker)
```bash
set +H
export SA_PASSWORD='YourStrong!Passw0rd'
docker compose -f docker/docker-compose.yml up -d
# then run the SQL in /sql (schema, procs, triggers, views, seed)

```
🗺️ ER Diagram (Mermaid)
erDiagram
  CUSTOMERS ||--o{ ORDERS : places
  ORDERS ||--o{ ORDERDETAILS : has
  PRODUCTS ||--o{ ORDERDETAILS : contains

  CUSTOMERS {
    int CustomerID PK
    string Name
    string Email
    string Address
    datetime CreatedAt
    datetime UpdatedAt
  }

  PRODUCTS {
    int ProductID PK
    string Name
    decimal Price
    int StockQuantity
    datetime CreatedAt
    datetime UpdatedAt
  }

  ORDERS {
    int OrderID PK
    int CustomerID FK
    datetime OrderDate
    string Status
    decimal TotalAmount
    datetime CreatedAt
    datetime UpdatedAt
  }

  ORDERDETAILS {
    int OrderDetailID PK
    int OrderID FK
    int ProductID FK
    int Quantity
    decimal UnitPrice
    decimal Subtotal "computed: Quantity*UnitPrice"
    datetime CreatedAt
    datetime UpdatedAt
  }


## Quickstart
```bash
set +H
export SA_PASSWORD='YourStrong!Passw0rd'
docker compose -f docker/docker-compose.yml up -d
# then run the SQL in /sql (schema → procs → triggers → views → seed)
```

Helpful Views

vwOrderSummary — orders with line counts and totals

vwBestSellers30D — top products by units & revenue (30d)

vwOrderSummaryWithStatus — includes Status

vwLowStock — low inventory products

## Windows Scripts

scripts/dev-init.bat — start container & run SQL

scripts/dev-status.bat — quick stats

scripts/report-low-stock.bat — export low-stock CSV

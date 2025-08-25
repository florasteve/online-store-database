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

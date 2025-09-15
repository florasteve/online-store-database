
# OnlineStoreDB
[![DB CI](https://github.com/florasteve/online-store-database/actions/workflows/db-ci.yml/badge.svg?branch=main)](https://github.com/florasteve/online-store-database/actions/workflows/db-ci.yml)
[![DB Tests](https://github.com/florasteve/online-store-database/actions/workflows/db-tests.yml/badge.svg?branch=main)](https://github.com/florasteve/online-store-database/actions/workflows/db-tests.yml)

<!-- Badges -->
[![License](https://img.shields.io/github/license/florasteve/online-store-database)](LICENSE)
[![Last commit](https://img.shields.io/github/last-commit/florasteve/online-store-database)](https://github.com/florasteve/online-store-database/commits/main)
[![Open issues](https://img.shields.io/github/issues/florasteve/online-store-database)](https://github.com/florasteve/online-store-database/issues)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/florasteve/online-store-database/pulls)
[![DB: SQL Server](https://img.shields.io/badge/DB-Microsoft%20SQL%20Server-CC2927?logo=microsoft-sql-server&logoColor=white)](https://www.microsoft.com/en-us/sql-server)
[![Container: Docker](https://img.shields.io/badge/Container-Docker-2496ED?logo=docker&logoColor=white)](https://www.docker.com)

**OnlineStoreDB** — Dockerized SQL Server demo with normalized schema (Customers, Products, Orders, OrderDetails), computed `Subtotal`, timestamps, procs for safe inserts & order lifecycle, analytics views, and seed data.

## <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/docker/docker-original.svg" height="20" alt="Docker logo"> Quickstart
```bash
set +H
export SA_PASSWORD='YourStrong!Passw0rd'
docker compose -f docker/docker-compose.yml up -d
```
  > *then run the SQL in /sql (schema → procs → triggers → views → seed)*


## <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/microsoftsqlserver/microsoftsqlserver-plain.svg" height="20" alt="SQL Server logo"> Helpful Views  
`vwOrderSummary` — orders with line counts and totals  
`vwBestSellers30D` — top products by units & revenue (last 30 days)  
`vwOrderSummaryWithStatus` — includes order `Status`  
`vwLowStock` — products with low inventory  

## <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/windows8/windows8-original.svg" height="20" alt="Windows logo"> Windows Scripts  
`scripts/dev-init.bat` — start container and run all SQL  
`scripts/dev-status.bat` — quick container/DB stats  
`scripts/report-low-stock.bat` — export low-stock CSV to `data/`  

## 🗺️ ER Diagram (Mermaid)
```mermaid
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
```

### Examples

**Category sales (30 days):**
```sql
SELECT TOP 10 CategoryName, Orders, Units, Revenue
FROM dbo.vwCategorySales30D
ORDER BY Revenue DESC;
```

**Close an order:**
```sql
EXEC dbo.CloseOrder @OrderID = 42;
```



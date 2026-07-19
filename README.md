# Hospital Billing Database Management System

## 🏥 Project Overview
A comprehensive database solution for hospital operations, managing the complete healthcare workflow from patient encounters through clinical services, insurance claims processing, and payment collection. This project demonstrates advanced database design principles including normalization to 3NF, strategic denormalization for performance, and complex business rule implementation.

## 🎯 Key Features
- **Patient Management**: Complete patient demographics and medical history tracking
- **Insurance Processing**: Multi-policy support with claims adjudication workflow
- **Clinical Operations**: Order management for labs, procedures, and medications
- **Billing Architecture**: Sophisticated payment processing with disjoint specialization pattern
- **Financial Tracking**: Complete audit trail from service delivery to payment collection
- **Provider Management**: Multi-provider encounter support with role-based assignments

## 💡 Technical Highlights
- **Database Design**: Achieved Third Normal Form (3NF) with strategic denormalization
- **Payment Architecture**: Implemented supertype/subtype pattern with disjoint specialization
- **Business Rules**: Enforced complex constraints including no patient installments, claim-charge relationships
- **Performance Optimization**: Direct foreign keys for common query patterns (Encounter → Billing_Charge)
- **Data Integrity**: Comprehensive constraints, triggers, and check conditions
- **SQL Implementation**: Complete DDL/DML scripts with 10+ rows of sample data per table

## 🏗️ Database Structure
- **16 Core Tables**: Patient, Insurance_Company, Insurance_Policy, Encounter, Provider, Clinical_Order, Billing_Charge, Claim, Payment (with subtypes)
- **Junction Tables**: Encounter_Provider, Claim_Charge for many-to-many relationships
- **Reference Tables**: Dictionary for standardized medical codes and pricing
- **Database Views**: `VW_PatientBillingSummary`, `VW_ProviderWorkload`, `VW_ActiveInsurancePolicies` for reporting
- **Triggers**: `TR_SettleBillingChargeOnClaimPayment_CTE` for automated payment processing
- **Stored Procedures & Functions**: `SP_ProcessNewOrderItem`, `SP_UpdateClaimStatus`, `SP_RecordPatientPayment`, `FN_CalculateItemCost`, `FN_GetPolicyCoverageRate`, `FN_GetTotalEncounterCharge`

## 📊 Design Decisions
- Separated Insurance_Company from Insurance_Policy to eliminate redundancy
- Implemented Payment supertype with Patient_Payment and Claim_Payment subtypes
- Strategic denormalization: Added encounter_id to Billing_Charge for query performance
- N:1 relationship from Billing_Charge to Patient_Payment (no installment complexity)

## 🛠️ Technologies Used
- **Database**: SQL Server
- **Design Tools**: draw.io for ERD modeling
- **SQL Features**: IDENTITY columns, BIT data types, CTEs, Views, Triggers
- **Documentation**: Comprehensive logical ERD with full attribute specifications

## 🚀 Getting Started

### Prerequisites
- SQL Server (2019+ recommended) or Azure SQL Database
- A SQL client (SSMS, Azure Data Studio, or `sqlcmd`)

### Setup

```bash
git clone https://github.com/ChloeA27/hospital_billing_management_system.git
cd hospital_billing_management_system
```

1. **Create the schema** — `database_scripts/DDL/create_tables.sql` drops and
   recreates a `HealthDB` database with all 16 tables, constraints, and
   relationships:
   ```bash
   sqlcmd -S <server> -i database_scripts/DDL/create_tables.sql
   ```
2. **Load sample data** — 10 rows per table:
   ```bash
   sqlcmd -S <server> -d HealthDB -i database_scripts/DML/insert_script.sql
   ```
3. **Create views, triggers, stored procedures & functions**:
   ```bash
   sqlcmd -S <server> -d HealthDB -i database_scripts/testing/psm_script.sql
   ```
4. **Validate** — row counts and data quality checks:
   ```bash
   sqlcmd -S <server> -d HealthDB -i database_scripts/DML/validation_proj.sql
   ```
5. **(Optional) Apply performance/security scripts**:
   ```bash
   sqlcmd -S <server> -d HealthDB -i database_scripts/optimization/indexes_script.sql
   sqlcmd -S <server> -d HealthDB -i database_scripts/optimization/encryption_script.sql
   ```
6. **(Optional) Run the stored-procedure test suite**:
   ```bash
   sqlcmd -S <server> -d HealthDB -i database_scripts/testing/test_psm.sql
   ```

## 📁 Repository Structure
```
/hospital_billing_management_system
│
├── README.md                      # Project documentation
│
├── /design_documents
│   ├── statement_and_objectives.pdf  # Mission statement and project objectives
│   ├── conceptual_DB_design.pdf      # Conceptual database design document
│   └── logical_DB_design.pdf         # Comprehensive logical design documentation
│
├── /ERD diagrams
│   ├── conceptual_ERD.png           # Conceptual ERD
│   └── logical_ERD_updated.png      # Logical ERD
│
├── /database_scripts
│   ├── /DDL
│   │   └── create_tables.sql        # Database schema creation
│   │
│   ├── /DML
│   │   ├── insert_script.sql        # Sample data insertion
│   │   └── validation_proj.sql      # Data validation checks
│   │ 
│   ├── /optimization
│   │   ├── indexes_script.sql       # Performance optimization indexes
│   │   └── encryption_script.sql    # Data security implementation
│   │
│   └── /testing
│       ├── psm_script.sql           # Stored procedures and functions
│       └── test_psm.sql             # Test cases for procedures
```

## 🎓 Academic Context
Developed as a comprehensive database course project demonstrating:
- Conceptual to logical ERD transformation
- Normalization theory application
- Business rule enforcement through database constraints
- Performance optimization techniques
- Financial transaction modeling

## 🚀 Future Enhancements
- [ ] Implement audit logging for HIPAA compliance
- [ ] Develop API layer for application integration

## 👤 Author

**Qi An**
- GitHub: [@ChloeA27](https://github.com/ChloeA27)
- LinkedIn: [Qi An](https://www.linkedin.com/in/qianchloe/)

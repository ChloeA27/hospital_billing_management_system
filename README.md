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
- **Database Views**: VW_PatientBillingSummary for reporting
- **Triggers**: TR_SettleBillingChargeOnClaimPayment_CTE for automated payment processing

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

## 📁 Repository Structure
```
/hospital-management-system
│
├── README.md                      # Project documentation
│
├── /Design Documents
│   ├── statement_and_objectives.pdf  # Mission statement and project objectives
│   ├── conceptual_DB_design.pdf      # Conceptual database design document
│   └── logical_DB_design.pdf         # Comprehensive logical design documentation
│
├── /ERD Diagrams
│   ├── conceptual_ERD.png           # Conceptual ERD
│   └── logical_ERD_updated.png      # Logical ERD
│
├── /Database Scripts
│   ├── /DDL
│   │   └── create_tables.sql        # Database schema creation
│   │
│   ├── /DML
│   │   ├── insert_script.sql        # Sample data insertion
│   │   └── validation_proj.sql      # Data validation checks
│   │ 
│   ├── /Optimization
│   │   ├── indexes_script.sql       # Performance optimization indexes
│   │   └── encryption_script.sql    # Data security implementation
│   │
│   └── /Testing
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

## 📫 Contact
Feel free to reach out for questions about the implementation!

## LinkedIn

```
https://www.linkedin.com/in/qianchloe/
```


🚀 Excited to share my Hospital Database Management System project! 

I've designed and implemented a comprehensive database solution that manages the entire healthcare workflow - from patient encounters through insurance claims to payment processing.

🔧 Technical Highlights:
- Achieved 3NF normalization while strategically denormalizing for performance
- Implemented sophisticated payment architecture using disjoint specialization patterns
- Designed 16+ interconnected tables managing patient care, billing, and insurance workflows
- Created automated triggers and views for financial reconciliation
- Enforced complex business rules through database constraints

💡 Key Design Decisions:
- Separated Insurance_Company from Policy entities to eliminate redundancy
- Built Payment supertype with Patient_Payment and Claim_Payment subtypes
- Optimized query performance through strategic foreign key placement
- Handled N:M relationships through properly designed junction tables

📊 Business Impact:
This system can track multiple insurance policies per patient, handle partial payments, support claim resubmissions, and maintain complete audit trails - all while ensuring data integrity.

The project demonstrates my ability to translate complex business requirements into efficient database architectures, balance normalization with performance needs, and implement enterprise-level database solutions.


#DatabaseDesign #SQL #DataModeling #HealthcareIT #SoftwareEngineering #DatabaseDevelopment #SQLServer #SystemDesign #TechInnovation #OpenToWork

Would love to connect with teams working on data-intensive applications!

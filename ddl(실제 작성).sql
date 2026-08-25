
/* =========================================================
   1. 근로계약
   employment_contract
   ========================================================= */



CREATE TABLE employment_contract (

    contract_no NUMBER PRIMARY KEY,

    employee_no NUMBER NOT NULL
        REFERENCES employee(employee_no),

    wage_type VARCHAR2(10) NOT NULL,
    CHECK (
        wage_type IN ('monthly', 'hourly', 'daily')
    ),

    base_wage NUMBER NOT NULL,
    CHECK (
        base_wage >= 0
    ),

    daily_work_hours NUMBER NOT NULL,
    CHECK (
        daily_work_hours >= 0
    ),

    weekly_work_hours NUMBER NOT NULL,
    CHECK (
        weekly_work_hours >= 0
    ),

    contract_start TIMESTAMP NOT NULL,

    contract_end TIMESTAMP,

    CHECK (
        contract_end IS NULL
        OR contract_end >= contract_start
    ),

    payday NUMBER(2) NOT NULL,
    CHECK (
        payday BETWEEN 1 AND 31
    ),

    contract_status VARCHAR2(12)
        DEFAULT 'active'
        NOT NULL,

    CHECK (
        contract_status IN (
            'active',
            'scheduled',
            'ended'
        )
    ),

    contract_content CLOB NOT NULL,

    employee_signature VARCHAR2(1000) NOT NULL,

    employer_signature VARCHAR2(1000) NOT NULL,

    signed_time TIMESTAMP NOT NULL
);


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


ALTER TABLE employment_contract
MODIFY employee_signature NULL;

ALTER TABLE employment_contract
MODIFY employer_signature NULL;

ALTER TABLE employment_contract
MODIFY signed_time NULL;


/* =========================================================
   2. 직원 근태
   employee_attendance
   ========================================================= */

CREATE TABLE employee_attendance (

    emp_attendance_no NUMBER PRIMARY KEY,

    contract_no NUMBER NOT NULL
        REFERENCES employment_contract(contract_no)
        ON DELETE CASCADE,

    work_date TIMESTAMP NOT NULL,

    clock_in TIMESTAMP,

    clock_out TIMESTAMP,

    break_minutes NUMBER DEFAULT 0 NOT NULL,
    CHECK (
        break_minutes >= 0
    ),

    attendance_type VARCHAR2(20)
        DEFAULT 'normal'
        NOT NULL,
    CHECK (
        attendance_type IN (
            'normal',
            'absent',
            'paid_leave',
            'unpaid_leave'
        )
    ),

    work_day_type VARCHAR2(10)
        DEFAULT 'weekday'
        NOT NULL,
    CHECK (
        work_day_type IN (
            'weekday',
            'holiday'
        )
    ),

    night_hours NUMBER DEFAULT 0 NOT NULL,
    CHECK (
        night_hours >= 0
    ),

    overtime_hours NUMBER DEFAULT 0 NOT NULL,
    CHECK (
        overtime_hours >= 0
    ),

    CHECK (
        clock_out IS NULL
        OR clock_in IS NULL
        OR clock_out >= clock_in
    ),

    UNIQUE (
        contract_no,
        work_date
    )
);

/* =========================================================
   1. 근로계약
   employment_contract
   ========================================================= */

CREATE TABLE employment_contract (
    contract_no NUMBER PRIMARY KEY,

    employee_no NUMBER NOT NULL
        REFERENCES employee(employee_no),

    wage_type VARCHAR2(10) NOT NULL
        CHECK (wage_type IN ('월급', '시급', '일급')),

    base_wage NUMBER NOT NULL
        CHECK (base_wage >= 0),

    daily_work_hours NUMBER(5,2) NOT NULL
        CHECK (daily_work_hours >= 0),

    weekly_work_hours NUMBER(5,2) NOT NULL
        CHECK (weekly_work_hours >= 0),

    contract_start TIMESTAMP NOT NULL,

    contract_end TIMESTAMP,

    payday NUMBER(2) NOT NULL
        CHECK (payday BETWEEN 1 AND 31),

    contract_status VARCHAR2(12) DEFAULT '진행중' NOT NULL
        CHECK (contract_status IN ('예정', '진행중', '종료')),

    employee_signature VARCHAR2(300) NOT NULL,

    employer_signature VARCHAR2(300) NOT NULL,

    signatured_time TIMESTAMP NOT NULL,

    CHECK (
        contract_end IS NULL
        OR contract_end >= contract_start
    )
);



/* =========================================================
   2. 직원근태
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

    break_minutes NUMBER DEFAULT 0 NOT NULL
        CHECK (break_minutes >= 0),

    attendance_type VARCHAR2(20) DEFAULT '정상' NOT NULL
        CHECK (
            attendance_type IN (
                '정상',
                '결근',
                '유급휴가',
                '무급휴가'
            )
        ),

    work_day_type VARCHAR2(10) DEFAULT '평일' NOT NULL
        CHECK (
            work_day_type IN ('평일', '휴일')
        ),

    night_hours NUMBER(6,2) DEFAULT 0 NOT NULL
        CHECK (night_hours >= 0),

    overtime_hours NUMBER(6,2) DEFAULT 0 NOT NULL
        CHECK (overtime_hours >= 0),

    UNIQUE (
        contract_no,
        work_date
    ),

    CHECK (
        clock_out IS NULL
        OR clock_in IS NULL
        OR clock_out >= clock_in
    )
);



/* =========================================================
   3. 급여
   payroll
   ========================================================= */

CREATE TABLE payroll (
    payroll_no NUMBER PRIMARY KEY,

    contract_no NUMBER NOT NULL
        REFERENCES employment_contract(contract_no)
        ON DELETE CASCADE,

    payroll_year NUMBER(4) NOT NULL,

    payroll_month NUMBER(2) NOT NULL
        CHECK (payroll_month BETWEEN 1 AND 12),

    payroll_status VARCHAR2(10) DEFAULT '산정중' NOT NULL
        CHECK (
            payroll_status IN (
                '산정중',
                '확정',
                '지급완료'
            )
        ),

    UNIQUE (
        contract_no,
        payroll_year,
        payroll_month
    )
);



/* =========================================================
   4. 급여 반영 근태
   payroll_attendance
   ========================================================= */

CREATE TABLE payroll_attendance (
    payroll_attendance_no NUMBER PRIMARY KEY,

    emp_attendance_no NUMBER NOT NULL
        REFERENCES employee_attendance(emp_attendance_no)
        ON DELETE CASCADE,

    payroll_no NUMBER NOT NULL
        REFERENCES payroll(payroll_no)
        ON DELETE CASCADE,

    UNIQUE (
        payroll_no,
        emp_attendance_no
    )
);



/* =========================================================
   5. 급여 지급항목
   payroll_earning
   ========================================================= */

CREATE TABLE payroll_earning (
    payroll_earning_no NUMBER PRIMARY KEY,

    payroll_no NUMBER NOT NULL
        REFERENCES payroll(payroll_no)
        ON DELETE CASCADE,

    earning_type VARCHAR2(20) NOT NULL
        CHECK (
            earning_type IN (
                '기본급',
                '수당',
                '기타'
            )
        ),

    earning_name VARCHAR2(30) NOT NULL
);



/* =========================================================
   6. 지급 계산근거
   payroll_earning_calc
   ========================================================= */

CREATE TABLE payroll_earning_calc (
    earning_calc_no NUMBER PRIMARY KEY,

    payroll_earning_no NUMBER NOT NULL
        REFERENCES payroll_earning(payroll_earning_no)
        ON DELETE CASCADE,

    base_amount NUMBER
        CHECK (
            base_amount IS NULL
            OR base_amount >= 0
        ),

    work_hours NUMBER(7,2)
        CHECK (
            work_hours IS NULL
            OR work_hours >= 0
        ),

    earn_calculated_amount NUMBER NOT NULL
        CHECK (earn_calculated_amount >= 0),

    earn_calc_note VARCHAR2(200)
);



/* =========================================================
   7. 급여 공제항목
   payroll_deduction
   ========================================================= */

CREATE TABLE payroll_deduction (
    deduction_no NUMBER PRIMARY KEY,

    payroll_no NUMBER NOT NULL
        REFERENCES payroll(payroll_no)
        ON DELETE CASCADE,

    deduction_type VARCHAR2(30) NOT NULL
        CHECK (
            deduction_type IN (
                '소득세',
                '지방소득세',
                '국민연금',
                '건강보험',
                '장기요양보험',
                '고용보험',
                '기타'
            )
        )
);



/* =========================================================
   8. 공제 계산근거
   payroll_deduction_calc
   ========================================================= */

CREATE TABLE payroll_deduction_calc (
    deduction_calc_no NUMBER PRIMARY KEY,

    deduction_no NUMBER NOT NULL
        REFERENCES payroll_deduction(deduction_no)
        ON DELETE CASCADE,

    base_amount NUMBER NOT NULL
        CHECK (base_amount >= 0),

    deduction_rate NUMBER(10,6)
        CHECK (
            deduction_rate IS NULL
            OR deduction_rate >= 0
        ),

    fixed_deduction_amount NUMBER
        CHECK (
            fixed_deduction_amount IS NULL
            OR fixed_deduction_amount >= 0
        ),

    deduction_calculated_amount NUMBER NOT NULL
        CHECK (deduction_calculated_amount >= 0),

    deduction_basis_year NUMBER(4) NOT NULL,

    deduction_calc_note VARCHAR2(200)
);



/* =========================================================
   9. 급여 지급이력
   payroll_payment
   ========================================================= */

CREATE TABLE payroll_payment (
    payroll_payment_no NUMBER PRIMARY KEY,

    payroll_no NUMBER NOT NULL
        REFERENCES payroll(payroll_no)
        ON DELETE CASCADE,

    payment_amount NUMBER NOT NULL
        CHECK (payment_amount >= 0),

    payment_at TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,

    payment_action VARCHAR2(10) NOT NULL
        CHECK (
            payment_action IN (
                '지급',
                '취소'
            )
        ),

    payment_method VARCHAR2(20),

    payment_note VARCHAR2(200)
);

CREATE TABLE `employment_contract` (
	`contract_no`	NUMBER	NOT NULL	COMMENT '근로계약번호',
	`wage_type`	VARCHAR(10)	NOT NULL	COMMENT '급여형태 : 월급/시급/일급',
	`base_wage`	NUMBER	NOT NULL	COMMENT '계약상 기준임금',
	`weekly_work_hours`	NUMBER	NOT NULL	COMMENT '주 소정근로시간',
	`contract_start`	TIMESTAMP	NOT NULL	COMMENT '근로계약 시작일',
	`contract_end`	TIMESTAMP	NULL	COMMENT '근로계약 종료일, 계약 진행중이면 NULL',
	`payday`	NUMBER(2)	NOT NULL	COMMENT '매월 급여 지급 예정일',
	`employee_no`	number	NOT NULL,
	`contract_status`	varchar(12)	NOT NULL	DEFAULT 진행중	COMMENT '작성중/예정/진행중/종료',
	`daily_work_hours`	number	NOT NULL	COMMENT '1일 소정 근로 시간',
	`employee_signature`	varchar(20)	NULL,
	`employer_signature`	varchar(20)	NULL,
	`signed_time`	timestamp	NULL,
	`contract_content`	clob	NOT NULL,
	`break_minutes`	number	NOT NULL	DEFAULT 0
);

CREATE TABLE `employee_attendance` (
	`emp_attendance_no`	NUMBER	NOT NULL	COMMENT '직원 근태번호',
	`contract_no`	NUMBER	NOT NULL	COMMENT '근로계약번호',
	`work_date`	timestamp	NOT NULL	COMMENT '근무 날짜',
	`clock_in`	TIMESTAMP	NULL	COMMENT '출근시간',
	`clock_out`	TIMESTAMP	NULL	COMMENT '퇴근시간',
	`break_minutes`	NUMBER	NOT NULL	DEFAULT 0	COMMENT '휴게시간(분), 없으면 0',
	`attendance_type`	VARCHAR(20)	NOT NULL	COMMENT '근태구분:정상/결근/유급휴가/무급휴가',
	`work_day_type`	varchar(10)	NOT NULL	DEFAULT 평일	COMMENT '근무 날짜 구분(평일/휴일/비근무일(휴무일))',
	`night_hours`	number	NOT NULL	DEFAULT 0,
	`overtime_hours`	number	NOT NULL	DEFAULT 0,
	`work_schedule_no`	number	NOT NULL
);

ALTER TABLE employee_attendance
DROP COLUMN work_day_type;


CREATE TABLE employee_work_schedule (
    work_schedule_no NUMBER NOT NULL,
    contract_no NUMBER NOT NULL,

    scheduled_work_date TIMESTAMP NOT NULL,

    scheduled_clock_in TIMESTAMP NULL,
    scheduled_clock_out TIMESTAMP NULL,

    scheduled_day_type VARCHAR2(10) NOT NULL,

    actual_work_hours NUMBER DEFAULT 0 NOT NULL,
    actual_overtime_hours NUMBER DEFAULT 0 NOT NULL,
    actual_night_hours NUMBER DEFAULT 0 NOT NULL,
    actual_holiday_hours NUMBER DEFAULT 0 NOT NULL,

    CONSTRAINT pk_employee_work_schedule
        PRIMARY KEY (work_schedule_no),

    CONSTRAINT fk_contract_work_schedule
        FOREIGN KEY (contract_no)
        REFERENCES employment_contract(contract_no),

    CONSTRAINT uq_contract_work_date
        UNIQUE (
            contract_no,
            scheduled_work_date
        ),

  CONSTRAINT ck_work_schedule_day_type
CHECK (
    scheduled_day_type IN (
        'workday',
        'holiday',
        'dayOff'
    )
)
);
CREATE SEQUENCE work_schedule_seq;





-- =========================================================
-- 1. PAYROLL
-- 직원 월 급여 산정 결과
-- =========================================================

CREATE TABLE payroll (
    payroll_no NUMBER NOT NULL,
    employee_no NUMBER NOT NULL,

    payroll_year NUMBER(4) NOT NULL,
    payroll_month NUMBER(2) NOT NULL,

    total_work_hours NUMBER DEFAULT 0 NOT NULL,
    total_overtime_hours NUMBER DEFAULT 0 NOT NULL,
    total_night_hours NUMBER DEFAULT 0 NOT NULL,
    total_holiday_hours NUMBER DEFAULT 0 NOT NULL,

    base_pay NUMBER DEFAULT 0 NOT NULL,
    week_holiday_pay NUMBER DEFAULT 0 NOT NULL,
    overtime_pay NUMBER DEFAULT 0 NOT NULL,
    night_pay NUMBER DEFAULT 0 NOT NULL,
    holiday_pay NUMBER DEFAULT 0 NOT NULL,

    gross_pay NUMBER DEFAULT 0 NOT NULL,
    total_deduction NUMBER DEFAULT 0 NOT NULL,
    net_pay NUMBER DEFAULT 0 NOT NULL,

    payroll_status VARCHAR2(12) DEFAULT 'calculating' NOT NULL,

    calculated_at TIMESTAMP NULL,
    confirmed_at TIMESTAMP NULL,

    CONSTRAINT pk_payroll
        PRIMARY KEY (payroll_no),

    CONSTRAINT fk_payroll_employee
        FOREIGN KEY (employee_no)
        REFERENCES employee(employee_no),

    CONSTRAINT uk_payroll_employee_period
        UNIQUE (
            employee_no,
            payroll_year,
            payroll_month
        ),

    CONSTRAINT ck_payroll_year
        CHECK (
            payroll_year BETWEEN 2000 AND 9999
        ),

    CONSTRAINT ck_payroll_month
        CHECK (
            payroll_month BETWEEN 1 AND 12
        ),

    CONSTRAINT ck_payroll_hours
        CHECK (
            total_work_hours >= 0
            AND total_overtime_hours >= 0
            AND total_night_hours >= 0
            AND total_holiday_hours >= 0
        ),

    CONSTRAINT ck_payroll_amount
        CHECK (
            base_pay >= 0
            AND week_holiday_pay >= 0
            AND overtime_pay >= 0
            AND night_pay >= 0
            AND holiday_pay >= 0
            AND gross_pay >= 0
            AND total_deduction >= 0
            AND net_pay >= 0
        ),

    CONSTRAINT ck_payroll_status
        CHECK (
            payroll_status IN (
                'calculating',
                'confirmed'
            )
        )
);


-- =========================================================
-- 2. PAYROLL_DEDUCTION
-- 급여 공제 내역
-- =========================================================

CREATE TABLE payroll_deduction (
    deduction_no NUMBER NOT NULL,
    payroll_no NUMBER NOT NULL,

    deduction_type VARCHAR2(30) NOT NULL,

    base_amount NUMBER NOT NULL,
    deduction_rate NUMBER NULL,
    fixed_deduction_amount NUMBER NULL,

    deduction_amount NUMBER NOT NULL,

    deduction_basis_year NUMBER(4) NOT NULL,
    deduction_note VARCHAR2(200) NULL,

    CONSTRAINT pk_payroll_deduction
        PRIMARY KEY (deduction_no),

    CONSTRAINT fk_deduction_payroll
        FOREIGN KEY (payroll_no)
        REFERENCES payroll(payroll_no),

    CONSTRAINT uk_payroll_deduction_type
        UNIQUE (
            payroll_no,
            deduction_type
        ),

    CONSTRAINT ck_deduction_base_amount
        CHECK (
            base_amount >= 0
        ),

    CONSTRAINT ck_deduction_rate
        CHECK (
            deduction_rate IS NULL
            OR deduction_rate >= 0
        ),

    CONSTRAINT ck_deduction_fixed_amount
        CHECK (
            fixed_deduction_amount IS NULL
            OR fixed_deduction_amount >= 0
        ),

    CONSTRAINT ck_deduction_amount
        CHECK (
            deduction_amount >= 0
        ),

    CONSTRAINT ck_deduction_basis_year
        CHECK (
            deduction_basis_year BETWEEN 2000 AND 9999
        ),

    CONSTRAINT ck_deduction_type
        CHECK (
            deduction_type IN (
                '국민연금',
                '건강보험',
                '장기요양보험',
                '고용보험',
                '소득세',
                '지방소득세',
                '기타'
            )
        )
);


-- =========================================================
-- 3. PAYROLL_PAYMENT
-- 실제 급여 지급 / 취소 내역
-- =========================================================

CREATE TABLE payroll_payment (
    payroll_payment_no NUMBER NOT NULL,
    payroll_no NUMBER NOT NULL,

    payment_amount NUMBER NOT NULL,
    payment_at TIMESTAMP NOT NULL,

    payment_status VARCHAR(25) ,
    payment_method VARCHAR2(20) NULL,
    payment_note VARCHAR2(200) NULL,

    CONSTRAINT pk_payroll_payment
        PRIMARY KEY (payroll_payment_no),

    CONSTRAINT fk_payment_payroll
        FOREIGN KEY (payroll_no)
        REFERENCES payroll(payroll_no),

    CONSTRAINT ck_payment_amount
        CHECK (
            payment_amount > 0
        ),

    CONSTRAINT ck_payment_status
        CHECK (
            payment_status IN (
               
				'paid',
                'cancel'
            )
        )
);

//급여 취소로 인한 추가

alter table payroll_payment
add cancel_target_payment_no number;

alter table payroll_payment
add constraint FK_PAYMENT_CANCEL_TARGET
foreign key (cancel_target_payment_no)
references payroll_payment(payroll_payment_no);

alter table payroll_payment
add constraint UK_PAYMENT_CANCEL_TARGET
unique (cancel_target_payment_no);

alter table payroll_payment
add constraint CK_PAYMENT_CANCEL_TARGET
check (
    (payment_status = 'paid'
        and cancel_target_payment_no is null)
    or
    (payment_status = 'cancelled'
        and cancel_target_payment_no is not null)
);

alter table payroll_payment
add constraint CK_PAYMENT_METHOD_REQUIRED
check (
    payment_status != 'paid'
    or payment_method is not null
);

-- =========================================================
-- SEQUENCE
-- =========================================================

CREATE SEQUENCE payroll_seq
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

CREATE SEQUENCE payroll_deduction_seq
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

CREATE SEQUENCE payroll_payment_seq
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;


-- =========================================================
-- COMMENTS : PAYROLL
-- =========================================================

COMMENT ON TABLE payroll IS '직원 월 급여 산정 결과';

COMMENT ON COLUMN payroll.payroll_no IS '급여번호';
COMMENT ON COLUMN payroll.employee_no IS '직원번호';

COMMENT ON COLUMN payroll.payroll_year IS '급여 산정 연도';
COMMENT ON COLUMN payroll.payroll_month IS '급여 산정 월';

COMMENT ON COLUMN payroll.total_work_hours IS '총 실제 근로시간';
COMMENT ON COLUMN payroll.total_overtime_hours IS '총 연장근로시간';
COMMENT ON COLUMN payroll.total_night_hours IS '총 야간근로시간';
COMMENT ON COLUMN payroll.total_holiday_hours IS '총 휴일근로시간';

COMMENT ON COLUMN payroll.base_pay IS '산정 기본급';
COMMENT ON COLUMN payroll.week_holiday_pay IS '주휴수당';
COMMENT ON COLUMN payroll.overtime_pay IS '연장근로수당';
COMMENT ON COLUMN payroll.night_pay IS '야간근로수당';
COMMENT ON COLUMN payroll.holiday_pay IS '휴일근로수당';

COMMENT ON COLUMN payroll.gross_pay IS '공제 전 총 지급액';
COMMENT ON COLUMN payroll.total_deduction IS '총 공제금액';
COMMENT ON COLUMN payroll.net_pay IS '공제 후 지급금액';

COMMENT ON COLUMN payroll.payroll_status IS '급여 산정 상태 calculating/confirmed';

COMMENT ON COLUMN payroll.calculated_at IS '급여 산정 일시';
COMMENT ON COLUMN payroll.confirmed_at IS '급여 확정 일시';


-- =========================================================
-- COMMENTS : PAYROLL_DEDUCTION
-- =========================================================

COMMENT ON TABLE payroll_deduction IS '급여별 공제 내역';

COMMENT ON COLUMN payroll_deduction.deduction_no IS '급여 공제번호';
COMMENT ON COLUMN payroll_deduction.payroll_no IS '급여번호';

COMMENT ON COLUMN payroll_deduction.deduction_type IS '공제항목';

COMMENT ON COLUMN payroll_deduction.base_amount IS '공제 계산 기준금액';
COMMENT ON COLUMN payroll_deduction.deduction_rate IS '공제 적용 요율';
COMMENT ON COLUMN payroll_deduction.fixed_deduction_amount IS '정액 공제금액';

COMMENT ON COLUMN payroll_deduction.deduction_amount IS '최종 공제금액';

COMMENT ON COLUMN payroll_deduction.deduction_basis_year IS '공제 기준연도';
COMMENT ON COLUMN payroll_deduction.deduction_note IS '공제 비고';


-- =========================================================
-- COMMENTS : PAYROLL_PAYMENT
-- =========================================================

COMMENT ON TABLE payroll_payment IS '급여 실제 지급 및 취소 내역';

COMMENT ON COLUMN payroll_payment.payroll_payment_no IS '급여 지급내역번호';
COMMENT ON COLUMN payroll_payment.payroll_no IS '급여번호';
COMMENT ON COLUMN payroll_payment.payment_amount IS '실제 지급 또는 취소 금액';
COMMENT ON COLUMN payroll_payment.payment_at IS '지급 또는 취소 처리일시';
COMMENT ON COLUMN payroll_payment.payment_action IS '지급행위: paid/cancel';
COMMENT ON COLUMN payroll_payment.payment_method IS '지급방법';
COMMENT ON COLUMN payroll_payment.payment_note IS '지급 비고';




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

CREATE TABLE `employee_work_schedule` (
	`work_schedule_no`	number	NOT NULL,
	`schedule_date`	timestamp	NOT NULL,
	`schedule_day_type`	varchar2(10)	NOT NULL,
	`employee_no2`	number	NOT NULL
);

ALTER TABLE `employment_contract` ADD CONSTRAINT `PK_EMPLOYMENT_CONTRACT` PRIMARY KEY (
	`contract_no`
);

ALTER TABLE `employee_attendance` ADD CONSTRAINT `PK_EMPLOYEE_ATTENDANCE` PRIMARY KEY (
	`emp_attendance_no`
);

ALTER TABLE `employee_work_schedule` ADD CONSTRAINT `PK_EMPLOYEE_WORK_SCHEDULE` PRIMARY KEY (
	`work_schedule_no`
);

ALTER TABLE `employment_contract` ADD CONSTRAINT `FK_employee_TO_employment_contract_1` FOREIGN KEY (
	`employee_no`
)
REFERENCES `employee` (
	`employee_no`
);

ALTER TABLE `employee_attendance` ADD CONSTRAINT `FK_employment_contract_TO_employee_attendance_1` FOREIGN KEY (
	`contract_no`
)
REFERENCES `employment_contract` (
	`contract_no`
);

ALTER TABLE `employee_attendance` ADD CONSTRAINT `FK_employee_work_schedule_TO_employee_attendance_1` FOREIGN KEY (
	`work_schedule_no`
)
REFERENCES `employee_work_schedule` (
	`work_schedule_no`
);

ALTER TABLE `employee_work_schedule` ADD CONSTRAINT `FK_employee_TO_employee_work_schedule_1` FOREIGN KEY (
	`employee_no`
)
REFERENCES `employee` (
	`employee_no`
);



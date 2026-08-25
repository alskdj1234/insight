
/* =========================================================
   1. 근로계약
   employment_contract
   ========================================================= */



CREATE TABLE employment_contract(

	contract_no NUMBER PRIMARY KEY,
	
	employee_no NUMBER NOT NULL REFERENCES employee(employee_no),
	
	wage_type varchar(10) NOT NULL,
	
	 check(wage_type IN ('monthly','hourly','daily')),
	 
	base_wage NUMBER NOT NULL,
	check(base_wage>=0),
	
	daily_work_hours NUMBER NOT NULL,
	CHECK (daily_work_hours >=0),
	
	weekly_work_hours NUMBER NOT NULL,
	CHECK (weekly_work_hours >=0),
	
	contract_start timestamp NOT NULL,

	contract_end timestamp,
	check(
		contract_end IS NULL OR contract_end >= CONTRACT_START 
	),
	
	payday NUMBER(2) NOT NULL,
	CHECK (payday BETWEEN  1 AND 31),
	
	contract_status varchar(12) DEFAULT 'active' NOT NULL,
	check(contract_status IN ('active','scheduled','ended')),
	
	employee_signature varchar(1000) NOT NULL,
	
	employer_signature varchar(1000) NOT NULL,
	
	signed_time timestamp NOT NULL
	
);

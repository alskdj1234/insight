ㅇㅇ. DDL 초안이랑 같이 저장하려면 **구조도에서도 PK / FK / UNIQUE가 바로 보이게** 이렇게 적는 게 제일 낫다.

표기부터 고정하면:

```text
PK = Primary Key
FK = Foreign Key
UK = Unique Key
NN = NOT NULL
```

### 1. EMPLOYMENT_CONTRACT

```text
┌─────────────────────────────────────────────┐
│ EMPLOYMENT_CONTRACT                         │
├─────────────────────────────────────────────┤
│ PK  contract_no          NUMBER              │
│ FK  employee_no          NUMBER              │
│     → employee.employee_no                   │
│     ON DELETE SET NULL                       │
│                                             │
│ NN  wage_type            VARCHAR2(20)        │
│ NN  base_wage            NUMBER              │
│ NN  daily_work_hours     NUMBER(5,2)         │
│ NN  weekly_work_hours    NUMBER(5,2)         │
│ NN  contract_start       DATE                │
│     contract_end         DATE                │
│ NN  payday               NUMBER(2)           │
│ NN  contract_status      VARCHAR2(20)        │
└─────────────────────────────────────────────┘
```

`employee_no`는 `ON DELETE SET NULL`이라 NOT NULL 아님.

---

### 2. EMPLOYEE_ATTENDANCE

```text
┌─────────────────────────────────────────────┐
│ EMPLOYEE_ATTENDANCE                         │
├─────────────────────────────────────────────┤
│ PK  emp_attendance_no    NUMBER              │
│                                             │
│ FK  contract_no          NUMBER NN           │
│     → employment_contract.contract_no        │
│     ON DELETE CASCADE                        │
│                                             │
│ NN  work_date            DATE                │
│     clock_in             TIMESTAMP           │
│     clock_out            TIMESTAMP           │
│ NN  break_minutes        NUMBER              │
│ NN  attendance_type      VARCHAR2(20)        │
│ NN  work_day_type        VARCHAR2(20)        │
│ NN  overtime_hours       NUMBER(6,2)         │
│ NN  night_hours          NUMBER(6,2)         │
├─────────────────────────────────────────────┤
│ UK  (contract_no, work_date)                 │
└─────────────────────────────────────────────┘
```

즉 같은 계약에서 같은 날짜 근태가 두 개 생기는 걸 막음.

---

### 3. PAYROLL

```text
┌─────────────────────────────────────────────┐
│ PAYROLL                                     │
├─────────────────────────────────────────────┤
│ PK  payroll_no           NUMBER              │
│                                             │
│ FK  contract_no          NUMBER NN           │
│     → employment_contract.contract_no        │
│     ON DELETE CASCADE                        │
│                                             │
│ NN  payroll_year         NUMBER(4)           │
│ NN  payroll_month        NUMBER(2)           │
│ NN  payroll_status       VARCHAR2(20)        │
├─────────────────────────────────────────────┤
│ UK  (contract_no,                         │
│      payroll_year,                           │
│      payroll_month)                          │
└─────────────────────────────────────────────┘
```

한 계약에 대해 **같은 연·월 급여가 두 개 생성되는 걸 방지**.

---

### 4. PAYROLL_ATTENDANCE

```text
┌─────────────────────────────────────────────┐
│ PAYROLL_ATTENDANCE                          │
├─────────────────────────────────────────────┤
│ PK  payroll_attendance_no NUMBER             │
│                                             │
│ FK  payroll_no            NUMBER NN          │
│     → payroll.payroll_no                     │
│     ON DELETE CASCADE                        │
│                                             │
│ FK  emp_attendance_no     NUMBER NN          │
│     → employee_attendance.emp_attendance_no  │
│     ON DELETE CASCADE                        │
├─────────────────────────────────────────────┤
│ UK  (payroll_no, emp_attendance_no)          │
└─────────────────────────────────────────────┘
```

여기가 딱 **급여 ↔ 근태 연결 테이블**임.

같은 근태를 같은 급여에 두 번 넣는 미친 짓을 UNIQUE가 막아줌.

---

### 5. PAYROLL_EARNING

```text
┌─────────────────────────────────────────────┐
│ PAYROLL_EARNING                             │
├─────────────────────────────────────────────┤
│ PK  payroll_earning_no   NUMBER              │
│                                             │
│ FK  payroll_no           NUMBER NN           │
│     → payroll.payroll_no                     │
│     ON DELETE CASCADE                        │
│                                             │
│ NN  earning_type         VARCHAR2(20)        │
│ NN  earning_name         VARCHAR2(50)        │
└─────────────────────────────────────────────┘
```

예:

```text
수당 / 연장수당
수당 / 야간수당
기본급 / 기본급
```

---

### 6. PAYROLL_EARNING_CALC

```text
┌─────────────────────────────────────────────┐
│ PAYROLL_EARNING_CALC                        │
├─────────────────────────────────────────────┤
│ PK  earning_calc_no          NUMBER          │
│                                             │
│ FK  payroll_earning_no       NUMBER NN       │
│     → payroll_earning.payroll_earning_no     │
│     ON DELETE CASCADE                        │
│                                             │
│ NN  base_amount              NUMBER          │
│     work_hours               NUMBER(7,2)     │
│ NN  earn_calculated_amount   NUMBER          │
│     earn_calc_note           VARCHAR2(500)   │
└─────────────────────────────────────────────┘
```

---

### 7. PAYROLL_DEDUCTION

```text
┌─────────────────────────────────────────────┐
│ PAYROLL_DEDUCTION                           │
├─────────────────────────────────────────────┤
│ PK  deduction_no         NUMBER              │
│                                             │
│ FK  payroll_no           NUMBER NN           │
│     → payroll.payroll_no                     │
│     ON DELETE CASCADE                        │
│                                             │
│ NN  deduction_type       VARCHAR2(30)        │
└─────────────────────────────────────────────┘
```

---

### 8. PAYROLL_DEDUCTION_CALC

```text
┌───────────────────────────────────────────────┐
│ PAYROLL_DEDUCTION_CALC                        │
├───────────────────────────────────────────────┤
│ PK  deduction_calc_no             NUMBER       │
│                                               │
│ FK  deduction_no                  NUMBER NN    │
│     → payroll_deduction.deduction_no           │
│     ON DELETE CASCADE                          │
│                                               │
│ NN  base_amount                    NUMBER       │
│     deduction_rate                NUMBER(10,6) │
│     fixed_deduction_amount        NUMBER       │
│ NN  deduction_calculated_amount   NUMBER       │
│     deduction_basis_year          NUMBER(4)    │
│     deduction_calc_note           VARCHAR2(500)│
└───────────────────────────────────────────────┘
```

---

### 9. PAYROLL_PAYMENT

```text
┌─────────────────────────────────────────────┐
│ PAYROLL_PAYMENT                             │
├─────────────────────────────────────────────┤
│ PK  payroll_payment_no   NUMBER              │
│                                             │
│ FK  payroll_no           NUMBER NN           │
│     → payroll.payroll_no                     │
│     ON DELETE CASCADE                        │
│                                             │
│ NN  payment_amount       NUMBER              │
│ NN  payment_at           TIMESTAMP           │
│ NN  payment_action       VARCHAR2(20)        │
│ NN  payment_method       VARCHAR2(30)        │
│     payment_note         VARCHAR2(500)       │
└─────────────────────────────────────────────┘
```

여긴 UNIQUE 일부러 없음. 한 급여에서:

```text
지급
추가지급
취소
재지급
```

처럼 **여러 이력이 생겨야 하니까** `PAYROLL 1:N PAYROLL_PAYMENT` 구조임.

---

## 9개 전체 관계 구조도

PK/FK까지 같이 보면 이렇게 보면 됨.

```text
EMPLOYEE
│
│ PK employee_no
│
└───────┐
        │ FK employee_no
        │ ON DELETE SET NULL
        ▼
┌───────────────────────────────┐
│ EMPLOYMENT_CONTRACT           │
│ PK contract_no                │
│ FK employee_no                │
└───────────────┬───────────────┘
                │
                │ 1
         ┌──────┴───────┐
         │              │
         ▼ N            ▼ N
┌──────────────────┐   ┌──────────────────────┐
│EMPLOYEE_ATTENDANCE│  │ PAYROLL              │
│PK attendance_no  │   │ PK payroll_no        │
│FK contract_no    │   │ FK contract_no       │
│                  │   │                      │
│UK(contract_no,   │   │UK(contract_no,       │
│   work_date)     │   │ year, month)         │
└────────┬─────────┘   └──────────┬───────────┘
         │                        │
         │                        │
         └──────────┐  ┌──────────┘
                    ▼  ▼
          ┌────────────────────────────┐
          │ PAYROLL_ATTENDANCE         │
          │ PK payroll_attendance_no   │
          │ FK payroll_no              │
          │ FK emp_attendance_no       │
          │                            │
          │ UK(payroll_no,             │
          │    emp_attendance_no)      │
          └────────────────────────────┘


                   PAYROLL
                      │
        ┌─────────────┼───────────────┐
        │             │               │
        ▼             ▼               ▼
┌────────────────┐ ┌────────────────┐ ┌────────────────┐
│PAYROLL_EARNING │ │PAYROLL_DEDUCTION│ │PAYROLL_PAYMENT │
│PK earning_no   │ │PK deduction_no │ │PK payment_no   │
│FK payroll_no   │ │FK payroll_no   │ │FK payroll_no   │
└───────┬────────┘ └───────┬────────┘ └────────────────┘
        │                  │
        ▼                  ▼
┌────────────────────┐ ┌────────────────────────┐
│PAYROLL_EARNING_CALC│ │PAYROLL_DEDUCTION_CALC  │
│PK earning_calc_no  │ │PK deduction_calc_no    │
│FK earning_no       │ │FK deduction_no         │
└────────────────────┘ └────────────────────────┘
```

그리고 **현재 UNIQUE는 딱 3개**라고 기억하면 편함.

| 테이블 | UNIQUE |
|---|---|
| `employee_attendance` | `(contract_no, work_date)` |
| `payroll` | `(contract_no, payroll_year, payroll_month)` |
| `payroll_attendance` | `(payroll_no, emp_attendance_no)` |

나머지는 지금 초안에서는 UNIQUE 없음.

이걸 DDL 바로 아래에 붙여놓으면 나중에 ERD 다시 볼 때 **“왜 얘가 중복되면 안 됐지?”**까지 바로 보인다. 그냥 PK/FK만 적힌 구조도보다 이게 훨씬 쓸모 있음.

* @ValidationCode : MjoyNzI4Nzk5ODk6Q3AxMjUyOjE2ODEyMTczMDgxNDY6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 11 Apr 2023 18:18:28
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : 91638
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOVER
SUBROUTINE REDO.V.AUT.AMEND.REL.CUST
****************************************************************
*--------------------------------------------------------------------------------------
* Company Name  : ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
* Developed By  : RAJA SAKTHIVEL K P
* Program Name  : REDO.V.AUT.AMEND.REL.CUST
*--------------------------------------------------------------------------------------
* Description: This routine is an authorisation routine attached to VERISION
* of Customer CUSTOMER,CREATE.STAFF, updates live file with the accounts generated
* for staff of the bank
*---------------------------------------------------------------------------------------
* Linked with: VERSION.CONTROL of Customer application as authorisation routine
* In parameter : None
* out parameter : None
*----------------------------------------------------------------------------------------
* MODIFICATION HISTORY
*----------------------------------------------------------------------------------------
*   DATE              ODR               WHO                 DESCRIPTION
* 02-03-10      ODR-2009-10-0532    RAJA SAKTHIVEL       Initial Creation
*
* 08-03-11         HD1053751        VENKATACHALAM       To restrict the employees from viewing
*                                                       the Account details which does not belongs
*                                                       to the current USER
* 20-05-11         CR013              PRABHU             Line 116 added
* 12-03-11         B88 Perform Issue  PRABHU             Changes done to update concat table REDO.CUST.EMPLOYEE
*Modification history
*Date                Who               Reference                  Description
*11-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM,FM TO @FM,++ TO +=1
*11-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*----------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.CUSTOMER
    $INSERT I_F.REDO.EMPLOYEE.ACCOUNTS
    $INSERT I_GTS.COMMON

    IF V$FUNCTION EQ 'A' THEN   ;* This has been attached as input routine in some version. in order to avoid write @ commit level
        GOSUB OPENFILES
        GOSUB PROCESS
    END

RETURN

*-------------
OPENFILES:
*-------------
    FN.REDO.EMPLOYEE.ACCOUNTS = 'F.REDO.EMPLOYEE.ACCOUNTS'
    F.REDO.EMPLOYEE.ACCOUNTS = ''
    CALL OPF(FN.REDO.EMPLOYEE.ACCOUNTS,F.REDO.EMPLOYEE.ACCOUNTS)

    FN.CUSTOMER = 'F.CUSTOMER'
    F.CUSTOMER  = ''
    CALL OPF(FN.CUSTOMER,F.CUSTOMER)

    FN.REDO.CUST.EMPLOYEE='F.REDO.CUST.EMPLOYEE'
    F.REDO.CUST.EMPLOYEE=''
    CALL OPF(FN.REDO.CUST.EMPLOYEE,F.REDO.CUST.EMPLOYEE)

RETURN
*---------
PROCESS:
*---------------------------------------------------------
* Getting the values of Rel.Customer from R.NEW and R.OLD
*---------------------------------------------------------


    Y.CUS.REL.CODES = R.NEW(EB.CUS.RELATION.CODE)

    Y.EMP.CODE.FOUND = 0
    LOOP
        REMOVE Y.CUS.REL.CODE.VAL FROM Y.CUS.REL.CODES SETTING Y.CUS.REL.POS
    WHILE Y.CUS.REL.CODE.VAL:Y.CUS.REL.POS
        IF Y.CUS.REL.CODE.VAL GT 300 AND Y.CUS.REL.CODE.VAL LT 499 THEN
            Y.EMP.CODE.FOUND = 1
        END
    REPEAT

    IF Y.EMP.CODE.FOUND AND NOT(R.OLD(EB.CUS.MNEMONIC)) THEN  ;*New record
        GOSUB UPDATE.NEW.RECORD
    END

    IF Y.EMP.CODE.FOUND AND R.OLD(EB.CUS.MNEMONIC) THEN       ;*Update existing record.

        CALL F.READ(FN.REDO.EMPLOYEE.ACCOUNTS,ID.NEW,R.REDO.EMPLOYEE.ACCOUNTS,F.REDO.EMPLOYEE.ACCOUNTS,ERR.REDO.EMPLOYEE.ACCOUNTS)

        Y.REL.CUST.NEW = R.NEW(EB.CUS.REL.CUSTOMER)
        Y.REL.CUST.OLD = R.OLD(EB.CUS.REL.CUSTOMER)
        IF Y.REL.CUST.NEW NE Y.REL.CUST.OLD THEN
            GOSUB CHECK.OLD
            GOSUB CHECK.NEW
            R.REDO.EMPLOYEE.ACCOUNTS<REDO.EMP.USER.ID> = R.NEW(EB.CUS.FAX.1)
            CALL F.WRITE(FN.REDO.EMPLOYEE.ACCOUNTS,ID.NEW,R.REDO.EMPLOYEE.ACCOUNTS)
        END ELSE
            R.REDO.EMPLOYEE.ACCOUNTS<REDO.EMP.USER.ID> = R.NEW(EB.CUS.FAX.1)
            CALL F.WRITE(FN.REDO.EMPLOYEE.ACCOUNTS,ID.NEW,R.REDO.EMPLOYEE.ACCOUNTS)
        END
*B88 Performance Issue ----REDO.CUST.EMPLOYEE----------------------------------
        R.REDO.CUST.EMPLOYEE=ID.NEW
        Y.REDO.CUST.ID      =R.NEW(EB.CUS.FAX.1)
        CALL F.WRITE(FN.REDO.CUST.EMPLOYEE,Y.REDO.CUST.ID,R.REDO.CUST.EMPLOYEE)
*B88 performance issue ---REDO.CUST.EMPLOYEE-----------------------------------
    END ELSE
        GOSUB UPDATE.RELATION
    END
RETURN

*-----------------------
UPDATE.RELATION:
*-----------------------

* Add relation to table for newly added rel.customer
    Y.REL.CUSTOMER = R.NEW(EB.CUS.REL.CUSTOMER)
    Y.REL.CUS.CNT  = DCOUNT(Y.REL.CUSTOMER,@VM)
    Y.VAR=1
    LOOP
    WHILE Y.VAR LE Y.REL.CUS.CNT
        Y.CUS.ID = Y.REL.CUSTOMER<1,Y.VAR>
        CALL F.READ(FN.CUSTOMER,Y.CUS.ID,R.CUSTOMER,F.CUSTOMER,CUS.ERR)
*        Y.FAX.ID = R.CUSTOMER<EB.CUS.FAX.1,1>

        Y.NEW.REL.LIST = R.CUSTOMER<EB.CUS.RELATION.CODE>
        Y.NEW.EMP.FOUND = 0


        CALL F.READ(FN.REDO.EMPLOYEE.ACCOUNTS,Y.CUS.ID,R.REDO.EMPLOYEE.ACCOUNTS,F.REDO.EMPLOYEE.ACCOUNTS,ERR.REDO.EMPLOYEE.ACCOUNTS)
        IF R.REDO.EMPLOYEE.ACCOUNTS THEN
            LOCATE ID.NEW IN R.REDO.EMPLOYEE.ACCOUNTS<REDO.EMP.REL.CUSTOMER,1> SETTING REL.POS ELSE
                R.REDO.EMPLOYEE.ACCOUNTS<REDO.EMP.REL.CUSTOMER,-1>=ID.NEW
                CALL F.WRITE(FN.REDO.EMPLOYEE.ACCOUNTS,Y.CUS.ID,R.REDO.EMPLOYEE.ACCOUNTS)
            END
        END

        Y.VAR += 1
    REPEAT

* Remove the relation from the table for old rel.code
    Y.OLD.RELATION.CUS = R.OLD(EB.CUS.REL.CUSTOMER)
    Y.OLD.REL.CUS.CNT  = DCOUNT(Y.OLD.RELATION.CUS,@VM)
    Y.VAR=1
    LOOP
    WHILE Y.VAR LE Y.OLD.REL.CUS.CNT
        Y.CUS.ID = Y.OLD.RELATION.CUS<1,Y.VAR>
        CALL F.READ(FN.CUSTOMER,Y.CUS.ID,R.CUSTOMER,F.CUSTOMER,CUS.ERR)

        Y.OLD.REL.LIST = R.CUSTOMER<EB.CUS.RELATION.CODE>

        LOCATE Y.CUS.ID IN Y.REL.CUSTOMER SETTING OLD.REL.POS ELSE
            CALL F.READ(FN.REDO.EMPLOYEE.ACCOUNTS,Y.CUS.ID,R.REDO.EMPLOYEE.ACCOUNTS,F.REDO.EMPLOYEE.ACCOUNTS,ERR.REDO.EMPLOYEE.ACCOUNTS)
            LOCATE ID.NEW IN  R.REDO.EMPLOYEE.ACCOUNTS<REDO.EMP.REL.CUSTOMER,1> SETTING POS1 THEN
                DEL R.REDO.EMPLOYEE.ACCOUNTS<REDO.EMP.REL.CUSTOMER,POS1>
                CALL F.WRITE(FN.REDO.EMPLOYEE.ACCOUNTS,Y.CUS.ID,R.REDO.EMPLOYEE.ACCOUNTS)
            END
        END

        Y.VAR += 1
    REPEAT

RETURN
*----------------
CHECK.OLD:
*----------------

    Y.OLD.CNT = DCOUNT(Y.REL.CUST.OLD,@VM)
    Y.VAR1=1
    LOOP
    WHILE Y.VAR1 LE Y.OLD.CNT
        GOSUB FINAL.OLD.CHECK
        Y.VAR1 += 1
    REPEAT

RETURN
*----------------
CHECK.NEW:
*----------------
    Y.NEW.CNT = DCOUNT(Y.REL.CUST.NEW,@VM)
    Y.VAR2=1
    LOOP
    WHILE Y.VAR2 LE Y.NEW.CNT
        GOSUB FINAL.NEW.CHECK
        Y.VAR2 += 1
    REPEAT


RETURN
*--------------------
FINAL.OLD.CHECK:
*--------------------

    Y.OLD.ID=Y.REL.CUST.OLD<1,Y.VAR1>
    LOCATE Y.OLD.ID IN Y.REL.CUST.NEW<1,1> SETTING POS1 ELSE
        LOCATE Y.OLD.ID IN R.REDO.EMPLOYEE.ACCOUNTS<REDO.EMP.REL.CUSTOMER,1> SETTING POS2 THEN
            DEL R.REDO.EMPLOYEE.ACCOUNTS<REDO.EMP.REL.CUSTOMER,POS2>
            CALL F.READ(FN.REDO.EMPLOYEE.ACCOUNTS,Y.OLD.ID,R.RELATION.EMP,F.REDO.EMPLOYEE.ACCOUNTS,EMP.ERR)
            IF R.RELATION.EMP THEN
                LOCATE ID.NEW IN R.RELATION.EMP<REDO.EMP.REL.CUSTOMER,1> SETTING EMP.POS THEN
                    DEL R.RELATION.EMP<REDO.EMP.REL.CUSTOMER,EMP.POS>
                    CALL F.WRITE(FN.REDO.EMPLOYEE.ACCOUNTS,Y.OLD.ID,R.RELATION.EMP)
                END
            END
        END
    END


RETURN
*----------------
FINAL.NEW.CHECK:
*----------------

    Y.NEW.ID=Y.REL.CUST.NEW<1,Y.VAR2>
    LOCATE Y.NEW.ID IN Y.REL.CUST.OLD<1,1> SETTING POS3 ELSE
        LOCATE Y.NEW.ID IN R.REDO.EMPLOYEE.ACCOUNTS<REDO.EMP.REL.CUSTOMER,1> SETTING POS3 ELSE
            R.REDO.EMPLOYEE.ACCOUNTS<REDO.EMP.REL.CUSTOMER,-1>=Y.NEW.ID
            CALL F.READ(FN.REDO.EMPLOYEE.ACCOUNTS,Y.NEW.ID,R.RELATION.EMP,F.REDO.EMPLOYEE.ACCOUNTS,EMP.ERR)
            IF R.RELATION.EMP THEN
                LOCATE ID.NEW IN R.RELATION.EMP<REDO.EMP.REL.CUSTOMER,1> SETTING EMP.POS ELSE
                    R.RELATION.EMP<REDO.EMP.REL.CUSTOMER,-1> = ID.NEW
                    CALL F.WRITE(FN.REDO.EMPLOYEE.ACCOUNTS,Y.NEW.ID,R.RELATION.EMP)
                END
            END
        END
    END



RETURN
*-------------------------------
UPDATE.NEW.RECORD:
*-----------------

    FN.CUSTOMER.ACCOUNT = 'F.CUSTOMER.ACCOUNT'
    F.CUSTOMER.ACCOUNT = ''
    CALL OPF(FN.CUSTOMER.ACCOUNT, F.CUSTOMER.ACCOUNT)

    Y.READ.ERR = ''
    R.CUS.ACC = ''
    CALL F.READ(FN.CUSTOMER.ACCOUNT, ID.NEW, R.CUS.ACC, F.CUSTOMER.ACCOUNT, Y.READ.ERR)

    R.NEW.EMPL.ACC<REDO.EMP.ACCOUNT> = CHANGE(R.CUS.ACC, @FM, @VM)
    R.NEW.EMPL.ACC<REDO.EMP.USER.ID> = R.NEW(EB.CUS.FAX.1)
    R.NEW.EMPL.ACC<REDO.EMP.REL.CUSTOMER> = R.NEW(EB.CUS.REL.CUSTOMER)
    CALL F.WRITE(FN.REDO.EMPLOYEE.ACCOUNTS,ID.NEW,R.NEW.EMPL.ACC)

RETURN
*--------------------------------

END

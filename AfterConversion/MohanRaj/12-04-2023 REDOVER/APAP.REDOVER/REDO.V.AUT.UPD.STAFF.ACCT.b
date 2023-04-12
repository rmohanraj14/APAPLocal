* @ValidationCode : MjoxMjY0MDQwMzU2OkNwMTI1MjoxNjgxMzAxODE1MDAzOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 12 Apr 2023 17:46:55
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
SUBROUTINE REDO.V.AUT.UPD.STAFF.ACCT

****************************************************************
*-------------------------------------------------------------------------
* Company Name  : ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
* Developed By  : RAJA SAKTHIVEL K P
* Program Name  : REDO.V.AUT.UPD.STAFF.ACCT
*-------------------------------------------------------------------------
* Description: This routine is an authorisation routine attached to VERISION,
* ACCOUNT,CREATE.STAFF set as "Y" & updates live file with the accounts generated
* for staff of the bank
*----------------------------------------------------------
* Linked with: VERSION.CONTROL of Account application as authorisation routine
* In parameter : None
* out parameter : None
*------------------------------------------------------------------------
* MODIFICATION HISTORY
*------------------------------------------------------------------------
*   DATE            ODR              WHO                DESCRIPTION
*
* 02-03-10    ODR-2009-10-0532    RAJA SAKTHIVEL      Initial Creation
*
* 08-03-11       HD1053751        VENKATACHALAM       To restrict the employees from viewing
*                                                     the Account details which does not belongs
*                                                     to the current USER
*05-05-11      ACCOUNT VI         PRABHU              V$FUNCTION removed from line 85
*Modification history
*Date                Who               Reference                  Description
*12-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM,++ TO +=1
*12-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.CUSTOMER
    $INSERT I_F.ACCOUNT
    $INSERT I_F.REDO.EMPLOYEE.ACCOUNTS

    GOSUB OPENFILES
    GOSUB PROCESS

RETURN

*--------------
OPENFILES:
*-----------
    FN.CUSTOMER = 'F.CUSTOMER'
    F.CUSTOMER = ''
    CALL OPF(FN.CUSTOMER,F.CUSTOMER)

    FN.REDO.EMPLOYEE.ACCOUNTS = 'F.REDO.EMPLOYEE.ACCOUNTS'
    F.REDO.EMPLOYEE.ACCOUNTS = ''
    CALL OPF(FN.REDO.EMPLOYEE.ACCOUNTS,F.REDO.EMPLOYEE.ACCOUNTS)

RETURN

*------------
PROCESS:
*------------
* The main process is carried over here

    Y.CUSTOMER.ID = R.NEW(AC.CUSTOMER)
    CALL F.READ(FN.CUSTOMER,Y.CUSTOMER.ID,R.CUSTOMER,F.CUSTOMER,CUS.ERR)
    Y.FAX.ID = R.CUSTOMER<EB.CUS.FAX.1,1>
    Y.JOINT.HOLDER = R.NEW(AC.JOINT.HOLDER)
    Y.JOINT.CNT = DCOUNT(Y.JOINT.HOLDER,@VM)
    Y.JOINT.HOLDER.OLD = R.OLD(AC.JOINT.HOLDER)
    Y.JOINT.OLD.CNT    = DCOUNT(Y.JOINT.HOLDER.OLD,@VM)
    IF Y.FAX.ID NE '' THEN
        GOSUB CHECK.EMPLOYEE
    END ELSE
        GOSUB UPDATE.RELATION.EMPLOYEE
    END

RETURN
*-----------------------------------------------------
CHECK.EMPLOYEE:
*-----------------------------------------------------
    CALL F.READ(FN.REDO.EMPLOYEE.ACCOUNTS,Y.CUSTOMER.ID,R.REDO.EMPLOYEE.ACCOUNTS,F.REDO.EMPLOYEE.ACCOUNTS,EMP.ACC.ERR)
    LOCATE ID.NEW IN R.REDO.EMPLOYEE.ACCOUNTS<REDO.EMP.ACCOUNT,1> SETTING POS ELSE
        R.REDO.EMPLOYEE.ACCOUNTS<REDO.EMP.ACCOUNT,-1>=ID.NEW

    END
    Y.VAR1=1
    LOOP
    WHILE Y.VAR1 LE Y.JOINT.CNT
        Y.JOIN.CUS.ID = Y.JOINT.HOLDER<1,Y.VAR1>
        LOCATE Y.JOIN.CUS.ID IN R.REDO.EMPLOYEE.ACCOUNTS<REDO.EMP.REL.CUSTOMER,1> SETTING POS ELSE
            R.REDO.EMPLOYEE.ACCOUNTS<REDO.EMP.REL.CUSTOMER,-1> = Y.JOIN.CUS.ID
        END
        Y.VAR1 += 1
    REPEAT

    Y.VAR2 = 1
    LOOP
    WHILE Y.VAR2 LE Y.JOINT.OLD.CNT
        Y.JOIN.OLD.ID = Y.JOINT.HOLDER.OLD<1,Y.VAR2>
        LOCATE Y.JOIN.OLD.ID IN Y.JOINT.HOLDER<1,1> SETTING OLD.POS ELSE
            LOCATE Y.JOIN.OLD.ID IN R.REDO.EMPLOYEE.ACCOUNTS<REDO.EMP.REL.CUSTOMER,1> SETTING POS.JOIN THEN
                DEL R.REDO.EMPLOYEE.ACCOUNTS<REDO.EMP.REL.CUSTOMER,POS.JOIN>
            END
        END
        Y.VAR2 += 1
    REPEAT
    CALL F.WRITE(FN.REDO.EMPLOYEE.ACCOUNTS,Y.CUSTOMER.ID,R.REDO.EMPLOYEE.ACCOUNTS)
    GOSUB UPDATE.RELATION.EMPLOYEE
RETURN
*------------------------------------------------------------------------
UPDATE.RELATION.EMPLOYEE:
*------------------------------------------------------------------------
    Y.VAR3=1
    LOOP
    WHILE Y.VAR3 LE Y.JOINT.CNT
        Y.JOIN.ID = Y.JOINT.HOLDER<1,Y.VAR3>
        CALL F.READ(FN.CUSTOMER,Y.JOIN.ID,R.JOIN.CUS,F.CUSTOMER,CUS.ERR)
        Y.JOIN.FAX.ID = R.JOIN.CUS<EB.CUS.FAX.1,1>
        IF Y.JOIN.FAX.ID THEN
            CALL F.READ(FN.REDO.EMPLOYEE.ACCOUNTS,Y.JOIN.ID,R.REDO.EMPLOYEE.ACCOUNTS,F.REDO.EMPLOYEE.ACCOUNTS,EMP.ERR)
            LOCATE ID.NEW IN R.REDO.EMPLOYEE.ACCOUNTS<REDO.EMP.ACCOUNT,1> SETTING ACC.POS ELSE
                R.REDO.EMPLOYEE.ACCOUNTS<REDO.EMP.ACCOUNT,-1>=ID.NEW
                CALL F.WRITE(FN.REDO.EMPLOYEE.ACCOUNTS,Y.JOIN.ID,R.REDO.EMPLOYEE.ACCOUNTS)
            END
        END
        Y.VAR3 += 1
    REPEAT
    Y.VAR4=1
    LOOP
    WHILE Y.VAR4 LE Y.JOINT.OLD.CNT
        Y.OLD.ID = Y.JOINT.HOLDER.OLD<1,Y.VAR4>
        LOCATE Y.OLD.ID IN Y.JOINT.HOLDER SETTING OLD.POS ELSE
            CALL F.READ(FN.REDO.EMPLOYEE.ACCOUNTS,Y.OLD.ID,R.REDO.EMPLOYEE.ACCOUNTS,F.REDO.EMPLOYEE.ACCOUNTS,EMP.ERR)
            LOCATE ID.NEW IN R.REDO.EMPLOYEE.ACCOUNTS<REDO.EMP.ACCOUNT,1> SETTING ACC.POS THEN
                DEL R.REDO.EMPLOYEE.ACCOUNTS<REDO.EMP.ACCOUNT,ACC.POS>
                CALL F.WRITE(FN.REDO.EMPLOYEE.ACCOUNTS,Y.OLD.ID,R.REDO.EMPLOYEE.ACCOUNTS)
            END
        END
        Y.VAR4 += 1
    REPEAT
RETURN
END

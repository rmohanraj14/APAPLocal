$PACKAGE APAP.AA ;*R22 Manual Code Conversion
SUBROUTINE REDO.AA.CHK.PAY.MTHD
*-------------------------------------------------------------------------
*DESCRIPTION:
*------------
* This routine is to check the field L.AA.PAY.METHD and check the fields L.AA.DEBT.AC, Y.AA.FORM
*
*-------------------------------------------------------------------------
*CALLED BY : REDO.AA.CHK.PAY.MTHD
*------------------------------------------------------------------------
*    Date               who           Reference            Description
* 10-JAN-2010     SHANKAR RAJU     ODR-2009-10-0529     Initial Creation
*-------------------------------------------------------------------------
*-----------------------------------------------------------------------------------

* Modification History: 

* * Date                  Who                               Reference           Description
* ----                  ----                                ----                 ----
* 29-March-2023          Ajith Kumar         R22 Manual Code Conversion      Package Name added APAP.AA
* 29-March-2023       Conversion Tool                        R22 Auto Code Conversion             VM to @Vm
* ----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.PAYMENT.SCHEDULE
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY
    $INSERT I_F.CUSTOMER.ACCOUNT
    $INSERT I_F.AA.ARRANGEMENT

    IF V$FUNCTION EQ 'I' THEN
        GOSUB INITIALISE
        GOSUB PROCESS
    END

RETURN
*-------------------------------------------------------------------------
INITIALISE:
*----------
    LOC.REF.APPL   ="AA.PRD.DES.PAYMENT.SCHEDULE"
    LOC.REF.FIELDS ="L.AA.PAY.METHD":@VM:"L.AA.DEBT.AC":@VM:"L.AA.FORM" ;*R22 Auto Code Conversion

    LOC.REF.POS    =""
    CALL MULTI.GET.LOC.REF(LOC.REF.APPL,LOC.REF.FIELDS,LOC.REF.POS)
    Y.AA.PAY.METHD = LOC.REF.POS<1,1>
    Y.AA.DEBT.AC   =  LOC.REF.POS<1,2>
    Y.AA.FORM      = LOC.REF.POS<1,3>

    FN.CUSTOMER.ACCOUNT = 'F.CUSTOMER.ACCOUNT'
    F.CUSTOMER.ACCOUNT  = ''
    R.CUSTOMER.ACCOUNT  = ''
    CALL OPF(FN.CUSTOMER.ACCOUNT,F.CUSTOMER.ACCOUNT)

RETURN
*-------------------------------------------------------------------------
PROCESS:
*-------

* IF PAY.METHD = 'DEBITO DIRECTO' [Direct Debit], Input of L.AA.DEBT.AC is mandatory; Else, L.AA.DEBT.AC should be made NULL.
    IF R.NEW(AA.PS.LOCAL.REF)<1,Y.AA.PAY.METHD> EQ 'Direct Debit' THEN
        IF R.NEW(AA.PS.LOCAL.REF)<1,Y.AA.DEBT.AC> EQ '' THEN
            AF    = AA.PS.LOCAL.REF
            AV    = Y.AA.DEBT.AC
            ETEXT = 'EB-INPUT.MAN.DEBT.AC'
            CALL STORE.END.ERROR
        END
    END ELSE
        R.NEW(AA.PS.LOCAL.REF)<1,Y.AA.DEBT.AC> = ''
    END

* IF PAY.METHD = 'NOMINA EXTERNA' [External Payroll], Input of L.AA.DEBT.AC is mandatory; Else, L.AA.DEBT.AC should be made NULL.
    IF R.NEW(AA.PS.LOCAL.REF)<1,Y.AA.PAY.METHD> EQ 'External Payroll' THEN
        IF R.NEW(AA.PS.LOCAL.REF)<1,Y.AA.FORM> EQ '' THEN
            AF    = AA.PS.LOCAL.REF
            AV    = Y.AA.FORM
            ETEXT = 'EB-MAND.FORM.PAY.SCH'
            CALL STORE.END.ERROR
        END
    END ELSE
        R.NEW(AA.PS.LOCAL.REF)<1,Y.AA.FORM> = ''
    END

* L.AA.DEBT.ACCOUNT will have dropdown list only the accounts that belong to the PRIMARY.OWNER of the AA Contract.
* If User inputs some other accounts, a BLOCKING OVERRIDE should be generated.

    Y.CUST.ACC = R.NEW(AA.PS.LOCAL.REF)<1,Y.AA.DEBT.AC>
    IF Y.CUST.ACC NE '' THEN
        Y.CUST.ID = c_aalocArrangementRec<AA.ARR.CUSTOMER>
        CALL F.READ(FN.CUSTOMER.ACCOUNT,Y.CUST.ID,R.CUSTOMER.ACCOUNT,F.CUSTOMER.ACCOUNT,ERR.CUS.ACC)
        LOCATE Y.CUST.ACC IN R.CUSTOMER.ACCOUNT SETTING POS.PS ELSE
            TEXT    = "REDO.ACC.NOT.OWNR"
            CURR.NO = DCOUNT(R.NEW(AA.PS.OVERRIDE),@VM)+ 1 ;*R22 auto Code Conversion
            CALL STORE.OVERRIDE(CURR.NO)
        END
    END
RETURN
*-------------------------------------------------------------------------
END

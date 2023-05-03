* @ValidationCode : MjotMTk5NTUzMDU4OkNwMTI1MjoxNjgxOTcxMjM1NTk0OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 20 Apr 2023 11:43:55
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
SUBROUTINE REDO.V.VAL.LINK.EMPLOYEE
*--------------------------------------------------------------------------------
*Company Name: ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
*Program Name: REDO.V.VAL.LINK.EMPLOYEE
*--------------------------------------------------------------------------------
* DESCRIPTION:
*---------------------------------------------------------------------------------
*    This routine is validation routine to populate the values from
*    RELATION.CODE field of customer to Local field L.AA.LINK and
*    L.AA.EMPLOYEE of VERSION "AA.ARR.CUSTOMER"
*---------------------------------------------------------------------------------
*MODIFICATION HISTORY:
*-----------------------------------------------------------------------------
*
*  DATE             WHO         REFERENCE         DESCRIPTION
* 28-06-2010      SUJITHA.S   ODR-2009-10-0326 N.3  INITIAL CREATION
* 31-01-2012      MARIMUTHU   PACS00241473
* 19-03-2013      PRAKASH     PACS00253689        Value in CUSTOMER's local field
*                                                 L.CU.TIPO.CL should not be 'CLIENTE MENOR'
*Modification history
*Date                Who               Reference                  Description
*20-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM,FM TO @FM
*20-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.CUSTOMER
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.AA.CUSTOMER
*   $INSERT I_F.CUSTOMER
    $INSERT I_F.REDO.BRANCH.INT.ACCT.PARAM

    GOSUB INIT
    GOSUB PROCESS
RETURN

*----------------------------------------------------------------------------------
INIT:
*----------------------------------------------------------------------------------

    FN.CUSTOMER="F.CUSTOMER"
    F.CUSTOMER=""
    CALL OPF(FN.CUSTOMER,F.CUSTOMER)

    FN.REDO.EMPLOYEE.ACCOUNTS = 'F.REDO.EMPLOYEE.ACCOUNTS'
    F.REDO.EMPLOYEE.ACCOUNTS = ''
    CALL OPF(FN.REDO.EMPLOYEE.ACCOUNTS,F.REDO.EMPLOYEE.ACCOUNTS)

    FN.REDO.BRANCH.INT.ACCT.PARAM = 'F.REDO.BRANCH.INT.ACCT.PARAM'
    F.REDO.BRANCH.INT.ACCT.PARAM = ''

    LOC.APPL="AA.PRD.DES.CUSTOMER":@FM:"CUSTOMER"
    LOC.FIELD="L.AA.LINK":@VM:"L.AA.EMPLOYEE":@FM:"L.CU.TIPO.CL"
    LOC.POS=''

RETURN

*----------------------------------------------------------------------------------
PROCESS:
*----------------------------------------------------------------------------------

    Y.SYS.ID = 'SYSTEM'
    CALL CACHE.READ(FN.REDO.BRANCH.INT.ACCT.PARAM,Y.SYS.ID,R.REDO.BRANCH.INT.ACCT.PARAM,PAR.ERR)

    CALL MULTI.GET.LOC.REF(LOC.APPL,LOC.FIELD,LOC.POS)
    Y.LINK.POS=LOC.POS<1,1>
    Y.EMP.POS=LOC.POS<1,2>
    CU.TIPO.CL = LOC.POS<2,1>

    Y.CUS = R.NEW(AA.CUS.PRIMARY.OWNER)
    CALL F.READ(FN.CUSTOMER,Y.CUS,R.CUSTOMER,F.CUSTOMER,Y.ERR)

* CLIENTE MENOR - RETAIL CUSTOMER not allowed - PACS00253689 - Start

    CU.TIPO.CL.VALUE = R.CUSTOMER<EB.CUS.LOCAL.REF,CU.TIPO.CL>
    IF CU.TIPO.CL.VALUE EQ 'CLIENTE MENOR' THEN
        AF = AA.CUS.PRIMARY.OWNER
        ETEXT = 'EB-CUS.TYPE.CLIENTE.MENOR'
        CALL STORE.END.ERROR
    END

* CLIENTE MENOR - RETAIL CUSTOMER not allowed - PACS00253689 - End

    Y.FAX = R.CUSTOMER<EB.CUS.FAX.1>
    Y.CNT = DCOUNT(Y.FAX,@VM)
    FL = ''
    LOOP
    WHILE Y.CNT GT 0 DO
        FL += 1
        R.NEW(AA.CUS.LOCAL.REF)<1,Y.EMP.POS,FL> = Y.FAX<1,FL>
        Y.CNT -= 1
    REPEAT

    Y.REL.COUNT=DCOUNT(R.CUSTOMER<EB.CUS.RELATION.CODE>,@VM)

    Y.PAR.REL.S = R.REDO.BRANCH.INT.ACCT.PARAM<BR.INT.ACCT.RELATION.START>
    Y.PAR.REL.E = R.REDO.BRANCH.INT.ACCT.PARAM<BR.INT.ACCT.RELEATION.END>

    Y.PAR.CNT = DCOUNT(Y.PAR.REL.S,@VM)

    IF Y.FAX THEN
        GOSUB APAP.EMP
    END ELSE
        GOSUB NON.APAP.EMP
    END

RETURN

*----------------------------------------------------------------------------------
APAP.EMP:
*----------------------------------------------------------------------------------

    FLG = '' ; FLG.1 = ''
    LOOP
    WHILE Y.REL.COUNT GT 0 DO
        FLG += 1
        Y.REL.CUS = R.CUSTOMER<EB.CUS.REL.CUSTOMER,FLG>
        Y.REL = R.CUSTOMER<EB.CUS.RELATION.CODE,FLG>
        GOSUB CHECK.REL.CNT
        Y.REL.COUNT -=  1
    REPEAT

RETURN

*----------------------------------------------------------------------------------
NON.APAP.EMP:
*----------------------------------------------------------------------------------

    FLG = '' ; FLG.1 = ''
    LOOP
    WHILE Y.REL.COUNT GT 0 DO
        FLG += 1
        Y.REL.CUS = R.CUSTOMER<EB.CUS.REL.CUSTOMER,FLG>
        Y.REL = R.CUSTOMER<EB.CUS.RELATION.CODE,FLG>

        IF Y.REL GE '300' AND Y.REL LE '399' THEN
            FLG.1 += 1
            R.NEW(AA.CUS.LOCAL.REF)<1,Y.LINK.POS,FLG.1> = Y.REL.CUS
        END
        Y.REL.COUNT -=  1
    REPEAT

RETURN

*----------------------------------------------------------------------------------
CHECK.REL.CNT:
*----------------------------------------------------------------------------------

    Y.PAR.CNT = DCOUNT(Y.PAR.REL.S,@VM)
    FLG.P = ''
    LOOP
    WHILE Y.PAR.CNT GT 0 DO
        FLG.P += 1
        Y.ST = Y.PAR.REL.S<1,FLG.P>
        Y.END = Y.PAR.REL.E<1,FLG.P>
        IF Y.REL GE Y.ST AND Y.REL LE Y.END THEN
            FLG.1 += 1
            R.NEW(AA.CUS.LOCAL.REF)<1,Y.LINK.POS,FLG.1> = Y.REL.CUS
        END
        Y.PAR.CNT -= 1
    REPEAT

RETURN

END

* @ValidationCode : MjoxNTI2NDk3ODI5OkNwMTI1MjoxNjg1NTMyNTUxNDUwOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 31 May 2023 16:59:11
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
$PACKAGE APAP.AA
SUBROUTINE REDO.UPDATE.LOAN.CONT.ACC
*--------------------------------------------------------------
*Description: This routine is post routine @ auth level for the
* activity lending-update-account to update the contingent accont created for the loan
*--------------------------------------------------------------
* Input Arg :   N/A
* Out   Arg :   N/A
* Deals With:   Post routine in the activity api
*--------------------------------------------------------------
* Date             Who               Dev Ref                        Comments
* 22 Oct 2012    H Ganesh           NAB Accounting-PACS00202156    Initial Draft
** 29-03-2023 Conversion Tool       R22 Auto Conversion  FM TO @FM, VM to @VM, SM to @SM
** 29-03-2023 Skanda                R22 Manual Conversion           CALL method format changed
*--------------------------------------------------------------


    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.ACCOUNT
    $INSERT I_F.AA.ACCOUNT
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.STATIC.CHANGE.TODAY
    $INSERT I_F.EB.CONTRACT.BALANCES
    $USING APAP.TAM

    IF c_aalocActivityStatus EQ 'AUTH' THEN
        GOSUB OPEN.FILES
        GOSUB PROCESS
    END

RETURN
*--------------------------------------------------------------
OPEN.FILES:
*--------------------------------------------------------------

    FN.REDO.CONCAT.ACC.NAB = 'F.REDO.CONCAT.ACC.NAB'
    F.REDO.CONCAT.ACC.NAB  = ''
    CALL OPF(FN.REDO.CONCAT.ACC.NAB,F.REDO.CONCAT.ACC.NAB)

    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT  = ''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)

    FN.EB.CONTRACT.BALANCES = 'F.EB.CONTRACT.BALANCES'
    F.EB.CONTRACT.BALANCES = ''
    CALL OPF(FN.EB.CONTRACT.BALANCES,F.EB.CONTRACT.BALANCES)


    LOC.REF.APPLICATION  = "ACCOUNT":@FM:"AA.PRD.DES.ACCOUNT"
    LOC.REF.FIELDS       = 'L.LOAN.STATUS':@VM:'L.OD.STATUS':@VM:'L.OD.STATUS.2':@VM:'ORIGEN.RECURSOS':@FM:'L.LOAN.STATUS':@VM:'L.OD.STATUS':@VM:'L.OD.STATUS.2':@VM:'ORIGEN.RECURSOS'
    LOC.REF.POS          = ''
    CALL MULTI.GET.LOC.REF(LOC.REF.APPLICATION,LOC.REF.FIELDS,LOC.REF.POS)

    POS.L.LOAN.STATUS    = LOC.REF.POS<1,1>
    POS.L.OD.STATUS      = LOC.REF.POS<1,2>
    POS.L.OD.STATUS.2    = LOC.REF.POS<1,3>
    POS.OR.RE.AC = LOC.REF.POS<1,4>
    POS.AA.L.LOAN.STATUS = LOC.REF.POS<2,1>
    POS.AA.L.OD.STATUS   = LOC.REF.POS<2,2>
    POS.AA.L.OD.STATUS.2 = LOC.REF.POS<2,3>
    POS.OR.RE.AA = LOC.REF.POS<2,4>

RETURN
*--------------------------------------------------------------
PROCESS:
*--------------------------------------------------------------
    Y.ARR.ID  = c_aalocArrId
    IN.ACC.ID = ''
    OUT.ID = ''
    APAP.TAM.redoConvertAccount(IN.ACC.ID,Y.ARR.ID,OUT.ID,ERR.TEXT);* R22 Manual conversion

    Y.LOAN.ACC.NO = OUT.ID

    CALL F.READ(FN.REDO.CONCAT.ACC.NAB,Y.LOAN.ACC.NO,R.REDO.CONCAT.ACC.NAB,F.REDO.CONCAT.ACC.NAB,NAB.ERR)

    IF R.REDO.CONCAT.ACC.NAB THEN
        GOSUB UPDATE.ACCOUNT
    END

RETURN
*--------------------------------------------------------------
UPDATE.ACCOUNT:
*--------------------------------------------------------------

    Y.WRITE.ACC = ''
    Y.LOAN.ACC.NO = R.REDO.CONCAT.ACC.NAB<1>
    CALL F.READ(FN.ACCOUNT,Y.LOAN.ACC.NO,R.ACCOUNT,F.ACCOUNT,ACC.ERR)

    IF R.ACCOUNT<AC.LOCAL.REF,POS.L.LOAN.STATUS> NE R.NEW(AA.AC.LOCAL.REF)<1,POS.AA.L.LOAN.STATUS> THEN
        Y.WRITE.ACC = 'YES'
        R.ACCOUNT<AC.LOCAL.REF,POS.L.LOAN.STATUS> = R.NEW(AA.AC.LOCAL.REF)<1,POS.AA.L.LOAN.STATUS>
    END

    IF R.ACCOUNT<AC.LOCAL.REF,POS.L.OD.STATUS> NE R.NEW(AA.AC.LOCAL.REF)<1,POS.AA.L.OD.STATUS> THEN
        Y.WRITE.ACC = 'YES'
        R.ACCOUNT<AC.LOCAL.REF,POS.L.OD.STATUS> = R.NEW(AA.AC.LOCAL.REF)<1,POS.AA.L.OD.STATUS>
    END

    IF R.ACCOUNT<AC.LOCAL.REF,POS.L.OD.STATUS.2> NE R.NEW(AA.AC.LOCAL.REF)<1,POS.AA.L.OD.STATUS.2> THEN
        Y.WRITE.ACC = 'YES'
        R.ACCOUNT<AC.LOCAL.REF,POS.L.OD.STATUS.2> = R.NEW(AA.AC.LOCAL.REF)<1,POS.AA.L.OD.STATUS.2>
    END

    IF R.ACCOUNT<AC.LOCAL.REF,POS.OR.RE.AC> NE R.NEW(AA.AC.LOCAL.REF)<1,POS.OR.RE.AA> THEN
        Y.WRITE.ACC = 'YES'
        R.ACCOUNT<AC.LOCAL.REF,POS.OR.RE.AC> = R.NEW(AA.AC.LOCAL.REF)<1,POS.OR.RE.AA>
    END


    IF Y.WRITE.ACC EQ 'YES' THEN
        CALL F.LIVE.WRITE(FN.ACCOUNT,Y.LOAN.ACC.NO,R.ACCOUNT)

        CALL F.READ(FN.EB.CONTRACT.BALANCES,Y.LOAN.ACC.NO,R.ECB,F.EB.CONTRACT.BALANCES,ECB.ERR)
        IF R.ECB THEN
            R.SCT = ''
            R.SCT<RE.SCT.SYSTEM.ID>   = R.ECB<ECB.PRODUCT>
            R.SCT<RE.SCT.OLD.PRODCAT> = R.ACCOUNT<AC.CATEGORY>
            OLD.CONSOL.KEY            = R.ECB<ECB.CONSOL.KEY>
            NEW.CONSOL.KEY = ''
            CALL UPDATE.STATIC.CHANGE.TODAY(Y.LOAN.ACC.NO, OLD.CONSOL.KEY, NEW.CONSOL.KEY, R.SCT)
        END
    END

RETURN
END

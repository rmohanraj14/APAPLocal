* @ValidationCode : Mjo0MDQyNjMwOTM6Q3AxMjUyOjE2ODEzODc5ODMwMzA6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 13 Apr 2023 17:43:03
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
SUBROUTINE REDO.V.FT.ACH.LOAN.STATUS.COND
*-------------------------------------------------------------------------------------------
*DESCRIPTION:
*             This is the internal call routine which updates the value of the local reference fields
* L.LOAN.STATUS.1 & L.LOAN.COND in FUNDS.TRANSFER application
* ------------------------------------------------------------------------------------------
* Input/Output:
*--------------
* IN  : -NA-
* OUT : -NA-
*
* Dependencies:
*---------------
* CALLS     : REDO.CRR.GET.CONDITIONS
* CALLED BY : -NA-
*
* Revision History:
*------------------
*   Date               who           Reference            Description
* 07-JUN-2010   N.Satheesh Kumar   ODR-2009-10-0331      Initial Creation
* 03-JUL-2011   Marimuthu S        PACS00082427
* 17-AUG-2011   Marimuthu S        PACS00060279 & PACS00074323
* 14-OCT-2011   Marimuthu S        PACS00142802
*Modification history
*Date                Who               Reference                  Description
*13-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM,SM TO @SM,FM TO @FM,++ TO +=1
*13-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*---------------------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.OVERDUE
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_GTS.COMMON
    $INSERT I_EB.TRANS.COMMON
    $INSERT I_F.ACCOUNT



    GOSUB GET.LRF.POS
    GOSUB PROCESS
RETURN

*-----------
GET.LRF.POS:
*-----------
*----------------------------------------------------------------------
* This section gets the position of the local reference field positions
*----------------------------------------------------------------------

    LR.APP = 'AA.PRD.DES.OVERDUE':@FM:'FUNDS.TRANSFER'
    LR.FLDS = 'L.LOAN.STATUS.1':@VM:'L.LOAN.COND':@FM
    LR.FLDS := 'L.LOAN.STATUS.1':@VM:'L.LOAN.COND'
    LR.POS = ''
    CALL MULTI.GET.LOC.REF(LR.APP,LR.FLDS,LR.POS)

    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)

    OD.LOAN.STATUS.POS = LR.POS<1,1>
    OD.LOAN.COND.POS =  LR.POS<1,2>
    FT.LOAN.STATUS.POS = LR.POS<2,1>
    FT.LOAN.COND.POS =  LR.POS<2,2>

RETURN

*-------
PROCESS:
*-------
*------------------------------------------------------------------------------------------------------------------------------------
* This section gets the latest overdue record for the arrangement id and stores the value of loan status and condition in R.NEW of FT
*------------------------------------------------------------------------------------------------------------------------------------

    Y.DF.ID = COMI

    CALL F.READ(FN.ACCOUNT,Y.DF.ID,R.ACCOUNT,F.ACCOUNT,AC.ERR)
    IF R.ACCOUNT THEN
        Y.AD.ID = R.ACCOUNT<AC.ARRANGEMENT.ID>
        IF Y.AD.ID[1,2] NE 'AA' THEN
            ETEXT = 'EB-NOT.AA.AC'
            AF = FT.CREDIT.ACCT.NO
            CALL STORE.END.ERROR
        END
    END

** PACS00082427 - S
    IF PGM.VERSION EQ ',REDO.MULTI.AA.ACRP' OR PGM.VERSION EQ ',REDO.MULTI.AA.OVR.CHQ' OR PGM.VERSION EQ ',REDO.MULTI.REPAY.CHQ' OR PGM.VERSION EQ ',TELLER,AA.OVR.REPAY' OR PGM.VERSION EQ ',REDO.MULTI.AA.ACCRAP.UPD' OR PGM.VERSION EQ ',REDO.MULTI.AA.ACCRAP.UPD.TR' OR PGM.VERSION EQ ',REDO.MULTI.AA.ACRP.UPD' OR PGM.VERSION EQ ',REDO.MULTI.AA.ACRP.UPD.TR' THEN
        CALL REDO.V.VAL.DEFAULT.AMT
    END
** PACS00082427 - E
    ACC.ID =  COMI
    PROP.CLASS = 'OVERDUE'
    PROPERTY = ''
    R.Condition = ''
    ERR.MSG = ''
    EFF.DATE = ''
    CALL REDO.CONVERT.ACCOUNT(ACC.ID,Y.ARR.ID,ARR.ID,ERR.TEXT)
    CALL REDO.CRR.GET.CONDITIONS(ARR.ID,EFF.DATE,PROP.CLASS,PROPERTY,R.Condition,ERR.MSG)
    LOAN.STATUS = R.Condition<AA.OD.LOCAL.REF,OD.LOAN.STATUS.POS>
    LOAN.COND = R.Condition<AA.OD.LOCAL.REF,OD.LOAN.COND.POS>
    CHANGE @SM TO @VM IN LOAN.STATUS
    CHANGE @SM TO @FM IN LOAN.COND
    Y.CNT = DCOUNT(LOAN.COND,@FM)
    Y.START.VAL =1
    LOOP
    WHILE Y.START.VAL LE Y.CNT
        LOAN.COND1<-1> = LOAN.COND<Y.START.VAL>
        LOAN.COND1 = CHANGE(LOAN.COND1,@FM,@SM)
        R.NEW(FT.LOCAL.REF)<1,FT.LOAN.COND.POS> = LOAN.COND1
        Y.START.VAL += 1
    REPEAT
    R.NEW(FT.LOCAL.REF)<1,FT.LOAN.STATUS.POS> = LOAN.STATUS

    CALL F.READ(FN.ACCOUNT,ACC.ID,R.ACCOUNT,F.ACCOUNT,ACC.ERR)
    Y.CUSID = R.ACCOUNT<AC.CUSTOMER>
    R.NEW(FT.ORDERING.CUST) = Y.CUSID
* PACS00142802 - s
    R.NEW(FT.CREDIT.CURRENCY) = R.ACCOUNT<AC.CURRENCY>
* PACS00142802 -e

    CHANGE @SM TO @VM IN LOAN.STATUS
    CHANGE @SM TO @VM IN LOAN.COND1

    IF ('JudicialCollection' MATCHES LOAN.STATUS) OR ('Write-off' MATCHES LOAN.STATUS) THEN
        ETEXT = 'EB-REQ.COLL.AREA.AUTH1'
        AF = FT.CREDIT.ACCT.NO
*AF = FT.LOCAL.REF    ;* These fields has been removed from version. So not required to point the error
*AV = FT.LOAN.STATUS.POS
        CALL STORE.END.ERROR
    END

    IF ('Legal' MATCHES LOAN.COND1) THEN
        ETEXT = 'EB-REQ.COLL.AREA.AUTH1'
        AF = FT.CREDIT.ACCT.NO
*AF = FT.LOCAL.REF ;* These fields has been removed from version. So not required to point the error
*AV = FT.LOAN.COND.POS
        CALL STORE.END.ERROR
    END

RETURN
END

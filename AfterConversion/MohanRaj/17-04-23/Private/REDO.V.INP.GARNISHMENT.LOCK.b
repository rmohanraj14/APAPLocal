* @ValidationCode : MjotMTk5MzUxNTA0MTpDcDEyNTI6MTY4MTcyOTEwNTMyMzo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 17 Apr 2023 16:28:25
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
SUBROUTINE REDO.V.INP.GARNISHMENT.LOCK
*-----------------------------------------------------------------------------
*-----------------------------------------------------------------------------
*Description:
*    This is an input routine for the version AC.LOCKED.EVENTS,INPUT
*---------------------------------------------------------------
* Company Name  : ASOCIACION POPUL
* Developed By  : BHARATH C
* Program Name  : REDO.V.INP.GARNISHMENT.LOCK
* ODR NUMBER    : ODR-2009-10-0531
* HD REFERENCE  : HD1016159
*Linked With    :AC.LOCKED.EVENTS,INPUT version as input routine
*---------------------------------------------------------------
* In parameter : NONE
*Out Parameter:none
*-----------------------------------------------------------------------
*MODIFICATION:
*   DATE           ODR
*18.4.2010     ODR-2009-10-0531
*Modification history
*Date                Who               Reference                  Description
*17-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM,FM TO @FM
*17-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*----------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AC.LOCKED.EVENTS
    $INSERT I_F.ACCOUNT
    $INSERT I_F.CUSTOMER.ACCOUNT
    $INSERT I_F.EB.CONTRACT.BALANCES                        ;*TUS S/E

    GOSUB INIT
    GOSUB OPENFILE
    GOSUB PROCESS
RETURN
*----------------------------
INIT:
    POS=''
    POS1=''
    ACCOUNT.LOCAL.NO=''
    STATUS1=''
    FLAG='0'
    D.COUNT='1'
    VAR.LOC.AMT = 0
RETURN
*------------------------------
OPENFILE:

    FN.ACCOUNT='F.ACCOUNT'
    F.ACCOUNT=''
    R.ACCOUNT=''
    ACCOUNT.NUMBER=''
    ERR.ACCOUNT=''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)

    FN.CUSTOMER.ACCOUNT='F.CUSTOMER.ACCOUNT'
    F.CUSTOMER.ACCOUNT=''
    CALL OPF(FN.CUSTOMER.ACCOUNT,F.CUSTOMER.ACCOUNT)

    LOCAL.FIELD='L.AC.GAR.AMT':@VM:'L.AC.AVAIL.BAL':@VM:'L.AC.CUSTOMER':@VM:'L.AC.ACCT.LOCK':@VM:'L.AC.STATUS1':@VM:'L.AC.STATUS2':@VM:'L.AC.LOCKE.TYPE':@FM:'L.AC.STATUS1'

    APPLICATION='AC.LOCKED.EVENTS':@FM:'ACCOUNT'

    CALL MULTI.GET.LOC.REF(APPLICATION,LOCAL.FIELD,AC.LOCK.POS)
RETURN
*----------------------------
PROCESS:

    AC.LOCKED.EVENTS.ID=ID.NEW
    POS=AC.LOCK.POS<1,1>
    GARNISHMENT.AMT=R.NEW(AC.LCK.LOCAL.REF)<1,POS>
    POS=AC.LOCK.POS<1,2>
    AVAILABLE.BAL=R.NEW(AC.LCK.LOCAL.REF)<1,POS>
    POS=AC.LOCK.POS<1,3>
    CUSTOMER=R.NEW(AC.LCK.LOCAL.REF)<1,POS>
    POS=AC.LOCK.POS<1,4>
    ACCTS.LOCKED=R.NEW(AC.LCK.LOCAL.REF)<1,POS>

    ACCOUNT.NUMBER=R.NEW(AC.LCK.ACCOUNT.NUMBER)
***********************************************************
    CALL F.READ(FN.CUSTOMER.ACCOUNT,CUSTOMER,R.CUSTOMER.ACCOUNT,F.CUSTOMER.ACCOUNT,CUST.ERR)

    LOOP
        REMOVE ACC.ID FROM R.CUSTOMER.ACCOUNT SETTING POS1
    WHILE ACC.ID:POS1
        CALL F.READ(FN.ACCOUNT,ACC.ID,R.ACCOUNT,F.ACCOUNT,ACCT.ERR)
        VAR.LOCKED.AMT=R.ACCOUNT<AC.LOCKED.AMOUNT>
        VAR.COUNT=DCOUNT(VAR.LOCKED.AMT,@VM)
        LOOP
        WHILE VAR.COUNT NE 0
            VAR.LOC.AMT = VAR.LOCKED.AMT<VAR.COUNT>
            VAR.COUNT -= 1
        REPEAT
    REPEAT
    VAR.GARNISH.AMT = GARNISHMENT.AMT - VAR.LOC.AMT
**************************************************************
    VAR.ACK.NO=R.NEW(AC.LCK.ACCOUNT.NUMBER)
    CALL F.READ(FN.ACCOUNT,VAR.ACK.NO,R.ACCOUNT,F.ACCOUNT,ACCT.ERR)
    CALL EB.READ.HVT ('EB.CONTRACT.BALANCES', VAR.ACK.NO, R.ECB, ECB.ERR)                ;*TUS START
*ACCT.AVAIL.BAL=R.ACCOUNT<AC.ONLINE.ACTUAL.BAL>
    ACCT.AVAIL.BAL=R.ECB<ECB.ONLINE.ACTUAL.BAL>                ;*TUS END

    LOCKED.AMOUNT=R.NEW(AC.LCK.LOCKED.AMOUNT)
    IF LOCKED.AMOUNT GT VAR.GARNISH.AMT THEN
        LOCKED.AMOUNT = VAR.GARNISH.AMT
    END
    IF LOCKED.AMOUNT GT ACCT.AVAIL.BAL THEN
        LOCKED.AMOUNT = ACCT.AVAIL.BAL
    END
    IF AVAILABLE.BAL GT '0' THEN
        GOSUB CHECK.FIRST.ACCOUT
    END
    ELSE
        GOSUB CHECK.FIRST.ACCOUT
    END
    POS=AC.LOCK.POS<1,6>
    R.NEW(AC.LCK.LOCAL.REF)<1,POS>='GARNISHMENT'

    POS=AC.LOCK.POS<1,7>
    R.NEW(AC.LCK.LOCAL.REF)<1,POS>='GARNISHMENT'

RETURN
*----------------------------
CHECK.FIRST.ACCOUT:
************************
    CALL F.READ(FN.ACCOUNT,ACCOUNT.NUMBER,R.ACCOUNT,F.ACCOUNT,ERR.ACCOUNT)

    POS=AC.LOCK.POS<2,1>
    STATUS1=R.ACCOUNT<AC.LOCAL.REF,POS>

    POS=AC.LOCK.POS<1,5>
    R.NEW(AC.LCK.LOCAL.REF)<1,POS>=STATUS1

    IF LOCKED.AMOUNT NE VAR.GARNISH.AMT THEN
        AF=AC.LCK.LOCKED.AMOUNT
        TEXT='GARNISH.AMT.NOT.EQUAL'
        CURR.NO=DCOUNT(R.NEW(AC.LCK.OVERRIDE),@VM) + 1
        CALL STORE.OVERRIDE(CURR.NO)
    END
RETURN
*-----------------------------
END

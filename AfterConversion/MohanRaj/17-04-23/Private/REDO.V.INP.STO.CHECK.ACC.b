* @ValidationCode : MjoxMTk3MTE5NzMyOkNwMTI1MjoxNjgxNzMzMzM3MjU0OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 17 Apr 2023 17:38:57
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
SUBROUTINE REDO.V.INP.STO.CHECK.ACC
*--------------------------------------------------------------------------------
*Company   Name    :Asociacion Popular de Ahorros y Prestamos
*Developed By      :PRABHU.N
*Program   Name    :REDO.V.INP.STO.CHECK.ACC
*---------------------------------------------------------------------------------

*DESCRIPTION       :Input routine generates  override when FT involves Account which
*                   is not active
*LINKED WITH       :

* ----------------------------------------------------------------------------------
*Modification Details:
*=====================
* 29-JUN-2010        Prabhu.N       ODR-2009-10-0315       Initial Creation
*Modification history
*Date                Who               Reference                  Description
*17-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM,FM TO @FM
*17-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*-----------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.ACCOUNT
    $INSERT I_F.USER
    $INSERT I_F.STANDING.ORDER
    $INSERT I_F.EB.CONTRACT.BALANCES ;*Tus (S/E)
    GOSUB INIT
    GOSUB FILEOPEN
    GOSUB PROCESS
RETURN
*----
INIT:
*----
    FN.ACCOUNT='F.ACCOUNT'
    F.ACCOUNT=''
    LREF.APP='ACCOUNT':@FM:'STANDING.ORDER'
    LREF.FIELD='L.AC.STATUS1':@VM:'L.AC.STATUS2':@VM:'L.AC.NOTIFY.1':@FM:'L.STO.START.DTE'
RETURN
*--------
FILEOPEN:
*--------
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)
    CALL MULTI.GET.LOC.REF(LREF.APP,LREF.FIELD,LREF.POS)

    Y.AC.ST1.POS=LREF.POS<1,1>
    Y.AC.ST2.POS=LREF.POS<1,2>
    Y.AC.ST3.POS=LREF.POS<1,3>

    Y.STO.SRT.POS = LREF.POS<2,1>

RETURN
*--------
PROCESS:
*--------


    Y.CR.DEB.ID=FIELD(ID.NEW,'.',1)
    GOSUB OVERRIDE.GEN
    Y.CR.DEB.ID=R.NEW(STO.CPTY.ACCT.NO)
    GOSUB OVERRIDE.GEN
RETURN
*-----------
OVERRIDE.GEN:
*-----------
    CALL F.READ(FN.ACCOUNT,Y.CR.DEB.ID,R.ACCOUNT,F.ACCOUNT,CRE.ERR)
    R.ECB=''; ECB.ERR='' ;*Tus Start
    CALL EB.READ.HVT ("EB.CONTRACT.BALANCES",Y.CR.DEB.ID,R.ECB,ECB.ERR);*Tus End

    Y.STATUS=R.ACCOUNT<AC.LOCAL.REF,Y.AC.ST1.POS>
    IF Y.STATUS NE 'ACTIVE' AND Y.STATUS NE '' AND R.ACCOUNT<AC.CUSTOMER> NE '' THEN
        VIRTUAL.TAB.ID='L.AC.STATUS1'
        CALL EB.LOOKUP.LIST(VIRTUAL.TAB.ID)
        Y.LOOKUP.LIST=VIRTUAL.TAB.ID<2>
        Y.LOOKUP.DESC=VIRTUAL.TAB.ID<11>
        CHANGE '_' TO @FM IN Y.LOOKUP.LIST
        CHANGE '_' TO @FM IN Y.LOOKUP.DESC
        LOCATE Y.STATUS IN Y.LOOKUP.LIST SETTING POS1 THEN
            IF R.USER<EB.USE.LANGUAGE> EQ 1 THEN        ;* This is for english user
                Y.MESSAGE=Y.LOOKUP.DESC<POS1,1>
            END
            IF R.USER<EB.USE.LANGUAGE> EQ 2 AND Y.LOOKUP.DESC<POS1,2> NE '' THEN
                Y.MESSAGE=Y.LOOKUP.DESC<POS1,2> ;* This is for spanish user
            END ELSE
                Y.MESSAGE=Y.LOOKUP.DESC<POS1,1>
            END
        END
        TEXT="REDO.AC.CHECK.ACTIVE":@FM:Y.CR.DEB.ID:@VM:Y.MESSAGE
        OVERRIDE.FIELD.VALUE = R.NEW(AC.OVERRIDE)
        CURR.NO = DCOUNT(OVERRIDE.FIELD.VALUE,'VM') + 1
        CALL STORE.OVERRIDE(CURR.NO)
    END
    Y.STATUS2=R.ACCOUNT<AC.LOCAL.REF,Y.AC.ST2.POS>
    IF Y.STATUS2 EQ 'DECEASED' THEN
        ETEXT='EB-REDO.AC.DECESED'
        CALL STORE.END.ERROR
    END

    IF Y.STATUS EQ 'ACTIVE' THEN
        GOSUB CHK.FUT.INACT.ACT
    END


RETURN

CHK.FUT.INACT.ACT:

    Y.STO.SRT.DATE = R.NEW(STO.LOCAL.REF)<1,Y.STO.SRT.POS>
* Y.LAST.CR.CUST = R.ACCOUNT<AC.DATE.LAST.CR.CUST> ;*Tus Start
    LOCATE 'CUST-CR' IN R.ECB<ECB.INITIATOR.TYPE,1> SETTING CUST.CR.POS THEN
        Y.LAST.CR.CUST = R.ECB<ECB.DATE.LAST,CUST.CR.POS>
    END
* Y.LAST.DR.CUST = R.ACCOUNT<AC.DATE.LAST.DR.CUST>
    LOCATE 'CUST-DR' IN R.ECB<ECB.INITIATOR.TYPE,1> SETTING CUST.DR.POS THEN
        Y.LAST.DR.CUST= R.ECB<ECB.DATE.LAST,CUST.DR.POS>
    END ;*Tus End
    Y.LATST.DATE = ''

    IF Y.LAST.CR.CUST AND Y.LAST.DR.CUST THEN
        IF Y.LAST.CR.CUST GT Y.LAST.DR.CUST THEN
            Y.LATST.DATE = Y.LAST.CR.CUST
        END ELSE
            Y.LATST.DATE = Y.LAST.DR.CUST
        END
    END ELSE
        IF Y.LAST.CR.CUST THEN
            Y.LATST.DATE = Y.LAST.CR.CUST
        END
        IF Y.LAST.DR.CUST THEN
            Y.LATST.DATE = Y.LAST.DR.CUST
        END
    END

    IF Y.LATST.DATE THEN
        YDATE = Y.LATST.DATE
    END ELSE
        YDATE = TODAY
    END

    YREGION = '' ; YDAYS.ORIG = '+180C'
    CALL CDT(YREGION,YDATE,YDAYS.ORIG)

    IF Y.STO.SRT.DATE THEN
        IF Y.STO.SRT.DATE GT YDATE THEN
            ETEXT = 'EB-REDO.AC.INACT.FUT'
            CALL STORE.END.ERROR
        END
    END ELSE
        Y.CUR.FREQ = R.NEW(STO.CURRENT.FREQUENCY)
        Y.STO.SRT.DATE = Y.CUR.FREQ[1,8]
        IF Y.STO.SRT.DATE GT YDATE THEN
            ETEXT = 'EB-REDO.AC.INACT.FUT'
            CALL STORE.END.ERROR
        END
    END


RETURN

END

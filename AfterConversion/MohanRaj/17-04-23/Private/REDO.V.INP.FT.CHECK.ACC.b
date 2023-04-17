* @ValidationCode : MjotMTAwMzI1NDU2OTpDcDEyNTI6MTY4MTcyODkwMzMxNzo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 17 Apr 2023 16:25:03
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
SUBROUTINE REDO.V.INP.FT.CHECK.ACC
*--------------------------------------------------------------------------------
*Company Name :Asociacion Popular de Ahorros y Prestamos
*Developed By :PRABHU.N
*Program Name :REDO.V.INP.FT.CHECK.ACC
*---------------------------------------------------------------------------------

*DESCRIPTION :Input routine generates override when FT involves Account which
* is not active
*LINKED WITH :

* ----------------------------------------------------------------------------------
*Modification Details:
*=====================
* 29-JUN-2010 Prabhu.N ODR-2009-10-0315 Initial Creation
* 19-Apr-11 H Ganesh PACS00054881 Override with account number for inactive status
*Modification history
*Date                Who               Reference                  Description
*17-04-2023      conversion tool     R22 Auto code conversion    FM TO @FM,VM TO @VM
*17-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*-----------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.ACCOUNT
    $INSERT I_F.USER
    $INSERT I_F.FUNDS.TRANSFER

    GOSUB INIT
    GOSUB FILEOPEN
    GOSUB PROCESS
RETURN
*----
INIT:
*----
    FN.ACCOUNT='F.ACCOUNT'
    F.ACCOUNT=''
    LREF.APP='ACCOUNT'
    LREF.FIELD='L.AC.STATUS1'
RETURN
*--------
FILEOPEN:
*--------
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)
    CALL GET.LOC.REF(LREF.APP,LREF.FIELD,LREF.POS)
RETURN
*--------
PROCESS:
*--------


    Y.CR.DEB.ID=R.NEW(FT.CREDIT.ACCT.NO)
    GOSUB OVERRIDE.GEN
    Y.CR.DEB.ID=R.NEW(FT.DEBIT.ACCT.NO)
    GOSUB OVERRIDE.GEN
RETURN
*-----------
OVERRIDE.GEN:
*-----------
    CALL F.READ(FN.ACCOUNT,Y.CR.DEB.ID,R.ACCOUNT,F.ACCOUNT,CRE.ERR)
    Y.STATUS=R.ACCOUNT<AC.LOCAL.REF,LREF.POS>
    IF Y.STATUS NE 'ACTIVE' AND Y.STATUS NE '' AND R.ACCOUNT<AC.CUSTOMER> NE '' THEN
        VIRTUAL.TAB.ID='L.AC.STATUS1'
        CALL EB.LOOKUP.LIST(VIRTUAL.TAB.ID)
        Y.LOOKUP.LIST=VIRTUAL.TAB.ID<2>
        Y.LOOKUP.DESC=VIRTUAL.TAB.ID<11>
        CHANGE '_' TO @FM IN Y.LOOKUP.LIST
        CHANGE '_' TO @FM IN Y.LOOKUP.DESC
        LOCATE Y.STATUS IN Y.LOOKUP.LIST SETTING POS1 THEN
            IF R.USER<EB.USE.LANGUAGE> EQ 1 THEN ;* This is for english user
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
RETURN
END

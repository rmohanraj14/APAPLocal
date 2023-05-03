* @ValidationCode : MjotMTM0MDIzNDQ2MzpDcDEyNTI6MTY4MjA3Mzc5MTY0MDo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 21 Apr 2023 16:13:11
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
$PACKAGE APAP.LAPAP
*Modification history
*Date                Who               Reference                  Description
*21-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM,FM TO @FM,SM TO @SM
*21-04-2023      Mohanraj R          R22 Manual code conversion   No changes
***Rutina para quitar el id alterno de ABANK a un prestamo despues
*** de que el prestamo estan cancelado
*-----------------------------------------------------------------------------
SUBROUTINE LAPAP.DEL.IDALTERNO.CANCELADO
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.APP.COMMON
    $INSERT I_F.ALTERNATE.ACCOUNT
    $INSERT I_F.ACCOUNT
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY
    $INSERT I_F.USER
    $INSERT I_F.AA.ARRANGEMENT
    GOSUB MAIN.PROCESS

MAIN.PROCESS:
    GOSUB INITIALISE
    GOSUB SET.PROCESS
RETURN

**************
INITIALISE:
**************
    FN.USER = 'F.USER'
    F.USER = ''
    CALL OPF(FN.USER,F.USER)
    FN.ACCOUNT.HST = 'F.ACCOUNT$HIS'
    F.ACCOUNT.HST = ''
    CALL OPF(FN.ACCOUNT.HST,F.ACCOUNT.HST)
    FN.ACCOUNT = "F.ACCOUNT"
    FV.ACCOUNT = ""
    CALL OPF(FN.ACCOUNT,FV.ACCOUNT)
    FN.SL = '&SAVEDLISTS&'
    F.SL = ''
    CALL OPF(FN.SL,F.SL)
    FN.ALTERNATE.ACCOUNT = "F.ALTERNATE.ACCOUNT"
    FV.ALTERNATE.ACCOUNT = ""
    CALL OPF(FN.ALTERNATE.ACCOUNT,FV.ALTERNATE.ACCOUNT)
    FN.AA = "F.AA.ARRANGEMENT"
    F.AA = ""
    CALL OPF(FN.AA, F.AA)

RETURN
****************
SET.CONTRATO.OLD:
*****************
    YH.ACINT.ID = Y.CONTRATO.OLD
    Y.OLD.ALT = Y.IDALTERNO
    Y.VACIO = ""
    R.AC1 = ''
    CALL F.DELETE(FN.ALTERNATE.ACCOUNT,Y.OLD.ALT)
    CALL JOURNAL.UPDATE(Y.OLD.ALT)
    READ R.AC1 FROM FV.ACCOUNT, YH.ACINT.ID ELSE R.AC1 = ''
    IF (R.AC1) THEN
        Y.ALT.TYPE = R.AC1<AC.ALT.ACCT.TYPE>
        CHANGE @VM TO @FM IN Y.ALT.TYPE
        CHANGE @SM TO @FM IN Y.ALT.TYPE
        LOCATE "ALTERNO1" IN Y.ALT.TYPE<1> SETTING EYPO.POS1 THEN
            R.AC1<AC.ALT.ACCT.ID,EYPO.POS1,1> = ''
        END
        WRITE R.AC1 TO FV.ACCOUNT, YH.ACINT.ID
        CALL JOURNAL.UPDATE("")
    END ELSE
        SEL.CMD = " SELECT " : FN.ACCOUNT.HST : " WITH @ID LIKE " :YH.ACINT.ID:"..."
        CALL EB.READLIST(SEL.CMD, SEL.LIST, '',NO.OF.RECS,SEL.ERR)
        LOOP
            REMOVE Y.ALTHISID FROM SEL.LIST SETTING FI.POS
        WHILE Y.ALTHISID DO
            CALL F.READ(FN.ACCOUNT.HST, Y.ALTHISID, R.AC1, F.ACCOUNT.HST, AC.ERROR)
            IF R.AC1 THEN
                Y.ALT.TYPE = R.AC1<AC.ALT.ACCT.TYPE>
                CHANGE @VM TO @FM IN Y.ALT.TYPE
                CHANGE @SM TO @FM IN Y.ALT.TYPE
                LOCATE "ALTERNO1" IN Y.ALT.TYPE<1> SETTING EYPO.POS THEN
                    R.AC1<AC.ALT.ACCT.ID,1> = ''
                    R.AC1<AC.ALT.ACCT.ID,EYPO.POS,1> = ""
                    CALL F.WRITE(FN.ACCOUNT.HST,Y.ALTHISID,R.AC1)
                    CALL JOURNAL.UPDATE("")
                END
            END
        REPEAT
    END
RETURN
***********************
SET.PROCESS:
**********************
    Y.VALOR = ''
    Y.ARCHIVO = 'REMOVER.IDALTERNO'
    CALL F.READ(FN.SL,Y.ARCHIVO,Y.ID.LIST,F.SL,RET.ERR)
    LOOP
        REMOVE YGRP.ARR.ID FROM Y.ID.LIST SETTING YPOS
    WHILE YGRP.ARR.ID:YPOS
        Y.CONTRATO.OLD = FIELD(YGRP.ARR.ID,',',1)
        Y.IDALTERNO = FIELD(YGRP.ARR.ID,',',2)
        GOSUB SET.CONTRATO.OLD
    REPEAT
RETURN
END
